![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### Master:  

**Beware**: Beware of creating aliases in the host file. They may not always work. It's less confusing to simply use the machine  
names.

**Recommended**: Add `source /usr/local/greenplum-db/greenplum_path.sh` to `.bashrc` so that it sources everytime it starts. Then do it for `gpadmin` as well:  

            su - gpadmin  
            vi .bashrc  
            #insert source /usr/local/greenplum-db/greenplum_path.sh  
            

The preceding steps are only recommended for the master.   

Create a ssh-key. Paste the public part to all hosts unders `/root/.ssh/authorized_keys`. Then ssh from the master onto all 
of the hosts using `ssh <segment_name_in_hosts_file>`.  

#### Validate:  
Greenplum provides several steps to validate the install.  

#### Packages:  
Greenplum has many extensions that can be installed using `gppkg`.  
These extensions include: **PL/Python**, PL/R, PL/Java, PL/Perl, PostGIS and MADlib.  

#### Python Package Installation:  

#### Python Package Usage:  <-- link to another doc


#### Create Database Storage Areas:  
**This will be useful so that on Magellan we can use device `vdb` with 150 GB of space instead of `vda` with only 40 GB of space.  
`df -h` shows partitions and drives available  
`mount | grep 'vdb'` shows where device `vdb` is mounted  
- it improves performance if `vdb` uses xfs file system and is [configure] (http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3)   

now move on to creating storage area...  

      cd /mnt  
      mkdir data  
      mdkir data/master  
      chown gpadmin data
      chown gpadmin data/master
      df data/master # to check which partition the file is on   
       
  
  
To create data directory locations on segment hosts we will use `gpssh`. Log into master as root, and create a file containing all
 hosts `hostfile_gpssh_segonly`:  
  
      gp_segment1    
      gp_segment2  
      gp_segment3  

Now use `gpssh` to create the files:   

      gpssh -f hostfile_gpssh_segonly -e 'mkdir /mnt/data'  
      gpssh -f hostfile_gpssh_segonly -e 'mkdir /mnt/data/primary'
      gpssh -f hostfile_gpssh_segonly -e 'mkdir /mnt/data/mirror'  
      gpssh -f hostfile_gpssh_segonly -e 'chown gpadmin /mnt/data'  
      gpssh -f hostfile_gpssh_segonly -e 'chown gpadmin /mnt/data/primary'  
      gpssh -f hostfile_gpssh_segonly -e 'chown gpadmin /mnt/data/mirror'   

**gpssh**: is a utility that allows us to perform the same task accross all of the segments.    
      Provides SSH access to multiple hosts at once  
      -f : file containing all segment host  
      -v : verbose  
      -e : echoes the commands passed to each and echoes the output of each host  


#### Synchronize the Time on All:  
Synchronizing time is important so that we can correlate incidents from clocks and for the database to run correctly.  
The basic idea is that segments will periodically synchronize their time with that of the master using NTP protocol.  

If using CentOS 7 on Magellan, you will first have to install NTP (Network Time Protocol).   
      yum install ntp # sudo su before this  
       systemctl ntpd start #this starts the service

Then find the NTP server:  

      ntpq -p # this shows the status    
      # the active NTP server, current time source,  will have an asterisk *   

Change the files on all of the hosts and the master. Make the master point to the network NTP servers, and make the hosts point 
to the master. Then restart the service.  

Master:   

      server 0.dns1.@%@# iburst  
      server 1.dns2@#$#  iburst  

Hosts:   

      server 0.gp_amster prefer  
      server 1.dns1.@#$@ iburst  


Restart the service:  

      systemctl restart ntpd  #restart on hosts and master
      gpssh -f hostfile_gpssh_allhosts -v -e 'ntpd' # doc recommends this, which restarts remotely...  



#### Validating Your Systems: 

      su - gpadmin  
      . /usr/local/greenplum-db/greenplum_path.sh  # source  
      
Create a file with master and host names each on a single line:  

      gp_master  
      gp_segment1  
      gp_segment2  
      gp_segment3  

Run :  

      gpcheck -f hostfile_gpcheck # gpcheck will check OS parameters  
      #is likely to print errors   

Error produced by `gpcheck`:  
      <p align="center"> ![xfs-error](https://github.com/syuja/GreenPlumSetup/blob/master/img/xfs_error.png)  </p>  
        

Go [here] (docs/FORMAT.md) to change the ephemeral driver's, `devb`, formatting.   

**SKIPPING `gpcheck` VALIDATION KEEPS PRODUCING SAME ERROR EVEN AFTER CHANGING MOUNT OPTIONS AND REMOUNTING**  

**To Test the hardware (network, disk i/o, mem bandwidth) run gpcheckperf**   
 1. create `hostfile_gpcheck`containing:   


      gp_master  
      gp_segment1  
      gp_segment2  
      gp_segment3  
         
  

 2. `gpcheckperf -f hostfile_gpcheck -d /mnt/data -r dsN > gpcheckperf_results`  


      -f : points to file containing all hosts   
      -d : file to test transferring to and from   
      -r : specifies performance stest to run   
             dsN:     'd' is for disk, 's' for stream and 'N' is for parallel    

  
 3. I recommend running with `nohup <command> <arguments> &` so that it doesn't hang.  
 4. check performance results in `gpcheckperf_results`.    
 **Initial performance results**:  
  ![initial performance results](https://github.com/syuja/GreenPlumSetup/blob/master/img/gpcheck_performance.png)

 Performance results with 4 segments, instead of 3. (Not using `xfs` options).  
  ![second perf results](https://github.com/syuja/GreenPlumSetup/blob/master/img/gpcheckperf_4segments.png)  

#### Initialize:    
Greenplum password is "changeme" for now.  








