
use "finaldata\GN_data.dta", clear


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth 
	  
local DGcontrols  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka  
	  


foreach var in tg_t6ValColor tg_t6ValMath tg_t6ValNote tg_t6ValPencl ///
	tg_t6ValPens tg_t6ValRubber tg_t6ValRuler tg_t6ValSharpen tg_t6ValSocks { 
		replace `var'=. if `var'>24
		}
		
foreach var in tg_t6ValColor tg_t6ValMath tg_t6ValNote tg_t6ValPencl ///
	tg_t6ValPens tg_t6ValRubber tg_t6ValRuler tg_t6ValSharpen tg_t6ValSani { 
		replace `var'=. if `var'>24
		}

egen school_supplies=rsum(tg_t6ValColor tg_t6ValMath tg_t6ValNote tg_t6ValPencl ///
	tg_t6ValPens tg_t6ValRubber tg_t6ValRuler tg_t6ValSharpen)
egen temp=rowmiss(tg_t6ValColor tg_t6ValMath tg_t6ValNote tg_t6ValPencl ///
	tg_t6ValPens tg_t6ValRubber tg_t6ValRuler tg_t6ValSharpen)
replace school_supplies=. if temp!=0 
drop temp 

egen pure_consumption=rsum(tg_t6ValHairI tg_t6ValScarf tg_t6ValBrclts ///
	tg_t6ValLip tg_t6ValPurse tg_t6ValRings tg_t6ValLolli tg_t6ValBisc ///
	tg_t6ValJiggies tg_t6ValSnakes) 
egen temp=rowmiss(tg_t6ValHairI tg_t6ValScarf tg_t6ValBrclts ///
	tg_t6ValLip tg_t6ValPurse tg_t6ValRings tg_t6ValLolli tg_t6ValBisc ///
	tg_t6ValJiggies tg_t6ValSnakes)
replace pure_consumption=. if temp!=0
drop temp

egen inbetween=rsum(tg_t6ValSani tg_t6ValSocks)
egen temp=rowmiss(tg_t6ValSani tg_t6ValSocks)
replace inbetween=. if temp!=0
drop temp

xtset classid
local se "cluster(classid)"


	 
foreach var in `controls' {
	drop if `var'==.
	}



*daughter's total number of tokens: tg_t6ValTotal



gen net_useful=school_supplies+inbetween


	sum `controls' if treatment_actual!=0 & gameDG==1
	*don't include missing eth because it is always 0 for this group
	
	xi: lasso2 net_useful `DGcontrols' if treatment_actual!=0  & gameDG==1, adaptive postresults fe 
	lasso2, fe lic(aic) postresults	

	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols' if treatment_actual!=0  & gameDG==1 & net_useful!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe net_useful negotiation safespace gamecomm   treatment_info i.tg_t6ValTotal `first' `second' gameDG if treatment_actual!=0 & gameDG==1, `se' absorb(classid)
est store DG1
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)



	xi: lasso2 pure_consumption `DGcontrols' if treatment_actual!=0  & gameDG==1, adaptive postresults fe 
	lasso2, fe lic(aic) postresults 	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols' if treatment_actual!=0  & gameDG==1 & pure_consumption!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe pure_consumption negotiation safespace gamecomm   treatment_info  i.tg_t6ValTotal `first' `second' gameDG if treatment_actual!=0 & gameDG==1, `se' absorb(classid)
est store DG3
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

*again no missing eth so need to drop from set of possible controls

	xi: lasso2 net_useful `DGcontrols' if treatment_actual!=0  & gameDG==0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols'  if treatment_actual!=0  & gameDG==0 & net_useful!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}



xi: reghdfe net_useful commXNeg commXSS gamecomm negotiation safespace treatment_info  i.tg_t6ValTotal  `first' `second' gameDG if treatment_actual!=0  & gameDG==0    , `se' absorb(classid)
est store all1
test commXNeg=commXSS
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)
lincom negotiation+commXNeg
lincom safespace+commXSS
lincom (negotiation+commXNeg)-(safespace+commXSS)


	xi: lasso2 pure_consumption `DGcontrols' if treatment_actual!=0  & gameDG==0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols'  if treatment_actual!=0  & gameDG==0 & pure_consumption!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}



xi: reghdfe pure_consumption commXNeg commXSS gamecomm negotiation safespace treatment_info  i.tg_t6ValTotal  `first' `second' gameDG if treatment_actual!=0  & gameDG==0    , `se' absorb(classid)
est store all3
test commXNeg=commXSS
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)
lincom negotiation+commXNeg
lincom safespace+commXSS
lincom (negotiation+commXNeg)-(safespace+commXSS)


	xi: lasso2 net_useful `DGcontrols' if treatment_actual!=0  & gamecomm==1, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols'  if treatment_actual!=0  & gamecomm==1 & net_useful!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}





xi: reghdfe net_useful    negotiation safespace treatment_info  i.tg_t6ValTotal  `first' `second' gameDG if treatment_actual!=0  & gamecomm==1    , `se' absorb(classid)
est store comm1
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)


	xi: lasso2 pure_consumption `DGcontrols' if treatment_actual!=0  & gamecomm==1, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols' if treatment_actual!=0  & gamecomm==1 & pure_consumption!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe pure_consumption    negotiation safespace treatment_info  i.tg_t6ValTotal  `first' `second' gameDG if treatment_actual!=0  & gamecomm==1    , `se' absorb(classid)
est store comm2
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)



	xi: lasso2 net_useful `DGcontrols' if treatment_actual!=0  & gamecomm==0 & gameDG==0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols' if treatment_actual!=0  & gamecomm==0 & gameDG==0 & net_useful!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe net_useful    negotiation safespace treatment_info  i.tg_t6ValTotal  `first' `second' gameDG if treatment_actual!=0  & gamecomm==0 & gameDG==0   , `se' absorb(classid)
est store nocomm1
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

	xi: lasso2 pure_consumption `DGcontrols' if treatment_actual!=0  & gamecomm==0 & gameDG==0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `DGcontrols' if treatment_actual!=0  & gamecomm==0 & gameDG==0 & pure_consumption!=., adaptive postresults fe 
	lasso2, fe lic(aic) postresults  fe 	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}




xi: reghdfe pure_consumption    negotiation safespace treatment_info  i.tg_t6ValTotal `first' `second' gameDG if treatment_actual!=0  & gamecomm==0 & gameDG==0    , `se' absorb(classid)
est store nocomm2
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)



xml_tab comm1 comm2 all1  all3 nocomm1 nocomm2 DG1  DG3 , save("tables/table_A14.xml") replace below stats(testp mean N r2_a) ///
	keep(negotiation safespace  commXNeg commXSS ) ///
	cnames("Non-Consumption, Comm" "Consumption, Comm" "Non-Consumption, IG" "Consumption, IG" "Non-Consumption, No Comm" "Consumption, No Comm" "Non-Consumption, DG" "Consumption, DG")
	
	

