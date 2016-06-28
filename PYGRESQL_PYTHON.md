
![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

#### Why use `pygresql` over `psycopg2`?  

  1. The `pygresql` interface is more intuitive.  
    a. DB() connnects and query() queries  
    b. get_tables() returns all of the tables  
    c. get_attname() returns column data types and column names  
  2. It returns Pythons lists as results of listing commands.     
  3. It also supports the DB-API 2.0.  


To list all tables can simply run:  

    query("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")   


#### Install:  

      su -c 'yum list pygresql' #lists available PyGresSQL installations  
      yum install PyGreSQL.x86_64


For more info: http://www.pygresql.org/contents/tutorial.html
