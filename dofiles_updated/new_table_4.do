use  "finaldata/GN_data.dta", clear



local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth 
	


foreach var in zero took_nat_exam   above_73_eng above_73_math     avg_att_rate  ever_pregnant  { 	
	sum `var' if treatment_actual==1, d
	local s_`var'=r(sd)
	}


foreach var in  `controls' { 
	drop if `var'==.
	}
	
drop if treatment_actual==0
	


local se cluster(classid)

xtset classid

	xi: lasso2 zero `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & zero!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

xi: reghdfe zero negotiation safespace treatment_info  `first' `second'   if treatment_actual!=0  ,  `se' absorb(classid)

local zerof="`first'"
local zeros="`second'"



local tran=_b[negotiation]/`s_zero'

estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_zero'
estadd scalar tran_safe=`tran' 

	test negotiation=safespace
	estadd scalar testp=r(p)
	
	sum zero if treatment_actual==1 & e(sample), d
	estadd scalar mean = r(mean)
	est store reg1


	xi: lasso2 took_nat_exam `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe 
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & took_nat_exam!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

local tooknatf="`first'"
local tooknats="`second'"
	
xi: reghdfe took_nat_exam negotiation safespace treatment_info  `first' `second'    if treatment_actual!=0 ,  `se' absorb(classid)


local tran=_b[negotiation]/`s_took_nat_exam'
estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_took_nat_exam'
estadd scalar tran_safe=`tran' 



	test negotiation=safespace
	estadd scalar testp=r(p)
sum took_nat_exam if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)
est store reg2

	xi: lasso2 above_73_math `controls' if treatment_actual!=0 , adaptive postresults fe 
	lasso2, lic(aic) postresults fe

	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & above_73_math!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}

	
local abovemf="`first'"
local abovems="`second'"
	
xi: reghdfe above_73_math  negotiation safespace  treatment_info `first' `second'   if treatment_actual!=0 ,  `se' absorb(classid)


local tran=_b[negotiation]/`s_above_73_math'
estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_above_73_math'
estadd scalar tran_safe=`tran' 

	test negotiation=safespace
	estadd scalar testp=r(p)
sum above_73_math if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)
est store reg3


	xi: lasso2 above_73_eng `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & above_73_eng!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
local aboveef="`first'"
local abovees="`second'"	
		
xi: reghdfe above_73_eng  negotiation safespace treatment_info `first' `second'   if treatment_actual!=0 ,  `se' absorb(classid)




local tran=_b[negotiation]/`s_above_73_eng'
estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_above_73_eng'
estadd scalar tran_safe=`tran' 


	test negotiation=safespace
	estadd scalar testp=r(p)
sum above_73_eng if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)

est store reg3_2

	xi: lasso2 avg_att_rate `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & avg_att_rate!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe	
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
local attf="`first'"
local atts="`second'"

xi: reghdfe avg_att_rate  negotiation safespace treatment_info `first' `second'   if treatment_actual!=0 ,  `se' absorb(classid)



local tran=_b[negotiation]/`s_avg_att_rate'
estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_avg_att_rate'
estadd scalar tran_safe=`tran' 


	test negotiation=safespace
	estadd scalar testp=r(p)
sum avg_att_rate if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)
est store reg4



	xi: lasso2 ever_pregnant `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & ever_pregnant!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
local pregf="`first'"
local pregs="`second'"


xi: reghdfe ever_pregnant negotiation  safespace treatment_info `first' `second'   if treatment_actual!=0 ,  `se' absorb(classid)

local tran=_b[negotiation]/`s_ever_pregnant'
estadd scalar tran_neg=`tran' 

local tran=_b[safespace]/`s_ever_pregnant'
estadd scalar tran_safe=`tran' 

	test negotiation=safespace
	estadd scalar testp=r(p)
sum ever_pregnant if treatment_actual==1 & e(sample), d
estadd scalar mean=r(mean)
est store reg6


	xi: lasso2 alt_human_capital `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe 
	local first=e(selected)

	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & alt_human_capital!=., adaptive postresults fe  
	lasso2, lic(aic) postresults fe 
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
	

	xi: reghdfe alt_human negotiation   safespace  treatment_info    `first' `second' if treatment_actual!=0  ,  `se' absorb(classid)
	test negotiation=safespace


	estadd scalar testp=r(p)
	sum alt_human_capital if treatment_actual==1 & e(sample), d
	estadd scalar mean=r(mean)
	est store reg7

	local hci_first "`first'"
	local hci_second "`second'"


	

xml_tab  reg7  reg1 reg2 reg3 reg3_2 reg4 reg6   , save("tables/new_table_4.xml") replace below stats( tran_neg tran_safe mean testp   N r2_a) ///
	keep(negotiation safespace  ) ///
	cnames( "Human Capital Investment Index"  "Paid All Fees, Year 9" "Took National Exam" "Top 25, Math" "Top 25, Eng" "Average Attendence Rate" ///
	"Ever Pregnant"  "HC, No Test Scores")  sheet("OLS")


*aes


tempfile data
save `data', replace

gen regnum=1

forval x=2/6 { 
	append using `data'
	replace regnum=`x' if regnum==.
	}
	
gen outcome=zero if regnum==1
sum outcome if negotiation==0 & treatment_actual!=0 & safespace==0, d
local sd_1=r(sd)

local x=2
foreach out in took_nat_exam above_73_eng above_73_math avg_att  ever_pregnant   { 
	gen temp=`out' if regnum==`x'
	sum temp if treatment_actual!=0 & negotiation==0 & safespace==0, d
	local sd_`x'=r(sd)
	replace outcome=temp if regnum==`x'
	local x=`x'+1
	drop temp
	}

forval x= 1/6 { 
	gen negotiation_`x'= negotiation*(regnum==`x')
	gen safespace_`x'= safespace*(regnum==`x')
	gen treatment_info_`x'= treatment_info*(regnum==`x')
	}
	
local controls
local allcontrols
foreach var of varlist  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_excel speak_nyanja_excel read_english_excel speak_english_excel     ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well bl_age age2  bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth  { 
	forval x=1/6 { 
		gen `var'_`x'=`var'*(regnum==`x')
		local allcontrols `var'_`x' `allcontrols'
		}
	}
	

	
local hci_aes
foreach var in `hci_first' `hci_second' { 
	forval x=1/5 { 
		local hci_aes `hci_aes' `var'_`x'
		}
	}	
	

local full_aes
foreach var in `full_first' `full_second' { 
	forval x=1/6 { 
		local full_aes `full_aes' `var'_`x'
		}
	}	
	
	
matrix OUT=J(1,6,0)

egen schoolid_num=group(schoolid class regnum)






xi: reghdfe outcome negotiation_* safespace_*  treatment_info_* `hci_aes' if treatment_actual!=0 & regnum!=6, absorb(schoolid_num ) `se'

*human capital
lincom 1/5*(negotiation_1/`sd_1' + negotiation_2/`sd_2' + negotiation_3/`sd_3' + negotiation_4/`sd_4' + negotiation_5/`sd_5' ) 
matrix OUT[1,1]=r(estimate)
matrix OUT[1,2]=r(se)

lincom 1/5*(safespace_1/`sd_1' + safespace_2/`sd_2' + safespace_3/`sd_3' + safespace_4/`sd_4' + safespace_5/`sd_5' ) 
matrix OUT[1,3]=r(estimate)
matrix OUT[1,4]=r(se)

lincom 1/5*(treatment_info_1/`sd_1' + treatment_info_2/`sd_2' + treatment_info_3/`sd_3' + treatment_info_4/`sd_4' + treatment_info_5/`sd_5'  ) 
matrix OUT[1,5]=r(estimate)
matrix OUT[1,6]=r(se)

*test

lincom 1/5*(negotiation_1/`sd_1' + negotiation_2/`sd_2' + negotiation_3/`sd_3' + negotiation_4/`sd_4' + negotiation_5/`sd_5'  ) - ///
1/5*(safespace_1/`sd_1' + safespace_2/`sd_2' + safespace_3/`sd_3' + safespace_4/`sd_4' + safespace_5/`sd_5' ) 


lincom 1/5*(negotiation_1/`sd_1' + negotiation_2/`sd_2' + negotiation_3/`sd_3' + negotiation_4/`sd_4' + negotiation_5/`sd_5'  ) - ///
1/5*(treatment_info_1/`sd_1' + treatment_info_2/`sd_2' + treatment_info_3/`sd_3' + treatment_info_4/`sd_4' + treatment_info_5/`sd_5' ) 


xml_tab OUT  , save("tables/new_table_4.xml") append  ///
	cnames("Negotiation Coef" "Se" "SS Coef" "Se" "Information Coef" "Se") rnames("Human Capital AES" ) sheet("AES")
