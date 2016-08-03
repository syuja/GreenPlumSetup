import subprocess
import os
import csv
from pg import DB


#CONNECTION INFORMATION
username = "root" + "@"
ip = "10.1.8.4" + ":"
fname = "/mnt2/h1/eng-all/1/googlebooks-eng-all-1gram-20090715-1.csv.zip"

#GET LOCAL FILENAME
p_aux = subprocess.Popen(["basename", fname], stdout=subprocess.PIPE)
l_fname = p_aux.communicate()[0].strip()
print "l_fname after running dirname= %s" % l_fname

#REMOVE .zip extension
p_aux = subprocess.Popen(["basename", fname, ".zip"], stdout=subprocess.PIPE)
lf_name_e = p_aux.communicate()[0].strip()
print "without extension= %s" % lf_name_e

#RSYNC PREP
remote_dir= "'" + username + "@" + ip + ":" + fname
print "remote_dir = %s" % remote_dir
local_dir = "/home/data_loader"


#GET THE FILE
p = subprocess.Popen(['rsync', '-avzuP', username + ip + fname, l_fname])

sts = os.waitpid(p.pid, 0)

#UNZIP THE FILE
p = subprocess.Popen(['unzip', l_fname])
sts = os.waitpid(p.pid, 0)

#READ CSV AND INSERT INTO INTERNAL TABLE
f = open(lf_name_e, 'r')
reader = csv.reader(f, delimiter='\t')
db = DB(dbname="ngram" ,user="data_loader" , port=5432)

for row in reader:
	print row
	#db.query <== insert one by one
db.close()
