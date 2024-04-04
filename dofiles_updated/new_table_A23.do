use "finaldata/GN_data.dta", clear


*balance with stratified prop matching
local matchcontrols  both_parents_alive live_with_bio_dad live_with_bio_mom live_with_mom_dad ///
	parents_pay_fees read_nyanja_e speak_nyanja_e read_english_ex speak_english_ex      bl_age  ///
	read_nyanja_well speak_nyanja_well read_english_well speak_english_well  
	
	
gen treated=0
replace treated=1 if treatment_actual!=0
replace treated=. if treatment_actual==.

pscore treated `matchcontrols', pscore(pscore1) blockid(myblocks) comsup detail

matrix BALANCE=J(15, 4, 0)
local count=1
foreach var in `matchcontrols' { 
	reg `var'  treated if negotiation==0 & safespace==0, cluster(schoolid)
	matrix BALANCE[`count', 1] =_b[treated]
	matrix BALANCE[`count', 2]=_se[treated]
	
		xi: areg `var' treated  if  negotiation==0 & safespace==0 & comsup==1,  cluster(schoolid) absorb(myblock)
		matrix BALANCE[`count',3]=_b[treated]
		matrix BALANCE[`count', 4] =_se[treated]
		local row=`row'+1
		
	local count=`count'+1
	}
	
reg treated `matchcontrols' if negotiation==0 & safespace==0, cluster(schoolid)
test `matchcontrols'
matrix BALANCE[`count', 1]=r(p)

	areg treated `matchcontrols'  if  negotiation==0 & safespace==0 & comsup==1, cluster(schoolid) absorb(myblock)
	test `matchcontrols'
	matrix BALANCE[`count', 3] = r(p)

xml_tab BALANCE, save("tables/table_A23.xml") sheet("Balance") replace ///
	cnames("Coef." "Se" "Coef., Stratifed" "Se") rnames("Both Parents Alive" "Live with Bio Dad" "Live with Bio Mom" /// 
	"Live With Mom and Dad" "Parents Pay Fees" "Read Nyanja Excellently" "Speak Nyanja Excellently" "Read English Excellently" ///
	"Speak English Excellently " "Age" "Read Nyanja Well" "Speak Nyanja Well" "Read English Well" "Speak English Well" "Joint Test")
	

