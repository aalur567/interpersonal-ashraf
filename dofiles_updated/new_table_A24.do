
*boys in edstats DD


use "finaldata/EdAssist2001_2016PanelFull.dta" , clear
gen post=0
replace post=1 if year>=2014
drop if year>2014


gen intervention=0
replace intervention=1 if GNIntervention==1
gen post_int=post*intervention

xi: areg g9mRate  post_int i.year , absorb(code) cluster(code)
est store grade9
sum g9mRate if e(sample) & intervention==0

keep if year==2012
keep if GNIntervention==1|GNIntervention==2
gen treated_school=0
replace treated_school=1 if GNIntervention==1

local row=1
matrix SUMMARY=J(18 , 3, 0) 
foreach outcome in  g8m_students g8f_students special_ed teachers_total g8fRate  g8mRate total_students ///
	STR m_toiletsLatrines f_toiletsLatrines has_power_gridDum has_protected_wellDum has_telephoneDum ///
	has_unprotected_wellDum     ///
	classrooms_total   g8_regular_hours libbooks { 
		reg `outcome' treated_school, r
		matrix SUMMARY[`row', 1] = _b[treated_school]
		matrix SUMMARY[`row', 2] = _se[treated_school]
		matrix SUMMARY[`row', 3] = e(N)
		local row=`row'+1

		}
		
preserve 
*joint test using aes
tempfile data
save `data', replace


local count=1
foreach outcome in  g8m_students g8f_students special_ed teachers_total g8fRate  g8mRate total_students ///
	STR m_toiletsLatrines f_toiletsLatrines  has_protected_wellDum has_telephoneDum ///
	     ///
	classrooms_total   g8_regular_hours libbooks {
	use `data', clear
		keep `outcome' treated_school school_num
		rename `outcome' out
		sum out if treated_school==0, d
		local sd_`count'=r(sd)
		rename treated_school treated`count'
		tempfile data`count'
		
		gen outnum=`count'
		save `data`count'', replace
		
		local count=`count'+1
		}
		
		
local command "treated1/`sd_1'"

local count=2
foreach outcome in   g8f_students special_ed teachers_total g8fRate  g8mRate total_students ///
	STR m_toiletsLatrines f_toiletsLatrines  has_protected_wellDum has_telephoneDum ///
	     ///
	classrooms_total   g8_regular_hours libbooks {
	
		local command "`command' + treated`count'/`sd_`count''"
	local count=`count'+1
	}
	
	
use `data1', clear
forval x=2/15 { 
	append using `data`x''
	}
	
forval x=1/15 { 
	replace treated`x'=0 if treated`x'==.
	}
	

reg out treated* i.outnum, cluster(school_num)

display "`command'"
lincom 1/15*(`command')

*have to calc p-value by hand
local t=r(estimate)/r(se)
local df=r(df)
local p=ttail(`df', `t')
local p = 2*(1-`p')
display "`p'"
matrix SUMMARY[18,1] = `p'

xml_tab SUMMARY, save("tables/table_A24.xml") sheet("SchoolBalance") replace rnames("Number Male Students" ///
	"Number Female Students" "Special Ed" "Total Teachers" "Female Drop Out Rate" "Male Drop Out Rate" "Total Students" ///
	"STR" "Male Toilets/Students" "Female Toilets/Students" "Has Power" "Has Protected Well" "Has Telephone" ///
	"Has Unprotected Well" "Total Classrooms"  "Regular Hours" "Library Books" "Joint Test") cnames("Coef" "Se" "N")
	
	
