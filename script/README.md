![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

This directory holds all of the `psql` scripts for creating tables, loading tables, and testing the tables.   
To use these, turn timing on and call them interactively from within a database:   

    \timing on  
    \i <script_name>  


Please view [here](../perf/README.md) for performance results.    
Feel free to modify the scripts.  

|Directory                 |Contents           |
| --------------------- | -------------------- |
|[ETL](ETL): | scripts that create External table, Load table, and Fact table |
|[Create](Create):   | create the tables with different partitions and orientations for testing   |
|[Load](Load):   | scripts that copy from the Fact table into the tables created by Create scripts |
|[Copy](Copy):   | creates copies of tables created by Load scripts and copies into them   |
|[InsRec](InsRec):   | scripts for inserting into all of the tables   |
|[Join](Join):   | scripts for joining Load tables with their copies   |
|[UpdRec](UpdRec):   | scripts for updating records based on the values in 1 column   |
|[UpdRec2Cols](UpdRec2Cols):   | scripts for updating records based on the values in 2 columns   |


[Copy](Copy) scripts are used to create copies of the tables created by [Load](Load) in order to be able to join them.   
`JOIN` requires two tables. It's not possible to `JOIN` a table on itself.   

However, it may be a good idea to look into using virtual tables with `JOIN AS` command.   
This would allow joining of a table with it's alias or virtual table.   
Creating more tables expands the size of the database.   

All of these scripts can be timed to measure performance of the database.  





  
  





[Top](#top)
