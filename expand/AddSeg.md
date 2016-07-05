![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

#### Intro:  
As the database grows in size, it will become necessary to expand it periodically.   
Fortunately, Greenplum provides administrators a utility, `gpexpand`, to assist with expansion.   
However, each segment to be added will have to be manually and individually configured.   
Also, the database will suffer slow performance while expanding as the data will be skewed and   
the distribution policies will be set to random.   

Expansion is a multi-step process that may take several days.   
It includes:    

    1. Preparing new nodes   
    2. Creating an expansion input file   
    3. Initializing the new segments (creates expansion schema and changes distribution policy)   
    4. Redistributing tables   
    5. Removing the expansion schema   

It is recommended it be done during periods of low activity and in batches.    
The expansion process can be paused if necessary.   
It also has a rollback feature, but it's not guaranteed to work.   


#### Preparing New Nodes:   
Preparing the new nodes is similar to the process of installing Greenplum for the very first time.   
We will change the OS settings, install the Greenplum binaries, exchange `SSH` keys, and then run performance tests.   

First, change the OS settings according to this [document](https://github.com/syuja/GreenPlumSetup/blob/master/inst/Installation_Recap.md).   


`SFTP` the binaries to each node.  Unzip them and run them with `bash`.  

    sftp -i ~/.ssh/id_rsa centos@140.221.x.x   
    put greenplum_.zip  #replace greenplum_.zip with the actual name of the file.  
    unzip greenplum_.zip   
    /bin/bash greenplum_.bin   

Now, you are ready to exchange keys.   
You will exchange keys as `root` and as `gpadmin` from the the Master to all Segment hosts.    

Greenplum provides a utility, `gpssh-exkeys`, to exchange keys.   
It doesn't always work. Do it manually, first and then run the utility.  
`SSH` into the master and segments.  Then copy the public key to each segment host.    
Finally, try to connect from the master to each host.   
Having done that run the `gpssh-exkeys` utility to verify that it can connect.    

Repeat the process after creating a `gpadmin` user in each segment host.    




#### Creating an expansion input file:   
########################





<sub><sup> References: http://gpdb.docs.pivotal.io/4380/admin_guide/expand/expand-overview.html </sub></sup>  
[Top](#top)   
