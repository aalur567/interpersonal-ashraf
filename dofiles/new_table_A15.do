
use "finaldata\GN_data.dta", clear

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka  
	  

local se cluster(classid)

gen succeed=0
replace succeed=1 if tg_t01_word_act>=3 & tg_t01_word_act!=.


rename tg_t1_tokens_sent_guardian token_g
gen daughter_total=2*token_g + tg_t3_extra_tokens
replace daughter_total=token_g + tg_t3_extra_tokens if succeed==0 & gameword==1
gen daughter_welfare=daughter_total-tg_t10_tokens_sent_girl if gameDG==0
replace daughter_welfare = daughter_total if gameDG==1

gen appeared=0
replace appeared=1 if tg_game_type!=.

*sample selection

foreach var in `controls' {
	drop if `var'==.
	}


xtset classid


	xi: lasso2 daughter_welfare `controls' if treatment_actual!=0 & gameDG==1, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & daughter_welfare!=. & gameDG==1, adaptive postresults fe
	lasso2, fe lic(aic) postresults
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg daughter_welfare negotiation safespace gamecomm   treatment_info  `first' `second' gameDG i.classid if treatment_actual!=0 & gameDG==1, `se' 
est store DG
test negotiation=safespace
estadd scalar testp=r(p)
sum daughter_welfare if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)


	xi: lasso2 daughter_welfare `controls' if treatment_actual!=0 & gameDG==0 & gamecomm==0, adaptive postresults fe
	lasso2, fe lic(aic) postresults	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & daughter_welfare!=. & gameDG==0  & gamecomm==0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe daughter_welfare negotiation safespace  i.classid  treatment_info  `first' `second' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se' absorb(classid)
est store investmentnocomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum daughter_welfare if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

	xi: lasso2 daughter_welfare `controls' if treatment_actual!=0 & gamecomm==1, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & daughter_welfare!=. & gamecomm==1, adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reghdfe daughter_welfare negotiation safespace  i.classid treatment_info  `first' `second' gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se' absorb(classid)
est store investmentcomm
test negotiation=safespace
estadd scalar testp=r(p)
sum daughter_welfare if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

	xi: lasso2 daughter_welfare `controls' if treatment_actual!=0 & gameDG==0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & daughter_welfare!=. & gameDG==0, adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe daughter_welfare commXNeg commXSS gamecomm negotiation safespace treatment_info  i.classid  `first' `second' gameDG if treatment_actual!=0  & gameDG==0    , `se' absorb(classid)
est store all
test commXNeg=commXSS
estadd scalar testp=r(p)
sum daughter_welfare if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

lincom negotiation+commXNeg
lincom safespace +commXSS
lincom (negotiation+commXNeg)-(safespace +commXSS)




xml_tab investmentcomm all investmentnocomm    DG, save("tables/table_A15.xml") replace below stats(testp mean N r2_a) ///
	keep(negotiation safespace  commXNeg commXSS ) ///
	cnames( "Communication" "IG Pooled"  "No Communication" "DG")
