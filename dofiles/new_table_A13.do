
use "finaldata\GN_data.dta", clear

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth 
	

foreach var in `controls' {
	drop if `var'==.
	}




local se cluster(classid)

*combined knowledge measure: qu_k134_code
gen know_comm=gamecomm*qu_k134_code
gen ss_comm=gamecomm*safespace
gen neg_comm=negotiation*gamecomm
xtset classid



	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0  & gameDG==0 & gamecomm==0, adaptive postresults fe  
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0  & gameDG==0 & gamecomm==0 & tg_t1_tokens_sent_guardian!=., adaptive postresults fe 
		lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe tg_t1_tokens_sent_guardian negotiation safespace qu_k134_code i.classid  treatment_info  `first' `second' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se' absorb(classid)
est store investmentnocomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0  & gameDG==0 & gamecomm==1, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0  & gameDG==0 & gamecomm==1 & tg_t1_tokens_sent_guardian!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe tg_t1_tokens_sent_guardian negotiation safespace qu_k134_code i.classid  treatment_info  `first' `second' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==1 , `se' absorb(classid)
est store investmentcomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)
 
 	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0  & gameDG==0 , adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0  & gameDG==0 & tg_t1_tokens_sent_guardian!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

 
xi: reghdfe tg_t1_tokens_sent_guardian negotiation safespace qu_k134_code know_comm ss_comm neg_comm gamecomm i.classid  treatment_info  `first' `second'  if treatment_actual!=0  & gameDG==0  , `se' absorb(classid)
est store pooled 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0  & gameDG==1 , adaptive postresults fe
	lasso2, fe lic(aic) postresults
	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0  & gameDG==1  & tg_t1_tokens_sent_guardian!=., adaptive postresults fe 
		lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe tg_t1_tokens_sent_guardian negotiation safespace qu_k134_code i.classid  treatment_info  `first' `second' gameDG if treatment_actual!=0  & gameDG==1 , `se' absorb(classid)
est store DG 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)


xml_tab  investmentcomm pooled investmentnocomm  DG, save("tables/table_A13.xml") replace below stats(testp mean N r2_a) ///
	keep(negotiation safespace  qu_k134_code gamecomm know_comm ss_comm neg_comm    ) ///
	cnames( "Comm" "Pooled" "No Comm" "DG")
