	
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
	

/* Load Data ___________________________________________________________________*/	

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear
	
/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
	/* Primary Analysis is only with people who own a radio */					
	keep if  endline_as == 1
	keep if  m_comply_attend == 1
	
/* Generate any necessary variables ____________________________________________*/

	/* Create "received radio" */
	gen received_radio = (rd_treat == 1)
	encode id_ward_uid, gen(block_as)
	
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
				replace `var' = vill_`var' if `var' == .
			}

/* Save ________________________________________________________________________*/

	save "${data_as}/pfm_as_analysis.dta", replace
