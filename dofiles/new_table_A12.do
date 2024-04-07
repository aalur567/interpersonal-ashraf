
use "finaldata\GN_data.dta", clear


local controls gamecomm 


local se cluster(classid)

gen ts_comm=tg_t1_tokens_sent_guardian*gamecomm
rename tg_t1_tokens_sent_guardian token_s

keep if gameDG==0

xi: reg alt_human_capital token_s   `controls' if treatment_actual!=0 , `se'  
est store reg1
sum alt_human_capital if treatment_actual==1, d
estadd scalar mean=r(mean)

xi: reg enrolled3 token_s   `controls'  if treatment_actual!=0  , `se' 
est store reg2
sum enrolled3 if treatment_actual==1, d
estadd scalar mean=r(mean)

xi: reg enrolled4 token_s   `controls' if treatment_actual!=0 , `se' 
est store reg3
sum enrolled4 if treatment_actual==1, d
estadd scalar mean=r(mean)

xi: reg enrolled5 token_s   `controls' if treatment_actual!=0  , `se' 
est store reg4
sum enrolled5 if treatment_actual==1, d
estadd scalar mean=r(mean)


xi: reg morning10 token_s   `controls' if treatment_actual!=0 , `se' 
est store reg5
sum enrolled4 if treatment_actual==1, d
estadd scalar mean=r(mean)

xi: reg morning11 token_s   `controls' if treatment_actual!=0  , `se'   
est store reg6
sum enrolled5 if treatment_actual==1, d
estadd scalar mean=r(mean)

xml_tab reg1 reg2 reg3 reg4 reg5 reg6, save("tables/table_A12.xml") below replace stats(mean N r2_a) keep(token_s) cnames("Human Capital Index" ///
	"9th Grade Erollment" "10th Grade" "11th Grade" "Morning, Grade 10" "Morning, Grade 11") note("IG sample only.")
