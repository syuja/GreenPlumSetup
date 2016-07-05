![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>
#### Table of Contents:  
  1. [What is Greenplum Database (GP)?] (#gp)  
    a. [Basic Structure] (#struct)  
    b. [OLTP vs .OLAP] (#oltp)  
  2. [Installation] (#inst)  
    a. [Helpful Tips] (#help)
  3. [**Data Distribution**] (#data)  
    a. [Orientation] (#ori)  
    b. [Partitioning] (#part)  
    c. [Loading with gpfidst] (#gpf)  
  4. [Tutorial] (#tut)  
  5. [Exercises] (EXERCISES.md)



<a id="gp"></a>
## What is Greenplum (GP)?
  Greenplum Database is a massively parallel processing (MPP) share-nothing database built on PostgreSQL (PSQL).  
  - Consists of master node and segment nodes  
    - master node contains catalog information
    - all of the data is stored in the segment nodes  
  - Essentially several PostgreSQL database instances acting together as one cohesive DBMS. 
    - PSQL is supplemented to support parallel structure of: 
    parallel data loading using external tables, query optimizations, etc.  

<a id="struct"></a>
### Basic Structure
  - **Master node**: entry point where users connect and submit SQL queries. Creates query plan and distributes work to segments. Coordinates segments which store and process data. 
  - **Segments**: 2 or more processors that carry out an operation, each with its own resources. PSQL instances containing distinct data.  
  - **Interconnect**: networking layer and infrastructure for inter-process communication. (uses UDP and Greenplum version of TCP) 
  - **Pivotal Query Optimizer**: produces a query plan, and is contained within the master. Master dispatches the query plan to segments.  
  - **Query Plan**: is the set of operations Greenplum Database will perform to produce the result-set.  
<p align = "center">
![architecture] (https://github.com/syuja/GreenPlumSetup/blob/master/img/architecture.png)
  </p>  
`Dispatching Parallel Query Plan`
<p align = "center">
![dispatching] (https://github.com/syuja/GreenPlumSetup/blob/master/img/parallel_plan.png)
  </p>


<sub><sup> Ideally, data is distributed evenly, so that the segments start and finish at the same time.</sup></sub>


<a id="oltp"></a>
### OLTP vs OLAP 
OLTP (On-line Transaction Processing): characterized by a large number of short on-line transactions (INSERT, UPDATE, DELETE). Main
emphasis is put on very fast query processing and effectiveness is measured by number of transactions per second (throughput).

OLAP (On-line Analytical Processing): characterized by relatively low volume of transactions. Queries are often very complex and
involve aggregations. Response time is effectiveness measure. 


         | OLTP    | OLAP    |
---------|---------|---------|
Source of Data:| Operational data. OLTPs | Consolidation of various OLTPs| 
Purpose of Data:| Day to day information | Data analysis |
Data is:| Snapshot of ongoing state | Multi-dimensional view |  
 
**Relevance**: Data used for OLAP transactions should be stored in column-oriented tables instead of row-oriented tables. Queries will have better performance. 

<a id="inst"></a>  
## [Installation] (docs/INSTALLATION.md) 
<a id="help"> </a>  
  - [Helpful Tips] (docs/INSTALLATION.md)  
  
<a id="data"></a>
## Data Distribution  
In order to exploit the maximum parallelism possible, it is important to know a few basic details about how data is stored in
Greenplum. Minor modifications to several parameters can result in great speedups.  

<a id="ori"></a>
### Orientation 
---  
Greenplum allows storing tables as separate columns in different segments (instead of a subset of rows of a table in each segment).  
Column-oriented storage is good when users query few columns, for compressing data (easier to compress same data type), and regular updates that modify single columns.  

For more information see [Tutorial](TUTORIAL.md).  

<a id="part"></a>
### Partitioning 
---  
Partitioned tables can improve query performance by allowing the query optimizer to scan only the needed data.  
Partitioning is logical (not physical). Tables are paritioned during `CREATE TABLE` using the `PARTITION BY` clause.  

Greenplum Database supports partitioning by range, by list and by a combination of both. It is generally a good idea to partition if the table is very large and the WHERE clauses search by range or list values. For example, if most queries tend to look up records
by date.  


    -- Example  
    CREATE TABLE sales (trans_id int, date date, amount decimal(9,2), region text)  
    DISTRIBUTED BY (trans_id) -- uses trans_id column for hashing into different segments  
    PARTITION BY RANGE (date)  -- * PARTITION
    SUBPARTITION BY LIST (region)  
    SUBPARTITION TEMPLATE  
    (SUBPARTITION usa VALUES ('usa'),  
    SUBPARTITION asia VALUES ('asia'),  
    SUBPARTITION europe VALUES ('europe')  
    DEFAULT SUBPARTITION other_regions)  
    (START (date '2011-01-01)))  INCLUSIVE  
    END (date '2012-01-01') EXCLUSIVE  
    EVERY (INTERVAL '1 month'),  
    DEFAULT PARTITION outlying_dates);  
      
  
  Tables can only be partitioned at creation.  <br>
  </br>
  
  <p align="center"> ![partition] (https://github.com/syuja/GreenPlumSetup/blob/master/img/partition.png)</p>

<sub><sup>Table scans and maintenance jobs will run more slowly the more the table is partitioned. However, queries will
run faster if the **query optimizer can eliminate partitions based on query predicates**.</sub></sup>

<a id="gpf"></a>
### gpfidst 
---
Simply using INSERT or COPY will **not** read or write data in **parallel**. 

Steps for reading in parallel:
  
  
_**Host (serves data to be read into Greenplum)**_:  
  1. Copy the gpfdist utility to hosts that contain the external tables (the data that you want to read).  
  2. Add gpfdist to the $PATH of the hosts.   
  3. Start gpfdist by specifying directory containing the data and the port to serve the data: 
  
    `gpfdist -d ~/home/directory/ -p 8081 > /tmp/stdout/goes/here 2>&1 &  `


_**Greenplum Database machine**_:  
  1. Create local load table to copy external data into.  
  2. Create **external table** indicating the protocol as gpfdist and the port number the host uses to serve.  
  

    `CREATE EXTERNAL TABLE faa.ext_load_otp  `  
    `(LIKE faa.faa_otp_load) -- copy columns from faa.faa_otp_load  (LOAD table)`  
    `LOCATION ('gpfdist://localhost:8081/otp*.gz') -- INDICATE WHERE DATA IS LOCATED important: gpfdist is the protocol `  
    `FORMAT 'csv' (header)  `  
    `LOG ERRORS INTO faa.faa_load_errors SEGMENT REJECT LIMIT 50000 rows; -- log errors into error table, and  `  
    `--cease operation if greater than 50,000 errors `  

Now, when you use SELECT from external tables, gpfdist will serve files evenly to all segments. 

  <p align="center"> ![gpfdist] (https://github.com/syuja/GreenPlumSetup/blob/master/img/gpfdist_figure.png)</p>

**Note**: gpfload is a wrapper for gpfdist. Specify a task in a YAML control file, and gpload runs gpfdist using the configuration
set in the control file.  

<a id="tut"></a>
## [Tutorial] (TUTORIAL.md)  

See [Exercises](EXERCISES.md) to complete some exercises.  
[Top](#top)  
