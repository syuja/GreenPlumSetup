
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
