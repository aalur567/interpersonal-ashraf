
use "finaldata\GN_data.dta", clear

drop if treatment_actual==0
matrix SAMPLE=J(2,3,0)

count if gamecomm==1 & gamewords==1
matrix SAMPLE[1,1]=r(N)


count if gamecomm==1 & gamewords==0
matrix SAMPLE[2,1]=r(N)


count if gamecomm==0 & gameDG==0 & gamewords==1
matrix SAMPLE[1,2]=r(N)


count if gamecomm==0 & gameDG==0 & gamewords==0
matrix SAMPLE[2,2]=r(N)


count if gameDG==1 & gamewords==1
matrix SAMPLE[1,3]=r(N)


count if gameDG==1 & gamewords==0
matrix SAMPLE[2,3]=r(N)


xml_tab SAMPLE, save("tables/table_A11.xml") replace ///
	cnames("Comm. IG" "No Comm. IG" "DG") ///
	rnames("Word Game" "No Word Game")
