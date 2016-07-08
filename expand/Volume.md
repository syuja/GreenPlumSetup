![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>
  
  
In order to load data into Greenplum, we will first create a volume on OpenStack.  
We will attach it to an instance. This instance along with its attached volume will  
become our **ETL server**. 
Then, we will `rsync` an external data set into it.  
Finally, we will use `gpfdist` to make it available from the ETL server to the Greenplum database.  


### Intro: 
This module will help you create a new volume, attach it to an instance, format it,
optimize the instance, install and run `gpfdist`.  

The ideal setup of our ETL server would look something like this:  
![ideal_etl](https://github.com/syuja/GreenPlumSetup/blob/master/img/ideal_etl.png)

### Creating and Attaching a Volume:  
Read this Open Stack [reference](http://docs.openstack.org/user-guide/common/cli_manage_volumes.html).  
Especially, read "Create a volume" and "Attach the volume to an instance".   

Read [CalcStorage.md](CalcStorage.md) to get an estimate of the needed volume size.  

After attaching the volume to the instance, `SSH` into the instance.  
List the volumes of that instance:  

    lsblk    

Format the volume:  

    sudo mkfs.xfs -f /dev/vdc   # assuming vdc is the volume  

Mount the volume:   

    mount -o rw -o noatime -o inode64 -o allocsize=16m /dev/vdc /mnt2   


### Settings:    
We need to adjust some settings 
Disable SELINUX on the instance, `/etc/selinux/config`.    

Change the kernel settings also.


For more optimizations, read [here](http://gpdb.docs.pivotal.io/4360/prep_os-system-params.html#topic3).  
These are important to allow faster transfer rate.  




### Getting a Dataset with `rsync`:    
`rsync` is a utility that copies files from a host via a remote `rsync` daemon.  
It reduces the amount of data sent by sending only the differences between the source file and the received file.  

We used the following command:   

    rsync -avzuP publicdata.opensciencedatacloud.org::ark:/31807/osdc-6a9633ac/ /mnt3  
    #actually, we used the follwing command  
    nohup 'rsync -avzuP publicdata.opensciencedatacloud.org::ark:/31807/osdc-6a9633ac/ /mnt3' &    
    
We copied it into `mnt3` because that is where are 2 TB volume is located.  

`nohup '<command>' &` prevents the `rsync` process from stopping if we disconnect our shell.  

The flags `-avzuP` have the following meaning:   

        '-a' - archive mode  
        '-v' - verbose mode  
        '-z' - compresses file during transfer  
        '-P' - shows progress during transfer   
        '-u' - skips files that are newer on the receiver   
        


`rsync` is better than `curl` for larger files (> 1 GB).  
In our case, it happened that the data server provided an `rsync` daemon to download the dataset.   

### Installing Load Utilities:   
First, install `unzip` in the Centos7 instance that you are running:  

    yum -y install unzip   

Download the [Loaders](https://network.pivotal.io/products/pivotal-gpdb#/releases/1683/file_groups/410 ).  
Then, `sftp` them to our ETL server.  

Unzip the loaders:  

    unzip greenplum-loaders-4.3.x.x-PLATFORM.bin.zip

Install the Loaders:  

    /bin/bash greenplum-loaders-4.3.x.x-PLATFORM.bin   

Source it the Loader paths:   

    source /usr/local/greenplum-loaders-4.3.8.1-build-1/greenplum_loaders_path.sh     

This instance (with the dataset) and Greenplum are on the same network.  
There is no need to enable remote client connections.  

For more information, click [here](http://gpdb.docs.pivotal.io/4380/client_tool_guides/load/unix/unix_load_install.html) .  


### Running `gpfdist`:   
After the load tools have been installed, we can start running our **ETL server** using `gpfdist`.  

If `gpfdist` does not run correctly, you may have to add it to the $PATH variable.  

To run `gpfdist` specify the directory containing the data set, the port to use, and the log file in which to log output.  

        gpfdist -d /home/centos -p 8081 -l ./log/ &;  

When creating an external table, the segment host will be directed to the directory specified by `gpfdist`.  

To check if `gpfdist` is running:  

        ps -ef | grep gpfdist  


For more information, read [here](http://gpdb.docs.pivotal.io/4330/utility_guide/admin_utilities/gpfdist.html).   

### Creating an External Table from Greenplum:   
The external table does not move data into our Greenplum Database.  
It simply provides a reference to the external data.  
Creating external tables is important in order to allow **parallel insertion** into the Greenplum database  
using `gpfdist`. Otherwise, insertion would occur sequentially.  

Example of external table:  

        CREATE EXTERNAL TABLE faa.ext_loat_otp #faa is the schema (namespace)   
        (LIKE faa.faa_otp_load) #LIKE creates table with same columns and data types   
        LOCATION ('gpfdist: //localhost8081/otp*.gz')    
        FORMAT 'csv' (HEADER) #csv with header    
        LOG ERRORS INTO err_log SEGMENT REJECT LIMIT 50000 rows; #aborts if too many errors    

Use the same `port` number used for the ETL server.  If the `err_log` table hasn't been created, the database will  
automatically generate it using the same columns used to create the table.  

Then simply, run the command `INSERT INTO` to copy the external data into our Greenplum database.  
`INSERT INTO` will copy in parallel, since we've set up the external table and ETL server using `gpfdist`.  

For more information, read [Load Data with Greenplum utilities](https://github.com/syuja/GreenPlumSetup/blob/413fcf8fe683772908a72e831b93c66f37c551ba/tutorial/TUTORIAL.md#).   

For sample `psql` scripts view [here](../script/README.md).  

### Loading the Data Internally:   
Create a load table and simply `INSERT INTO` it.  
Note that the load table will be exactly the same as the external table.   

        INSERT INTO faa.faa_otp_load SELECT * FROM faa.ext_load_otp;  


Transformation will occur after the data has been loaded.  
This is done in order to quickly load the data, and then we exploit our local hardware to transform the data.  

This is faster than transforming the data before we load it locally.  




[Top](#top) 
