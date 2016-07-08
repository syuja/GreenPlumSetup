![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
<a id='top'></a>   
## Helpful Commands:   

#### PSQL:  
**Always run `gpstop` before leaving/rebooting/shutting down, and `gpstart` to restart the database.**   
**Note**: restarting the Master instance without running `gpstop` will crash the database.   

For sample scripts, go [here](../script/README.md). 

**Listing Tables, View Schemas:**  
----  

            \d - lists tables, views, sequences \d table_name shows description of table  
            \du - list of roles (users and groups)  
            \dt - list tables, also shows schemas  
            \dv - list views   
            \l - lists all databases  
            \dn - list schemas   
            \d [object_name] - **will show data types for each column**   


**Accessing Database:**  

            \c - connect to new database  
            \q - quit database   

**Help:**  
  
            \h - help on syntax for SQL command \h SELECT or \h *  
            \? - list psql commands   
      

**Utility:**    

            \timing [on | off] - timer will time all commands  
            \cd - change working directory  
            \i - runs SQL scripts from inside  
            
**From Terminal:**  
  
            psql -l - list all available databases  
            psql -U username db - connects user name to db  
                  example:  psql -d crimes -h gpMaster -p 5432 -U gpadmin (-d database ,-h host, -p port, -U user)  
            

**External Table:**   
Please view the sample [scripts](../script/README.md).   

The most important part is to specify the `gpfdist` protocol:  

            LOCATION ('gpfdist://10.1.8.4:8081/Crimes*.csv')    



**gpfdist:**   

            gpfdist -d /home/centos -p 8081 -l ./log/ &  #runs gpfdist    
            #'/home/centos' will be what the external table accesses   
            ps -ef | grep gpfdist  #for killing the process    
            kill <pid from previous command>    

**List processes on Ports:**  

            lsof -i:8081 #lists process running on 8081, useful for checking if gpfdist is running on the port    
            netstat -tulpn | grep '5432'  #also checks what process is running on port '5432'  
            netstat -tanpu # list processes running on ports  

**Drives Mounted:**  

            df -h #shows size and mounted drives (accounts for inodes and other overheads)  
            du -hs #shows size used by files  
            lsblck - lists drives that haven't been mounted, but that are connected  
            

**Common Problems:**   

Environment variables do not point to the correct file locations, therefore database commands are   
unable to run.  
In `.bashrc`, create proper variables with locations. Before running commands, source the `.bashrc`.   

** Rsync and SFTP: **  

            #sftp can move entire directory with the '-r' flag  
            #first you need to have a directory with the same name on the remote machine  
            sftp> mkdir bin  
            sftp> put -r bin  
            
`rsync` uses a different protocol.  

            #it can push and pull(get) like sftp  
            #push from local to remote  
            rsync -avzuP <local_dir> user@remote:<dest_dir>  
            #pull  
            rsync -avzuP user@remote:<remote_dir_to_pull>   <local_dir_to_place>   


[Top](#top)  

