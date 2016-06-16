


Synchronizing:   
Need install ntp  
    yum install -y ntp  
    systemctl start ntpd  

Check available ntp servers:   

    ntpq -p  
      
Make master point to these and makes segment hosts point to master.  
