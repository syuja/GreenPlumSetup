![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

### Estimating Storage Capacity:  
This module will help you determine how much data your Greenplum database can hold, **total storage capacity**.   

First, we calculate `formatted_disk_space` and use it to calculate **`usable disk space`**.   

        formatted_disk_space = (raw_cap * 0.9)  
        #assuming 10% formatting overhead and RAID-10   

**Usable disk space** is the amount of space available to the user per segment host.   
Next we calculate, the **usable disk space**:  

        usable_disk_space = formatted_disk_space * .70   
        #running at 70% capacity provides optimal performance   

Next, we save some space in memory for running queries.  

        usable_disk_space = usable_disk_space - 1/3 (usable_disk_space) 
        # 1/3 reserved as working area for active queries 
  

Finally, we can calculate the **total storage capacity** of our system:  

        total_storage_capacity = usable_disk_space * num_seg_hosts 


The **total storage capacity** is greater than what is available to the user.   
There are additional storage overheads that we must subtract from **total storage capacity**.   

**User space** is the amount of memory available for holding data (total storage capacity - overheads).   

### User Data Available:  
The data will occupy more space once loaded onto the database.  
It will occupy approximately **1.4** more than the size of the data set.  
This is due to:  
        A. Page Overhead  
        B. Row Overhead  
        C. Attribute Overhead  
        D. Indexes  

This will reduce the space available to the user.  

Greenplum metadata and logs will consume further space:  
         a. System Metadata (20 MB per segment)  
         b. Write Ahead Log (approximately 1088 MB per segment or master)  
          c. Log files (will grow over time)  
          d. Data collection agents (system performance monitor requires minimum space)  
  
### Summary:  
Allocate enough memory in order to account for formatting, running at 70% capacity, query working area and 
Greenplum overhead.  

To get an estimate of the space needed, start off with the size of the data set. Multiply it by 1.5.  
Then, run this estimate through above calculations until you arrive at the  **total storage capacity** minus  
the overheads. If the resulting size is very close to the size of the database, increase your required size  
and perform the calculations again.    
  
Repeat until the estimated storage size is ~20-30% larger than the dataset.  

If multiple queries to the database occur concurrently, then consider increasing the working area for the queries.  

 


### Example:  
Running `df -h` shows formatted disk space for one segment.  

    /dev/vdb        158G  3.3G  147G   3% /mnt

Plug that into:  

    #usable_disk_space = formatted_disk_space * .70  
    usable_disk_space = 158 GB 8 .70  ~ 111 GB  

Use the next formula:  

    #usable_disk_space = usable_disk_space - 1/3 (usable_disk_space)  
    usable_disk_space = 111  - 1/3 (111) = 74 GB per segment  

Finally, multiply by the number of segments (5 in our case):  

    #total_storage_capacity = usable_disk_space x num_seg_hosts  
    total_storage_capacity = 74 * 5 = 370 GB  

Now, we determine the largest data set our Greenplum database can hold:  

    largest_data_set = 370 GB / 1.4 = 264 GB  

Keep in mind that the log files and database will grow thereby reducing the working space available for active queries.  
This will result in slower queries.  

### Example 2:  
This example demonstrates how we estimated the number of instances required to store   
Google's n-gram dataset version 1.   

We are using `i2.2xlarge.sd`, which contain a 360 GB unformatted ephemeral drive.   

First we calculate `usable_disk_space`:   

        360 * .9 * .7 = 226.8   
        226.8 - (.3*226.8) = 158.76  
        
So our `usable disk space` is 158.76 GB per instance.   

Next, we look at the Google N-gram dataset.    
It's zipped size is 769 GB. Assume that unzipping increases the size by 20%:  

        769 * 1.2  = 922.8 GB #unzipped estimate   
        922.8 * 1.4 = 1292 GB #including GP overhead  
        
How many segments do we need for a total storage capacity of 1292 GB?   

        1292/158.76 = 8.13 # need 8.13 segments   
        
We should use 9 segments, but will attempt to only use 8.   
We will use our `Master` as **both** `Master` and as a `Segment`.   
This will be done by using both `/dev/vda` and `/dev/vdb`;    
one will hold the `Master's` log file and the other will hold database data.   
This will be specified in the `gpinitsystem_config` file.    

Also, we will process the dataset in batches, so we will only `unzip`   
one language at a time while we load it. We will discard the expanded version after   
loading onto Greenplum.  

<sub><sup> References: http://gpdb.docs.pivotal.io/4360/install_guide/capacity_planning.html </sub></sup>  
[Top](#top)   
