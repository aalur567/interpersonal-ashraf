clear
set more off
set matsize 800

*install ado files

capture ssc install xml_tab
capture ssc install reghdfe
capture ssc install ftools
capture ssc install estout
capture ssc install lassopack

*cd into your main directory
cd "/Users/anitaalur/Desktop/"

cd "ashraf_replication_files"


do "dofiles/new_table_1.do"
do "dofiles/new_table_3.do"
do "dofiles/new_table_4.do"
do "dofiles/new_table_5.do"
do "dofiles/new_table_6.do"
do "dofiles/new_table_7.do"
do "dofiles/new_table_8.do"

*Open tables using Microsoft Excel
