	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Natural Experiment
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

	/* Attendance Data */
	import excel "${data_as}\pfm_as_attendance.xlsx", sheet("Sheet1") firstrow clear
		replace comply_true = 1 if m_comply_attend == "Yes" & comply_true == .
			replace comply_true = 0 if m_comply_attend == "No" & comply_true == .
		drop fm_reject resp_female m_comply_attend treat Diff id_resp_n id_village_n
	save `temp_attend', replace

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

	
/* Merge  ______________________________________________________________________*/	

	merge 1:1 id_resp_uid using `temp_attend'
	
/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
	/* Primary Analysis is only with people who own a radio */					
	keep if  endline_as == 1
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

/* Save ________________________________________________________________________*/

	save "${data_as}/pfm_as_analysis.dta", replace
