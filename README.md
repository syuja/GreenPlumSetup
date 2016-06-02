![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
# Table of Contents
  1. [What is Greenplum (GP)?] (#gp)  
    a. [Basic Structure] (#struct)
  2. [Installation] (#inst)  
    a. [Helpful Tips] (#help)
  3. 

<a id="gp"></a>
## What is Greenplum (GP)?

  It's massively parallel processing (MPP) database server built on open source PostgreSQL.
  - Essentially several PostgreSQL db instances acting together as one cohesive DBMS. 
    - Greenplum supplements PostgreSQL (PSQL) to support parallel structure of: 
    parallel data loading using external tables, query optimizations, etc.  

<a id="struct"></a>
### Basic Structure
  - Master: entry point
  - Segments: 2 or more processors that carry out an operation, each with its own resources
  - Interconnect:  
  - Pivotal Query Optimizer:  
  
![architecture] (https://github.com/syuja/GreenPlumSetup/blob/master/img/architecture.png)
   
 add image

  Master is entry point where users connect and submit SQL queries. It coordinates other db instances called segments which store
  and process data
    
    
Ideal:distributed evenly so start and finish at the same time
<a id="inst"></a>
## Installation
Images of how to download
untar then opening it
initial look 
<a id="help"> </a>
### Helpful Tips
Helpful: Ownership of keyboard and mouse ==> special key right cmd
Global setting ==> right control ^ <== 
helpful left control and arrows to move from full screen and out!!
https://www.virtualbox.org/manual/ch01.html <== captured

the image provided by greenplum will require that you install yum
sudo yum install git-all

to see version type :
cat /proc/version


##############################
Steps Provided: *like Toc provide links!
1. Setup create username ==> don't want to stay in sudo
2. Create and Prepare Database
3. Create Tables
4. Data Loading
5. Queries and Performance Tuning
6. intro to Greenplum In-Db analytics
7. backup and recovery

1. **run start script!!!** ./start_all.sh <== otherwise will not be able to follow the steps
WHAT IS TEMPLATE 1? <== psql??

CREATE USER -P: 
create user creates a new PostgreSQL user/role (wrapper around CREATE ROLE)
-P flag will issue a prompt for the password of the new user

psql: command-line client to connect to PostgreSQL server. PostgreSQL interactive terminal. Can be used to type queries interactively.

\du:
get a list of roles. 

\q: quit PostgreSQL command prompt

psql -l: list all available databases (postgres: holds system wide info, template0 pristine template holds core postgres stuff,
template1 default template for new db can be changed)

CREATE USER user2 WITH PASSWORD 'pivotal' NOSUPERUSER: alias for create role 
CREATE ROLE users: role is an entity that can own database objects and have database privilege (can be "user" or  a "group")
GRANT users TO user1, user2 : defines access privileges; conveys the privileges granted to a role to each of its members

\q exits ==> exits the psql shell...

dropuser <user_name>; : drops user... inside the user is in semicolon is important!!
DROP ROLE <user or group>; :drops user...  

2. Create a database and prepare it
createdb: wrapper for CREATE DATABASE command
dropdb: wrapper for DROP DATABASE
psql -l list all databases
psql -U user1 tutorial: connects as user1 to tutorial db

B) GRANT PRIVILEGES TO USERS:
grant users the minimum permissions required to do their work...
- connect as admin
- grant privileges

C) SCHEMA: container for a set of database objects (tables, data types, functions).
namespace; suppose 1 db used for many applications, so may need multiple schemas.
access objects by prefixing with schema... <schema>.table_person... employee.person or customer.person

DROP SCHEMA IF EXISTS faa CASCADE; : cascade automatically drops objects (table, functions) that are contained in the schema...

db contains schema search path.. starts with user, public..
SET SEARCH_PATH TO faa, public, pg_catalog, gp_toolkit; <== not permanent if log out will have to back in
#not persistent ==> associate search path with user role, so that each time connect the search path is restored

ALTER ROLE user1 SET search_path TO faa, public, pg_catalog, gp_toolkit;**important every time I log out and into database**





3. Create Tables==> Important: definition of table includes distribution policy of the data, and distribution policy will affect performance
Goals: - distribute volume of data and query execution work evenly among segments AND
      - enable segments to accomplish the most expensive query process steps locally...
- for joins, use DISTRIBUTED BY (column,...) faster to join columns on different segments than it is to join rows on different segments



\h ==> shows available postgresql commands
\dt *; for all schemas
\dt or \d show only visible tables in search_path (may need to add things to search path)
\? <== to see all available commands...

running a script that creates tables
sign in to db
psql -U user1 tutorial
tutorial=# \i create_dim_tables.sql
tutorial# \dt ==> shows all tables created (make sure **search_path** is set) reference to setting search path



4. Data Loading
- INSERT is slowest, but simplest
- COPY can specify the format of external text file to parse BUT not parallel
- Greenplum utilities: gpfdist and gpload using external data tables at
HIGH DATA TRANSFER RATES, parallel data loading... 
-gpload runs a load task that you specify in a YAML-formatted control file... allows you to describe a complex task and execute it in
a controlled, repeatable fashion..

\i <== run sql scripts to COPY from csv-formatted text files
\d d_cancellation_codes <== will show description of the table

###SLOWEST BUT SIMPLEST
INSERT INTO faa.d_cancellation_codes
VALUES('A','Carrier'),('B','Weather'),('C','NAS')...

SELECT * FROM faa.d_cancellation_codes <== to see inside table

###COPY STATEMENT:
\COPY faa.d_airlines FROM 'L_AIRLINE_ID.csv' CSV HEADER LOG ERRORS INTO faa.faa_load_errors KEEP SEGMENT REJECT LIMIT 50 ROWS;
==> \COPY <table_name> FROM 'file_name' CSV(comma-separated mode) HEADER(file contains a header line with the names of each column)
LOG ERRORS INTO(optional clause precedes reject, specifies error table where rows with formatting errors will be logged when 
running in single row error isolation mode; if dne will be generated) <error_table> KEEP(error table not dropped even if no errors)
REJECT LIMIT 50 ROWS (allows you to isolate format errors in external table data and to continue loading correctly formatted rows.
if limit exceeded then entire external table operation is aborted);

setting REJECT LIMIT 50 ROWS allows greenplum to scan external data in single row error isolation mode--> applist to external data rows

http://gpdb.docs.pivotal.io/4320/ref_guide/sql_commands/COPY.html

### Load Data with Greenplum utilities:
#### gpdist: guarantees maximum parallelism while reading from or writing to external tables
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
