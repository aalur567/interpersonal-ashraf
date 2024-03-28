clear
set more off
set matsize 2000

*install ado files

capture ssc install xml_tab
capture ssc install reghdfe
capture ssc install lasso2

*cd into your main directory
cd "C:\Users\nbau\Dropbox\Natalie_GN"

cd "replication_files"


do "dofiles/new_table_1.do"
do "dofiles/new_table_2.do"
do "dofiles/new_table_3.do"
do "dofiles/new_table_4.do"
do "dofiles/new_table_5.do"
do "dofiles/new_table_6.do"
do "dofiles/new_table_7.do"
