![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  
# Tutorial  
# Table of Contents  
  a. [Setup Create Username] (#username)  
  b. [Create and Prepare Database] (#createdb)  
  c. [Create Tables] (#createtb)  
  d. [Data Loading] (#load)  
    e. [Queries and Performance Tuning] (#tuning)  

**Before starting**: run the start script, otherwise you will not be able to connect to the database.
    `[gpadmin@gpdb-sandbox]$ ./start_all.sh`  

**Note**: there are two types of commands psql and bash commands; psql commands will begin with `#`  

<a id="tut"></a>
## [Tutorial] (TUTORIAL.md)

what is a template??

<a id="username"></a>
### 1. Create Username  
`CREATE USER -P:`  
  - creates a new PostgreSQL (psql) user/role (wrapper for CREATE ROLE)  
  - P flag issues prompt for password  

`dropuser <user_name>;`: drops user; semicolon is important ???wrapper?
`DROP ROLE <user or group>;` :drops user...  

`psql`:  
  - command-line client to connect to PostgreSQL server.  
  - PostgreSQL interactive terminal (can type queries interactively)  

`\du`:  
  - get a list of roles.  

`\q`:  
  - quit psql shell

`psql -l`:  
  - list all available databases  
    - postgres: holds system wide info  
    - template0: pristine template holds core postgres stuff  
    - template1 default template for new db can be changed  
  

    `CREATE USER user2 WITH PASSWORD 'pivotal' NOSUPERUSER: alias for create role `  
    `CREATE ROLE users -- role is an entity that can own database objects and have database privilege (can be "user" or  a "group")`  
    `GRANT users TO user1, user2 --  defines access privileges; conveys the privileges granted to a role to each of its members`  
    `\q --quits psql`  
    



<a id="createdb"></a>
### 2. Create a Database and Prepare it  
`createdb`: wrapper for CREATE DATABASE command  
`dropdb`: wrapper for DROP DATABASE  
`psql -U user1 tutorial`: connects as user1 to tutorial db  

????prepare it, so I need to add script stuff!!!


### `GRANT PRIVILEGES TO USERS`:  
Grant users the minimum permissions required to do their work.  
- connect as admin  
- grant privileges  


### `SCHEMA`  
  - container for a set of database objects (tables, data types, functions).
  - namespace; Multiple schemas allow using one database for many applications. 
  - access objects by prefixing with schema.  
    - <schema>.table_person, employee.person or customer.person  

### `DROP SCHEMA IF EXISTS faa CASCADE`   
  - cascade automatically drops objects (table, functions) that are contained in the schema.  

Each user has a search path; it determines which schemas are searched when referencing object (tables, views, etc).  

`SET SEARCH_PATH TO faa, public, pg_catalog, gp_toolkit;`  
  - changes search_path temporarily  

What if we want to change the search_path for a user more permanently?  

`ALTER ROLE user1 SET search_path TO faa, public, pg_catalog, gp_toolkit;` :  
 - will be restored everytime the user logs into the database

<a id="createtb"></a>
### 3. Create Tables:  

The definition of a table includes the distribution policy of the data, and the distribution policy will affect performance.   

**Our goals**:  
  - distribute data and query work evenly    
    - enable segments to accomplish most expensive query process steps locally  
  - distribute by  
- for joins, use DISTRIBUTED BY (column,...) faster to join columns on different segments than it is to join rows on different segments  ???????  



`\h` or `\?` : help;shows available postgresql commands  
`\dt *;` :  shows all schemas  
`\dt` or `\d`:  show only visible tables **in search_path** (add schemas to search path if necessary) 

**running a script that creates tables** : 
    psql -U user1 tutorial -- sign in to db <tutorial>
    tutorial=# \i create_dim_tables.sql -- creates tables 
    tutorial# \dt -- shows all tables create  
      


<a id="load"></a>
### 4. Data Loading: 3 Ways  
  A.  INSERT is slowest, but simplest   
  B.  COPY: specify the format of external text file **but** not parallel  
  C.  Greenplum utilities: gpfdist and gpload using **external data tables** at **_HIGH DATA TRANSFER RATES_** (parallel)  
  

gpload is a wrapper for gpfdist. It call gpfdist using the setting specified in a YAML-formatted control file. Control file allows you to configure gpfdist in na controlled, repeatable fashion.   


`\i` : run sql scripts  
`\d d_cancellation_codes`: show description of table  

### A. Slowest But Simplest
    `INSERT INTO faa.d_cancellation_codes`  
    `VALUES('A','Carrier'),('B','Weather'),('C','NAS')... `  
 **see inside table**:  
    `SELECT * FROM faa.d_cancellation_codes;`  
    

### B. Copy Statement
    `\COPY faa.d_airlines FROM 'L_AIRLINE_ID.csv' CSV HEADER LOG ERRORS`  
    `INTO faa.faa_load_errors KEEP SEGMENT REJECT LIMIT 50 ROWS;` 
    `-- setting REJECT LIMIT allows Greenplum to scan in single row error isolation mode`  
    

Syntax:
    `\COPY <table_name> FROM 'file_name' CSV --comma-separated mode` 
    `HEADER -- file contains a header row with colnames`  
    `LOG ERRORS INTO --optionally precedes reject, specifies error table where rows with formatting errors will be logged`  
    `<error_table> KEEP -- do not drop error_table`  
    `REJECT LIMIT 50 ROWS; -- isolate errors into external table data while continuing to read correct rows`  
   `--if limit exceeded then entire external table operation is aborted`  
     

(http://gpdb.docs.pivotal.io/4320/ref_guide/sql_commands/COPY.html)  

### C. Load Data with Greenplum utilities:  
#### i. gpdist: guarantees maximum parallelism while reading from or writing to external tables
1. gpfdist -d ~/gpdb-sandbox-tutorials/faa -p 8081 > /tmp/gpfdist.log 2>&1 & <== starts gpfdist process
  -d sets "home" directory to read and write files
  -p switch to set the port 
  > /tmp/gpfdist.log redirects stdout to a log file
  2>&1 redirects stderr to stdout which is being redirected to the log file
  -- effectively silences all output!!
get more help on gpfdist: http://gpdb.docs.pivotal.io/4350/client_tool_guides/load/unix/gpfdist.html

best load speed gpfdist, runs on  the servers where data is located

2. ps -A | grep gpfdist <== shows it running

3. more /tmp/gpfdist.log <== shows stdout and stderr of when gpfdist was executed

4.create load tables <== psql session as admin
  -A psql -U gpadmin tutorial
  -B \i create_load_tables.sql <== creates 2 tables into whic gpdist will load data, and errros will be logged
  -C faa_otp_laod table structured to match the format of the input data from the FAA Web site
  
  let's take a closer look at create_load_tables.sql script:
  create table faa.faa_otp_load(
  Flt_Year smallint, <== column name followed by psql data type (smallint is 2 bytes)
  Flt_Quarter smallint,
  ...
  AirlineID integer,
  DepDelay numeric,
  ...)
  distribute by (Flt_Year, Flt_Month, Flt_DayofMonth); <== creates distribution key using 3 columns, hashes the distribution key,
  result of hash function determines which segment stores which row, rows that have same distribution key stored in same segment
  ==> ideal case: different tables joined on columns that have the same distribution key, why? much faster to join rows that are
  on the same segment
  ==> suppose have two tables Employees and Contact Information both contain Name column, if I use Name column as distribution key
  and then do a join on Name where Name=, I'll be joining rows on 1 segment which will be very fast 
  
  create table faa.faa_load_errors (cmdtime timestamp with time zone, filename text, ...) <== timestamep with time zone 8 bytes 
  data type
  distribute by randomly; <== distributes rows in round-robin fashion among the segments (example: 10 rows to seg1, next 10 rows
  to seg2, next 10 to seg3)
  ==> distributing rows randomly slows joins down as joining rows across segments
  
  *how data is distributed will affect performance depending how user plans to access the data
  
  faa <== is the schema, like the namespace/container that will hold that table
  
5. create external table definition with same struct as faa_otp_load table:

*no data has moved from host to database yet. external table definition simply provide **references** two otp files on host.  
*external tables enable accessing external files as if they were regular database tables. can query external table data directly
and in parallel 
*creating external database table will facilitate moving host data files to database (can call SELECT INTO using the external
database table and copy into local database)

syntax: 
CREATE <READABLE|WRITABLE> EXTERNAL TABLE <table_name> <== readable is default, used for loading data into Greenplum Database
LIKE <other_table> <== specifies a table from which the new external table automatically copies all column names, data types and 
distribution policy
LOCATION <protocol://host:port_num/path/file',...> <== specifies the url of external data source to be used to populate the
external table
FORMAT <'text'|'csv'>
LOG ERRORS INTO <error_table> <== can examine to see error rows that were not loaded
SEGMENT REJECT LIMIT <count> [ROWS|PERCENT]; <== row with errors discarded until limit reached, if limit reached discard whole
thing

CREATE EXTERNAL TABLE faa.ext_load_otp
(LIKE faa.faa_otp_load)
LOCATION ('gpfdist: //localhost8081/otp*.gz')
FORMAT 'csv' (header)
LOG ERRORS INTO SEGMENT REJECT LIMIT 50000 rows;

finally move from external table to load table
INSERT INTO faa.faa_otp_load SELECT * FROM faa.ext_load_otp; <== many gpfdist processes running, one on each host...

more on external database tables: http://gpdb.docs.pivotal.io/4320/admin_guide/load.html

-Show the results:
tutorial=# \x <== opens expanded display
tutorial=# SELECT DISTINCT relname, errmsg, count(*)
        FROM faa.faa_load_errors GROUP BY 1,2;
tutorial=#\q


#### gpload - wrapper program for gpfdist that does much of the setup work
1. kill gpfdist since gpload executes gpfdist
  - ps -A |grep gpfdist
  - killall gpfdist
  
2. edit gpload.yaml
  - TRUNCATE: true ensures that the data loaded previously will be removed before the load in this exercise starts
  
3. execute gpload with gpload.yaml input file ==> include -v flag to see details of loading process
  -gpload -f gpload.yaml -l gpload.log -v
  -f <control_file> : yaml file containing the load specification details
  -l <log_file> : where to write the log file
  - v (verbose mode) : verbose output of load steps as they are executed!

B: Create and Load Fact Tables:
  why? when you copy, it is a raw copy, column names, data types are the same. Transform filter unneeded rows and columns <== don't 
  waste resources on unneeded data; convert data types, conformed dimension possibly join several external tables..
  - moves data from load table to the fact table
  help for gpload: gpload ? | less
  
  - psgl -U gpadmin tutorial
  - tutorial=# \i create_fact_tables.sql ==> create final tables: excluded some cols, cast datatypes of some cols 
  - tutorial=# \i load_into_fact_table.sql ==> load from loaded tables into fact tables ==> INSERT TO
  
  create_fact_tables script:
  create table faa.otp_r ( <== _r is for row oriented
  Flt_year smallint, <== column name and data types
  Flt_Quarter smallint,
  ...
  Origin text, -- airport code <== this is a comment SQL comment starts with "--", C-style block comments can be used "/**/"
  ...
  )
  distributed by (UniqueCarrier, FlightNum); <== will provide a distribution key, which will be hashed in order to place in
  different segments..
  
  create table faa.otp_c(LIKE faa.otp_r) <== _c is for column-oriented and partitioned; LIKE new table copies all column names
  their data types...
  WITH (appendonly=true, orientation=column) <== WITH allows setting storage options, appendonly : create a table as an append-
  optimized table instead of regular heap-storage table, orientation: only valid if appendonly option used, column oriented storage
  distributed by (UniqueCarrier, FlightNum) 
  PARTITION BY RANGE(FlightDate) <== enables supporting very large tables by logically dividing them into smaller more manageable
  pieces, partitioning can improve performance by allowing query only needed data... doesn't change physical distribution
  ( 
  PARTITION mth START('2009-06-01'::date) END ('2010-10-31'::date) EVERY('1 mon'::interval)
  );
  )
  
  **http://gpdb.docs.pivotal.io/4380/admin_guide/ddl/ddl-storage.html <== choosing orientation guidelines
  **http://gpdb.docs.pivotal.io/4350/admin_guide/ddl/ddl-partition.html <== partitioning guidelines
 
  load_into_fact_table script:
  insert into faa.otp_r select l.Flt_year, l.Flt_Quarter, l.Flt_Month, l.Flt_DayofMonth,
  ... l.DepDelay::float8, -- cast from numeric
  l.DepartureDelayGroups::smallint,
  l.TaxiOut::integer,
  l.WheelsOff,
  coalesce(l.CarrierDelay::smallint, 0),
  coalesce(l.WeatherDelay::smallint, 0), <== cast to smallint, if it's NULL then place a 0 there
  from faa.faa_otp_load l; <== l like an alias for that load table
  
  insert into faa.otp_c select * from faa.otp_r; <== copy into _r without all of the formatting in _c table
  
Data Loading Summary: 
ELT allows load processes to make use of massive parallelissm ... set-based operations can be done in parallel
COPY loads using single process
external tables provide a means of leveraging the parallel processing power of segments <== also allows us to access multiple
data sources with one SELECT of an external table




<a id ="tuning"></a>
5. Queries and Performance Tuning:
useful for writing and tuning queries

master receives, parses and optimizes queries resulting query is either parallel or targeted.
master then dispatches query plans to all segments... each segment is responsible for executing local database operations on its
own set of data...

most database operations - execute across all segments in parallel, performed on a segment database independent of the data
stored in the other segment databases...

[*****add image****]

*query plan: set of operations GP db will perform to produce the answer to a query; executed bottom up
*motion operation: involves moving tuples between the segments during query processing; describes when and how data should be 
transferred between nodes during query execution. (3 types: broadcast: every seg target data to all other; redistribute: every seg
rehashes and distributes to every seg gather: every segment to a single node)
*slice: portion of plan that segments can work on independently; sliced wherever motion operation occurs

Understanding Parallel Query Execution:
 Processes:
 query dispatcher (QD): on master, process responsible for creating and dispatching the query plan
 - also accumulates and presents the final result
 query executor (QE): on segment, process responsible for completing its portion of work and communicating its intermediate results
 to the other worker processes
 
 at least one worker process assigned to each slice of the query plan:: each works on assigned portion of query plan independently
 GANGS: <== related processes working on same slice but different segments
 as portion of work is completed, tuples flow up the query plan from one gang of processes to the next
 IPC btwn segments is referred t as interconnect component of the GP db

*more info on query plan: http://gpdb.docs.pivotal.io/4330/admin_guide/parallel_proc.html
understanding parallel query execution: 


Please see EXERCISES.md to complete some exercises for part V.



*most important time it with data, and see how to interface it with python... what do I call greenplum? or postgre from python??
