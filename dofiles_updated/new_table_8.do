use "finaldata/GN_data.dta", clear



local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	  bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  

*when do chores get done
foreach x in before during after { 
	gen any_`x'=0
	replace any_`x'=1 if ml_chore_`x'_schl>0 
	replace any_`x'=. if ml_chore_`x'_schl==.
	}
	
gen friday=0
replace friday=1 if ml_time_use_day==5
gen neg_friday=negotiation*friday
gen safe_friday=safespace*friday

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


factor  read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex read_nyanja_well speak_nyanja_well read_english_well speak_english_well 
predict ability_factor
gen neg_ability=negotiation*ability_factor
gen safe_ability=safespace*ability_factor

local se cluster(classid)

foreach var in  `controls' { 
	drop if `var'==.
	}
	

xtset classid

	xi: lasso2 ml_b7_asked_more_food_yes `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_b7_asked_more_food_yes!=., adaptive postresults fe  
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg ml_b7_asked_more_food_yes negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se'

est store reg1
test negotiation = safespace
estadd scalar testp=r(p)
sum ml_b7_asked_more_food_yes if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 gu_e2a_difficult_chores `controls' if treatment_actual!=0, adaptive postresults fe 

	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_e2a_difficult_chores!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		

reghdfe gu_e2a_difficult_chores negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se' absorb(classid)
est store reg2
test negotiation = safespace
estadd scalar testp=r(p)
sum gu_e2a_difficult_chores if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)


	xi: lasso2 ml_chore_before_schl `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_chore_before_schl!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg ml_chore_before_schl negotiation  safespace `first' `second' i.classid i.ml_time_use_day if treatment_actual!=0,  `se'
est store reg3
test negotiation = safespace
estadd scalar testp=r(p)
sum ml_chore_before_schl if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)


	xi: lasso2 ml_chore_during_schl `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_chore_during_schl!=., adaptive postresults fe
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg ml_chore_during_schl negotiation  safespace `first' `second' i.classid  i.ml_time_use_day if treatment_actual!=0,  `se'
est store reg4
test negotiation = safespace
estadd scalar testp=r(p)
sum ml_chore_during_schl if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 ml_chore_after_schl `controls' if treatment_actual!=0, adaptive postresults fe
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}

	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_chore_after_schl!=., adaptive postresults fe
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg ml_chore_after_schl negotiation  safespace `first' `second' i.classid i.ml_time_use_day if treatment_actual!=0,  `se'
est store reg5
test negotiation = safespace
estadd scalar testp=r(p)
sum ml_chore_after_schl if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 ml_b1_hrs_spent_housework `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}

	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_b1_hrs_spent_housework!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg ml_b1_hrs_spent_housework negotiation  safespace  neg_friday safe_friday friday `first' `second' i.classid  i.ml_time_use_day if treatment_actual!=0,  `se'
est store reg6
test neg_friday = safe_friday
estadd scalar testp=r(p)
sum ml_b1_hrs_spent_housework if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 gu_e2g_difficult_temper `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}

	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_e2g_difficult_temper!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reg gu_e2g_difficult_temper negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg7
test negotiation = safespace
estadd scalar testp=r(p)
sum gu_e2g_difficult_temper if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)


	xi: lasso2 gu_d7_rude `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}



	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d7_rude!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}


xi: reg gu_d7_rude negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg8
test negotiation = safespace
estadd scalar testp=r(p)
sum gu_d7_rude if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)


	xi: lasso2 gu_d6_be_respectful `controls' if treatment_actual!=0, adaptive postresults fe
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}


	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_d6_be_respectful!=., adaptive postresults fe  
	lasso2, lic(aic) postresults fe 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
xi: reg gu_d6_be_respectful negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg9
test negotiation = safespace
estadd scalar testp=r(p)
sum gu_d6_be_respectful if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 gu_f13a_smarts_class `controls' if treatment_actual!=0,  postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}

	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & gu_f13a_smarts_class!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
				

xi: reg gu_f13a_smarts_class negotiation  safespace `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg10
test negotiation = safespace
estadd scalar testp=r(p)
sum gu_f13a_smarts_class if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)



xi: reg gu_f13a_smarts_class negotiation  safespace neg_ability ability_factor safe_ability  `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg11
test neg_ability = safe_ability
estadd scalar testp=r(p)
sum gu_f13a_smarts_class if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)

	xi: lasso2 ml_d1_grade_complete_want `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ml_d1_grade_complete_want!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
			

xi: reg ml_d1_grade_complete_want negotiation  safespace    `first' `second' i.classid if treatment_actual!=0,  `se'
est store reg12
test negotiation=safespace
estadd scalar testp=r(p)
sum ml_d1_grade_complete_want if e(sample) & treatment_actual==1
estadd scalar depmean=r(mean)


xml_tab reg1 reg2 reg7 reg8  reg10 reg11 reg12 reg3 reg4 reg5 reg6, save("tables/new_table_8.xml") ///
	replace below stats(testp depmean N r2_a) ///
	keep(negotiation safespace neg_friday safe_friday neg_ability safe_ability ) ///
	cnames("More Food" "Difficulty Getting to do Chores" "Difficulty Controlling Temper" "Girl is Rude" "Natural Ability"  "Natural Ability" ///
	 "Grade Wants to Complete" "Chores Before School" "Chores During School" "Chores After School" "Total Weekday Chores")
	
