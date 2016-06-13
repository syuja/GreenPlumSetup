![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### FSTAB:  
`/etc/fstab` contains the necessary information to automate the process of mounting partitions.   
Mounting is the process where a raw (physical) partition is prepared for access   
and assigned a location on the file system tree (or mount point). [more] (https://help.ubuntu.com/community/Fstab).  

`[Device] [Mount Point] [File System Type] [Options] [Dump] [Pass]`  

**Create a backup image** before changing the fstab table.  

options for Greenplum should be:  
`rw,noatime,inode64,allocsize=16m`  


In our example, our `etc/fstab` file should look like this:  
      
