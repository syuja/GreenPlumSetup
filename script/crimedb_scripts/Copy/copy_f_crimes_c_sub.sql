CREATE TABLE jf_crimes_c_sub (LIKE f_crimes_c_sub)
WITH (appendonly=true, orientation=column)
DISTRIBUTED BY (ID)
PARTITION BY RANGE(DATE)
SUBPARTITION BY LIST(arrest)
SUBPARTITION TEMPLATE
(
	SUBPARTITION arrest VALUES('t'),
	SUBPARTITION no_arrest VALUES('f')
)
(	PARTITION Jan01 START (timestamp without time zone '2001-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan02 START (timestamp without time zone '2002-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan03 START (timestamp without time zone '2003-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan04 START (timestamp without time zone '2004-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan05 START (timestamp without time zone '2005-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan06 START (timestamp without time zone '2006-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan07 START (timestamp without time zone '2007-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan08 START (timestamp without time zone '2008-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan09 START (timestamp without time zone '2009-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan10 START (timestamp without time zone '2010-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan11 START (timestamp without time zone '2011-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan12 START (timestamp without time zone '2012-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan13 START (timestamp without time zone '2013-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan14 START (timestamp without time zone '2014-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan15 START (timestamp without time zone '2015-01-01 00:00:00') INCLUSIVE, 
	PARTITION Jan16 START (timestamp without time zone '2016-01-01 00:00:00') INCLUSIVE 
	END (timestamp without time zone '2016-05-31 23:59:00') INCLUSIVE );
