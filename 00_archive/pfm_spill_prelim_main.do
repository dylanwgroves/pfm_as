	
/* Overview ______________________________________________________________________

	Project: Wellspring Tanzania, Audio Screening
	Purpose: Analysis Prelimenary Work
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23l

________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_attend
	tempfile temp_all

	
/* Load Data ___________________________________________________________________*/	

	/* Attendance Data */
	import excel "${data_spill}/pfm_as_attendance_RM.xlsx", sheet("Sheet1") firstrow clear
		drop fm_reject resp_female m_comply_attend treat Diff id_resp_n id_village_n
	save `temp_attend', replace

	/* Main Survey Data */
	use "${data}/03_final_data/pfm_appended_prefix.dta", clear
	drop if sample == "ne"

	
/* Merge  ______________________________________________________________________*/	

	merge 1:1 id_resp_uid using `temp_attend', gen(_merge_attendance)
		

/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *	// Get rid of prefix
	drop k_*
																

/* Import this stuff ___________________________________________________________*/

	
/* Generate any necessary variables ____________________________________________*/	

	/* Generate attrition */
	gen attrition_midline = 1 if m_consent_confirm == 0 | m_consent_confirm == .
		replace attrition_midline = 0 if m_consent_confirm == 1
		
	gen attrition_endline = 1 if consent == .
		replace attrition_endline = 0 if consent == 1
		
	/* Update compliance */
	replace comply_true = 0 if m_comply_attend == 0
		replace comply_true = 0 if comply_true == .
	
	/* Create "radio group" */
	gen rd_group = 2 if rd_treat == 1
		replace rd_group = 1 if rd_treat == 0
		replace rd_group = 0 if rd_treat == .
	encode id_ward_uid, gen(block_as)
	
	gen radio_received = (rd_treat == 1)
	
	/* Norms */
	
	/* Some norm reject information is missing - bring in from norm-bean 		*/	// We could also just drop this observations
	replace em_norm_reject_dum = 1 if em_norm_reject_bean >=5 & em_norm_reject_bean < 11 & em_norm_reject_dum == .
		replace em_norm_reject_dum = 0 if em_norm_reject_bean < 5 & em_norm_reject_bean > -1 & em_norm_reject_dum == .

	gen m_em_reject_norm_money = m_em_reject_norm if m_treat_efmvig_scen == 1
	gen m_em_reject_norm_daught = m_em_reject_norm if m_treat_efmvig_scen == 0
	
	destring m_treat_efmvig_age, replace
	gen m_fm_reject_norm = m_em_reject_norm if m_treat_efmvig_age > 17
	gen m_em_reject_norm_under18 = m_em_reject_norm if m_treat_efmvig_age < 18
		
	/* Create forced vs early marriage and divide up by story */
	gen m_fm_reject_story = m_em_reject_story if m_treat_efmvig_age > 17
	gen m_fm_reject_story_money = m_fm_reject_story if m_treat_efmvig_scen == 1
	gen m_fm_reject_story_daught = m_fm_reject_story if m_treat_efmvig_scen == 0
	
	replace m_em_reject_story = . if m_treat_efmvig_age > 17
	gen m_em_reject_story_money = m_em_reject_story if m_treat_efmvig_scen == 1
	gen m_em_reject_story_daught = m_em_reject_story if m_treat_efmvig_scen == 0

	
	/* Generate endline compliance */
	gen comply_attend_efm = 1 if comply_true == 1 & treat == 1
		replace comply_attend_efm = 0 if comply_true == 0
		replace comply_attend_efm = 0 if treat == 0 

	gen m_comply_topic_correct = 1 if (m_comply_topic == 1 | m_comply_topic == 2) 
		replace m_comply_topic_correct = 0 if (m_comply_topic == .d | m_comply_topic == .o | m_comply_topic == 3 | m_comply_topic == .) 
		replace m_comply_topic_correct = . if attrition_midline == 1

	gen comply_topic_correct = 1 if (comply_topic == 1 | comply_topic == 2) 
		replace comply_topic_correct = 0 if (comply_topic == .d | comply_topic == .o | comply_topic == 3 | comply_topic == .)
		replace comply_topic_correct = . if attrition_endline == 1
		
	gen comply_discuss_correct = 1 if comply_discuss == 1 & comply_topic_correct == 1 
		replace comply_discuss_correct = 0 if comply_discuss == 0
		replace comply_discuss_correct = 0 if comply_topic_correct == 0

	gen m_comply_discuss_correct = 1 if m_comply_disc == 1 & m_comply_topic_correct == 1
		replace m_comply_discuss_correct = 0 if m_comply_disc == 0
		replace m_comply_discuss_correct = 0 if m_comply_topic_correct == 0
		
	/* Priority Ranking */
	gen m_em_priority_unchanged = m_em_priority_list
		recode m_em_priority_unchanged (-1=0)(0=1)(1=2)(2=3)(3=4)
		
	replace m_em_priority_list = 0 if m_em_priority_list == -1
	replace m_em_priority_list = 2 if m_em_priority_list == 1 & m_hiv_priority_list > 1
	replace m_em_priority_list = 3 if m_em_priority_list == 2 & m_hiv_priority_list > 2

	gen m_em_prioritytoptwo = (m_em_priority_list > 2)
	replace m_em_prioritytoptwo = 1 if m_em_priority_list == 2 & m_hiv_priority_list > 2

	* Change endline to match midline */
	gen em_priority_list = .
		replace em_priority_list = 3 if ptixpref_rank_efm == 9 
		replace em_priority_list = 3 if ptixpref_rank_efm == 8 & ptixpref_rank_health > 8
		
		replace em_priority_list = 2 if ptixpref_rank_efm == 8 & ptixpref_rank_health < 8
		replace em_priority_list = 2 if ptixpref_rank_efm == 7 & ptixpref_rank_health > 7
		
		replace em_priority_list = 1 if ptixpref_rank_efm == 7 & ptixpref_rank_health < 7
		
		replace em_priority_list = 0 if ptixpref_rank_efm < 7
		


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
							b_media_news_daily 
							b_radio_any 
							b_resp_lang_swahili 
							b_resp_literate 	
							b_resp_standard7 
							b_resp_nevervisitcity 
							b_resp_married 
							b_resp_hhh 
							b_resp_numkid
							p_resp_age 
							p_resp_female 
							p_resp_muslim
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

	save "${data_spill}/pfm_spill_analysis.dta", replace
	save `temp_all', replace
	

