	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Analysis Prelimenary Work
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/12/23l


	This mostly just subsets the data and does anything else necessary before
	running the analysis
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_attend

	
/* Load Data ___________________________________________________________________*/	

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

/* Set Seed ____________________________________________________________________*/

	set seed 1956
	
/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* kidssample* endline_as svy_enum rd_treat sample_rd_pull m_resp_phone1 m_resp_phone2 resp_female resp_age resp_muslim s20q1b id_village_uid id_village_n id_village_c id_ward_c id_ward_n id_ward_uid id_district_c id_district_n
	order id_* kidssample* endline_as svy_enum 
	
/* Select Closes Friend (Remove if Family Member) ______________________________*/
	keep if endline_as == 1
	keep if kidssample_kidnum > 0 & kidssample_kidnum != .

	reshape long kidssample_name_ kidssample_gender_ kidssample_age_, j(kidnum) i(id_resp_uid)
	

	/* Drop Kids Too Young */
	drop if kidssample_age < 13 | kidssample_age > 18
	drop if kidssample_age == .
	
	/* Randomize Order */	
	gen random_1 = runiform()
	gen random_2 = runiform()	
	sort random_1 random_2
	bys id_resp_uid : gen kidrank = _n
	sort id_resp_uid kidrank
	drop random_1 random_2 kidnum
	
	/* Reshape Wide */
	reshape wide kidssample_name_ kidssample_gender_ kidssample_age_, j(kidrank) i(id_resp_uid)
	
	order id_village_uid id_resp_uid id_resp_n id_resp_n kidssample_consent 
	keep id_village_uid id_resp_uid id_resp_n kidssample_consent kidssample_name_* kidssample_gender* kidssample_age*
	
	save "${data_as}/pfm_kids_sample.dta", replace

		
stop

br if id_resp_uid == "3_151_2_40"