![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>  

#### Performance Table of Contents:  
  1. [Crimes Database] (#cdb)  
  2. [N-gram] (#ng)  
  3. [Protein] (#prot)   
  
#### Crimes Database:  
For performance results of the crimes database, please view [perf_crimes_db.xlsx](perf_crimes_db.xlsx).  

We used 5 instances to create the Greenplum database. Each instance was an 'i2.large.sd'.  
The ephemeral drive ,`vdb`, of each instance held the data, the Master's data was also placed on `vdb`.    
The Master also held database data in the `/mnt/primary/data` file.    

Optimizer was off, since it could not be turned on.  

The Greenplum timing utility was used to obtain all of the timing information.   

Five tables were tested.   

|Table                 |Distributed by : | Orientation | Partitioned | Subpartitioned  |
| ----------------- | ----- |----- |----- |----- |
|Default Dist by ID: | ID | Row | False | False | 
|Row Part by Date: | ID | Row | Date | False | 
|Row Part and Sub by Arrest: | ID | Row | Date | Arrest | 
|Col Part by Date: | ID | Col | Date | False | 
|Col Part and Sub by Arrest: | ID | Col | Date | Arrest | 

The **`psql` command** used to test them are listed under the column `Full_Operation`.  
The **`psql` scripts** can all be found in the [scripts](../script) module.   

A **key** is provided indicating the name of the table in the database.  
Finally, the increase in size is noted.  





#### N-gram:   


#### Protein:  










[Top](#top) 
