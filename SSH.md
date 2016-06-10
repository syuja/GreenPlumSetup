![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
## Table of Contents  
  1. [Create Virtual Machines](#open)  
  2. [Connect to VMs](#con)  
  3. [SFTP Guide](#sftp)
  4. [Virtual Box] (#vbox)
  5. [Install Greenplum on Master] (../docs/Master_Install.md)  
  6. [Install Greenplum on all Hosts] (../docs/Hosts_Install.md)  
  
<a id="open"></a>
### Open Stack Instances  
Create a ssh-key on your **local** machine.  
`ssh-keygen name it 'magellan'` leave the passphrase blank  
  - produces 2 files:  
    a copy public one into security of open stack   
    b private one will use to ssh into   
Go to havana.cloud.mcs.anl.gov .   
  - click on instances  
  - launch instance  
  - Access and Security  
    -   `cat magellan.pub` (on local machine)
    - paste the public key here  


Once the instance is running, click `associate a floating ip address `  

<a id="con"></a>
### Connect to VMs  
From local machine: 
`ssh -i <name_of_key_local_file> centos@<ipaddress_associated_to_me>`  



Example with public key named magellan, CentOS instance, and assigned ip being '140.221.65.33':   
`ssh -i magellan centos@140.221.65.33`   

**Troubleshoot: ** It may be necessary to remove known_hosts in order to establish a connection. 
`rm ~/.ssh/known_hosts`  

Type yes for:   
![rsa](https://github.com/syuja/GreenPlumSetup/blob/master/img/rsa_key.png)   

Type `sudo su` in order to install things.  

On open stack, click `Create Snapshot`. This snapshot can be used to create other instances.  

http://gpdb.docs.pivotal.io/4380/install_guide/init_gpdb.html#topic1  

---  
Do this for all segments... (using a clone, so should be done)  
http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3  
kernel config, xfs, scheduler (grubby for centOs 7), disable transparent huge pages (grubby)  


**MISSING: changing xfs to their config crashes the system... AND HOSTS <== /etc/hosts**  



<a id="sftp"></a>
### SFTP Guide  
-----  
This quick guide is intended as a review. SFTP is used in order to transfer binaries to the virtual machine.  
Note: **curl** command can also be used to download the binaries.  

`sftp -i <private_key_name> centos@<ip_address>`
! - drop into local shell
exit to return to sftp session
put - transfer to the remote server
put -r - recursive

`get remoteFile` - download from remote host
`get -r - recursive` (directory and contents)
`get -r remoteFile remote_Renamed` - renames as it downloads

df -h - check remote has enough space
!; df -h - check local has enough space

<a id="vbox"></a>  
### Virtual Box:   

ssh -p 2222 gpadmin@127.0.0.1

virtual box settings: 
  1. adapter is NAT and the other one is Host-only adapter
  2. on NAT adapter set port forwarding: ssh tcp 127.0.0.1 2222 10.0.2.15 22 
then restart the virtual machine.
  3. run ifconfig upon startup: check that eth0 is 10.0.2.15.22
  4. from host os: ssh -p gpadmin@127.0.0.1
