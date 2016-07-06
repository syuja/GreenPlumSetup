CREATE EXTERNAL TABLE crimes_schema.ext_load_crimes(
ID int4,
Case_Num text,
Date timestamp without time zone,
Block text,
IUCR text,
Primary_Type text,
Description text,
Location_Desc text, 
Arrest bool,
Domestic bool,
Beat int4,
District int4,
Ward int4,
Community_Area int4,
FBI_Code text,
X_Coord int4,
Y_Coord int4,
Year int4,
Updated_On timestamp without time zone,
Latitude float8,
Longitude float8,
Location text)
LOCATION ('gpfdist://10.1.8.4:8081/Crimes*.csv')
FORMAT 'csv' (header)
LOG ERRORS INTO crimes_schema.ext_load_errors SEGMENT REJECT LIMIT 500 rows;
