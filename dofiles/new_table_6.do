
use "finaldata/GN_data.dta", clear


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	   bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth


*get rid of no baseline or ethnic controls sample
foreach var in `controls' { 
	drop if `var'==.
	}
	
xtset classid

local se cluster(classid)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gamecomm treatment_info  i.classid  gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG00
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace   i.classid  treatment_info  gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 ,  `se'
est store investmentnocomm00
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace  i.classid  treatment_info   gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  ,  `se' 
est store investmentcomm00
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian commXNeg commXSS gamecomm negotiation safespace  i.classid   gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all00
test commXNeg=commXSS
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

lincom negotiation+commXNeg

lincom safespace +commXSS

lincom (negotiation+commXNeg)-(safespace +commXSS)

*double lasso

	xi: lasso2 tg_t1_tokens_sent_guardian `controls'  if treatment_actual!= 0 & gameDG==1, adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==1 & tg_t1_tokens_sent_guardian!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gamecomm treatment_info `firstset' `secondset'  i.classid  gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG0
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)


	xi: lasso2 tg_t1_tokens_sent_guardian `controls'  if treatment_actual!= 0 & gameDG==0 & gamecomm==0, adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0 & gamecomm==0 & tg_t1_tokens_sent_guardian!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}


xi: reg tg_t1_tokens_sent_guardian negotiation safespace   i.classid  treatment_info  `firstset' `secondset'  gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 ,  `se'
est store investmentnocomm0
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls'  if treatment_actual!= 0 & gameDG==0 & gamecomm==1, adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0 & gamecomm==1 & tg_t1_tokens_sent_guardian!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}


xi: reg tg_t1_tokens_sent_guardian negotiation safespace  i.classid  treatment_info  `firstset' `secondset'  gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  ,  `se' 
est store investmentcomm0
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

	xi: lasso2 tg_t1_tokens_sent_guardian `controls'  if treatment_actual!= 0 & gameDG==0 , adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gameDG==0 & tg_t1_tokens_sent_guardian!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}


xi: reg tg_t1_tokens_sent_guardian commXNeg commXSS gamecomm negotiation safespace  i.classid   `firstset' `secondset' gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all0
test commXNeg=commXSS
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

lincom negotiation+commXNeg

lincom safespace +commXSS

lincom (negotiation+commXNeg)-(safespace +commXSS)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace gamecomm i.classid  treatment_info  `controls' gameDG if treatment_actual!=0 & gameDG==1, `se'
est store DG
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace  i.classid  treatment_info  `controls' gameDG if treatment_actual!=0  & gameDG==0 & gamecomm==0 , `se'
est store investmentnocomm 
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

xi: reg tg_t1_tokens_sent_guardian negotiation safespace  i.classid treatment_info  `controls' gameDG if treatment_actual!=0 & gameDG==0 & gamecomm==1  , `se'
est store investmentcomm
test negotiation=safespace
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)



xi: reg tg_t1_tokens_sent_guardian commXNeg commXSS gamecomm negotiation safespace treatment_info  i.classid  `controls' gameDG if treatment_actual!=0  & gameDG==0    , `se'
est store all
test commXNeg=commXSS
estadd scalar testp=r(p)
sum tg_t1_tokens_sent_guardian if e(sample) & treatment_actual==1
estadd scalar avg=r(mean)

lincom negotiation+commXNeg

lincom safespace +commXSS

lincom (negotiation+commXNeg)-(safespace +commXSS)


*now make results in two panels, first panel with comm and pooled, second panel with non comm and dictator game

xml_tab   investmentcomm00 investmentcomm0  all00 all0 , save("tables/new_table_6.xml") replace below stats(testp avg N r2_a) ///
	keep(negotiation safespace  commXNeg commXSS ) ///
	cnames( /// 
	"Comm, Baseline Controls" "Double Lasso" "Pooled, Baseline Controls" "Double Lasso"  ) ///
	sheet("PanelA")

xml_tab   investmentnocomm00 investmentnocomm0   DG00 DG0 , save("tables/new_table_6.xml") append below stats(testp avg N r2_a) ///
	keep(negotiation safespace  ) ///
	cnames( "No Comm, Baseline Controls" "Double Lasso"  "DG, Baseline Controls" "Double Lasso"  ) ///
	sheet("PanelB")
	
*check if DG and IG no comm are statistically different
gen neg_DG=gameDG*negotiation
gen ss_DG=gameDG*safespace

xi: reg tg_t1_tokens_sent_guardian negotiation safespace  neg_DG ss_DG i.classid treatment_info  gameDG if treatment_actual!=0 & gamecomm==0 , `se'



