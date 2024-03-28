use "finaldata\GN_data.dta", clear

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		   treatment_info 	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  

local se cluster(classid)

matrix OUTPUT=J(12,7,0)
local count=1
foreach var in enrolled3 enrolled4 enrolled5 morning10 morning11 zero took_nat_exam   above_73_math above_73_eng    avg_att_rate  ever_pregnant  both_parents_alive  { 
	gen M`var'=0
	replace M`var'=1 if `var'==.
	
	xi: reghdfe M`var' negotiation safespace  treatment_info  if treatment_actual!=0  ,  `se' absorb(classid)
	sum M`var' if treatment_actual==1, d
	matrix OUTPUT[`count', 1]=r(mean)
	
	matrix OUTPUT[`count', 2]=_b[negotiation]
	matrix OUTPUT[`count', 3]=_se[negotiation]
	
	matrix OUTPUT[`count', 4]=_b[safespace]
	matrix OUTPUT[`count', 5]=_se[safespace]
	
	matrix OUTPUT[`count', 6]=_b[treatment_info]
	matrix OUTPUT[`count', 7]=_se[treatment_info]
	
	local count=`count'+1
	}
	

	
xml_tab OUTPUT, save("tables/table_A1.xml") replace cnames("Control Mean" "Negotiation Coef." "Se" "Safe Space Coef." "Se" "Info Coef." "Se") sheet("Outcomes")  ///
	rnames("9th Grade Enrollment" "10th Grade Enrollment" "11th Grade" "10th Grade Morning" "11th Grade Morning" "Zero balance" "Took Exam" "Math Score" "English Score" "Average Att. Rate" "Ever Pregnant" "Missing Baseline Data")

