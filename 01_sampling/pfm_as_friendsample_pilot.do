	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Sampling Sheets for Mobilizers to mobilize friends
Author: beatrice montano, bm2955@columbia.edu
Date: 2020/01/21

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

	use "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\03_clean\audio_screening_survey_pilot_output.dta", clear


/* Extract Data ________________________________________________________________*/

	gen id_village_id = substr(id,1,6)


/* Keep Certain Variables ______________________________________________________*/


	keep id_* resp_name comsample*
	

/* Select Closes Friend (Remove if Family Member) ______________________________*/
			
	gen     relationship1_family = 0
	replace relationship1_family = 1 if 	comsample_1_rltn == 1  | comsample_1_rltn == 2  | ///
											comsample_1_rltn == 3  |  ///
											  comsample_1_rltn == 12 | ///
											comsample_1_rltn == 16 | comsample_1_rltn == 17 | comsample_1_rltn == 18
	
	gen relationship2_family = 0 
	replace relationship2_family = 1 if 	comsample_2_rltn == 1  | comsample_2_rltn == 2  | ///
											comsample_2_rltn == 3  |  ///
											 comsample_2_rltn == 12 | ///
											comsample_2_rltn == 16 | comsample_2_rltn == 17 | comsample_2_rltn == 18

	gen name1 = comsample_1_name 
	replace name1 = "" if relationship1_family == 1 
	
	gen relationship1 = comsample_1_rltn
	replace relationship1 = . if relationship1_family == 1 
	lab val relationship1 s33q2_r
	
	gen name2 = comsample_2_name
	replace name2 =  "" if relationship2_family == 1 

	gen relationship2 = comsample_2_rltn
	replace relationship2 = . if relationship2_family == 1 
	lab val relationship2 s33q2_r

	replace name1 = name2 if name1=="" & name2!=""
	replace relationship1 = relationship2 if name1 == name2
	replace name2 = "" if name1 == name2
	replace relationship2 = . if name2==""

/* Generate list of Original + Partner + Friends (maybe eligible) _______________*/
	
br id_resp_uid name1 relationship1 name2 relationship2 

