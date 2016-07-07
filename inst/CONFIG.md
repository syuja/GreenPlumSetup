![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>    


#### Preparing to Install:  
*****
First, disable `selinux`, `iptables`, and `firewalld`.  
Please see [here](http://gpdb.docs.pivotal.io/4380/prep_os-system-req.html#topic2).
You may want to re-enable these after the database has been installed.  

Second, set the OS Parameters, but do not change `/etc/fstab` as this will  
cause our machines to have trouble restarting.   

Changing the `/etc/fstab` file cause the system to go into `emergency  mode` upon rebooting.  
`/dev/vdb` is ephemeral, and the system will not be able to mount it.   
  
  
Please see [here](http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3) for all parameters.  

#### Installation Files:  
******   
The installation will require several files specifying all of the instances that will be part of the  
Greenplum database.  

First, modify the `/etc/hosts` file and add aliases for all of the Greenplum instances.   
Our `hosts` file looks like this:   

  <p align="center"> ![etc_hosts](https://github.com/syuja/GreenPlumSetup/blob/master/inst/img/etc_hosts.png) </p> 

The `IP` on the left is the internal `IP` provided by OpenStack/Magellan:   

  <p align="center"> ![internal_ip](https://github.com/syuja/GreenPlumSetup/blob/master/inst/img/internal_ip.png) </p> 

  
Our `hostfile_exkeys` looks like this:  

  <p align="center"> ![hostfile_exkeys](https://github.com/syuja/GreenPlumSetup/blob/master/inst/img/hostfile_exkeys.png) </p>  
  
We have **1** interface per instance, so we have no need to add numbers after each host.  

Remember that you will have to run `gpseginstall` twice.  
Make sure that you change the ownership of `hostfile_exkeys` in `/home/gpadmin` the second time running it.   

Running it twice is necessary, the installation will fail the first time.  
This is because it will create a new user `gpadmin` in each instance, and try to `SSH` into it from the 
Master to the Segment. **But** no `SSH` keys have been exchanged yet.   

#### Initialization:  
After installing Greenplum, we will need to initialize.  

The `gpinitsystem` utility is used to initialize the database.  
It will require a `gpinitsystem_config` file as input.    
Ours looks like this:  

  <p align="center"> ![gpinitconfig](https://github.com/syuja/GreenPlumSetup/blob/master/img/gpinitsystem_config.png)  </p>  
  
Note that we did not set up mirrors, and also note that the Master instance also contains database data.  
This happens because we created a directory for data on the Master, we specified it in the `hostfile_exkeys`.   

`gpinitsystem` requires a `hostfile_gpinitsystem`. For this, we simply reuse the `hostfile_exkeys`.   
It simply lists all segment hosts in our Greenplum database, and in our case Master is also a segment.  
(Master is a segment for space considerations, it will probably affect system performance.)     


#### Charater Set:  
The default character set for the Greenplum database is set in the  
**ENCODING** parameter in the `gpinitsystem_config` file.   

By default, it will be UTF8 or Unicode.   
This is important if the database were to hold string containing  
characters from different languages.   


#### Summary:   
We show the most basic configurations of all files required to install Greenplum.   

We hope that they will be useful to you.   

### Definitions:   
***
##### **SELinux** :  
----------
security-enhanced Linux; it's a kernel security module. It's predecessor, discretionary access control (DAC),  
only used file permissions and access control lists to control access to files.  

Under DAC, users and programs could grant insecure file permissions to others.  
DAC only had two privilege levels, root and user.  

SELinux, follows the model of least-privilege more closely.  
By default, everything is blocked, and exceptions are written to give access to elements of the system.  
Giving users only the access necessary to function.   

<sub><sup> https://wiki.centos.org/HowTos/SELinux </sub></sup>  

##### **iptables**:   
----------
user-space application that allows sys admin to configure tables in the Linux kernel firewall (Netfilter)  
and to configure the chains it stores.  

It's really a front-end to the kernel-level firewall, Netfilter.  
It works by matching packets that cross the networking interface against a set of rules to decide what to do.  

**Rules** define a set of characteristics that a packet must have to match the rule, and they define action   
to be taken for matching packets. Rules can match based on protocol type, source address or port, destination  
address or port.  

When a packet matches a defined patter, the action take is called a **target**.   
Target is the policy decision taken for the packet (dropping, accepting, etc.) .  

**Chain** is a set of rules that is checked sequentially.   
When a packet matches one of the rules, it executes the associated action without checking against the remaining   
rules.   

There are 3 default chains. Users can create chains as needed.   
Each chain has a **default policy** that determines what happens when a packet fails to meet any  
of the rules in a chain.   

`iptables` can also track connections by creating rules that keep track of packets based on previous packets.  

  
  
<sub><sup> https://en.wikipedia.org/wiki/Iptables </sub></sup>
<sub><sup> https://www.digitalocean.com/community/tutorials/how-the-iptables-firewall-works </sub></sup>  

##### **firewalld**:   
------
It's a front-end controller for `iptables`.  
It has a graphical user interfaces.  
It uses _zones_ and _services_ instead of chains and rules.  
Also, it manages rule sets dynamically, so there is no need to interrupt the connection while updating rules.  

`firewalld` is included in CentOS, but `iptables` are not.  
The former uses the latter to enforce network policies.  


<sub><sup> https://www.linode.com/docs/security/firewalls/introduction-to-firewalld-on-centos </sup></sub>

[Top](#top) 
