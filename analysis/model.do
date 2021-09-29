
/*======================================================================================
DO FILE NAME:			model.do
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


*convert CSV files to .dta files

import delimited using "$gd/output/measures/measure_RTI_weekly.csv", clear
drop value
save "$gd/output/measures/measure_RTI_weekly.dta", replace

import delimited using "$gd/output/measures/measure_aRTI_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_aRTI_weekly.dta", replace

import delimited using "$gd/output/measures/measure_gastro_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_gastro_weekly.dta", replace

import delimited using "$gd/output/measures/measure_coviddiag_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_coviddiag_weekly.dta", replace

import delimited using "$gd/output/measures/measure_covidsympsens_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_covidsympsens_weekly.dta", replace

import delimited using "$gd/output/measures/measure_covidsympspec_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_covidsympspec_weekly.dta", replace

import delimited using "$gd/output/measures/measure_antibio_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_antibio_weekly.dta", replace

import delimited using "$gd/output/measures/measure_adm_weekly.csv", clear
drop population value
save "$gd/output/measures/measure_adm_weekly.dta", replace


*get weekly level counts for any type of GP consultation - treat as base dataset
use "$gd/output/measures/measure_RTI_weekly.dta", clear

*+merge on tables for other outcomes to create single unified dataset
merge 1:1 practice_id date using "$gd/output/measures/measure_aRTI_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_gastro_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_coviddiag_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_covidsympsens_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_covidsympspec_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_antibio_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd/output/measures/measure_adm_weekly.dta"
drop _merge


*fill in missing counts
replace rti_events=0 if rti_events==.|rti_events<0
replace arti_events=0 if arti_events==.|arti_events<0
replace gastro_events=0 if gastro_events==.|gastro_events<0
replace coviddiag_events=0 if coviddiag_events==.|coviddiag_events<0
replace covidsympsens_events=0 if covidsympsens_events==.|covidsympsens_events<0
replace covidsympspec_events=0 if covidsympspec_events==.|covidsympspec_events<0
replace antibio_events=0 if antibio_events==.|antibio_events<0
replace adm_events=0 if adm_events==.|adm_events<0

*define pre and post intervention periods
generate date2 = date(date, "YMD")
format %td date2
gen period = (date2>=d(10nov2020))

*consecutively number weeks
sort date2 practice_id

gen year = year(date2)
gen week = week(date2)

gen week_date = week - 27
replace week_date = week + 25 if year==2021

*save practice x week level data
save "$gd/output/practice_weekly.dta", replace


*** I. Per protocol analysis

*+collapse post-intervention data to one row per practice - sum event counts for each outcome 
drop if period==1
collapse (sum) rti_events arti_events gastro_events coviddiag_events covidsympsens_events covidsympspec_events antibio_events adm_events population, by(practice_id)

*add practice covariates
merge 1:1 practice_id using "$gd/output/practice_variables.dta"
drop _merge

*save data for use in process evaluation
save "$gd/output/process_eval.dta", replace


*+Compare event rates between intervention vs. control during post-intervention period: 10/11/20 - 15/03/21

glm rti_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names 

glm arti_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("Antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events i.intervention, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/PerProtocol.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names



*** II. Time series analysis

** A. Weekly level analysis

*get population values by intervention group
use "$gd/output/practice_variables.dta", replace
collapse (sum) list_size, by(intervention)
save "$gd/output/pop_by_intervention.dta", replace

tab list_size

*get practice x week level data, then collapse to one row per week, summing event counts for each outcome
use "$gd/output/practice_weekly.dta", replace

*add intervention group indicator
merge m:1 practice_id using "$gd/output/practice_variables.dta"
drop _merge
drop if intervention==.

collapse (sum) rti_events arti_events gastro_events coviddiag_events covidsympsens_events covidsympspec_events antibio_events adm_events population, by(date2 week_date intervention)
gen time=week_date - 17.5
gen period = (date2>=d(10nov2020))


*add population
merge m:1 intervention using "$gd/output/pop_by_intervention.dta"
drop _merge

*check data
export excel using "$gd/output/weekly_check.xlsx", firstrow(variables) replace


*create interaction variables
gen time_period = 0
replace time_period = time if period==1

gen time_intervention = 0
replace time_intervention = time if intervention==1

gen intervention_period = 0
replace intervention_period = 1 if intervention==1 & period==1

gen time_int_period = 0
replace time_int_period = time if intervention_period==1


* i. Difference in differences model
glm rti_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events intervention period intervention_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/DiD_weekly.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


* ii. Controlled interrupted time series model

sort intervention time

*Respiratory tract infections
glm rti_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

predict rti_yhat
gen rti_rate=rti_events/list_size
gen rti_pred_rate=rti_yhat/list_size
graph twoway (line rti_pred_rate time if intervention==1, lcolor(maroon)) (line rti_pred_rate time if intervention==0, lcolor(navy)) (scatter rti_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter rti_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/rti_plot.pdf", as(pdf)

*Acute respiratory tract infections
glm arti_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

predict arti_yhat
gen arti_rate=arti_events/list_size
gen arti_pred_rate=arti_yhat/list_size
graph twoway (line arti_pred_rate time if intervention==1, lcolor(maroon)) (line arti_pred_rate time if intervention==0, lcolor(navy)) (scatter arti_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter arti_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/arti_plot.pdf", as(pdf)

*Gastro intestinal infections
glm gastro_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

predict gastro_yhat
gen gastro_rate=gastro_events/list_size
gen gastro_pred_rate=gastro_yhat/list_size
graph twoway (line gastro_pred_rate time if intervention==1, lcolor(maroon)) (line gastro_pred_rate time if intervention==0, lcolor(navy)) (scatter gastro_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter gastro_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/gastro_plot.pdf", as(pdf)

*Covid-19 diagnoses
glm coviddiag_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

predict coviddiag_yhat
gen coviddiag_rate=coviddiag_events/list_size
gen coviddiag_pred_rate=coviddiag_yhat/list_size
graph twoway (line coviddiag_pred_rate time if intervention==1, lcolor(maroon)) (line coviddiag_pred_rate time if intervention==0, lcolor(navy)) (scatter coviddiag_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter coviddiag_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/coviddiag_plot.pdf", as(pdf)

*Covid-19 symptoms - senstivie list
glm covidsympsens_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

predict covidsympsens_yhat
gen covidsympsens_rate=covidsympsens_events/list_size
gen covidsympsens_pred_rate=covidsympsens_yhat/list_size
graph twoway (line covidsympsens_pred_rate time if intervention==1, lcolor(maroon)) (line covidsympsens_pred_rate time if intervention==0, lcolor(navy)) (scatter covidsympsens_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter covidsympsens_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/covidsympsens_plot.pdf", as(pdf)

*Covid-19 symptoms - specific list
glm covidsympspec_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

predict covidsympspec_yhat
gen covidsympspec_rate=covidsympspec_events/list_size
gen covidsympspec_pred_rate=covidsympspec_yhat/list_size
graph twoway (line covidsympspec_pred_rate time if intervention==1, lcolor(maroon)) (line covidsympspec_pred_rate time if intervention==0, lcolor(navy)) (scatter covidsympspec_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter covidsympspec_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/covidsympspec_plot.pdf", as(pdf)

*Antibiotics
glm antibio_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

predict antibio_yhat
gen antibio_rate=antibio_events/list_size
gen antibio_pred_rate=antibio_yhat/list_size
graph twoway (line antibio_pred_rate time if intervention==1, lcolor(maroon)) (line antibio_pred_rate time if intervention==0, lcolor(navy)) (scatter antibio_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter antibio_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/antibio_plot.pdf", as(pdf)

*Hospital admissions
glm adm_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(list_size)
putexcel set "$gd/output/CITS_weekly.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names

predict adm_yhat
gen adm_rate=adm_events/list_size
gen adm_pred_rate=adm_yhat/list_size
graph twoway (line adm_pred_rate time if intervention==1, lcolor(maroon)) (line adm_pred_rate time if intervention==0, lcolor(navy)) (scatter adm_rate time if intervention==1, mcolor(maroon) msymbol(o)) (scatter adm_rate time if intervention==0, mcolor(navy) msymbol(o)), legend(order(1 "Intervention estimate" 2 "Control estimate" 3 "Intervention rates" 4 "Control rates")) xline(0, lcolor(black) lpattern(dash))
graph export "$gd/output/adm_plot.pdf", as(pdf)



** B. Practice level weekly time-series analysis
use "$gd/output/practice_weekly.dta", replace

*add practice covariates
merge m:1 practice_id using "$gd/output/practice_variables.dta"
drop _merge

gen time=week_date - 17.5

*create interaction variables
gen time_period = 0
replace time_period = time if period==1

gen time_intervention = 0
replace time_intervention = time if intervention==1

gen intervention_period = 0
replace intervention_period = 1 if intervention==1 & period==1

gen time_int_period = 0
replace time_int_period = time if intervention_period==1

*Random intercepts CITS
menbreg rti_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

menbreg arti_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

menbreg gastro_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

menbreg coviddiag_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

menbreg covidsympsens_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

menbreg covidsympspec_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

menbreg antibio_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

menbreg adm_events time intervention period time_intervention time_period intervention_period time_int_period median_age deprivation_pctile female_pct, exposure(list_size) || practice_id: 
putexcel set "$gd/output/CITS_RandInt.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names