

* Project:	Germ Defence Study P512
* Program:	model.do
* Purpose:	Analyse data acording to the study protocol within the OpenSafely system, including primary and secondary analyses
* Author:	Scott Walter, Sept 2021

* Note: + indicates sections that need updating before running this program on real data.

*+ how to set the directory for running on real data?
global gd "C:\Users\dy21108\OneDrive - University of Bristol\Documents\GitHub\GermDefence"

*convert CSV files to .dta files
*import delimited `c(pwd)'/output/input.csv
import delimited using "$gd\output\measures\measure_RTI_weekly.csv", clear

*send all output to log file
log using "$gd\metadata\analysis_log.log", replace

drop value
save "$gd\output\measures\measure_RTI_weekly.dta", replace

import delimited using "$gd\output\measures\measure_aRTI_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_aRTI_weekly.dta", replace

import delimited using "$gd\output\measures\measure_gastro_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_gastro_weekly.dta", replace

import delimited using "$gd\output\measures\measure_coviddiag_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_coviddiag_weekly.dta", replace

import delimited using "$gd\output\measures\measure_covidsympsens_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_covidsympsens_weekly.dta", replace

import delimited using "$gd\output\measures\measure_covidsympspec_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_covidsympspec_weekly.dta", replace

import delimited using "$gd\output\measures\measure_antibio_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_antibio_weekly.dta", replace

import delimited using "$gd\output\measures\measure_adm_weekly.csv", clear
drop population value
save "$gd\output\measures\measure_adm_weekly.dta", replace



*get weekly level counts for any type of GP consultation - treat as base dataset
use "$gd\output\measures\measure_RTI_weekly.dta", clear

*merge on tables for other outcomes to create single unified dataset
merge 1:1 practice_id date using "$gd\output\measures\measure_aRTI_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_gastro_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_coviddiag_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_covidsympsens_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_covidsympspec_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_antibio_weekly.dta"
drop _merge
merge 1:1 practice_id date using "$gd\output\measures\measure_adm_weekly.dta"
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
save "$gd\output\practice_weekly.dta", replace


*** I. Per protocol analysis

*+collapse post-intervention data to one row per practice - sum event counts for each outcome 
drop if period==1
collapse (sum) rti_events arti_events gastro_events coviddiag_events covidsympsens_events covidsympspec_events antibio_events adm_events population, by(practice_id)

*+merge on practice covariates
gen intervention = uniform() < .5
*gen population = rpoisson(200)
replace population=1 if population<1

*+Compare event rates between intervention vs. control during post-intervention period: 10/11/20 - 15/03/21



glm rti_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names 

glm arti_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("Antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events i.intervention, family(nb) link(log) exposure(population)
putexcel set "$gd\output\PerProtocol.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


*** II. Time series analysis

** A. Weekly level analysis

*get practice x week level data, then collapse to one row per week, summing event counts for each outcome
use "$gd\output\practice_weekly.dta", replace
gen intervention = uniform() < .5
collapse (sum) rti_events arti_events gastro_events coviddiag_events covidsympsens_events covidsympspec_events antibio_events adm_events population, by(date2 week_date intervention)
gen time=week_date - 17.5
gen period = (date2>=d(10nov2020))

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
glm rti_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events intervention period intervention_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\DiD_weekly.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names

* ii. Controlled interrupted time series model
glm rti_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

glm arti_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

glm gastro_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

glm coviddiag_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

glm covidsympsens_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

glm covidsympspec_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

glm antibio_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

glm adm_events time intervention period time_intervention time_period intervention_period time_int_period, family(nb) link(log) exposure(population)
putexcel set "$gd\output\CITS_weekly.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


** B. Practice level analysis
use "$gd\output\practice_weekly.dta", replace
gen intervention = practice_id < 1500

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
menbreg rti_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("RTI") replace
putexcel A1=matrix(r(table)), names

menbreg arti_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

menbreg gastro_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

menbreg coviddiag_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("CovidDiag") modify
putexcel A1=matrix(r(table)), names

menbreg covidsympsens_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("CovidSympSens") modify
putexcel A1=matrix(r(table)), names

menbreg covidsympspec_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("CovidSympSpec") modify
putexcel A1=matrix(r(table)), names

menbreg antibio_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("antibio") modify
putexcel A1=matrix(r(table)), names

menbreg adm_events time intervention period time_intervention time_period intervention_period time_int_period, exposure(population) || practice_id: 
putexcel set "$gd\output\CITS_RandInt.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


*** III. Process evaluation.


log close