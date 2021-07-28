

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
							
		global efm_gender		
							f_ge_index 
							f_ge_work 
							f_ge_leadership 
							f_ge_business 
							f_ge_school
							;
							
		global efm_ipv 		
							f_ipv_rej_disobey 
							f_ipv_norm_rej 
							f_ipv_report
							;
							
		global efm_fm 		
							f_fm_reject
							f_fm_reject_long
							;
							
		global efm_em 			
							f_em_reject
							f_em_reject_index
							f_em_reject_religion_dum 
							f_em_reject_money_dum
							f_em_report
							f_em_norm_reject_dum
							;
							
		global efm_priority		
							f_em_elect
							f_ptixpref_efm 
							f_ptixpref_efm_first 
							f_ptixpref_efm_topthree 
							f_ptixpref_efm_notlast 
							;
							
		global efm_em_record
							f_em_record_reject 
							f_em_record_shareptix 
							f_em_record_sharepfm 
							f_em_record_shareany 
							f_em_record_name 
							f_em_record_shareptix_name 
							f_em_record_sharepfm_name 
							f_em_record_shareany_name
							;

		global hiv_know		
							f_hivknow_arv_survive
							;
							
		global hiv_disclose	
							f_hivdisclose_index 
							f_hivdisclose_friend 
							f_hivdisclose_cowork  
							;
							
		global hiv_stigma 	
							f_hivstigma_yesbus 
							;
							
		global hiv_priority 	
							f_hiv_elect
							f_ptixpref_hiv 
							f_ptixpref_hiv_first 
							f_ptixpref_hiv_topthree 
							f_ptixpref_hiv_notlast
							;

		/* Covariates */	
		global cov_always	
							i.block_as									
							;					

		
	
		/* Lasso Covariates - Partner */
		global cov_lasso	
							f_resp_age 
							f_resp_female 
							f_resp_muslim
							f_resp_religiosity
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
							i.f_svy_enum
							;
