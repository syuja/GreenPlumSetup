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
format it mkfs.xfs
mount it


### Settings:  

Disable SELINUX on the instance, `/etc/selinux/config`.  

Change kernel settings


### Getting a Dataset with `curl`:  



### Installing Load Utilities:   


### Running `gpfdist`:   


### Creating an External Table from Greenplum:  


### Loading the Data Internally:  











[Top](#top) 
