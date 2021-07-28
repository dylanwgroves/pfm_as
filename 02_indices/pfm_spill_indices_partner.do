

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
							
		global efm_gender		
							p_ge_index 
							p_ge_work 
							p_ge_leadership 
							p_ge_business 
							p_ge_school
							;
							
		global efm_ipv 			
							p_ipv_rej_disobey 
							p_ipv_norm_rej 
							p_ipv_report
							;
							
		global efm_fm 			
							p_fm_reject
							p_fm_reject_long
							;
							
		global efm_em 			
							p_em_reject
							p_em_reject_index
							p_em_reject_religion_dum 
							p_em_reject_noschool_dum 
							p_em_reject_pregnant_dum 
							p_em_reject_money_dum 
							p_em_report
							p_em_norm_reject_dum
							;
							
		global efm_priority		
							p_em_elect
							p_ptixpref_efm 
							p_ptixpref_efm_first 
							p_ptixpref_efm_topthree 
							p_ptixpref_efm_notlast 
							p_ptixpref_partner_efm
							;				
							
		global efm_wpp 			
							p_wpp_attitude_dum 
							p_wpp_norm_dum 
							p_wpp_behavior 
							;
							
		global efm_em_record
							p_em_record_reject 
							p_em_record_shareptix 
							p_em_record_sharepfm 
							p_em_record_shareany 
							p_em_record_name 
							p_em_record_shareptix_name 
							p_em_record_sharepfm_name 
							p_em_record_shareany_name
							;
		
		global hiv_know		
							p_hivknow_index 
							p_hivknow_arv_survive 
							p_hivknow_arv_nospread 
							p_hivknow_transmit 
							;
							
		global hiv_disclose	
							p_hivdisclose_index 
							p_hivdisclose_friend 
							p_hivdisclose_cowork 
							p_hivdisclose_nosecret 
							;
							
		global hiv_stigma 	
							p_hivstigma_index 
							p_hivstigma_notfired 
							p_hivstigma_yesbus 
							p_hivstigma_notfired_norm 
							;
							
		global hiv_priority	
							p_ptixpref_hiv 
							p_ptixpref_hiv_first 
							p_ptixpref_hiv_topthree 
							p_ptixpref_hiv_notlast
							p_hiv_elect
							;
		
		/* Covariates */	
		global cov_always	
							i.block_as									
							;					

		
	
		/* Lasso Covariates - Partner */
		global cov_lasso	
							p_resp_age 
							p_resp_female 
							p_resp_muslim
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
							i.p_svy_enum
							;
