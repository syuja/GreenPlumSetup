![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### Command for Viewing the Dataset:
The following commands are intended to help the user view the dataset without having to open it. (Opening will attempt 
to load the entire dataset onto memory).  

**Cut**: cuts out the selected portions of each line of a file.  
`-c` flag specifies the character position to cut out  

      cut -c1 <name_of_dataset>
  
`sort -n` will sort it numerically. Then, `uniq` will filter out repeated lines in a file. The `-c` will count the number  
of times the line occurs.  

      cut -c1  Crimes_-_2001_to_present.csv | sort -n | uniq -c

`f1` specifies to print the first fiel (column) and `-d,` specifies the delimiter:   

      cut -f1 -d, Crimes_-_2001_to_present.csv

`head` prints the first few lines of the file:  

      head Crimes_-_2001_to_present.csv
