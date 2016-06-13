![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
# Installation Instructions 

# Table of Contents 
  1. [Readme] (../README.md)
  2. [Installation] (#inst)  
    a. [Helpful Tips] (#help)  
  3. [Tutorial] (../README.md)  
  4. [fstab]   (../fstab.md)

<a id="inst"></a>
## Installation  
These instructions will go over how to install and run on VirtualBox.  

1. Download the Greenplum database virtual machine image from (https://network.pivotal.io/products/pivotal-gpdb#/releases/567/file_groups/337).  
 <p align = "center"> ![home_download](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_download_site.png) </p>
  a. will have to sign up.  
<p align = "center"> ![install_sign_up](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_sign_up.png) </p>  
  b. Untar by double-clicking the downloaded image.  
2. Open the image in Virtual box  (double click, requires VirtualBox)
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
  a. Otherwise will get run error (when running tutorial):  
<p align="center"> ![run_error](https://github.com/syuja/GreenPlumSetup/blob/master/img/install_run_error.png)</p>   


Now you're ready to start the tutorial. We will mostly use the `~/gpadmin/gpdb-sandbox-tutorials/faa` directory.  


<a id="help"> </a>
### Helpful Tips  
Set a keyboard shortcut to allow the host Operating System to retain ownership of the keyboard and mouse:  
  
  <p align= "center"> ![global_settings](https://github.com/syuja/GreenPlumSetup/blob/master/img/help1.png) </p>  
   <p align= "center"> ![drop_down](https://github.com/syuja/GreenPlumSetup/blob/master/img/help2.png) </p>  
   `Uncheck auto-capture keyboard and set the uncapture key:`   
     
     
   <p align= "center"> ![change key](https://github.com/syuja/GreenPlumSetup/blob/master/img/help3.png) </p> 
  
  
To install git run:  
      `sudo yum install git-all`  
  

To see the operating system version run:  
      `cat /proc/version`  
  
  
### [Useful Commands](https://github.com/syuja/GreenPlumSetup/blob/master/docs/useful_commands) in Greenplum
