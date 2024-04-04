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

sum bl_age, d

factor both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad parents_pay_fees
predict altruism_factor 

sum altruism_factor, d
gen above_alt=0
replace above_alt=1 if altruism_factor>=r(p50)
replace above_alt=. if altruism_factor==.

gen neg_alt=above_alt*negotiation
gen safespace_alt=above_alt*safespace

sum bl_age, d
gen above_age=0
replace above_age=1 if bl_age>=r(p50)
replace above_age=. if bl_age==.

gen neg_aboveage=negotiation*above_age
gen ss_aboveage=safespace*above_age


gen neg_low_alt=negotiation*(above_alt==0)
gen neg_low_age=negotiation*(above_age==0)

gen ss_low_alt=safespace*(above_alt==0)
gen ss_low_age=safespace*(above_age==0)

local hetero2 above_age neg_aboveage ss_aboveage neg_low_age ss_low_age
local hetero3 above_alt neg_alt safespace_alt neg_low_alt ss_low_alt
local count=3

	
	
*altruism
local count=3
forvalues i = 3/5{

	xi: reghdfe enrolled`i' `hetero3' treatment_info  if treatment_actual!=0 ,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_alt = neg_alt
	estadd scalar testp=r(p)

	
	est store reg`count'
	local count=`count'+1
	
	xi: lasso2 enrolled`i' `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local enrolled`i'f=e(selected)
	
	if "`enrolled`i'f'"=="." { 
		local enrolled`i'f 
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & enrolled`i'!=., adaptive postresults fe lic(aic) 
	local enrolled`i's=e(selected)
	
	if "`enrolled`i's'"=="." { 
		local enrolled`i's
		}

	xi: reghdfe enrolled`i'  treatment_info `hetero3' `enrolled`i'f' `enrolled`i's' if treatment_actual!=0,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_alt = neg_alt
	estadd scalar testp=r(p)
	

	est store reg`count'
	local count=`count'+1

	xi: reghdfe enrolled`i'  treatment_info `hetero3' `controls' if treatment_actual!=0,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_alt = neg_alt
	estadd scalar testp=r(p)
	

	
	est store reg`count'
	local count=`count'+1

}


xml_tab  reg3 reg4  reg6 reg7  reg9 reg10 , save("tables/table_A9.xml") replace stats(testp  mean N r2_a) below ///
	keep(neg_low_alt neg_alt ss_low_alt safespace_alt ) sheet("Thresholds_altruism") cnames( ///
	"Grade 9" "Grade 9" "Grade 10" "Grade 10"  ///
	"Grade 11" "Grade 11"  )
	
	
	
*age
local count=3
forvalues i = 3/5{

	xi: reghdfe enrolled`i'   `hetero2' treatment_info  if treatment_actual!=0 ,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_age = neg_aboveage
	estadd scalar testp=r(p)
	
	est store reg`count'
	local count=`count'+1
	
	xi: lasso2 enrolled`i' `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local enrolled`i'f=e(selected)
	
	if "`enrolled`i'f'"=="." { 
		local enrolled`i'f 
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & enrolled`i'!=., adaptive postresults fe lic(aic) 
	local enrolled`i's=e(selected)
	
	if "`enrolled`i's'"=="." { 
		local enrolled`i's
		}

	xi: reghdfe enrolled`i'  treatment_info `hetero2' `enrolled`i'f' `enrolled`i's' if treatment_actual!=0,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_age = neg_aboveage
	estadd scalar testp=r(p)	

	est store reg`count'
	local count=`count'+1

	xi: reghdfe enrolled`i'   treatment_info `hetero2' `controls' if treatment_actual!=0,  `se' absorb(classid)

	sum enrolled`i', d
	estadd scalar mean=r(mean)
	test neg_low_age = neg_aboveage
	estadd scalar testp=r(p)

	
	est store reg`count'
	local count=`count'+1

}


xml_tab  reg3 reg4  reg6 reg7  reg9 reg10 , save("tables/table_A9.xml") append stats(testp  mean N r2_a) below ///
	keep(neg_low_age neg_aboveage ss_low_age ss_aboveage ) sheet("Thresholds_age") cnames( ///
	"Grade 9" "Grade 9"  "Grade 10" "Grade 10"   ///
	"Grade 11" "Grade 11"  )
	

