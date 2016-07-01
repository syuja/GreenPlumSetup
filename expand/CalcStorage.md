![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)
<a id='top'></a>

### Estimating Storage Capacity:  
This module will help you determine how much data your Greenplum database can hold, **total storage capacity**.    

We will first obtain **usable disk space** and use it to calculate the *total storage capacity**.  

    total_storage_capacity = usable_disk_space x num_seg_hosts  
    usable_disk_space = usable_disk_space - 1/3 (usable_disk_space) 
    # 1/3 reserved as working area for active queries  

Usable disk space is obtained by removing formatting overheads and by running at 70% capacity (optimal performance).  

    usable_disk_space = formatted_disk_space * .70  
    # 70% capacity provides optimal performance  
    formatted_disk_space = (raw_cap * 0.9)  
    #assuming 10% formatting overhead and RAID-10  
  

The **total storage capacity** is greater than what is available to the user.  
Next, we will subtract additional overheads from **total storage capacity** space to obtain user space.  
**User space** is the amount of memory available for holding data (total storage capacity - overheads).  

### User Data Available:  
Data will be larger when loaded into the Greenplum database.  
Approximately, **1.4** times larger due to:  
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
Allocate enough space for the database in order to provide queries enough working area.  
Determine the total storage capacity and divide by 1.4 to determine the largest dataset your Greenplum database  
can store.  


### Example:  
Running `df -h` shows formatted disk space for one segment.  

    /dev/vdb        158G  3.3G  147G   3% /mnt

Plug that into:  

    #usable_disk_space = formatted_disk_space * .70  
    usable_disk_space = 158 GB * .70  ~ 111 GB  

Use the next formula:  

    #usable_disk_space = usable_disk_space - 1/3 (usable_disk_space)  
    usable_disk_space = 111  - 1/3 (111) = 74 GB per segment  

Finally, multiply by the number of segments (5 in our case):  

    #total_storage_capacity = usable_disk_space x num_seg_hosts  
    total_storage_capacity = 74 x 5 = 370 GB  

Now, we determine the largest data set our Greenplum database can hold:  

    largest_data_set = 370 GB / 1.4 = 264 GB  

Keep in mind that the log files and database will grow thereby reduce the working space available for active queries.  


<sub><sup> References: http://gpdb.docs.pivotal.io/4360/install_guide/capacity_planning.html </sub></sup>  
[Top](#top)   
