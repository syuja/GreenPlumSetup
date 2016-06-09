
### Open Stack Instances
havana.cloud.mcs.anl.gov
ssh-keygen name it
produces a 2 files: copy public one into security of open stack
--> private one will use to ssh into

associate a floating ip address
I already added the key
ssh -i <name_of_key_local_file> centos@<ipaddress_associated_to_me>

Can now sudo su: <-- install things
then Create Snapshot, from that I can create other instances with that snapshot

http://gpdb.docs.pivotal.io/4380/install_guide/init_gpdb.html#topic1
---
Do this for all segments... (using a clone, so should be done)
http://gpdb.docs.pivotal.io/4380/prep_os-system-params.html#topic3
kernel config, xfs, scheduler (grubby for centOs 7), disable transparent huge pages (grubby)


**MISSING: changing xfs to their config crashes the system... AND HOSTS <== /etc/hosts**








-----
command:
may have to remove .ssh/known_hosts

ssh -p 2222 gpadmin@127.0.0.1

virtual box settings: 
1. adapter is NAT and the other one is Host-only adapter
2. on NAT adapter set port forwarding: ssh tcp 127.0.0.1 2222 10.0.2.15 22 
then restart the virtual machine.
3. run ifconfig upon startup: check that eth0 is 10.0.2.15.22
4. from host os: ssh -p gpadmin@127.0.0.1

practice sftp:


run gpfdist on host os, have the vm create an external table:

load the external table:

tranform the external table:
