use "finaldata\GN_data.dta", clear

xtset classid

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex  bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth

foreach var in `controls' { 
	drop if `var'==.
	}
	

bysort classid: egen num_neg=total(negotiation)	
bysort classid: egen class_size=count(negotiation)
gen num_neg_comm= num_neg*gamecomm
gen classize_comm=class_size*gamecomm
gen neg_comm=negotiation*gamecomm
gen ss_comm=safespace*gamecomm

gen treated=0
replace treated=1 if treatment_actual!=0
replace treated=. if treatment_actual==.


local se cluster(classid)

xi: areg tg_t1_tokens_sent_guardian num_neg class_size  negotiation safespace treatment_info if gamecomm==1 & treatment_actual!=0  , `se' absorb(schoolid)
est store reg1


	xi: lasso2 tg_t1_tokens_sent_guardian`i' `controls' if treatment_actual!=0 & gamecomm==1, adaptive postresults fe lic(aic) 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gamecomm==1, adaptive postresults fe lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: areg tg_t1_tokens_sent_guardian num_neg class_size   negotiation safespace treatment_info `firstset' `secondset' if gamecomm==1  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg2

xi: areg tg_t1_tokens_sent_guardian num_neg class_size   negotiation safespace treatment_info `controls' if gamecomm==1   & treatment_actual!=0 , `se' absorb(schoolid)
est store reg3

xi: areg tg_t1_tokens_sent_guardian neg_comm ss_comm num_neg num_neg_comm classize_comm class_size    treated  negotiation safespace treatment_info if gameDG==0  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg4

	xi: lasso2 tg_t1_tokens_sent_guardian`i' `controls' if treatment_actual!=0 & gameDG==0, adaptive postresults fe lic(aic) 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0, adaptive postresults fe lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: areg tg_t1_tokens_sent_guardian neg_comm ss_comm num_neg num_neg_comm classize_comm  negotiation safespace treatment_info `firstset' `secondset' if  gameDG==0  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg5

xi: areg tg_t1_tokens_sent_guardian neg_comm ss_comm num_neg num_neg_comm classize_comm  negotiation safespace treatment_info `controls' if  gameDG==0  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg6

xml_tab reg1 reg2  reg4 reg5 , save("tables/table_A21.xml")  ///
	sheet("GamePanelA") stats(N df_r r2_a) keep(negotiation safespace num_neg neg_comm ss_comm num_neg_comm) replace below cnames("Comm." "Comm." "Pooled" "Pooled" )


xi: areg tg_t1_tokens_sent_guardian num_neg class_size    negotiation safespace treatment_info if gamecomm==0 & gameDG==0  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg1

	xi: lasso2 tg_t1_tokens_sent_guardian`i' `controls' if treatment_actual!=0 & gamecomm==0  & gameDG==0 , adaptive  fe 
	lasso2, fe lic(aic) postresults
	local firstset=e(selected)
	
	
	if "`firstset'"=="." { 
		local firstset
		}
		
	xi: lasso2 negotiation `controls' if treatment_actual!=0 & gamecomm==0  & gameDG==0, adaptive  fe 
	lasso2, fe lic(aic) postresults
	local secondset=e(selected)
	
	
	if "`secondset'"=="." { 
		local secondset
		}
		
xi: areg tg_t1_tokens_sent_guardian num_neg class_size    negotiation safespace treatment_info `firstset' `secondset' if gamecomm==0  & gameDG==0  & treatment_actual!=0 , `se' absorb(schoolid)
est store reg2 

xi: areg tg_t1_tokens_sent_guardian num_neg class_size    negotiation safespace treatment_info `controls' if gamecomm==0  & gameDG==0  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg3

xi: areg tg_t1_tokens_sent_guardian   num_neg class_size    negotiation safespace treatment_info if gameDG==1  & treatment_actual!=0  , `se' absorb(schoolid)
est store reg4

	xi: lasso2 tg_t1_tokens_sent_guardian`i' `controls' if treatment_actual!=0 & gameDG==1, adaptive  fe 
	lasso2, fe lic(aic) postresults
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==1, adaptive  fe
	lasso2, fe lic(aic) postresults
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}

xi: areg tg_t1_tokens_sent_guardian num_neg class_size    negotiation safespace treatment_info `firstset' `secondset' if  gameDG==1  & treatment_actual!=0 , `se' absorb(schoolid)
est store reg5

xi: areg tg_t1_tokens_sent_guardian  num_neg class_size    negotiation safespace treatment_info `controls' if  gameDG==1  & treatment_actual!=0 , `se' absorb(schoolid)
est store reg6

xml_tab reg1 reg2  reg4 reg5 , save("tables/table_A21.xml")  ///
	sheet("GamePanelB") stats(N df_r r2_a) keep(negotiation safespace num_neg ) append below cnames("No Comm."  ///
	"No Comm." "DG" "DG" )
