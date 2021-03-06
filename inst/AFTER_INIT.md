![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
---
<a id='top'></a>
### After Initializing:  
#### Table of Contents:  
  1. [Accessing the Database](#access)    
  2. [Configure Clients](#clients)  
  3. [Roles and Privileges](#roles)
  4. [Quick Recap](Installation_Recap.md)

If you did not specify a database to create after initialization in `gpinitsystem_config `, then you will have to create a new  
one.

 <p align = 'center'>![optional_create](https://github.com/syuja/GreenPlumSetup/blob/master/img/optional_create_db.png)</p>  
 
First log in to `template1` as `gpadmin`:  

     psql -d template1 -h gpMaster -p 5432 -U gpadmin  
  
 
<a id ='access'></a>
### Accessing the Database:  
We will first demonstrate how to use `psql` to access the local database.  
Then we will demonstrate how to add external users.  

<a id='clients'></a>  
### Configure Client Authentication:   
We will edit the PostgreSQL host-based authentication file, `pg_hba.conf`, to allow outside users  
to access our databse.  


<a id='roles'></a>
### Roles and Privileges:  


Change the query optimizer after initializing the database for faster results.  

[back to top](#top)
