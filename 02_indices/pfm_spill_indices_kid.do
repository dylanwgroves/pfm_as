

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
							
		global efm_gender
							k_ge_index
							k_ge_earning 
							k_ge_parent_earning 
							k_ge_school 
							k_ge_wep_dum  
							k_ge_hhlabor_chores_dum 
							k_ge_hhlabor_money_dum 
							;
							
		global efm_fm		k_fm_reject
							k_fm_reject_long
							k_fm_parent_reject
							;
							
		global efm_em		k_em_reject 
							k_em_parent_reject 
							k_em_reject_religion_dum 
							k_em_reject_money_dum 
							k_em_legalage18
							k_em_reject_index
							;
							
		global efm_priority	k_em_elect
							;				
							
		global hiv_know		k_hivknow_arv_survive
							;
							
		global hiv_disclose	k_hivdisclose_nosecret
							;
							
		global hiv_stigma 	k_hivstigma_yesbus
							k_hivstigma_parent_yesbus
							;
							
		global hiv_priority k_hiv_elect
							;
		
		/* Covariates */	
		global cov_always	i.block_as									
							;					

		
	
		/* Lasso Covariates - Partner */
		global cov_lasso	
							k_resp_female 
							k_resp_age 
							k_resp_edu 
							k_resp_readandwrite 
							k_resp_religion
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
							i.k_svy_enum
							;
