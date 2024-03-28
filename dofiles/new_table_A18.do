
use "finaldata\GN_data.dta", clear

xtset classid
*sample selection
local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka  
	
local se cluster(classid)

	 
foreach var in `controls' {
	drop if `var'==.
	}





*midline outcomes: siblings

foreach var in gu_f5_school_will_girl  ml_d1_grade_complete_want  gu_f4_school_want_girl { 
	replace `var'=17 if `var'==12
	replace `var'=8 if `var'==1
	replace `var'=9 if `var'==2
	replace `var'=10.5 if `var'==3
	replace `var'=12 if `var'==4
	replace `var'=12.5 if `var'==5
	replace `var'=15 if `var'==6
	replace `var'=16 if `var'==7

} 

*how much schooling will X complete
foreach var in gu_f6_school_will_male gu_f7_school_will_female { 
	recode `var' (1=9)
	recode `var' (2=10.5)
	recode `var' (3=12)
	recode `var' (4=14)
	recode `var' (5=16)
	}
	


	xi: lasso2 gu_c11_male_sib `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_c11_male_sib!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
		
xi: areg gu_c11_male_sib negotiation  safespace `first' `second'  if treatment_actual!=0, absorb(classid) `se'
est store reg1
sum gu_c11_male_sib if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)

//Name of female sibling


	xi: lasso2 gu_c12_female_sib `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_c12_female_sib!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		

xi: reghdfe gu_c12_female_sib negotiation  safespace `first' `second' if treatment_actual!=0, absorb(classid) `se'
est store reg2
sum gu_c12_female_sib if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)

foreach sib in male female {


	xi: lasso2 gu_b2_chores_`sib' `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_b2_chores_`sib'!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
		
	xi: reghdfe gu_b2_chores_`sib' negotiation  safespace `first' `second'  if treatment_actual!=0, absorb(classid) `se'
	est store reg3_`sib'
	
	sum gu_b2_chores_`sib' if treatment_actual==1 & e(sample), d
	estadd scalar mean=r(mean)
	}
	
foreach sib in male female {



	xi: lasso2 gu_b3_schoolwork_`sib' `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_b3_schoolwork_`sib'!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
	xi: reghdfe gu_b3_schoolwork_`sib' negotiation  safespace `first' `second'  if treatment_actual!=0, absorb(classid) `se'
	est store reg4_`sib'
	
	sum gu_b3_schoolwork_`sib' if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)
	}

*pay for girls rather than boys

	xi: lasso2 gu_e9_fees_allocate_2a `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, fe lic(aic) postresults
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_e9_fees_allocate_2a!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
xi: reghdfe gu_e9_fees_allocate_2a negotiation  safespace `first' `second' if treatment_actual!=0, absorb(classid) `se'	
est store reg6

sum gu_e9_fees_allocate_2a if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)


//male child closest in age

	xi: lasso2 gu_f6_school_will_male `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_f6_school_will_male!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
xi: reghdfe gu_f6_school_will_male negotiation  safespace `first' `second'  if treatment_actual!=0, absorb(classid) `se'
est store reg7

sum gu_f6_school_will_male if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)

//female child closest in age

	xi: lasso2 gu_f7_school_will_female `controls' if treatment_actual!=0, adaptive postresults fe lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_f7_school_will_female!=., adaptive postresults fe lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
		
xi: reghdfe gu_f7_school_will_female negotiation  safespace `first' `second'  if treatment_actual!=0, absorb(classid) `se'
est store reg8


sum gu_f7_school_will_female if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)


*add three columns at start: 1 on spillovers with principal components matching, and 1 on DD with male dropout
xml_tab reg1 reg2 reg3_female reg3_male reg4_male reg4_female  reg6 reg7 reg8, save("tables/table_A18.xml") replace sheet("Siblings") below ///
	stats(mean N r2_a) cnames("Pile, Male" "Pile, Female" "Chores, Male" "Chores, Female" "Schoolwork, Male" "Schoolwork, Female" "Pay for Girls Rather than Boys" ///
	"Schooling Complete, Male" "Schooling Complete, Female") keep(negotiation safespace) 
