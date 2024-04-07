use "finaldata\GN_data.dta", clear


local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex  bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
  bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth
	  


foreach var in  `controls' { 
	drop if `var'==.
	}
	

xtset classid
local se cluster(classid)
local count=1

*full controls

foreach out in qu_k1_code  qu_k3_code qu_k4_code   qu_k134_code   { 

	xi: lasso2 `out' `controls' if treatment_actual!=0, adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local first=e(selected)
	
	if "`first'"=="." { 
		local first
		}
		
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & `out'!=., adaptive postresults fe 
	lasso2, lic(aic) postresults fe
	local second=e(selected)
	
	if "`second'"=="." { 
		local second
		}
		
	xi: reghdfe `out' negotiation safespace  treatment_info `first' `second'  if treatment_actual!=0 ,  `se' absorb(classid)
	
	test negotiation=safespace
	estadd scalar testp=r(p)

	sum `out' if treatment_actual==1 & e(sample)==1, d
	estadd scalar mean=r(mean)
	est store reg`count'
	local count=`count'+1
	}

xml_tab  reg1 reg2 reg3 reg4, save("tables/table_A3.xml") replace stats(testp mean N r2_a) below ///
	keep(negotiation safespace) sheet("Knowledge") cnames( ///
	"Question 1" "Question 2" "Question 3" "Combined" )
	
