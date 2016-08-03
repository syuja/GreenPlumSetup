
import csv
from pg import DB

'''Inserts from external table into load tables:
	does this row by row using python to modify the data
	before inserting it
''' 



f = open('googlebooks-chi-sim-all-1gram-20090715-1.csv' ,'rb')
#INSERT INTO p_chi_1 (columns) VALUES (id, row[0],.... );
tb_name = "p_chi_1"

sqlp1 = "INSERT INTO"
sqlp2 = "(id, ngram, year, match_count, page_count, volume_count) VALUES"

#global db object then call query

#reads a line, splits and returns it
def read_line():
	i = 0 
	reader = csv.reader(f, delimiter='\t')
	db = DB(dbname="ngram" ,user="data_loader" , port=5432)
	for row in reader: 
		#ngram, year, match_count, page_count, volume_count
		sql = sqlp1 + " " + tb_name + " " + sqlp2 + "  (" + str(i) + ", " \
		+  "\'" + row[0] + "\'" + ", " + row[1] + ", " + row[2] + ", " + row[3] \
		+ ", " +  row[4] + ");"; 
		print sql
		i = i + 1
		#call insert(sql)
		db.query(sql)	
		db.close()	
	
#insert into appropriate db
def insert_fxn( sql ):
	pass
	
#call over all of the files
def loop():
	pass

read_line()


