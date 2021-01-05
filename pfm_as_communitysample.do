	
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

	keep id_* comsample* s33q2_oth_r endline_as svy_enum s33q3_b_oth rd_treat sample_rd_pull m_resp_phone1 m_resp_phone2 resp_female resp_age resp_muslim s20q1b
	

/* Create Family Indicators ____________________________________________________*/

	drop comsample_1_fam comsample_2_fam 										// Drop and redefine family member
	gen comsample_1_fam = .
	gen comsample_2_fam = .
	forval j = 1/2 {
		forval i = 1/3 {
			replace comsample_`j'_fam = 1 if comsample_`j'_rltn == `i'
		}
		forval i = 17/18 {
			replace comsample_`j'_fam = 1 if comsample_`j'_rltn == `i'
		}
		forval i = 4/16 {
			replace comsample_`j'_fam = 0 if comsample_`j'_rltn == `i'
		}
	}
		
	
/* Select Closes Friend (Remove if Family Member) ______________________________*/

	gen community_name = comsample_1_name if comsample_1_fam == 0 
	gen community_rltn = comsample_1_rltn if comsample_1_fam == 0 

	/* Replace with second most-talked to person if first is missing or family */
		gen community_1_miss = 1 if comsample_1_fam == 1 | comsample_1_name == "" 
			replace community_1_miss = 0 if comsample_1_fam != 1 & comsample_1_name != ""
			
		replace community_name = comsample_2_name if community_1_miss == 1
		replace community_rltn = comsample_2_rltn if community_1_miss == 1
		
	gen community_name_alt = comsample_2_name if community_1_miss == 0
	gen community_rltn_alt = comsample_2_rltn if community_1_miss == 0
	
	/* Tag if Family  */
	gen community_fam = 1 if 		community_rltn == 1 | community_rltn == 2 | ///
									community_rltn == 3 | community_rltn == 17 | ///
									community_rltn == 18	
									
	gen community_fam_alt = 1 if community_rltn_alt == 1 | community_rltn_alt == 2 | ///
								 community_rltn_alt == 3   | community_rltn_alt == 17 | ///
								 community_rltn_alt == 18	
								 
	gen community_miss = 1 if community_name == ""
	gen community_miss_alt = 1 if community_name_alt == ""
									
	/* Label Variables */
	lab val community_rltn_alt s33q2_r 
	lab val community_rltn s33q2_r
	lab val community_fam community_fam_alt yesno
	lab val community_miss community_miss_alt yesno
	
	lab var community_name "Name of selected community member"
	lab var community_rltn "Relationship of selected community member to respondent"
	lab var community_fam "Is selected commuity member a family member"
	
	lab var community_name_alt "Name of atlernate community member"
	lab var community_rltn_alt "Relationship of alternate community member to respondent"
	lab var community_fam_alt "Is alternate community member a family member"
	
	
	/* Order and Keep */
	order id_village_uid id_resp_uid id_resp_n community_name community_rltn community_fam community_miss community_name_alt community_rltn_alt community_fam_alt community_miss_alt comsample*
	sort id_village_uid id_resp_uid
	keep if endline_as == 1
	keep id_village_uid id_resp_uid id_resp_n community_name community_rltn community_fam community_miss community_name_alt community_rltn_alt community_fam_alt community_miss_alt svy_enum rd_treat sample_rd_pull m_resp_phone1 m_resp_phone2 resp_female resp_age resp_muslim s20q1b comsample* id*
	
	save "${data_as}/pfm_community_sample.dta", replace

		
stop
s