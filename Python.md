![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
# Python `psycopg2` module  

This tutorial shows how to use `psycopg2` Python module to connect to Greenplum db and query it.  
An alternative is `pygresql`, it's written IN Python instead of C, so it runs a little bit slower.  
Also, `pygresql` is licensed by MIT, not a GPL.  
Further reading is needed to understand thread safety.  
Implements  DB API 2.0.  DB API 2.0 defines functions across python modules that access databases in order to provide  
some consistency.  

Downside of using `psycopg2` is that it's very difficult to run commands like `\dt` to list all tables or  
`d <table_name>` to list the data types of the columns of a table.  
  
  


#### Tutorial:  

`SSH` into the Magellan instance:  

    ssh -i ~/.ssh/id_rsa centos@140.221.67.65   
    #then become root   
    sudo su   


Be sure that the Greenplum database is running:   
  
    su - gpadmin   
    gpstart  

Now enter python interactively:   

    python  
    >>> import psycopg2 as ps   
    >>> conn = ps.connect(database="crimes", user="gpadmin", host="gpMaster", port=5432)   
    >>> cur=conn.cursor()  
    >>> cur.execute('SELECT * FROM f_crimes WHERE id=4640862')    
    >>> cur.fetchone() #returns the result of the query  

After work is done, commit the changes and close the connections:   

    >>> conn.commit()   
    >>> cur.close()   
    >>> conn.close()   



##### Functions:  
`connect` : creates a new database session and returns `connection` instance; encapsulates session    
`cursor` : allows interaction with the database  
  - `execute` : `cursor` method sends command to database   
  - `fetchone` : `cursor` method retrieve data from the database; `fetchmany` retrieves multiple queries  
  
#### Problems:  



For more information visit http://initd.org/psycopg/docs/usage.html#using-copy-to-and-copy-from .  
