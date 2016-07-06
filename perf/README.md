![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>  

#### Performance Table of Contents:  
  1. [Crimes Database] (#cdb)  
  2. [N-gram] (#ng)  
  3. [Protein] (#prot)   
  
#### Crimes Database:  
For performance results of the crimes database, please view [perf_crimes_db.xlsx](perf_crimes_db.xlsx).  

Five instances were used to create the Greenplum database.   
Each instance was of type `i2.large.sd` on OpenStack/Magellan.  

One instance is the Master, and four instances were hosts.  
The ephemeral drive, `vdb`, was mounted to `/mnt` folder.   
Device `vdb` held all of the data for the database.  
Each segment has data located in `/mnt/data/primary`.  
The Master had metadate in `/mnt/data/master` and database content in `/mnt/data/primary`.  

No mirrors were set up.  

The measurements were taken with the **optimizer** off, since it could not be turned on.    

    gpconfig -c optimizer_analyze_root_partition -v on --masteronly #resulted in error  


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

A **key** is provided indicating the name of each table in the database.  
Finally, the increase in size is noted.   



#### N-gram:   


#### Protein:  










[Top](#top) 
