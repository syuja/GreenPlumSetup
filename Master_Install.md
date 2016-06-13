![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### Master:  


**Beware**: Beware of creating aliases in the host file. They may not always work. It's less confusing to simply use the machine  
names.

Create a ssh-key. Paste the public part to all hosts unders `/root/.ssh/authorized_keys`. Then ssh from the master onto all 
of the hosts using `ssh <segment_name_in_hosts_file>`.
