use "finaldata\GN_data.dta", clear

	
local sumvars  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex        ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well   bl_age 
	
local keepcontrols  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex        ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well   bl_age 
	



local se cluster(classid)


matrix SAMPLE=J(15, 9, 0)
local count=1
foreach var in `sumvars' { 

	sum `var' if treatment_actual!=0 , d
	matrix SAMPLE[`count', 1] =r(mean)
	matrix SAMPLE[`count', 2] =r(sd)
	matrix SAMPLE[`count', 9] =r(N)
	
	*neg vs control
	reghdfe  `var' negotiation treatment_info if treatment_actual!=0 & (treatment_actual==1| treatment_actual==3) ,  `se' absorb( classid) 	
	matrix SAMPLE[`count', 3] =_b[negotiation]
	matrix SAMPLE[`count', 4] =_se[negotiation]	
	
	*neg vs SS
	reghdfe  `var' negotiation treatment_info if treatment_actual!=0 & (treatment_actual==3| treatment_actual==2) ,  `se' absorb( classid)	
	matrix SAMPLE[`count', 5] =_b[negotiation]
	matrix SAMPLE[`count', 6] =_se[negotiation]	
	
	*SS vs control
	reghdfe  `var' safespace treatment_info if treatment_actual!=0 & (treatment_actual==1| treatment_actual==2) ,  `se' absorb( classid)
	matrix SAMPLE[`count', 7] =_b[safespace]
	matrix SAMPLE[`count', 8] =_se[safespace]	
	
	
	local count=`count'+1
	}
	
*joint tests

reghdfe   negotiation `keepcontrols' treatment_info  if treatment_actual!=0 & (treatment_actual==1| treatment_actual==3) ,  `se' absorb( classid)
test `keepcontrols'
matrix SAMPLE[`count', 3] =r(p)

reghdfe   negotiation `keepcontrols' treatment_info  if treatment_actual!=0 & (treatment_actual==3| treatment_actual==2) ,  `se' absorb( classid)
test `keepcontrols'
matrix SAMPLE[`count', 5] =r(p)

reghdfe   safespace `keepcontrols'  treatment_info  if treatment_actual!=0 & (treatment_actual==1| treatment_actual==2) ,   `se'  absorb( classid)	
test `keepcontrols'
matrix SAMPLE[`count', 7] =r(p)



xml_tab SAMPLE, save("tables/new_table_1.xml") replace sheet("Table1") ///
cnames("Mean" "SD" "Coeff (Neg. vs Control)" "SE" "Coeff (Neg vs. SS)" "SE" "Coeff (SS vs Control)" "SE" "N") rnames("Both Parents Alive" "Live With Bio Dad" "Live With Bio Mom" "Live With Mom and Dad" "Parents Pay Fees" "Read Nyanja Excellently" ///
	"Speak Nyanja Excellently" "Read English Excellently" "Speak English Excellently"   "Read Nyanja Well" "Speak Nyanja Well" ///
	"Read English Well" "Speak English Well"  "Age" "P-value (joint test)")
