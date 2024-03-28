use "finaldata\GN_data.dta", clear

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth 
		 


gen neg_info=negotiation*treatment_info
gen ss_info=treatment_info*safespace



foreach var in `controls' {
	drop if `var'==.
	}



xtset classid
local se cluster(classid)
	
local count=1
foreach out in enrolled3 enrolled4 enrolled5 morning10 morning11 alt_human_capital { 


	xi: lasso2 `out' `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2,  lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & `out'!=., adaptive postresults fe 
	lasso2,  lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

		
		
	xi: reghdfe `out' negotiation  safespace   treatment_info   `first' `second'   if treatment_actual!=0  ,  `se' absorb(classid)
	est store reg`count'
		
	test negotiation = treatment_info
	estadd scalar testp=r(p)
	
	sum `out' if treatment_actual==1, d
	estadd scalar mean=r(mean)
	
	xi: reghdfe `out' negotiation  safespace   treatment_info   live_with_bio_dad live_with_mom_dad ///
		read_nyanja_excel read_english_excel bl_age read_nyanja_well read_english_well ///
		speak_english_well speak_english_excel nsenga other if treatment_actual!=0  ,  `se' absorb(classid)

	local count=`count'+1

	}

local count=1
foreach out in enrolled3 enrolled4 enrolled5 morning10 morning11 alt_human_capital { 


	xi: lasso2 `out' `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & `out'!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
	xi: reghdfe `out' negotiation   safespace  treatment_info neg_info   `first' `second' if treatment_actual!=0  ,  `se' absorb(classid)
	est store oth`count'
		
	test negotiation = treatment_info
	estadd scalar testp=r(p)

	sum `out' if treatment_actual==1, d
	estadd scalar mean=r(mean)

	local count=`count'+1

	}
	

xml_tab reg1 oth1 reg2 oth2 reg3 oth3 reg4 oth4 reg5 oth5 reg6 oth6, save("tables/table_A8.xml") replace below stats(  testp mean N r2_a) ///
	keep(negotiation  treatment_info neg_info  safespace  ) note("All regressions include school FE and controls from the baseline for both parents alive, lives with biological dad, lives with biological mom, lives with mom and dad, parents pay fees, reads and writes Nyanga and English excellently, age, and ethnicity FE.") ///
	cnames("9th Grade Enrollment" "9th Grade Enrollment" "10th Grade" "10th Grade" "11th Grade" "11th Grade" ///
	"Morning 10" "Morning 10" "Morning 11" "Morning 11" "Human Capital Index" "Human Capital Index")
