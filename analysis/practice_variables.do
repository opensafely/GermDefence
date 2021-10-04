
/*=============================================================================
DO FILE NAME:			practice_variables.do
PROJECT:				Germ Defence
AUTHOR:					S Walter
DATE: 					Sept 2021					
DESCRIPTION OF FILE:	Set up practice-level variables to be merged onto 
						main study data 
DATASETS USED:			data in memory ($output/input_practice.dta)
DATASETS CREATED: 		practice_variables.dta
OTHER OUTPUT: 			none		
==============================================================================*/

global gd "`c(pwd)'"
 
use "$gd/output/input_practice.dta", clear

*check numbers of practices
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

*create practice-level data set
collapse (median) median_age=age (sum) n_female=sex2 (first) practice_trial_arm deprivation_pctile ethnic_minority_pct n_users (count) list_size=n, by(practice_id)

*additional variable set up
gen female_pct=n_female/list_size

gen intervention=0
replace intervention=1 if practice_trial_arm=="1"

tab intervention
summarize female_pct median_age deprivation_pctile ethnic_minority_pct, detail

*save practice-level data for use in main analysis programs
save "$gd/output/practice_variables.dta", replace
export excel using "$gd/output/practice_variables.xlsx", firstrow(variables) replace