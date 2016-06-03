![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

## Exercises  

## spell check!!*****

#### [Back to README.md](../README.md)
#### [Go to ANALYTICS.md](./ANALYTICS.md)

### Table of Contents
  1. [VACUUM and ANALYZE](#vac)
  2. [Explain Plans](#expl)
  3. [Indexes and Performance](#ind)
  4. [Rows vs. Column Orientation](#row)  
     a. [Choosing Row or Column Orientation] (#choose)
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

```
psql -U gpadmin tutorial  
-- for every table, or can run ANALYZE on individual tables  
tutorial=# ANALYZE faa.d_airports;  
ANALYZE  
tutorial=# ANALYZE faa.d_airlines;  
ANALYZE
```
  
Summary: Vacuum removes old rows to free up space. Analyze generates statistics that are used by the query optimizer. Run both
after major changes have been made to the table.
  
<a id="expl"></a>
#### Explain Plans  

<a id="ind"></a>
#### Indexes and Performance 
Segments execute table scans in parallel, each segment **scanning a small segment** of the table, 
the traditional performance advantage from indexes is diminished.  
Indexes consume large amounts of space and require considerable CPU time to compute during loads.  

_Exception:_ Indexes are useful for highly selective queries. For example, query looks up a single
row, an index can dramatically improve performance. (197 ms vs 29 ms).  
    
    tutorial=# SELECT * from sample WHERE big = 12345;
    Time: 197.640 ms
    tutorial=# EXPLAIN SELECT * from sample WHERE big = 12345;
    QUERY PLAN
    ...  
   Time: 19.719 ms  
    

Create index and run it again:  
    
    tutorial=# CREATE INDEX sample_big_index ON sample(big);
    CREATE INDEX
    Time: 1106.47 ms  
    
    tutorial=# EXPLAIN SELECT * FROM sample WHERE big = 12345;
    QUERY PLAN
    ...
    Time: 23.674
    
    --actual run
    tutorial=# SELECT * FROM sample WHERE big=12345;
    Time: 29.421 ms  
    

_Notice the difference in timing: 197 ms vs 29 ms. The difference is more pronounce for larger
tables._


<a id="row"></a>
#### Rows vs. Column Orientation  
Both storage options have advantages, depending upon data compression characteristics, 
the kinds of queries, row length, and complexity and number of joins.  
Generally, very wide tables are better in row orientation. Column orientation saves space with
compression and to reduce I/O when there is duplicated data on column.  
    please see previous tutorial for orientation creation  
    to check size:
    tutorial=# SELECT pg_size_pretty(pg_relation_size('faa.otp_r'));
    tutorial=# SELECT pg_size_pretty(pg_relation_size('faa.otp_c'));

_Colum-oriented is append-only and partitioned._  

<a id="choose"></a>
#### Choosing Row or Column Orientation<sup> 2 <sup>


more info available at : http://gpdb.docs.pivotal.io/4380/admin_guide/ddl/ddl-storage.html#topic39


<a id="even"></a>
#### Even Data Distribution  
**Check for even data distribution on segments.**  

The tables are distributed with a hash function on UniqueCarrier and FlightNum. These columns 
were selected because they produces even distribution of data onto segments. Also, frequent joins
are expected on these two columns. Try to distribute based on a unique column, since this 
ensures an even distribution. Low cardinality columns will yield poor distribution.  

One goal is to ensure approximately same amount of data in each segment.  
    tutorial=# SELECT gp_segment_id, COUNT(*) FROM faa.otp_c GROUP BY
    gp_segment_id ORDER BY gp_segment_id;


<a id="part"></a>
#### Partitioning  
Partitioning tables can improve query performnace by allowing the query optimizer to scan only
the needed data to satisfy the query. Paritioning is logical not physical, and the table is divided
into smaller child files.  

Why does it increase performance? When a query filters on same criteria used to define partitions, the 
optimizer can avoid searching irrelevant partitions.  

Two types:  
  A. range partitioning: division based on range, such as date or price  
  B. list partitioning: based on a list of values, such as territory or product line  
  C. combination of both types  
  
  <p align = "center">
![partition] (https://github.com/syuja/GreenPlumSetup/blob/master/img/partition.png)
  </p>

Partitioning occurs during CREATE TABLE PARTITION BY. When a new partition is added, run ANALYZE
again. Can either run ANALYZE on root partition or simply the new partition.  

    
    tutorial=#\timing on
    tutorial=# SELECT MAX(depdelay) FROM faa.otp_c WHERE UniqueCarrier='UA';
    --not partitioned by unique carrier
    Time: 641.574 ms
    
    tutorial=# SELECT MAX(depdelay) FROM faa.otp_c WHERE flightdate='2009-11-01';
    Time: 30.658 ms
      

The query on the partitioned column(flightdate) takes much less time. First scan, scans all
17 children, while the second one just scans one child file.  

more info on [partitions] (http://gpdb.docs.pivotal.io/4350/admin_guide/ddl/ddl-partition.html)  


#### [ANALYTICS.md](./ANALYTICS.md)
---
<sup id="fn1"><a href="#ref1" title="jump back">1:For isolation, there is a tradeoff between concurrency and concurrency effect(dirty reads, lost updates). More isolation results in
less concurrency and less concurrency effects.</a></sup> 
  
  
