/*======================================================================================
DO FILE NAME:			process_eval.do
PROJECT:				Germ Defence
AUTHOR:					S Walter
DATE: 					Sept 2021					
DESCRIPTION OF FILE:	Merge data for each outcome into one 
						Run intervention-control comparisons - as per protocol analysis
						Run interrupted time series models as secondary analysi
DATASETS USED:			data in memory ($output/input_practice.dta)
DATASETS CREATED: 		practice_variables.dta
OTHER OUTPUT: 			none		
=======================================================================================*/

global gd "`c(pwd)'"
	
use "$gd/output/process_eval.dta", replace


gen user_rate=n_users/listsize

gen imd_decile2=real(imd_decile)


*** 1. Main process analysis - all practices

** A. Model outcomes with user rate as continuous covariate

xi: glm rti_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("RTI")
putexcel A1=matrix(r(table)), names

xi: glm arti_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


** B. Model user rate as categorical

gen users_cat3=0
replace users_cat3=1 if user_rate>0.01 & user_rate<0.1
replace users_cat3=2 if user_rate>=0.1

xi: glm rti_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("RTI")
putexcel A1=matrix(r(table)), names

xi: glm arti_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd/output/process_eval2.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


** 3. Model only practices with >1% uptake

*A. User rate as continuous


*B. User rate as categorical 