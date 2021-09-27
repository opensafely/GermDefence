
global gd "C:\Users\dy21108\OneDrive - University of Bristol\Documents\GitHub\GermDefence"


global gd "`c(pwd)'"
 
use "$gd/output/input_practice.dta", clear

tab practice_trial_arm

*reformat variables
gen n=1

gen sex2=0
replace sex2=1 if sex=="F"

gen deprivation_pctile=real(practice_deprivation_pctile)

gen ethnic_minority_pct=0
replace ethnic_minority_pct=real(practice_ethmin) if practice_ethmin != "NA"

gen n_users=0
replace n_users=real(practice_n_visits) if practice_n_visits != "NA"


collapse (median) age (sum) sex2 (first) practice_trial_arm deprivation_pctile ethnic_minority_pct n_users (count) list_size=n, by(practice_ID)