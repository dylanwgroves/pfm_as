	
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

	keep id_* resp_name kidssample* endline_as svy_enum 
	order id_* resp_name kidssample* endline_as svy_enum 
	
/* Select Closes Friend (Remove if Family Member) ______________________________*/
	keep if endline_as == 1
	keep if kidssample_kidnum > 0 & kidssample_kidnum != .

	reshape long kidssample_name_ kidssample_gender_ kidssample_age_, j(kidnum) i(id_resp_uid)
	

	/* Drop Kids Too Young */
	drop if kidssample_age < 13
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
	
	order id_village_uid id_resp_uid resp_name kidssample_consent 
	keep id_village_uid id_resp_uid resp_name kidssample_consent kidssample_name_* kidssample_gender* 
	
	save "${data_as}/pfm_kids_sample.dta", replace

		
stop
