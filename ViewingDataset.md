![Greenplum](https://github.com/syuja/GreenPlumSetup/blob/master/img/greenplum-logo.png)  

### Command for Viewing the Dataset:
The following commands are intended to help the user view the dataset without having to open it. (Opening will attempt 
to load the entire dataset onto memory).  

`cut -c1 <name_of_dataset>`

`cut -c1  Crimes_-_2001_to_present.csv | sort -n | uniq -c`

`cut -f1 -d, Crimes_-_2001_to_present.csv`

`head Crimes_-_2001_to_present.csv` 
