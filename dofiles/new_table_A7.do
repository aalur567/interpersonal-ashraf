use "finaldata\GN_data.dta", clear



local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex  bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	 bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth

foreach var in `controls' {
	drop if `var'==.
	}


	
xtset classid 

local se cluster(classid)
*hazard model
preserve 

reshape long enrolled, i(ID) j(time)

*make survival time data
gen dropout=enrolled
recode dropout (1=0) (0=1)
bysort ID: egen everdropout=max(dropout)

egen tag=tag(ID)
stset time, fail(dropout) id(ID)



xi: stcox negotiation  safespace treatment_info  i.classid if treatment_actual!=0 , `se'

sum everdropout if e(sample) & treatment_actual==1 & tag==1
estadd scalar mean=r(mean)
test negotiation=safespace
estadd scalar testp=r(p)
test negotiation=treatment_info
estadd scalar testp2=r(p)
est store reg0

*double lasso

	xi: lasso2 dropout `controls'  if treatment_actual!= 0 , adaptive  fe  
	lasso2, lic(aic) postresults fe	
	
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & dropout!=., adaptive  fe  
	lasso2, lic(aic) postresults fe	
	
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}
	
xi: stcox negotiation safespace treatment_info `firstset' `secondset'  i.classid if treatment_actual!=0 , `se'

sum everdropout if e(sample) & treatment_actual==1 & tag==1
estadd scalar mean=r(mean)
test negotiation=safespace
estadd scalar testp=r(p)
test negotiation=treatment_info
estadd scalar testp2=r(p)
est store reg1

xi: stcox negotiation safespace treatment_info `controls' i.classid if treatment_actual!=0, `se' 

sum everdropout if e(sample) & treatment_actual==1  & tag==1
estadd scalar mean=r(mean)
test negotiation=safespace
estadd scalar testp=r(p)
test negotiation=treatment_info
estadd scalar testp2=r(p)
est store reg2

xml_tab reg0 reg1 , save("tables/table_A7.xml") replace stats(testp  mean N r2_a) below ///
	keep(negotiation safespace ) sheet("Hazard") cnames("Hazard" "Hazard" ) eform(hr)
	
