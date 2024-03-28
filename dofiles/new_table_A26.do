use "finaldata\GN_data.dta", clear

local se cluster(classid)

xtset classid

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		   treatment_info 	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  

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
gen treated_comm=treated*gamecomm



xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info if gamecomm==1  , cluster(schoolid) 
est store reg1

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gamecomm==1, adaptive postresults  lic(aic) 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 treated `controls'  if gamecomm==1, adaptive postresults  lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}

xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info `firstset' `secondset' if gamecomm==1  , cluster(schoolid) 
est store reg2

xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info `controls' if gamecomm==1  , cluster(schoolid) 
est store reg3

xi: reg tg_t1_tokens_sent_guardian neg_comm ss_comm treated_comm  treated  negotiation safespace treatment_info if gameDG==0  , cluster(schoolid) 
est store reg4

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gameDG==0, adaptive postresults  lic(aic) 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 treated `controls'  if gameDG==0, adaptive postresults  lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: reg tg_t1_tokens_sent_guardian neg_comm ss_comm treated_comm treated  negotiation safespace treatment_info `firstset' `secondset' if  gameDG==0 , cluster(schoolid) 
est store reg5

xi: reg tg_t1_tokens_sent_guardian neg_comm ss_comm treated_comm treated  negotiation safespace treatment_info `controls' if  gameDG==0 , cluster(schoolid) 
est store reg6

xml_tab reg1 reg2  reg4 reg5 , save("tables/table_A26.xml")  ///
	sheet("GamePanelA") stats(N df_r r2_a) keep(negotiation safespace treated neg_comm ss_comm treated_comm) replace below cnames( "Comm." "Comm." "Pooled" "Pooled" )


xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info if gamecomm==0 & gameDG==0 , cluster(schoolid) 
est store reg1

xi: reg tg_t1_tokens_sent_guardian neg_comm ss_comm treated_comm  treated  negotiation safespace treatment_info if gameDG==0  , cluster(schoolid) 
est store reg4

preserve
	

	  
	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if gamecomm==0 & gameDG==0,    adaptive
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 treated `controls'  if gamecomm==0 & gameDG==0, adaptive postresults  lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info `firstset' `secondset' if gamecomm==0  & gameDG==0 , cluster(schoolid) 
est store reg2 

restore 

xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info `controls' if gamecomm==0  & gameDG==0  , cluster(schoolid) 
est store reg3

xi: reg tg_t1_tokens_sent_guardian   treated  negotiation safespace treatment_info if gameDG==1  , cluster(schoolid) 
est store reg4


	
xi: lasso2 treated `controls' if gameDG==1, adaptive postresults  lic(aic) 
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if gameDG==1, adaptive postresults  lic(aic) 
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}


xi: reg tg_t1_tokens_sent_guardian treated  negotiation safespace treatment_info `firstset' `secondset' if  gameDG==1 , cluster(schoolid) 
est store reg5

xi: reg tg_t1_tokens_sent_guardian  treated  negotiation safespace treatment_info `controls' if  gameDG==1, cluster(schoolid) 
est store reg6

xml_tab reg1 reg2  reg4 reg5 , save("tables/table_A26.xml")  ///
	sheet("GamePanelB") stats(N df_r r2_a) keep(negotiation safespace treated ) append below cnames("No Comm." "No Comm." ///
	 "DG" "DG" )

