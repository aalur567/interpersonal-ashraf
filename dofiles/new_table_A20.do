
use "finaldata\GN_data.dta", clear


local tests above_73_eng above_73_math




gen treated=0
replace treated=1 if treatment_actual!=0
replace treated=. if treatment_actual==.


local se cluster(classid)

xtset schoolid

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	
foreach var in `controls' {
	drop if `var'==.
	}


bysort classid: egen num_neg=total(negotiation)
bysort classid: egen class_size=count(negotiation)


	  
	xi: lasso2 enrolled3 `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & enrolled3!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
	  
xi: reghdfe enrolled3 negotiation  safespace num_neg class_size  `first' `second'   if treatment_actual!=0   ,  `se'  absorb(schoolid)
est store reg12

	xi: lasso2 enrolled4 `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & enrolled4!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		


xi: reghdfe enrolled4 negotiation   safespace num_neg class_size   `first'  `second'  if treatment_actual!=0   , `se' absorb(schoolid)
est store reg22
test negotiation=safespace

	xi: lasso2 enrolled5 `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & enrolled5!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe enrolled5 negotiation   safespace num_neg class_size   `first' `second'   if treatment_actual!=0   , `se' absorb(schoolid)
est store reg32
test negotiation=safespace


	xi: lasso2 alt_human_capital `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & alt_human_capital!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe alt_human_capital negotiation   safespace num_neg class_size  `first' `second'   if treatment_actual!=0   , `se' absorb(schoolid)
est store reg42
test negotiation=safespace


	xi: lasso2 morning10 `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & morning10!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe morning10 negotiation  num_neg class_size safespace  `first' `second'   if treatment_actual!=0   , `se' absorb(schoolid)
est store morn10
test negotiation=safespace

	xi: lasso2 morning11 `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 num_neg `controls'  if treatment_actual!=0 & morning11!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe morning11 negotiation  num_neg class_size safespace   `first' `second'   if treatment_actual!=0   , `se' absorb(schoolid)
est store morn11
test negotiation=safespace


xml_tab    reg12  reg22  reg32 morn10 morn11 reg42   , save("tables/table_A20.xml") replace below stats(N r2_a) ///
	keep(  negotiation safespace num_neg   ) sheet("ClassroomSpillovers_HumCap") ///
	cnames("Enrolled 9" "Enrolled 10" "Enrolled 11" "Morning 10" "Morning 11" "Human Capital Index" )
