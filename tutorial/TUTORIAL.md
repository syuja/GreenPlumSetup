![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
# Tutorial  
# Table of Contents  
  a. [Setup Create Username] (#username)  
  b. [Create and Prepare Database] (#createdb)  
  c. [Create Tables] (#createtb)  
  d. [Data Loading] (#load)  
    e. [Queries and Performance Tuning] (#tuning)  

**Before starting**: 
  1. run the start script, otherwise you will not be able to connect to the database.  
    `[gpadmin@gpdb-sandbox]$ ./start_all.sh`  
  2. review basic [commands] (../docs/useful_commands)  

**Note**: there are two types of commands psql and bash commands; psql commands will begin with `#`.    

<a id="tut"></a>
## [Tutorial] (TUTORIAL.md)
This tutorial will guide you through setting up users, creating a database, creating tables, and loading data into 
the database. We will also discuss some important considerations for performance tuning.  

<a id="username"></a>
### 1. Create Username  
`CREATE USER -P:`  
  - creates a new PostgreSQL (psql) user/role (wrapper for CREATE ROLE)  
  - P flag issues prompt for password  

`dropuser <user_name>;`: wrapper around DROP ROLE  
`DROP ROLE <user or group>;`: drops user  
`psql`:  
  - command-line client to connect to PostgreSQL server.  
  - PostgreSQL interactive terminal (can type queries interactively)  

`psql -l`:  
  - list all available databases  
    - postgres: holds system wide info  
    - template0: pristine template holds core postgres stuff  
    - template1 default template for new db can be changed  
  
    `CREATE USER user2 WITH PASSWORD 'pivotal' NOSUPERUSER: alias for create role `  
    `CREATE ROLE users  `  
    `GRANT users TO user1, user2`   
    `\q --quits psql`  

`ROLE`:  is an entity, user or group, that can own database objects and have database privileges  
`GRANT TO`: defines access privileges; conveys the privileges granted to a role to each of its members    

<a id="createdb"></a>
### 2. Create a Database  
`createdb`: wrapper for CREATE DATABASE command  
`dropdb`: wrapper for DROP DATABASE  

`GRANT PRIVILEGES TO USERS`:  
  - Grant user minimum permissions necessary 
    - connect as admin    
    - grant privileges  

`SCHEMA`:  
  - container for a set of database objects (tables, data types, functions).
  - a namespace   
  - avoids name collisions, so one database can have many applications  
  - access objects by prefixing with schema.   
    - <schema>.table_person, employee.person or customer.person  

`DROP SCHEMA IF EXISTS faa CASCADE;`   
  - cascade automatically drops objects (table, functions) that are contained in the schema   

Each user has a search path; it determines which schemas are searched when referencing object (tables, views, etc).  

`SET SEARCH_PATH TO faa, public, pg_catalog, gp_toolkit;`  
  - changes search_path temporarily  

`ALTER ROLE user1 SET search_path TO faa, public, pg_catalog, gp_toolkit;` :  
 - search_path is restored every time the user logs in  

<a id="createtb"></a>
### 3. Create Tables:  

The definition of a table includes the distribution policy of the data, and the distribution policy will affect performance.   

**Our goals**:  
  - distribute data and query work evenly
    - enable segments to accomplish most expensive query process steps locally  
  - define a distribution key that will optimize joins  
    - faster to join rows at segments than across segments  
    
  

**Running a script that creates tables** :  

      psql -U user1 tutorial -- sign in to db <tutorial>  
      tutorial=# \i create_dim_tables.sql -- creates tables  
      tutorial# \dt -- shows all tables create  
      


<a id="load"></a>
### 4. Data Loading: 3 Ways  
**INSERT** is slowest, but simplest.     
**COPY** allows the user to specify the format of external text file **but** it doesn't read/write in parallel.    
**Greenplum utilities**, gpfdist and gpload, uses **external data tables** at **_HIGH DATA TRANSFER RATES_** (in parallel).    
  

`gpload` is a wrapper for `gpfdist`. It calls `gpfdist` using the settings specified in a YAML-formatted control file. The control file allows you to configure `gpfdist` in a controlled, repeatable fashion.   


#### A. Slowest But Simplest
    INSERT INTO faa.d_cancellation_codes   
    VALUES('A','Carrier'),('B','Weather'),('C','NAS')... ;    
 **see inside table**:  

      SELECT * FROM faa.d_cancellation_codes;  
    

#### B. Copy Statement  

    \COPY faa.d_airlines FROM 'L_AIRLINE_ID.csv' CSV HEADER LOG ERRORS   
    INTO faa.faa_load_errors KEEP SEGMENT REJECT LIMIT 50 ROWS; 
    -- setting REJECT LIMIT allows Greenplum to scan in single row error isolation mode   
    

Syntax:  

    \COPY <table_name> FROM 'file_name' CSV --comma-separated mode  
    HEADER -- file contains a header row with colnames   
    LOG ERRORS INTO --specifies error table to log rows with errors  
    <error_table> KEEP -- do not drop error_table   
    REJECT LIMIT 50 ROWS; -- isolate errors into external table data while continuing to read correct rows   
    --if limit exceeded, then entire external table operation is aborted   
     

(http://gpdb.docs.pivotal.io/4320/ref_guide/sql_commands/COPY.html)  

#### C. Load Data with Greenplum utilities:  
i. gpdist: guarantees maximum parallelism while reading from or writing to external tables   
  1. run gpfdist on host (where data is located):   
    `gpfdist -d ~/gpdb-sandbox-tutorials/faa -p 8081 > /tmp/gpfdist.log 2>&1 & -- starts gpfdist process`  
    -d sets "home" directory to read and write files  
    -p switch to set the port  
   > /tmp/gpfdist.log redirects stdout to a log file  
    2>&1 redirects stderr to stdout which is being redirected to the log file  
    -- effectively silences all output!!  

<sub><sup>get more help on [gpfdist] (http://gpdb.docs.pivotal.io/4350/client_tool_guides/load/unix/gpfdist.html)</sup></sub>

  2. check that gpfdist is running on the host:  
    `ps -A | grep gpfdist -- shows it running`  

  3. see log file produced:  
    `more /tmp/gpfdist.log -- see stdout, stderr of gpdist`    

  4. Create load tables on Greenplum database:  
    `--data to be read to load tables`  
    `psql -U gpadmin tutorial`  
    `\i create_load_tables.sql -- creates 2 load tables, please view script`  

  
  Take a closer look at create_load_tables.sql script:  
  
    `create table faa.faa_otp_load(`  
    `Flt_Year smallint, -- column name followed by data type`  
    `Flt_Quarter smallint,`  
    `...`  
    `AirlineID integer,`  
    `DepDelay numeric,`  
    `...)`  
    `distribute by (Flt_Year, Flt_Month, Flt_DayofMonth);`  
    `-- distributes rows across segments using three columns as the hash`  
    `-- ideally, different tables are joined on columns with same hash key, `  
    `since it's faster to join at segments than across segments`   
 
 **Distributing by randomly** slows joins across segments. Distribution of data may affect performance,
 depending on how user queries it.    
  
  Note: faa is a schema, it's like namespace/container that will hold the table.  

  4. Create an External table:  
  Creating an external table doesn't move the data into our Greenplum database. The external table definition simply provides 
  **references** to external files on the host. It also declares the communication protocol, `gpfdist`, and the port number to use.  
  
  External tables can be accessed as if they were regular, local database tables. They can be queried directly and in parallel.   

  External tables are mainly used to facilitate the moving of host data files to the local database. They allow us to call SELECT INTO, and 
  also to exploit parallelism by establishing a connection using gpfdist.  

  syntax:   

      CREATE <READABLE|WRITABLE> EXTERNAL TABLE <table_name> -- readable is default, used for loading data into Greenplum Database  
      LIKE <other_table> -- specifies a table from which column names, distribution policy and data types is copied  
      LOCATION <protocol://host:port_num/path/file',...> -- specifies protocol, url and port of external data  
      FORMAT <'text'|'csv'>  
      LOG ERRORS INTO <error_table> -- save errors to error table
      SEGMENT REJECT LIMIT <count> [ROWS|PERCENT]; -- rows with errors are discarded, until limit reached
      --at limit the whole external table is dropped  
  
  
  example:  

      CREATE EXTERNAL TABLE faa.ext_load_otp  
      (LIKE faa.faa_otp_load)  
      LOCATION ('gpfdist: //localhost8081/otp*.gz')  
      FORMAT 'csv' (header)  
      LOG ERRORS INTO SEGMENT REJECT LIMIT 50000 rows;  
  

  5. Move from external table to load table  


      `INSERT INTO faa.faa_otp_load SELECT * FROM faa.ext_load_otp;`     
      `-- many gpfdist processes running, one on each host.`     
  
![gpfdist_image](https://github.com/syuja/GreenPlumSetup/blob/master/img/gpfdist_figure.png)


more on [external database](http://gpdb.docs.pivotal.io/4320/admin_guide/load.html) tables  

Show the results:  

      tutorial=# \x -- opens expanded display  
      tutorial=# SELECT DISTINCT relname, errmsg, count(*)  
      FROM faa.faa_load_errors GROUP BY 1,2;  
      tutorial=#\q -- quits   



#### gpload - wrapper around gpfdist  
1. Kill gpfdist (gpload will start it)  
  


    `ps -A |grep gpfdist`  
    `killall gpfdist`  
  
2. Edit gpload.yaml  
  - TRUNCATE: true ensures that the previous data is discarded  
  
3. Execute gpload with gpload.yaml control file   


      `gpload -f gpload.yaml -l gpload.log -v`   
      `# f <control_file> : yaml file containing the load specification details`    
      `# l <log_file> : where to write the log file `   
      `# v (verbose mode) : prints output of load steps`  
  

#### Create and Load Fact Tables:  
  When we copy from the external table into the load table, we simply copy raw data. We copy Load tables into Fact tables, so that we
  may **transform** the data. Transforming means discarding unneeded data, converting data types, renaming columns and possibly joining several external tables. Transforming makes the data more usable. 
  We can use it for our particular application.   

      gpload ? | less  -- help for gpload  
      psgl -U gpadmin tutorial  
      tutorial=# \i create_fact_tables.sql ==> create final tables: excluded some cols, cast datatypes of some cols  
      tutorial=# \i load_into_fact_table.sql ==> load from loaded tables into fact tables ==> INSERT TO
 
  `create_fact_tables script:`  

      create table faa.otp_r ( -- _r is for row oriented  
      Flt_year smallint, -- column name and data types  
      Flt_Quarter smallint,  
      ...  
      Origin text, -- airport code  
      ...  
      distributed by (UniqueCarrier, FlightNum); -- will provide a distribution key
      --key will be hashed to distribute across segments  
  
  `script for colum-oriented table: `   

     create table faa.otp_c(LIKE faa.otp_r) -- _c is for column-oriented
     -- LIKE copies column names, data types from another table  
     WITH (appendonly=true, orientation=column) -- column-oriented, appendonly instead of heap  
     distributed by (UniqueCarrier, FlightNum)   
     PARTITION BY RANGE(FlightDate)  
      PARTITION mth START('2009-06-01'::date) END ('2010-10-31'::date) EVERY('1 mon'::interval)  
      );  --partitioning can improve performance  
  
   Guidelines for [orientation] (http://gpdb.docs.pivotal.io/4380/admin_guide/ddl/ddl-storage.html)   
  Guidelines for [partioning](http://gpdb.docs.pivotal.io/4350/admin_guide/ddl/ddl-partition.html)
 
  `Transform (load) into Fact table`:  

      insert into faa.otp_r select l.Flt_year, l.Flt_Quarter, l.Flt_Month, l.Flt_DayofMonth,  
      ... l.DepDelay::float8, -- cast from numeric  
      l.DepartureDelayGroups::smallint,  
      l.TaxiOut::integer,  
      l.WheelsOff,  
      coalesce(l.CarrierDelay::smallint, 0),  
      coalesce(l.WeatherDelay::smallint, 0), <== cast to smallint, if NULL then 0   
      from faa.faa_otp_load l; <== l like an alias for that load table
      insert into faa.otp_c select * from faa.otp_r; -- copy into _r without all of the formatting in _c table
  
  
    
#### Data Loading Summary:   
  ELT (extract, load, transform) allows load processes to make use of massive parallelissm. Gpfdist reads the data in parallel. Once loaded, we can leverage the parallelism of the Greenplum database to tranform it (set-based operations can be done in parallel).   
  COPY loads using single process, so it is less efficient.     
  External tables provide a means of leveraging the parallel processing power of segments. They also allows us to access multiple
  data sources with one SELECT statement of an external table. 

<a id ="tuning"></a>
#### 5. Queries and Performance Tuning:  
----  

This section provides a useful introduction into Greenplum queries.  

First, the master receives, parses and optimizes queries producing a resulting query that is either parallel or targeted.  
The master then dispatches query plans to all segments. Each segment is responsible for executing local database operations on its
own set of data.  
  
  <p align = "center"> ![query_distribution](https://github.com/syuja/GreenPlumSetup/blob/master/img/parallel_plan.png)</p>
  
Most database operations - execute across all segments in parallel, performed on a segment database independent of the data
stored in the other segment databases...


**`Terminology`**:  
  - query plan: set of operations GP db will perform to produce the answer to a query; executed bottom up
  - motion operation: moving tuples between the segments during query processing; 
    - describes when and how data should be transferred between nodes during query execution.  
  - slice: portion of plan that segments can work on independently; 
    - query plan is sliced wherever motion operation occurs  
    - slices are passed to segments  

**`Understanding Parallel Query Execution`**:  
  - query dispatcher (QD): on master, process responsible for creating and dispatching the query plan
    - also accumulates and presents the final result
  - query executor (QE): on segment, process responsible for completing its portion of work and communicating its intermediate results
 to the other worker processes
  - gangs: related processes working on the same slice but on different segments  

 
At least one worker process is assigned to each slice of the query plan. Each works on assigned portion of query plan independently.
 As a portion of the work is completed, tuples of data flow up the query plan from one gang to the next. The inter-process communication between segments is referred to as the _interconnect component_ of the Greenplum database.  


More info on [query plan] (http://gpdb.docs.pivotal.io/4330/admin_guide/parallel_proc.html)  
Please see [Exercises] (https://github.com/syuja/GreenPlumSetup/blob/master/TUTORIAL.md) for practice.   
