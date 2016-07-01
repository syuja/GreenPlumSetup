![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
### Helpful Commands:  
Check if Postgres or Greenplum are running:  

      ps -ef | grep postgres #or greenplum  

Is the master available on port `5432`:   

      netstat -tulpn | grep '5432'  

**Common problem**  
Environment variables do not point to the correct file locations, therefore database commands are   
unable to run.  
In `.bashrc`, create proper variables with locations. Before running commands, source the `.bashrc`.  

