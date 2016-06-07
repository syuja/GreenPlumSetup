![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
# Table of Contents
  1. [What is Greenplum Database (GP)?] (#gp)  
    a. [Basic Structure] (#struct)  
    b. [OLTP vs .OLAP] (#oltp)  
  2. [Installation] (#inst)  
    a. [Helpful Tips] (#help)
  3. [Tutorial] (#tut)  
  4. [Exercises] (docs/EXERCISES.md)



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
  - **Master node**: entry point where users connect and submit SQL queries. Creates query plan and distributes work to segments. Coordinate segments which store and process data. 
  - **Segments**: 2 or more processors that carry out an operation, each with its own resources. PSQL instances containing distinct data.  
  - **Interconnect**: networking layer and infrastructure for inter-process communication. (uses UDP and Greenplum version of TCP) 
  - **Pivotal Query Optimizer**: produces a query plan, and is contained within the master. Master dispatches the query plan to segments.  
  - **Query Plan**: is the set of operations Greenplum Database will perform to produce the result-set.  
<p align = "center">
![architecture] (https://github.com/syuja/GreenPlumSetup/blob/master/img/architecture.png)
  </p>  
`Dispatching Parallel Query Plan`
<p align = "center">
![architecture] (https://github.com/syuja/GreenPlumSetup/blob/master/img/parallel_plan.png)
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

<a id="tut"></a>
## [Tutorial] (TUTORIAL.md)  

See [Exercises](../docs/EXERCISES.md) to complete some exercises.  
[Top](#top)  
