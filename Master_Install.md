![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### Master:  


**Beware**: Beware of creating aliases in the host file. They may not always work. It's less confusing to simply use the machine  
names.

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


#### Synchronize the Time on All:  


#### Validating Your Systems:  


#### Initialize <-- link to another file
