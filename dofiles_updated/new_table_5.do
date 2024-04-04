use "finaldata/GN_data.dta", clear

destring ID, replace
merge 1:1 ID using "finaldata/rand_sample_clust.dta"
tab _merge
drop _merge


factor  read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex read_nyanja_well speak_nyanja_well read_english_well speak_english_well 
predict ability_factor

gen above_45=0
replace above_45=1 if ability_factor>.45
replace above_45=. if ability_factor==.


gen neg_above=negotiation*above_45
gen neg_below=negotiation*(above_45==0)

gen ss_above=safespace*above_45
gen ss_below=safespace*(above_45==0)



local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex  bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	 bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	 
	
*use distinct random sample
keep if randsample==1

*get rid of no baseline or ethnic controls sample
foreach var in `controls' { 
	drop if `var'==.
	}
	
xtset classid
local se cluster(classid)
local count=3

forvalues i = 3/5{

	xi: reghdfe enrolled`i' neg_above neg_below  ss_above ss_below above_45 treatment_info  if treatment_actual!=0  ,  `se' absorb(classid)

	sum enrolled`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	
	test neg_above = ss_above
	estadd scalar testnegss=r(p): reg`count'
	
	test neg_above = neg_below
	estadd scalar testp=r(p): reg`count'

	local count=`count'+1

	*double lasso
	xi: lasso2 enrolled`i' `controls'  if treatment_actual!=0, adaptive  fe  
	lasso2, lic(aic) postresults fe
	
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & enrolled`i'!=., adaptive  fe  
	lasso2, lic(aic) postresults fe 
	
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}
		
	xi: reghdfe enrolled`i' neg_above neg_below  above_45 ss_above ss_below treatment_info `firstset' `secondset' if treatment_actual!=0 ,  `se' absorb(classid)

	sum enrolled`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	test neg_above = neg_below
	estadd scalar testp=r(p)
	test neg_above = ss_above
	estadd scalar testnegss=r(p)
	local count=`count'+1

	xi: reghdfe enrolled`i' neg_above neg_below above_45   ss_above ss_below treatment_info `controls' if treatment_actual!=0 ,  `se' absorb(classid)

	sum enrolled`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	test neg_above = neg_below
	estadd scalar testp=r(p)
	test neg_above = ss_above
	estadd scalar testnegss=r(p)
	local count=`count'+1

}



xml_tab  reg3 reg4  reg6 reg7  reg9  reg11, save("tables/new_table_5.xml") replace stats(mean testp testnegss N r2_a) below ///
	keep(neg_above neg_below ss_above ss_below) sheet("PanelA") cnames( ///
	"Grade 9" "Grade 9"  "Grade 10" "Grade 10"   ///
	"Grade 11" "Grade 11"  )
	
local count=1	
forvalues i = 10/11 {

	xi: reghdfe morning`i' neg_above neg_below  above_45 treatment_info ss_above ss_below  if treatment_actual!=0  ,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	test neg_above = neg_below
	estadd scalar testp=r(p)
	test neg_above = ss_above
	estadd scalar testnegss=r(p)
	local count=`count'+1
	

	*double lasso
	xi: lasso2 morning`i' `controls'  if treatment_actual!=0, adaptive  fe  
	lasso2, lic(aic) postresults fe
	
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & morning`i'!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	
	if "`secondset'"=="." { 
		local secondset 
		}

	xi: reghdfe morning`i' neg_above neg_below  ss_above ss_below above_45 treatment_info `firstset' `secondset' if treatment_actual!=0  ,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	test neg_above = neg_below
	estadd scalar testp=r(p)
	test neg_above = ss_above
	estadd scalar testnegss=r(p)
	local count=`count'+1

	xi: reghdfe morning`i' neg_above neg_below above_45 ss_above ss_below  treatment_info `controls' if treatment_actual!=0  ,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1, d
	estadd scalar mean= r(mean)
	est store reg`count'
	test neg_above = neg_below
	estadd scalar testp=r(p)
	test neg_above = ss_above
	estadd scalar testnegss=r(p)
	local count=`count'+1

}



xml_tab  reg1 reg2  reg4 reg5 , save("tables/new_table_5.xml") append stats(mean testp testnegss N r2_a) below ///
	keep(neg_above neg_below ss_above ss_below) sheet("PanelB") cnames( ///
	 "Grade 10" "Grade 10"   ///
	"Grade 11" "Grade 11"  )
	
	
