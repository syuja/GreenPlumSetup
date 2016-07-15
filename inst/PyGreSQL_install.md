![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

### Intro:  
This module will guide you through installing the `PyGreSQL` package for Python on your Master instance.  
We are running CentOS 7.1, and we encountered some problems installing it.  
This tutorial will help you circumvent those problems.   

### Setup:     

Ideally, you would run `pip install PyGreSQL` to install `PyGreSQL`.  
However, first you will need to install `pip`:   

    #from user centos run:   
    $ sudo -y install python-pip   
    #running from centos and not sudo   
    #will preclude the 'module import error'  


Next, you will have to install Python 2.7.   
This is necessary since `pip` no longer supports Python 2.6, the default installation on CentOS 7.1.  
However, this needs to be done carefully since `yum` depends on the default system Python install.   

    #from centos user run:  
    sudo yum install centos-release-scl     
    sudo yum install python27  
    #for some reason this works!!!   

Now, `pip` and `python27` should be installed on your system.   

### PyGreSQL:  

`PyGreSQL` has a dependency on `pg_config`.   
Only `gpadmin` user has access to `pg_config`.   
(Adding `pg_config` to root PATH doesn't maek it available to root.)         
We will need to give `gpadmin` sudoer privileges.   

    #/etc/sudoers file contains the permissions we need to change   
    visudo  

Uncomment the following line `# %wheel        ALL=(ALL)       ALL`.  
`/etc/sudoers` should be editing like this:   

    ## Allows people in group wheel to run all commands     
    %wheel        ALL=(ALL)       ALL   

Next, add `gpadmin` to the `wheel` group to give it sudoers permissions.   

    $ usermod -aG wheel gpadmin  
    #verify   
    $ su - gpadmin #changing users   
    $ groups  
    #result:   
    gpadmin wheel   

Finally, from `gpadmin` run:   

    sudo pip install PyGreSQL   
    #this should work   

  
  

[Top](#top)  
