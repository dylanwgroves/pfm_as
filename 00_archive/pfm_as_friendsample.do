	
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

/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* resp_name comsample* s33q2_oth_r endline_as svy_enum s33q3_b_oth svy_enum rd_treat sample_rd_pull m_resp_phone1 m_resp_phone2 resp_female resp_age resp_muslim s20q1b
	

/* Select Closes Friend (Remove if Family Member) ______________________________*/

	gen community_n = comsample_1_name if comsample_1_fam == 0 
	gen community_rltn = comsample_1_rltn if comsample_1_fam == 0 

		replace community_n = comsample_2_name if comsample_1_fam == 1 | comsample_1_name == "" | comsample_1_fam == 2
		replace community_rltn = comsample_2_rltn if comsample_1_fam == 1 | comsample_1_name == "" | comsample_1_fam == 2
		gen community_second = 1 if comsample_1_fam == 1
		
	lab val community_rltn s33q2_r
	
	gen community_rltn_fam = 1 if 	community_rltn == 1 | community_rltn == 2 | ///
									community_rltn == 3 | community_rltn == 4 | ///
									community_rltn == 5 
	
	order id_village_uid id_resp_uid resp_name community_n community_rltn community_rltn_fam 
	sort id_village_uid id_resp_uid 
	keep id_village_uid id_resp_uid resp_name community_n community_rltn community_rltn_fam 
	
	/* Save */
	save "${data_as}/pfm_friends_sample.dta", replace
	save "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\08_Friends\pfm_friends_sample.dta", replace
	export delimited using "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\08_Friends\pfm_friends_sample.csv", nolabel replace


	