	
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
	
	save "${data_as}/pfm_community_sample.dta", replace

		
stop
	
stop	
	
	/* Primary Analysis is only with people who own a radio */					
	keep if  comply_true == 1
	
/* Import this stuff ___________________________________________________________*/

	
/* Generate any necessary variables ____________________________________________*/

	/* Create "radio group" */
	gen rd_group = 2 if rd_treat == 1
		replace rd_group = 1 if rd_treat == 0
		replace rd_group = 0 if rd_treat == .
	encode id_ward_uid, gen(block_as)
	
	gen radio_received = (rd_treat == 1)
	
/* Fill missing baseline values ________________________________________________*/

		#d ;
		/* Lasso Covariates */
		global cov_lasso	resp_female 
							resp_muslim
							b_resp_religiosity
							b_values_likechange 
							b_values_techgood 
							b_values_respectauthority 
							b_values_trustelders 
							b_fm_reject
							b_ge_raisekids 
							b_ge_earning 
							b_ge_leadership 
							b_ge_noprefboy 
							b_media_tv_any 
							b_media_news_never 
							b_radio_any 
							b_resp_lang_swahili 
							b_resp_literate 
							b_resp_standard7 
							b_resp_nevervisitcity 
							b_resp_married 
							b_resp_hhh 
							b_resp_numkid
							;
		#d cr
		
			foreach var of global cov_lasso {
				bys id_village_uid : egen vill_`var' = mean(`var')
				replace `var' = vill_`var' if `var' == . | `var' == .d | `var' == .r
 			}
			
/* Generate Community Level Baseline ___________________________________________*/

	foreach var of varlist b_ge_raisekids b_ge_earning b_ge_leadership ///
							b_ge_noprefboy b_ge_index b_fm_reject {
		bys id_village_uid : egen v_`var' = mean(`var')
	}

/* Save ________________________________________________________________________*/

	save "${data_as}/pfm_as_analysis.dta", replace
