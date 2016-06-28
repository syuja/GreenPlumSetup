
![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
<a id='top'></a>
#### Table of Contents:  


#### Why use `pygresql` over `psycopg2`?  

  1. The `pygresql` interface is more intuitive.  
    a. `DB()` connnects and `query()` queries  
    b. `get_tables()` returns all of the tables  
    c. `get_attname()` returns column data types and column names  
  2. It returns Python lists as results of listing commands.     
  3. It also supports the DB-API 2.0.  


To list all tables can simply run:  

    query("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")   


#### Install:  

      su -c 'yum list pygresql' #lists available PyGresSQL installations  
      yum install PyGreSQL.x86_64


For more info: http://www.pygresql.org/contents/tutorial.html


#### Tutorial:  

`SSH` into the Magellan instance:  

    ssh -i ~/.ssh/id_rsa centos@140.221.67.65   
    #then become root   
    sudo su   


Be sure that the Greenplum database is running:   
  
    su - gpadmin   
    gpstart  

Log out of `gpadmin`. It allow running Python mostly for database analytics; it will be difficult to install the   
`pygresql` module there. The path will not be added properly.  

    #control d #logs out of gpadmin  and into root  


Now enter python interactively:     

    python  
    >>> import pg # or pgdb if intend to use DB-API 2.0     
    >>> db = pg.DB(dbname='crimes', host='gpMaster', port=5432, user='gpadmin')    
    >>> db.query("SELECT * FROM f_crimes WHERE id=4640862")  
    >>> db.get_tables()     
    >>> db.close()    
    >>> quit() # to quit Python  
  
  
