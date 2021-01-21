	
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

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* resp_name comsample* ///
		 p_id_resp_uid p_resp_name_new
	

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
	
	order id_district_n id_village_uid id_village_n id_resp_uid id_resp_n p_id_resp_uid p_resp_name_new name1 relationship1 name2 relationship2
	
	sort id_district_n id_village_uid id_village_n id_resp_uid id_resp_n
	
	keep id_district_n id_village_uid id_village_n id_resp_uid id_resp_n p_id_resp_uid p_resp_name_new name1 relationship1 name2 relationship2
	
	

	
	* Formatting XLS for export
	gen name3 = ""
	gen relationship3 = ""
	
	gen name4 = ""	
	gen relationship4 = ""
	
	gen age1 = ""
	gen age2 = ""
	gen age3 = ""
	gen age4 = ""
	
	decode relationship1, gen(relationship_1)
	decode relationship2, gen(relationship_2)

	replace relationship_1 = "A person who lives nearby" if relationship_1 == "A person who lives nearbye"
	replace relationship_2 = "A person who lives nearby" if relationship_2 == "A person who lives nearbye"

	local myvar id_village_n id_resp_n name1 relationship_1  name2  relationship_2
	foreach var of local myvar {
	local fmt: format `var'
	local fmt: subinstr local fmt "%" "%-"
	format `var' `fmt'
	}
	order  id_district_n id_village_n id_resp_uid id_resp_n name1 age1 relationship_1  name2 age2 relationship_2 name3 age3 relationship3 name4 age4 relationship4
	keep  id_district_n id_village_n id_resp_uid id_resp_n name1 age1 relationship_1  name2 age2 relationship_2 name3 age3 relationship3 name4 age4 relationship4
	
	rename relationship_1 relationship1
	rename relationship_2 relationship2
	rename id_district_n districtName
	rename id_village_n villageName
	rename id_resp_uid respondentID
	rename id_resp_n respondentName
	
	gen time = ""
	gen AS1 = ""
	gen AS2 = ""
	gen AS3 = ""
	gen AS4 = ""
	gen same1 = ""
	gen same2 = ""
	gen same3 = ""
	gen same4 = ""
	
	replace relationship1 = "Friends" if relationship1 == "A friend you spend your free time with"
	replace relationship2 = "Friends" if relationship2 == "A friend you spend your free time with"
	
	replace relationship1 = "Neighbor" if relationship1 == "A person who lives nearby"
	replace relationship2 = "Neighbor" if relationship2 == "A person who lives nearby"

	replace relationship1 = "Friend of prayer" if relationship1 == "A friend you go to church/mosque with"	
	replace relationship2 = "Friend of prayer" if relationship2 == "A friend you go to church/mosque with"
	
	replace relationship1 = "Community leader" if relationship1 == "Your community leader"	
	replace relationship2 = "Community leader" if relationship2 == "Your community leader"	
	
	sort districtName villageName respondentName 
	order  districtName villageName respondentID respondentName name1 age1 relationship1 AS1 same1 ///
															name2 age2 relationship2 AS2 same2 ////
															name3 age3 relationship3 AS3 same3 ////
															name4 age4 relationship4 AS4 same4
	
	drop districtName
	
	/* Save */
	save "${data_as}/pfm_friends_sample_v2.dta", replace
	export excel using "${user}/Box Sync/19_Community Media Endlines/04_Research Design/04 Randomization & Sampling/08_Friends/pfm_friends_sample_v3.xls", firstrow(var) replace


	
