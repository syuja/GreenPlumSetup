![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

## Exercises  

#### [Back to README.md](../README.md)

### Table of Contents
  1. [VACUUM and ANALYZE](#vac)
  2. [Explain Plans](#expl)
  3. [Indexes and Performance](#ind)
  4. [Rows vs. Column Orientation](#row)
  5. [Even Data Distribution](#even)
  6. [Partitioning] (#part)

<a id="vac"></a>
#### VACUUM and ANALYZE
Greenplum uses Multiversion Concurrency Control (MVCC) to guarantee isolation (one of ACID properties of RDBMS).
Isolation<sup><a href="#fn1" id="ref1">1</a></sup> is a property that defines how/whn the changes made by one operation become visible to others.   

MVCC allows users to obtain consistent query results for a query, even if data is changing as the query is beinng executed.
  - query sees snapshot of the database at a single point in time
  
`VACUUM:` removes older versions of rows that are no longer needed, **leaving free space that can be reused**.
  - row is updated or deleted, and no active transactions
  - loading data while tables are in use may produce older versions of rows

`ANALYZE:` command generates statistics about the distribution of data in a table 
  - stores histograms about the values in each of the columns
  - query optimizer depends on these to select best query plan
  
One of the optimizer's goals is to minimize the volume of data that must be analyzed and potentially moved
*good idea to run ANALYZE periodically or after major changes in the contents. Accurate statistics will help the planner to
choose the most appropriate query plan, and thereby improve the speed of query processing.  
    
      psql -U gpadmin tutorial
      -- for every table, or can run ANALYZE on individual tables
      tutorial=# ANALYZE faa.d_airports;
      ANALYZE
      tutorial=# ANALYZE faa.d_airlines;
      ANALYZE
      ...
  
<a id="expl"></a>
#### Explain Plans  

<a id="ind"></a>
#### Indexes and Performance 


<a id="row"></a>
#### Rows vs. Column Orientation  


<a id="even"></a>
#### Even Data Distribution  


<a id="part"></a>
#### Partitioning  




---
<sup id="fn1"><a href="#ref1" title="jump back">1:For isolation, there is a tradeoff between concurrency and concurrency effect(dirty reads, lost updates). More isolation results in
less concurrency and less concurrency effects.</a></sup> 
  
  
