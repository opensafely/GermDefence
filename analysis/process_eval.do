/*======================================================================================
DO FILE NAME:			process_eval.do
PROJECT:				Germ Defence
AUTHOR:					S Walter
DATE: 					Sept 2021					
DESCRIPTION OF FILE:	Analyse website usage data for intervention group
DATASETS USED:			data in memory ($output/process_eval.dta)
OUTPUT CREATED: 		procees_eval.xlsx, process_eval_cat.xlsx
						procees_eval2.xlsx, process_eval_cat2.xlsx
=======================================================================================*/

global gd "`c(pwd)'"
	
use "$gd/output/process_eval.dta", replace

*limit to intervention practices only
drop if intervention!=1

gen user_rate=n_users/list_size

xtile deprivation_decile = deprivation_pctile, nq(10)


*** 1. Main process analysis - all intervention practices

** A. Model outcomes with user rate as continuous covariate

* i. deprivation as continuous

glm rti_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


* ii. deprivation as categorical (deciles)

xi: glm rti_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("RTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm arti_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("aRTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("gastro2") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("coviddiag2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympsens2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("covidsympspec2") modify
putexcel A1=matrix(r(table)), names

xi: glm antibio_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("antibio2") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval.xlsx", sheet("adm2") modify
putexcel A1=matrix(r(table)), names


** B. Model user rate as categorical

gen users_cat3=0
replace users_cat3=1 if user_rate>0.01 & user_rate<0.1
replace users_cat3=2 if user_rate>=0.1

* i. deprivation as continuous

glm rti_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events users_cat3 deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


* ii. deprivation as categorical (deciles)

xi: glm rti_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("RTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm arti_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("aRTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("gastro2") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("coviddiag2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("covidsympsens2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("covidsympspec2") modify
putexcel A1=matrix(r(table)), names

xi: glm antbio_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("antibio2") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_events users_cat3 i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat.xlsx", sheet("adm2") modify
putexcel A1=matrix(r(table)), names


** 3. Model only practices with >1% uptake

drop if user_rate<0.01


**A. User rate as continuous

* i. deprivation as continuous

glm rti_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events user_rate deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


* ii. deprivation as categorical (deciles)

xi: glm rti_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("RTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm arti_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("aRTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("gastro2") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("coviddiag2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympsens2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("covidsympspec2") modify
putexcel A1=matrix(r(table)), names

xi: glm antibio_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("antibio2") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_events user_rate i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval2.xlsx", sheet("adm2") modify
putexcel A1=matrix(r(table)), names



** B. Model user rate as categorical

xtile user_rate_over1pct_cat = user_rate, nq(3)

* i. deprivation as continuous

glm rti_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events user_rate_over1pct_cat deprivation_pctile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


* ii. deprivation as categorical (deciles)

xi: glm rti_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("RTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm arti_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("aRTI2") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("gastro2") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("coviddiag2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("covidsympsens2") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("covidsympspec2") modify
putexcel A1=matrix(r(table)), names

xi: glm antibio_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("antibio2") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_events user_rate_over1pct_cat i.deprivation_decile ethnic_minority_pct median_age, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/process_eval_cat2.xlsx", sheet("adm2") modify
putexcel A1=matrix(r(table)), names
