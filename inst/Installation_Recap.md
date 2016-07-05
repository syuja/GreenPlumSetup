![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
---
<a id='top'></a>
#### Table of Contents:  
  1. [Before Starting](#bef)    
  2. [Requirements](#req)   
  3. [Installation](#inst)  
  4. [Cross Segments](#cross)  
  5. [Sync Time](#sync)  
  6. [Data Stores](#store)  
  7. [Initialization](#init)  
  8. [Final Steps](#fin)
  
This module will help you save time during the Greenplum installation.   
Please review it before installing Greenplum or if you run into problems.   

**Common Issues:**  

    A. SSH keys not exchanged for all users  
    B. Conflicting SSH keys (exchanged multiple times; delete lines in `.ssh/known_hosts`)  
    C. Proper Permissions (authorized_keys needs to be 600, `gpadmin` needs to have access/ownership of `/mnt/data/master`)  
    D. Installation Halts. (`ed` not installed, installed doesn't use `sed`)    
    E. XFS mounting (changing fstab to `xfs` will crash upon rebooting, do chroot, leave `ext4`)   
    F. Install to `/dev/vdb` not smaller `dev/vda` (easy fix in config file)    


<a id = 'bef'></a>
### Before Starting:   
To save time, do most of the setup on 1 instance in Openstack/Magellan.   
This instance will become the **Master**.  

Before running `gpseginstall`, we will take a snapshot and instantiate segments from it.   
This can greatly reduce the repetitive work done.   

**Using snapshots and images wisely will reduce the amount of repetitive work.**  


<a id = 'req'></a>
### Requirements:  
Install `ed`, `unzip` and `ntp` on the first instance, so that you don't have to individually install on each segment.  
Modify OS parameters as per the documentation, **except** for the **`/etc/fstab`** file.  

        yum install -y ed # also for the others

After changing the `/etc/ntp.conf`, restart the service using `systemctl restart ntpd`. Check if changes were successful  
by running `ntpq -p`.   


**Note**: if `ed` isn't installed the system will crash during installation; the 'backout' script is unlikely to work.    

Disable `selinux`. You do not have to disable `iptables` or `firewalld` since it isn't installed.   

Change the following Operating System Parameters:  
[OS parameters](http://gpdb.docs.pivotal.io/4380/prep_os-system-req.html#topic2)  
[OS parameters 2](http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3)  

Modify `/etc/hosts` on the original Master image.    

Change the configuration of `ntp`, restart it.  

Please view [here](CONFIG.md) to see all changes to configuration files.  

Finally, before running `gpseginstall` it is imperative to manually connect from the master to all segments.   
Also, be sure to do it for all users:  root to root, and centos to centos.   

Please view [here](https://github.com/syuja/ssh_tut) for our review on `SSH`.  

The installation will create a new user `gpadmin`. Then it will attempt to connect from `gpadmin` in Master to `gpadmin` in all   
segments, but it will fail.   
It has no SSH keys set up between it and the `gpadmin` of  the segments, so it will be unable to connect to the segments.   

Upon failing, manually connect, exchange `SSH` keys and connect, then **rerun** the installation.    


**It should work the second time.**   


<a id = 'inst'></a>
### Installation:  
Before running `gpseginstall` exchange keys from master to segments. Then, connect from the master to each segment to test.  
On master:   

            ssh-keygen #public key in /root/.sshid_rsa.pub  
            #paste it into /root/.ssh/authorized_keys of all segments  


Make sure that the `hostfile_exkeys` is accessible to all users. `gpadmin` will not have access to `hostfile_exkeys`.  
Be sure to grant `gpadmin` access to it.  

            chmod 777 hostfile_exkeys  

`hostfile_exkeys` is located in both the `root` home directory and the `gpadmin` home directory, so check **both**.  


If that doesn't work run `gpseginstall` with `-f /home/gpadmin/hostfile_exkeys`, instead of `-f hostfile_exkeys`.   
You're running it with the copy in the `gpadmin` home directory instead of the `root` home directory.   


At this point, snapshot the Master, and use it to **create** the Segment instances.   


<a id = 'cross'></a>
### Cross Segments:  
You may wish to use `gpssh` in order to create the non-existent `.ssh` directories in the `/home/gpadmin` directory.  

     gpssh -f hostfile_exkeys  -e 'mkdir -p /home/gpadmin/.ssh'  

But then individually do:   

    vi /home/gpadmin/.ssh/authorized_keys  

And paste the `id_rsa.pub` key from the Master into each `authorized_keys` file.    

Attempt to connect from the master to the segments. Re-run `gpseginstall` as listed in the documentation.  

<a id = 'sync'></a>
### Sync Time:   
After editing `/etc/ntp.conf`, be sure to restart the daemon.    

     systemctl restart ntpd  
     ntpq -p # to check that the configuration was successful  


View [here](CONFIGURATION.md) to view configuration.    

<a id = 'store'></a>  
### Data Stores:    
Create the data stores in the `/mnt` file, since this is where the ephemeral drive will be located.  
The ephemeral drive is larger than the primary drive.   

    df -h # to see the devices  
    #dev/vdb will likely be the largest  
    #likely that it's mounted on /mnt  



<a id = 'init'></a>  
### Initialization:   
Skipp `gpcheck` because `/etc/fstab` was not set to their recommendations.  

Before running the `gpinit` utility, make sure that the Master instance can `SSH` to itself.  
From `gpadmin` on Master try to ssh to `gpadmin` on Master.   

In `gpinitsystem_config` file, you may want to change the "Other Optional Parameters" value of "#DATABASE_NAME=..."   
and also uncomment it. This will create an initial database in the system.   

Note that there are several configurations possible for the database. For example, one segment can become a segment host by simply  
listing multiple data file and interfaces for it.    

<a id ='fin'></a>  
### Final Steps:   
Add, `export MASTER_DATA_DIRECTORY=/mnt/data/master/gpseg-1` to the `.bashrc`.   
`.bashrc` is located in `gpadmin`'s home directory.    

Then, source `.bashrc`.   


Also, make sure that **`greenplum_path.sh`** is also sourced.   
It will say `Greenplum Database instance successfully created.` upon successful initialization.   

![init_success](https://github.com/syuja/GreenPlumSetup/blob/master/img/init_success.png)

Run:   

     psql -d template1 -h gpMaster -p 5432 -U gpadmin #this will connect you to the database  


You are now ready to start loading tables!

Set the global variables in your `.bashrc`. 
[List](http://gpdb.docs.pivotal.io/4380/install_guide/env_var_ref.html)   
 



[Back to top](#top)
