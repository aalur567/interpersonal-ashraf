use  "finaldata\GN_data.dta", clear



local se cluster(classid)
xtset classid



local short	 both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_excel ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_excel   ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth bl_age age2


local longcontrols
foreach var in  `short' { 
	*gen M`var'=0
	*replace M`var'=1 if `var'==.
	replace `var'=0 if `var'==.
	local longcontrols `longcontrols' `var' 
	}
	


local longcontrols `longcontrols' no_baseline no_eth



gen days_neg=0
replace days_neg=1  if negotiation==1 & (daysattended>=5)

gen days_ss=0
replace days_ss=1  if safespace==1 & (daysattended>=5)

local se "cluster(classid)"

local count=3
forvalues i = 3/5{

	xi:  ivreghdfe enrolled`i' (days_neg days_ss = negotiation safespace)  treatment_info  if treatment_actual!=0 ,  `se' absorb(classid)

	sum enrolled`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	
	test days_neg=days_ss
	estadd scalar testp=r(p)
	
	
	est store reg`count'
	local count=`count'+1
	

	
	xi: lasso2 enrolled`i' `longcontrols'  if treatment_actual!=0,  adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	lasso2 negotiation `longcontrols'   if treatment_actual!=0 & enrolled`i'!=.,  adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}

	local lassocontrols `firstset' `secondset' 
	
	xi: ivreghdfe enrolled`i' (days_neg days_ss = negotiation safespace) treatment_info `lassocontrols'  no_baseline if treatment_actual!=0,  `se' absorb(classid)

	sum enrolled`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	
	test days_neg=days_ss
	estadd scalar testp=r(p)
	

	
	est store reg`count'
	local count=`count'+1

	xi: ivreghdfe enrolled`i' (days_neg days_ss = negotiation safespace)  treatment_info `longcontrols' if treatment_actual!=0,  `se' absorb(classid)

	test days_neg=days_ss
	estadd scalar testp=r(p)
	
	sum enrolled`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	


	
	est store reg`count'
	local count=`count'+1

}


xml_tab  reg3 reg4  reg6 reg7  reg9 reg10 , save("tables/table_A6.xml") replace stats(testp  mean N r2_a) below ///
	keep(days_neg days_ss ) sheet("IVMissingDummies") cnames( ///
	"Grade 9" "Grade 9"  "Grade 10" "Grade 10"   ///
	"Grade 11" "Grade 11" )


local count=1	
forvalues i = 10/11{

	xi: ivreghdfe morning`i' (days_neg days_ss = negotiation safespace)  treatment_info  if treatment_actual!=0 ,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	
	test days_neg=days_ss
	estadd scalar testp=r(p)
	
	
	est store reg`count'
	local count=`count'+1

	xi: lasso2 morning`i' `longcontrols'  if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe

	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation   `longcontrols'  if treatment_actual!=0 & morning`i'!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}
	

		
	local lassocontrols `firstset' `secondset' 

	xi: ivreghdfe morning`i' (days_neg days_ss = negotiation safespace)  treatment_info `lassocontrols'   no_baseline if treatment_actual!=0,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	
	test days_neg=days_ss
	estadd scalar testp=r(p)
	
	
	est store reg`count'
	local count=`count'+1

	xi: ivreghdfe morning`i' (days_neg days_ss = negotiation safespace) treatment_info `longcontrols' if treatment_actual!=0,  `se' absorb(classid)

	sum morning`i' if treatment_actual==1
	estadd scalar mean=r(mean)
	
	test days_neg=days_ss
	estadd scalar testp=r(p)
	
	
	est store reg`count'
	local count=`count'+1

}


xml_tab  reg1 reg2  reg4 reg5 , save("tables/table_A6.xml") append stats(testp  mean N r2_a) below ///
	keep(days_neg days_ss ) sheet("MorningMissingDummiesIV") cnames( ///
	 "Grade 10" "Grade 10"  ///
	"Grade 11" "Grade 11" )
