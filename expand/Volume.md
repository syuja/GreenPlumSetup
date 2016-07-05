![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

In order to load data into Greenplum, we will first create a volume on OpenStack.  
We will attach it to an instance. This instance along with its attached volume will  
become our **ETL server**. 
Then, we will `curl` an external data set into it.  
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


### Getting a Dataset with `curl`:    
****************


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


### Creating an External Table from Greenplum:  
****************


### Loading the Data Internally:   
************************

Now that the data has been loaded internally, we can transform it and start using it.  









[Top](#top) 
