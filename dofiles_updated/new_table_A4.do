local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	  bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth

use "finaldata\GN_data.dta", clear



foreach var in  `controls' { 
	drop if `var'==.
	}
	


xtset classid
local se cluster(classid)

*D: Guardian Relationship to Child Answers


	xi: lasso2 gu_d1_care_for `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d1_care_for!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe		
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
xi: reghdfe gu_d1_care_for   negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d1
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d1_care_for if treatment_actual==1, d
estadd scalar mean=r(mean)

	xi: lasso2 gu_d2_give_advice `controls' if treatment_actual!=0, adaptive postresults fe
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d2_give_advice!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe gu_d2_give_advice   negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d2
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d2_give_advice if treatment_actual==1, d
estadd scalar mean=r(mean)


	xi: lasso2 gu_d3 `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d3!=., adaptive postresults fe
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe gu_d3 negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d3
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d3 if treatment_actual==1, d
estadd scalar mean=r(mean)


	xi: lasso2 gu_d4 `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d4!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe gu_d4 negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d4
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d4 if treatment_actual==1, d
estadd scalar mean=r(mean)

	xi: lasso2 gu_d5 `controls' if treatment_actual!=0, adaptive postresults fe
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d5!=., adaptive postresults fe
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe gu_d5 negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d5
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d5 if treatment_actual==1, d
estadd scalar mean=r(mean)


	xi: lasso2 gu_d6 `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d6!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe		
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe gu_d6 negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store d6
test negotiation=safespace
estadd scalar testp=r(p)

sum gu_d6 if treatment_actual==1, d
estadd scalar mean=r(mean)

gen d_1_6_index=0
foreach var in gu_d1_care_for gu_d2_give_advice  gu_d3  gu_d4 gu_d5 gu_d6 { 
	egen temp=std(`var') 
	replace d_1_6_index=d_1_6_index+`var'
	drop temp
	}
replace d_1_6_index=. if d_1_6_index==0
replace d_1_6_index=d_1_6_index/6


	xi: lasso2 d_1_6_index `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe		
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & d_1_6_index!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe	 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe d_1_6_index negotiation safespace  treatment_info `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store index

test negotiation=safespace
estadd scalar testp=r(p)

sum d_1_6_index if treatment_actual==1, d
estadd scalar mean=r(mean)


xml_tab d1 d2 d3 d4 d5 d6 index , save("tables/table_A4.xml") replace below ///
	sheet("D1_6") cnames("Care for HH Mems" "Gives Advice" "Controls Neg Emotions" "Pursues Self Interests" "Understand POV" ///
		"Being Respectful" "Neg Skill Index") stats(testp mean N r2_a ) keep(negotiation safespace )
		
