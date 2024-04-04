
use "finaldata\GN_data.dta", clear

local keepcontrols  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_excel speak_nyanja_excel read_english_excel speak_english_excel     bl_age   ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well 
	
*look at selection
gen appeared=0
replace appeared=1 if  tg_game_type_enc !=.

foreach var in negotiation safespace `keepcontrols' { 
	xi: reghdfe appeared `var'  if treatment_actual!=0, absorb(classid) cluster(classid)
	est store `var'
	local ests `ests' `var'
	}


xml_tab `ests'  , save("tables/table_A10.xml") replace below stats(N r2_a) ///
	note("All regressions include school FE and controls from the baseline for both parents alive, lives with biological dad, lives with biological mom, lives with mom and dad, parents pay fees, reads and writes Nyanga and English excellently, age, and ethnicity FE.") ///
	title("Effect of Different Characteristics on Likelihood an Individual is in the Midline") sheet("Cols12")

 *what predicts midline show up interacted with negotiation
 local ests
 
foreach var in negotiation safespace `keepcontrols' { 
	gen inter=negotiation*`var'
	xi: reghdfe appeared `var' inter negotiation  if treatment_actual!=0, absorb(classid) cluster(classid)
	est store `var'
	local ests `ests' `var'
	drop inter
	}



xml_tab `ests'  , save("tables/table_A10.xml") append below stats(N r2_a) ///
	note("All regressions include school FE and controls from the baseline for both parents alive, lives with biological dad, lives with biological mom, lives with mom and dad, parents pay fees, reads and writes Nyanga and English excellently, age, and ethnicity FE.") ///
	title("Effect of Different Characteristics on Likelihood an Individual is in the Midline") sheet("Cols3456") keep(inter `keepcontrols'  )
	


