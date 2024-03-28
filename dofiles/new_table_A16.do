
use "finaldata\GN_data.dta", clear


	
factor  read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex read_nyanja_well speak_nyanja_well read_english_well speak_english_well 
predict ability_factor


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		   treatment_info 	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  

local se cluster(classid)

gen neg_word=negotiation*gameword
gen ss_word=safespace*gameword
gen word_comm=gameword*gamecomm
gen neg_word_comm=negotiation*gameword*gamecomm
gen ss_word_comm=safespace*gameword*gamecomm
gen neg_comm=negotiation*gamecomm
gen ss_comm=safespace*gamecomm
gen abil_word=ability_factor*gameword


foreach var in  `controls' { 
	drop if `var'==.
	}
	


xtset classid



	
xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gameDG==0 & gamecomm==0 & treatment_actual!=0, adaptive postresults  fe 
lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if gameDG==0 & gamecomm==0 & treatment_actual!=0 & tg_t1_tokens_sent_guardian!=. , adaptive postresults  fe
lasso2, lic(aic) postresults fe
	
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: reg tg_t1_tokens_sent_guardian negotiation safespace gameword i.classid  treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se'
est store investmentnocomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)



xi: reg tg_t1_tokens_sent_guardian negotiation neg_word  safespace ss_word gameword i.classid  treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se'
est store investmentnocomm2 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gameDG==0  & treatment_actual!=0, adaptive postresults  lic(aic) fe 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if gameDG==0 & treatment_actual!=0 & tg_t1_tokens_sent_guardian!=. , adaptive postresults  lic(aic) fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}
		
xi: reg tg_t1_tokens_sent_guardian negotiation safespace word_comm gameword gamecomm i.classid  treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0 , `se'
est store wordcomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)


xi: reg tg_t1_tokens_sent_guardian negotiation safespace word_comm abil_word ability_factor gameword gamecomm i.classid  treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0 , `se'
est store abil 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)


xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gamecomm==1 & gameDG==0 & treatment_actual!=0, adaptive postresults  lic(aic) fe 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if gamecomm==1 & gameDG==0 & treatment_actual!=0 & tg_t1_tokens_sent_guardian!=. , adaptive postresults  lic(aic) fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}
		

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gameword neg_word ss_word  i.classid treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se'
est store investmentcomm2
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gameword  i.classid treatment_info `firstset' `secondset' gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se'
est store investmentcomm
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gameword neg_word ss_word  i.classid treatment_info  `firstset' `secondset' gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se'
est store investmentcomm2
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar mean=r(mean)



xml_tab investmentcomm investmentcomm2 wordcomm abil investmentnocomm investmentnocomm2   , save("tables/table_A16.xml") replace below stats(testp mean N r2_a) ///
	keep(negotiation safespace gamewords neg_word ss_word word_comm   abil_word   ) ///
	cnames( "Comm" "Comm" "All IG" "All IG" "No Comm" "No Comm" )
