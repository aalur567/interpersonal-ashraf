use "finaldata/EdAssist2001_2016CrossSec2012", clear

keep if closed!=1

*GN, Lusaka, t-test, all schools, t-test
matrix SUMMARY=J(17 , 11, 0) 

gen treated=0
replace treated=1 if GNIntervention==1

keep if g8t_students !=0
*keep if run_GRZ==1
*has_library_alt cannot include w/o error because all missing post 2011
local row=1

replace m_toiletsLatrines=m_toiletsLatrines/total_students
replace f_toiletsLatrines = f_toiletsLatrines /total_students
replace libbooks=libbooks/total_students

foreach outcome in  g8m_students g8f_students special_ed teachers_total g8fRate  g8mRate total_students ///
	STR m_toiletsLatrines f_toiletsLatrines has_power_gridDum has_protected_wellDum has_telephoneDum ///
	has_unprotected_wellDum     ///
	classrooms_total   g8_regular_hours libbooks { 
		sum `outcome' if GNIntervention==1 &  run_GRZ==1
		matrix SUMMARY[`row', 1] = r(mean)
		matrix SUMMARY[`row', 2] = r(sd)
		
		sum `outcome' if rural==0  &  run_GRZ==1
		matrix SUMMARY[`row', 3] = r(mean)
		matrix SUMMARY[`row', 4] = r(sd)
		
		ttest `outcome' if  (rural==0 | GNIntervention==1) &  run_GRZ==1 , by(treated)
		matrix SUMMARY[`row', 5] = r(p)
		
		sum `outcome' if run_GRZ==1 
		matrix SUMMARY[`row', 6] = r(mean)
		matrix SUMMARY[`row', 7] = r(sd)
		
		ttest `outcome' if  run_GRZ==1  , by(treated)
		matrix SUMMARY[`row', 8] = r(p)
	
		sum `outcome' 
		matrix SUMMARY[`row', 9] = r(mean)
		matrix SUMMARY[`row', 10] = r(sd)
		
		ttest `outcome'  , by(treated)
		matrix SUMMARY[`row', 11] = r(p)
		local row=`row'+1

		}
		
xml_tab SUMMARY, save("tables/table_A2.xml") replace rnames("Number Male Students" ///
	"Number Female Students" "Special Ed" "Total Teachers" "Female Drop Out Rate" "Male Drop Out Rate" "Total Students" ///
	"STR" "Male Toilets/Students" "Female Toilets/Students" "Has Power" "Has Protected Well" "Has Telephone" ///
	"Has Unprotected Well" "Total Classrooms"  "Regular Hours" "Library Books") cnames("Intervention" "SD" "Urban Gov School" "SD" "T-test (P-value)" ///
	"Full Gov Sample" "SD" "T-test (P-value)" "Full Sample" "SD" "T-Test")
	
	
