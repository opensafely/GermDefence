
*** 1. Preamble and setup

global gd "C:\Users\dy21108\OneDrive - University of Bristol\Documents\GitHub\GermDefence"

import delimited using "C:\Users\dy21108\OneDrive - University of Bristol\Documents\Temp\GPlevel_InterventionGrp_withDummyCounts.csv", clear

gen n_users=0
replace n_users=real(n_visits_practice) if n_visits_practice != "NA"

gen listsize=real(list_size)
gen user_rate=n_users/listsize

gen imd_decile2=real(imd_decile)
gen minority_ethnic_total2=real(minority_ethnic_total)
gen medianage2=real(medianage)

gen arti_count=acuterti_count

*** 2. Main process analysis

** A. Model user rate as continuous

xi: glm rti_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("RTI")
putexcel A1=matrix(r(table)), names

xi: glm arti_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_count user_rate i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names


** B. Model user rate as categorical

gen users_cat3=0
replace users_cat3=1 if user_rate>0.01 & user_rate<0.1
replace users_cat3=2 if user_rate>=0.1

xi: glm rti_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("RTI")
putexcel A1=matrix(r(table)), names

xi: glm arti_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("aRTI") modify
putexcel A1=matrix(r(table)), names

xi: glm gastro_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("gastro") modify
putexcel A1=matrix(r(table)), names

xi: glm coviddiag_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("coviddiag") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympsens_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("covidsympsens") modify
putexcel A1=matrix(r(table)), names

xi: glm covidsympspec_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("covidsympspec") modify
putexcel A1=matrix(r(table)), names

xi: glm adm_count i.users_cat3 i.imd_decile2 minority_ethnic_total2 medianage2, family(nb) link(log) exposure(listsize)
putexcel set "$gd\output\process_eval2.xlsx", sheet("adm") modify
putexcel A1=matrix(r(table)), names