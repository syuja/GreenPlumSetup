![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

### Intro: 
This module will help you create a new volume, attach it to an instance, format it,
optimize the instance, install and run `gpfdist`.  

Ideal setup of our ETL server, the server with the dataset:  
![ideal_etl](https://github.com/syuja/GreenPlumSetup/blob/master/img/ideal_etl.png)

### Creating and Attaching a Volume:  
Read this Open Stack reference.  
Especially, read "creating a volume" and "attaching volume to an instance".  

From the instance list the volumes available.  
lsblk   
format it sudo mkfs.xfs -f /dev/vdc   
mount it mount -o rw -o noatime -o inode64 -o allocsize=16m /dev/vdc /mnt2   


### Settings:    

Disable SELINUX on the instance, `/etc/selinux/config`.    

Change kernel settings  


### Getting a Dataset with `curl`:    



### Installing Load Utilities:   
yum -y install unzip  
https://network.pivotal.io/products/pivotal-gpdb#/releases/1683/file_groups/410  
(http://gpdb.docs.pivotal.io/4380/client_tool_guides/load/unix/unix_load_install.html)  

source it!!
source /usr/local/greenplum-loaders-4.3.8.1-build-1/greenplum_loaders_path.sh     

don't have to enable remote client connections if within Magellan!


### Running `gpfdist`:   



### Creating an External Table from Greenplum:  



### Loading the Data Internally:   












[Top](#top) 
