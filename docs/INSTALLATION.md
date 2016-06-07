![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
# Installation Instructions 

# Table of Contents 
  1. [Readme] (../README.md)
  2. [Installation] (#inst)  
    a. [Helpful Tips] (#help)  
  3. [Tutorial] (../README.md)  

<a id="inst"></a>
## Installation  
These instructions will go over how to install and run on VirtualBox.  

1. Download the Greenplum database virtual machine image from (https://network.pivotal.io/products/pivotal-gpdb#/releases/567/file_groups/337).  
 <p align = "center"> ![home_download](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_download_site.png) </p>
  a. will have to sign up.  
<p align = "center"> ![install_sign_up](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_sign_up.png) </p>  
  b. note may have to untar by double-clicking the downloaded image.  
2. Open the image in Virtual box  
<p align = "center"> ![virtual_b](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_download.png) </p>
  a. Change the settings  
<p align = "center"> ![virtual_settings](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_vbox_settings.png) </p>
3. Start the virtual machine by selecting and hitting start.
<p align="center"> ![virtual_start](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_vbox_location.png)</p>
`Selection:`
<p align="center"> ![virtual_selection](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_vbox_start.png)</p>
4. Login using `gpadmin` as username and `pivotal` as password.  
<p align="center"> ![virtual_start](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_startup.png)</p>
5. **Run the script to start the server**.  
<p align="center"> ![start_server](https://github.com/syuja/GreenPlumSetup/blob/master/img/start_server_high.png)</p>  
  a. Otherwise will get run error: 
<p align="center"> ![run_error](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_run_error.png)</p>   


Now you're ready to start the tutorial. We will mostly use the `~/gpadmin/gpdb-sandbox-tutorials/faa` directory.  


<a id="help"> </a>
### Helpful Tips  
It is helpful to set up a shortcut keyboard so that the host Operating System can maintain ownership of the keyboard and mouse.  
<p align="center"> ![run_error](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_run_error.png)</p> 
Helpful: Ownership of keyboard and mouse ==> special key right cmd
Global setting ==> right control ^ <== 
helpful left control and arrows to move from full screen and out!!
https://www.virtualbox.org/manual/ch01.html <== captured

the image provided by greenplum will require that you install yum
sudo yum install git-all

to see version type :
cat /proc/version

### [Useful Commands](https://github.com/syuja/GreenPlumSetup/blob/master/docs/useful_commands) in Greenplum
