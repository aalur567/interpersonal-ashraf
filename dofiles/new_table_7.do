use "finaldata/GN_data.dta", clear

local controls  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex   bl_age age2 ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well speak_english_ex ///
	  bl_bemba  chewa tonga nsenga other ngoni lozi tumbuka missing_eth

	
rename tg_t1_tokens_sent_guardian token_g	
replace tg_t3_extra_tokens=tg_t3_extra_tokens-2
gen comm_extra_neg=negotiation*gamecomm*tg_t3_extra_tokens
gen comm_extra_safe=safespace*gamecomm*tg_t3_extra_tokens
gen comm_extra=gamecomm*tg_t3_extra_tokens
gen neg_extra=negotiation*tg_t3_extra_tokens
gen safe_extra=safespace*tg_t3_extra_tokens
	
local se  cluster(classid)
xtset classid

matrix PASS=J(6,4,.)

*get rid of no baseline or ethnic controls sample

	  
foreach var in `controls' { 
	drop if `var'==.
	}





*no controls
xi: reg tg_t10_tokens_sent_girl negotiation treatment_info safespace   ///
 tg_t3_extra_tokens comm_extra_neg neg_extra comm_extra gamecomm commXNeg  commXSS  ///
  gameDG i.token_g  i.classid  if treatment_actual!=0  , `se'
est store reg1
sum tg_t10_tokens_sent_girl if treatment_actual==1 & e(sample)
estadd scalar mean=r(mean)

*control pass-through
lincom tg_t3_extra_tokens  + comm_extra
matrix PASS[1,1]=r(estimate)
matrix PASS[2,1]=r(se)

*neg passthrough
lincom tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg
matrix PASS[3,1]=r(estimate)
matrix PASS[4,1]=r(se)



*double lasso

	xi: lasso2 tg_t10_tokens_sent_girl `controls'  if treatment_actual!= 0 , adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0 & tg_t10_tokens_sent_girl!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}
		
		
xi: reg tg_t10_tokens_sent_girl negotiation treatment_info safespace  `firstset' `secondset'  ///
 tg_t3_extra_tokens comm_extra_neg neg_extra comm_extra gamecomm commXNeg  commXSS  ///
  gameDG i.token_g  i.classid  if treatment_actual!=0  , `se'
est store reg2
sum tg_t10_tokens_sent_girl if treatment_actual==1 & e(sample)
estadd scalar mean=r(mean)


*control pass-through
lincom tg_t3_extra_tokens  + comm_extra
matrix PASS[1,2]=r(estimate)
matrix PASS[2,2]=r(se)


*neg passthrough
lincom tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg
matrix PASS[3,2]=r(estimate)
matrix PASS[4,2]=r(se)

*full controls
xi: reg tg_t10_tokens_sent_girl negotiation safespace treatment_info  ///
 tg_t3_extra_tokens comm_extra_neg neg_extra comm_extra gamecomm commXNeg  commXSS  ///
  `controls' gameDG i.token_g i.classid  if treatment_actual!=0  , `se'
est store reg2rf
sum tg_t10_tokens_sent_girl if treatment_actual==1 &  e(sample)
estadd scalar mean=r(mean)



xi: reg tg_t10_tokens_sent_girl negotiation treatment_info safespace  tg_t3_extra_tokens  ///
comm_extra_neg neg_extra comm_extra  comm_extra_safe safe_extra  gamecomm commXNeg  commXSS  i.token_g i.classid   gameDG  ///
	 if treatment_actual!=0  , `se'
est store reg11
test comm_extra_neg=comm_extra_safe
estadd scalar ptest=r(p)
sum tg_t10_tokens_sent_girl if treatment_actual==1 & e(sample)
estadd scalar mean=r(mean)


*control pass-through
lincom tg_t3_extra_tokens  + comm_extra
matrix PASS[1,3]=r(estimate)
matrix PASS[2,3]=r(se)

*neg passthrough
lincom tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg
matrix PASS[3,3]=r(estimate)
matrix PASS[4,3]=r(se)

*SS
lincom tg_t3_extra_tokens  + comm_extra  + safe_extra  + comm_extra_safe
matrix PASS[5,3]=r(estimate)
matrix PASS[6,3]=r(se)

*differences in pass-through

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  + safe_extra  + comm_extra_safe)

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  )


*double lasso

	xi: lasso2 tg_t10_tokens_sent_girl `controls'  if treatment_actual!= 0 , adaptive  fe  
	lasso2, lic(aic) postresults fe
	local firstset=e(selected)
	
	if "`firstset'"=="." { 
		local firstset 
		}
		
	
	xi: lasso2 negotiation `controls'  if treatment_actual!=0  & tg_t10_tokens_sent_girl!=., adaptive  fe  
	lasso2, lic(aic) postresults fe
	local secondset=e(selected)
	
	if "`secondset'"=="." { 
		local secondset 
		}
		

xi: reg tg_t10_tokens_sent_girl negotiation treatment_info safespace  tg_t3_extra_tokens `firstset' `secondset' ///
comm_extra_neg neg_extra comm_extra  comm_extra_safe safe_extra  gamecomm commXNeg   commXSS  i.token_g i.classid   gameDG  ///
	 if treatment_actual!=0  , `se'
est store reg3
test comm_extra_neg=comm_extra_safe
estadd scalar ptest=r(p)
sum tg_t10_tokens_sent_girl if treatment_actual==1 & e(sample)
estadd scalar mean=r(mean)




*control pass-through
lincom tg_t3_extra_tokens  + comm_extra
matrix PASS[1,4]=r(estimate)
matrix PASS[2,4]=r(se)

*neg passthrough
lincom tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg
matrix PASS[3,4]=r(estimate)
matrix PASS[4,4]=r(se)

*SS
lincom tg_t3_extra_tokens  + comm_extra  + safe_extra  + comm_extra_safe
matrix PASS[5,4]=r(estimate)
matrix PASS[6,4]=r(se)

*differences in pass-through

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  + safe_extra  + comm_extra_safe)

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  )





xi: reg tg_t10_tokens_sent_girl negotiation safespace treatment_info i.classid tg_t3_extra_tokens ///
comm_extra_neg neg_extra comm_extra  comm_extra_safe safe_extra  gamecomm commXNeg  commXSS  i.token_g   `controls' gameDG  ///
	 if treatment_actual!=0  , `se' 
est store reg3rf 
test comm_extra_neg=comm_extra_safe
estadd scalar ptest=r(p)
sum tg_t10_tokens_sent_girl if treatment_actual==1 & e(sample)
estadd scalar mean=r(mean)


*differences in pass-through

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  + safe_extra  + comm_extra_safe)

lincom (tg_t3_extra_tokens  + comm_extra  + neg_extra  + comm_extra_neg) - (tg_t3_extra_tokens  + comm_extra  )



xml_tab reg1 reg2  reg11    reg3rf, save("tables/new_table_7.xml") replace below stats(mean ptest N r2_a) ///
	keep(tg_t3_extra_tokens comm_extra_neg  neg_extra comm_extra safe_extra comm_extra_safe   ///
	      negotiation safespace  gamecomm commXNeg commXSS) ///
	cnames("Tokens Returned, No Controls" "Tokens Returned, Double Lasso" ///
	"Tokens Returned" "Double Lasso") sheet("Transfers")


xml_tab PASS, save("tables/new_table_7.xml") append  ///
	cnames("Tokens Returned, No Controls" "Tokens Returned, Par Controls" "Tokens Returned, Full Controls" "Tokens Returned" "Tokens Returned"  "Tokens Returned") sheet("PassThrough") ///
	rnames("Control" "Se" "Negotiation" "Se" "Safe Space" "Se")

