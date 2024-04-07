*boys in edstats DD


use "finaldata\EdAssist2001_2016PanelFull.dta" , clear
gen post=0
replace post=1 if year>=2014
drop if year>2014


gen intervention=0
replace intervention=1 if GNIntervention==1
gen post_int=post*intervention

xi: areg g9mRate  post_int i.year , absorb(code) cluster(code)
est store grade9
sum g9mRate if e(sample) & intervention==0


	  


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
		   treatment_info 	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	 
	

local matchcontrols  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex      bl_age  ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well  
	


use "finaldata\GN_data.dta", clear

tostring ID, replace
capture drop _merge

foreach var in `controls' {
	drop if `var'==.
	}




gen treated=0
replace treated=1 if treatment_actual!=0
replace treated=. if treatment_actual==.


egen school_tag=tag(schoolid)
local cluster(schoolid)



xi: logit treated    `matchcontrols' , cluster(schoolid)
est store pscorelogit

xml_tab pscorelogit, save("tables/table_A25.xml") replace below stats(N r2_a) ///
	sheet("PscorePredictors")

set seed 999

pscore treated `matchcontrols', pscore(pscore1) blockid(myblocks) comsup detail

replace enrolled3=enrolled2 if enrolled2!=.
*we stratify on propensity score



xi: reg enrolled3 treated  negotiation safespace treatment_info   , cluster(schoolid) 
est store reg9


	xi: lasso2 enrolled3 `controls' , adaptive postresults  lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 treated `controls' if enrolled3!=. , adaptive postresults  lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reg enrolled3 treated  negotiation safespace `first' `second' treatment_info , cluster(schoolid)
est store reg10

xi: reg enrolled3 treated   negotiation safespace `controls'  treatment_info , cluster(schoolid) 
est store reg11

	xi: lasso2 enrolled3 `controls' if comsup==1 , adaptive postresults  lic(aic) 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 treated `controls' if enrolled3!=. & comsup==1, adaptive postresults  lic(aic) 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: areg enrolled3 treated   negotiation safespace `first' `second'  treatment_info if comsup==1, cluster(schoolid) absorb(myblocks)
est store reg12



xml_tab  grade9 reg9 reg10  reg12  , save("tables/table_A22.xml") replace below stats(N r2_a) ///
	sheet("EnrollmentSpillovers") cnames( ///
		///
		"Boys Grade 9 Dropout, DD" "Grade 9 Enroll"  "Grade 9 Enroll, Double Lasso" "Stratified by Pscore") keep(post_int treated negotiation safespace treatment_info) stats(N df_r r2_a)
		

	
