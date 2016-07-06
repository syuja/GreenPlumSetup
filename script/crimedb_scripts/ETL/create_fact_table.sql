CREATE TABLE crimes_schema.f_crimes(
ID int4,
Case_Num text,
Date timestamp without time zone,
Block text,
IUCR text,
Primary_Type text,
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
Updated_On timestamp without time zone,
Latitude float8,
Longitude float8)
distributed by (ID);
