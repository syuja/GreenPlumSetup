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
  
The purpose of this document is to help you avoid the issues encountered by the author when first installing Greenplum.  
This should help you save a few hours in your installation.   

This document doesn't completely explain the whole installation process. I would recommend reviewing it before, and while installing  
Greenplum as you run into problems.  

**Common Issues:**  
    A. SSH keys not exchanged for all users  
    B. Conflicting SSH keys (exchanged multiple times; delete lines in `.ssh/known_hosts`)  
    C. Proper Permissions (authorized_keys needs to be 600, `gpadmin` needs to have access/ownership of `/mnt/data/master`)  
    D. Installation Halts. (`ed` not installed, installed doesn't use `sed`)    
    E. XFS mounting (changing fstab to `xfs` will crash upon rebooting, do chroot, leave `ext4`)   
    F. Install to `/dev/vdb` not smaller `dev/vda` (easy fix in config file)    


<a id = 'bef'></a>
### Before Starting:  

Start off with one instance on Magellan, do most of the setup. This first instance will become the **Master**.  
Before running `gpseginstall`, take snapshot and create the segments from that image.   
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
[OS parameters](http://gpdb.docs.pivotal.io/4380/prep_os-system-req.html#topic2)  
[OS parameters 2](http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3)  

Modify `/etc/hosts` on the original image; again, this will help you not have to do it individually for all segments.  

Change the configuration of `ntp`, restart it.  

Please view [here](docs/CONFIG.md) to see all changes to configuration files.  

Finally, before running `gpseginstall` it is imperative to manually connect from the master to all segments.  
Also, be sure to do it for all users:  root to root, and centos to centos.  

Please view [here](https://github.com/syuja/ssh_tut) for our review on `ssh`.  

The installation will create a new user `gpadmin`. Then it will attempt to connect from `gpadmin` in Master to `gpadmin` in all   
segments, but it will fail. Upon failing, manually connect, exchange ssh keys and connect, then **rerun** the installation.   
**It should work the second time.**  


<a id = 'inst'></a>
### Installation:  
Before running `gpseginstall` exchange keys from master to segments. Then, connect from the master to each segment to test.  
On master:   

            ssh-keygen #public key in /root/.sshid_rsa.pub  
            #paste it into /root/.ssh/authorized_keys of all segments  


Make sure that the `hostfile_exkeys` is accessible to all users.   

            chmod 777 hostfile_exkeys  

At this point, snapshot the Master, and use it to **create** the Segment instances.  

Run `gpseginstall`, this will likely crash because it creates `gpadmin`. It has no SSH keys set up between it and the `gpadmin` of  
the segments, so it will be unable to connect to the segments. Repeat the SSH key exchanges as above for `gpadmin`.  

Also, `gpadmin` will not have access to `hostfile_exkeys`. Copy `hostfile_exkeys` into `/home/gpadmin/` and grant `gpadmin`  
access to it.  

<a id = 'cross'></a>
### Cross Segments:  
You may wish to use `gpssh` in order to create the non-existent `.ssh` directories in the `/home/gpadmin` directory.  
         gpssh -f hostfile_exkeys  -e 'mkdir -p /home/gpadmin/.ssh'  

But then individually do:  
            vi /home/gpadmin/.ssh/authorized_keys  

And paste the `id_rsa.pub` key from the Master.  

Attempt to connect from the master to the segments. Re-run `gpseginstall` as listed in the documentation.  

<a id = 'sync'></a>
### Sync Time:   
After editing `/etc/ntp.conf`, be sure to restart the daemon.   

        systemctl restart ntpd  
        ntpq -p # to check that the configuration was successful  

View [here](docs/CONFIGURATION.md) to view configuration.  

<a id = 'store'></a>  
### Data Stores:    
Create the data stores in the `/mnt` file, since this is where the ephemeral drive will be located.  
The ephemeral drive is larger than the primary drive.  

            df -h # to see the devices  
            #dev/vdb will likely be the largest  
            #likely that it's mounted on /mnt  



<a id = 'init'></a>  
### Initialization:   
Skipped `gpcheck` because `/etc/fstab` was not set to their recommendations.  

Before running the `gpinit` utility, make sure that the Master instance can ssh to itself.  
From `gpadmin` on Master try to ssh to `gpadmin` on Master.  

In `gpinitsystem_config` file, you may want to change the "Other Optional Parameters" value of "#DATABASE_NAME=..."   
and also uncomment it. This will create an initial database in the system.   

Note that there are several configurations possible for the database. For example, one segment can become a segment host by simply  
listing multiple data file and interfaces for it.  

<a id ='fin'></a>  
### Final Steps:   
It will say `Greenplum Database instance successfully created.` upon successful initialization.  

Run:   

        psql -d template1 -h gpMaster -p 5432 -U gpadmin  

This will connect you to the database. You are now ready to start loading tables!!  


[Back to top](#top)
