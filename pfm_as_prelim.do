	
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
	import excel "${data_as}/pfm_as_attendance_final.xlsx", sheet("Sheet1") firstrow clear
		drop resp_female m_comply_attend treat id_resp_n id_village_n
	save `temp_attend', replace

	/* Main Survey Data */
	use "${data}/03_final_data/pfm_appended_prefix.dta", clear
	drop if sample == "ne"

	/* Main Survey Data */
	do "$X:\Documents\pfm_audioscreening_efm\02_indices\pfm_as_indices_covars.do"

	
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
	
	gen radio_received = (rd_treat == 1)
	
	/* Create block */	
	encode id_ward_uid, gen(block_as)

	/* Create cluster */
	encode id_village_uid, gen(cluster_as)
	
	/* Norms */
	
	/* Some norm reject information is missing - bring in from norm-bean 		*/	// We could also just drop this observations
	replace em_norm_reject_dum = 1 if em_norm_reject_bean >=5 & em_norm_reject_bean < 11 & em_norm_reject_dum == .
		replace em_norm_reject_dum = 0 if em_norm_reject_bean < 5 & em_norm_reject_bean > -1 & em_norm_reject_dum == .

	gen m_em_reject_norm_money = m_em_reject_norm if m_treat_efmvig_scen == 1
	gen m_em_reject_norm_daught = m_em_reject_norm if m_treat_efmvig_scen == 0
	
	destring m_treat_efmvig_age, replace
	gen m_fm_reject_norm = m_em_reject_norm if m_treat_efmvig_age > 17
	gen m_em_reject_norm_under18 = m_em_reject_norm if m_treat_efmvig_age < 18
		
	/* Create forced vs early marriage and divide up by story features */
	clonevar m_efm_reject_story = m_em_reject_story
	
	gen m_fm_reject_story = m_em_reject_story if m_treat_efmvig_age > 17
	gen m_fm_reject_story_money = m_fm_reject_story if m_treat_efmvig_scen == 1
	gen m_fm_reject_story_daught = m_fm_reject_story if m_treat_efmvig_scen == 0
	
	replace m_em_reject_story = . if m_treat_efmvig_age > 17
	gen m_em_reject_story_money = m_em_reject_story if m_treat_efmvig_scen == 1
	gen m_em_reject_story_daught = m_em_reject_story if m_treat_efmvig_scen == 0

	/* Remove missing values from survey enumerator */
	replace svy_enum = 0 if svy_enum == .
	
	/* Generate endline uptake */
	gen comply_attend_any = 1 if m_comply_attend == 1
		replace comply_attend_any = 1 if (m_comply_attend != 1 & comply_true == 1)
		replace comply_attend_any = 0 if m_comply_attend != 1 & comply_true != 1
		replace comply_attend_any = 0 if comply_attend == 1 & comply_true != 1
		
	gen comply_attend_efm = 1 if m_comply_attend == 1
		replace comply_attend_efm = 1 if (m_comply_attend != 1 & comply_true == 1)
		replace comply_attend_efm = 0 if m_comply_attend != 1 & comply_true != 1
		replace comply_attend_efm = 0 if comply_attend_efm == 1 & comply_true != 1
		replace comply_attend_efm = 0 if comply_attend_efm == 1 & treat == 0 

	gen m_comply_topic_correct = 1 if (m_comply_topic == 1 | m_comply_topic == 2) 
		replace m_comply_topic_correct = 0 if (m_comply_topic == .d | m_comply_topic == .o | m_comply_topic == 3 | m_comply_topic == .) 
		replace m_comply_topic_correct = 0 if attrition_midline == 1

	gen comply_topic_correct = 1 if (comply_topic == 1 | comply_topic == 2) 
		replace comply_topic_correct = 0 if (comply_topic == .d | comply_topic == .o | comply_topic == 3 | comply_topic == .)
		replace comply_topic_correct = 0 if attrition_endline == 1
		
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
			
	/* mix partner perception and self-report */
	gen fm_reject_mixed = (fm_reject + p_fm_partner_reject)/2
		*replace fm_reject_mixed = fm_reject if fm_reject_mixed == .
		
	/* destring age*/
	destring b_age, replace
		
		
/* Some Things for Tables ________________________________________________*/

	recode m_s4q2_fm_lawpref (.d .r = 0)



/* Fill missing baseline values ________________________________________________*/

		* Note: cov_lasso defined in "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_covars.do"
		foreach var of global cov_lasso {
			di "`var'"
			bys id_village_uid : egen vill_`var' = mean(`var')
			replace `var' = vill_`var' if `var' == . | `var' == .d | `var' == .r
 		}
	
	
/* Generate Community Level Baseline ___________________________________________*/

	foreach var of varlist b_ge_raisekids b_ge_earning b_ge_leadership ///
							b_ge_noprefboy b_ge_index b_fm_reject {
		bys id_village_uid : egen v_`var' = mean(`var')
	}
	
/* Create ______________________________________________________________________*/
	
	gen complier = 1 if m_comply_attend == 1 
	replace complier = 1 if m_comply_attend != 1 & comply_true == 1
	replace complier = 0 if complier != 1

	
/* Set things up for vignette __________________________________________________*/

gen age = m_treat_efmvig_age
replace  age = 18 if  m_treat_efmvig_age == 19
replace  age = 15 if  m_treat_efmvig_age == 13 |  m_treat_efmvig_age == 14
replace  age = 16 if m_treat_efmvig_age == 17

replace m_treat_efmvig_offer = subinstr(m_treat_efmvig_offer,",","",.)
destring m_treat_efmvig_offer, replace
replace m_treat_efmvig_offer = 500000 if m_treat_efmvig_offer < 500000 

gen amt = m_treat_efmvig_offer
replace amt = 5 if m_treat_efmvig_offer  ==  600000 | m_treat_efmvig_offer  ==  500000
replace amt = 9 if m_treat_efmvig_offer > 600000 & m_treat_efmvig_offer < 1000000
replace amt = 10 if m_treat_efmvig_offer  ==  1500000 | m_treat_efmvig_offer  ==  1000000
replace amt = 10 if m_treat_efmvig_offer  ==  2500000 | m_treat_efmvig_offer  ==  2000000

gen scenario = m_treat_efmvig_scen

drop m_efm_reject_story
gen m_efm_reject_story = m_em_reject_story 
	replace m_efm_reject_story = m_fm_reject_story if m_efm_reject_story == .
	
gen m_efm_norm_story = m_fm_reject_norm
	replace m_efm_norm_story = m_em_reject_norm if m_efm_norm_story == .

/* Save ________________________________________________________________________*/

	save "${data_as}/pfm_as_analysis.dta", replace
	save `temp_all', replace
	
	
	
/* Keep for replication files __________________________________________________*/

	use	"${data_as}/pfm_as_analysis.dta", clear
	
	encode id_village_n, gen(sb_id_village_n)
	drop id_village_n
	rename sb_id_village_n id_village_n
	label drop sb_id_village_n

	#d ;
	keep 						treat 
								treat_*
								cluster_as 
								block_as
								rd_group 
								id_village_n
								scenario 
								complier
								age
								b_age
								amt
								b_resp_female 
								m_efm_reject_story
								m_efm_norm_story
								attrition_midline
								attrition_endline
								comply_attend_any
								fm_reject
								fm_reject_long 									
								p_fm_partner_reject
								fm_reject_mixed
								em_reject_index
								em_reject_pregnant_dum 
								em_reject_money_dum 
								fm_norm_reject
								fm_partner_reject
								em_norm_reject_dum
								em_report
								em_report_norm
								em_elect
								ptixpref_efm_first 
								ge_index
								ipv_rej_disobey_long
								ipv_norm_rej	
								ipv_report
								m_fm_reject
								m_fm_reject_18
								m_fm_reject_story
								m_fm_reject_story_money
								m_fm_reject_story_daught
								m_em_reject_story
								m_em_reject_story_money
								m_em_reject_story_daught
								m_fm_reject_norm
								m_em_reject_norm_under18
								m_em_reject_norm
								m_em_report 
								m_em_report_norm
								m_ptixpref_efm_first 
								m_em_elect
								m_ge_index
								m_ipv_rej_disobey_long
								m_ipv_report 
								m_ipv_norm_rej
								resp_female 
								resp_muslim						
								resp_age
								b_resp_samevillage
								b_resp_religiosity
								b_resp_literate 	
								b_resp_standard7 
								b_resp_nevervisitcity 
								b_resp_married 
								b_resp_hhh 
								b_resp_numkid
								b_resp_numhh
								b_resp_yrsvill
								b_values_likechange 
								b_values_techgood 
								b_values_respectauthority 
								b_values_trustelders
								b_ge_raisekids 
								b_ge_earning 
								b_ge_leadership 
								b_ge_noprefboy 
								b_fm_reject
								b_media_tv_any 
								b_media_news_never 
								b_media_news_daily 
								b_radio_any 
								b_radio_community_ever
								b_radio_call_ever
								b_radio_stations_tbc 
								b_radio_stations_pfm 
								b_radio_stations_voa 
								b_radio_stations_clouds
								b_asset_multiplehuts
								b_asset_rooms
								b_asset_mudwalls
								b_asset_radio
								b_asset_tv
								b_asset_cell
								b_asset_cellint
								b_asset_worseconditions
								b_hiv_exctot
								b_hiv_safe
								b_asset_radio_num
								b_ge_index
								em_reject
								values_tzovertribe
								b_resp_education
								assets_electricity
								ge_work 
								m_ipv_rej_disobey 
								;
	#d cr
	

	save "${user}/Dropbox/Wellspring Tanzania Papers/Wellspring Tanzania - Audio Screening (efm)/cps_replication/cps_efm_analysis.dta", replace
	
/* Reshape Kids Long ___________________________________________________________

	use "${data}/01_raw_data/pfm_as_endline_clean_kid_long.dta", clear
	rename * k_*
	rename k_id_resp_uid id_resp_uid 
	merge n:1 id_resp_uid using `temp_all', gen(_merge_kids)
	keep if _merge_kids == 3
	save "${data_as}/pfm_as_analysis_kids.dta", replace
	*/
	
/* Reshape Leaders Long ________________________________________________________

	collapse (mean) treat block_as cluster_as ptixpref_rank_ag ptixpref_rank_crime ptixpref_rank_efm ptixpref_rank_edu ptixpref_rank_justice ptixpref_rank_electric ptixpref_rank_sanit ptixpref_rank_roads ptixpref_rank_health, by(id_village_uid)
	gen l_id_village_uid = id_village_uid
	merge 1:n l_id_village_uid using "${data}/01_raw_data/pfm_leader_long.dta", gen(merge_leaderlong)
	save "${data_as}/pfm_as_analysis_leaders.dta", replace

*/
