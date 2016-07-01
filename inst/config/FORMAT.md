![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

[back] (../Master_Install.md)
<a id ="top"> </a>
### Format:   
 To format `devb`, we will have to :   
   a. [unmount] (#mount)  
   b. [format using mk.xfs] (#format)  
   c. [change fstab](#fstab)    
   d. [mount] (#mount) 

<a id ="mount"></a>
#### Mount: 
To unmount:   

    umount /mnt   

To mount:  

    mount /dev/vdb  


<a id ="format"></a>
#### Format: 
 Must have `xfsprogs` installed. Then:  

    sudo mkfs.xfs -f /dev/vdb   


 
<a id ="fstab"></a>
#### fstab: 
Edit options before mounting again.  Change them to:  

![mount_options](https://github.com/syuja/GreenPlumSetup/blob/master/img/fstab_template.png)   

Finally, mount again.  

Great [reference](http://ask.xmodulo.com/create-mount-xfs-file-system-linux.html).

[top] (#top)
