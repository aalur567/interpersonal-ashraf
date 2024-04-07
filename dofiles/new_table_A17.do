
use "finaldata\GN_data.dta", clear


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		   treatment_info 	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  
foreach var in `controls' { 
	drop if `var'==.
	}


local se cluster(classid)


factor  read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex read_nyanja_well speak_nyanja_well read_english_well speak_english_well 
predict ability_factor

gen above_45=0
replace above_45=1 if ability_factor>.45
replace above_45=. if ability_factor==.

gen below=0
replace below=1 if ability_factor<=.45
replace below=. if ability_factor==.

gen neg_above=above_45*negotiation
gen neg_below=below*negotiation

gen neg_above_comm=above_45*negotiation*gamecomm
gen neg_below_comm=below*negotiation*gamecomm
gen above_comm=above_45*gamecomm


xtset classid

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace gamecomm above_45 treatment_info  i.classid  gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG00
test neg_above=neg_below
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below  safespace   i.classid  above_45 treatment_info  gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 ,  `se'
est store investmentnocomm00
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below  safespace  i.classid above_45  treatment_info   gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  ,  `se' 
est store investmentcomm00
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)


xi: reg tg_t1_tokens_sent_guardian neg_above neg_below neg_above_comm neg_below_comm above_45 commXSS gamecomm  safespace  i.classid   gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all00
test neg_above_comm=neg_below_comm
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

*double lasso

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0 & gameDG==1,    adaptive fe
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls' if treatment_actual!=0 & gameDG==1,    adaptive fe
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}
		
xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace gamecomm treatment_info above_45 `firstset' `secondset'  i.classid  gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG0
test neg_above=neg_below
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0 & gameDG==0 & gamecomm==0,    adaptive fe
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls' if treatment_actual!=0 & gameDG==0 & gamecomm==0,    adaptive fe
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}

	
	if "`secondset'"=="." { 
		local secondset
		}

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace   i.classid  treatment_info above_45 `firstset' `secondset'  gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 ,  `se'
est store investmentnocomm0
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0 & gameDG==0 & gamecomm==1,    adaptive lic(aic) fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0 & gamecomm==1, adaptive postresults  lic(aic)  fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}
		
xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace  i.classid  treatment_info above_45  `firstset' `secondset'  gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  ,  `se' 
est store investmentcomm0
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls' if treatment_actual!=0 & gameDG==0 ,    adaptive lic(aic) fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset
		}

		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0, adaptive postresults  lic(aic)  fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset
		}
xi: reg tg_t1_tokens_sent_guardian  neg_above neg_below neg_above_comm neg_below_comm  commXSS gamecomm  above_45 safespace  i.classid   `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all0
test neg_above_comm=neg_below_comm
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace gamecomm i.classid  treatment_info  `controls' above_45 gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)


xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace  i.classid  treatment_info  `controls' above_45 gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se'
est store investmentnocomm 
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian neg_above neg_below safespace  i.classid treatment_info  `controls' above_45 gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se'
est store investmentcomm
test neg_above=neg_below
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)



xi: reg tg_t1_tokens_sent_guardian neg_above neg_below neg_above_comm neg_below_comm  commXSS gamecomm  above_45 safespace treatment_info  i.classid  `controls' gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all
test neg_above_comm=neg_below_comm
estadd scalar testp=r(p)

sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)


*now make results in two panels, first panel with comm and pooled, second panel with non comm and dictator game

xml_tab   investmentcomm00 investmentcomm0  all00 all0 , save("tables/table_A17.xml") replace below stats( testp avg N r2_a) ///
	keep(neg_above neg_below safespace   neg_above_comm neg_below_comm  commXSS ) ///
	cnames( /// 
	"Comm, Baseline Controls" "Comm, Double Lasso"  "Pooled, Baseline Controls" "Pooled, Double Lasso"  ) ///
	sheet("PanelA")

xml_tab   investmentnocomm00 investmentnocomm0   DG00 DG0 , save("tables/table_A17.xml") append below stats(testp avg N r2_a) ///
	keep(neg_above neg_below safespace  ) ///
	cnames( "No Comm, Baseline Controls" "No Comm, Double Lasso"  "DG, Baseline Controls" "DG, Double Lasso"  ) ///
	sheet("PanelB")
	

