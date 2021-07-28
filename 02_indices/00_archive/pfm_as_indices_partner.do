

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
							
		global gender		/* Gender Equality */
							p_ge_index 
							p_ge_work 
							p_ge_leadership 
							p_ge_business 
							p_ge_school
							;
							
		global ipv 			p_ipv_rej_disobey 
							p_ipv_norm_rej 
							p_ipv_report
							;
							
		global fm 			p_fm_reject
							p_fm_reject_long
							;
							
		global em 			p_em_reject_index
							p_em_reject_religion_dum 
							p_em_reject_noschool_dum 
							p_em_reject_pregnant_dum 
							p_em_reject_money_dum 
							p_em_report
							p_em_norm_reject_dum
							;
							
		global priority		p_em_elect
							p_em_priority_list
							p_ptixpref_partner_efm
							;				
							
		global wpp 			p_wpp_attitude_dum 
							p_wpp_norm_dum 
							p_wpp_behavior 
							;
		
		/*
		global hivknow		p_hivknow_index 
							p_hivknow_arv_survive 
							p_hivknow_arv_nospread 
							p_hivknow_transmit 
							;
							
		global hivdisclose	p_hivdisclose_index 
							p_hivdisclose_fam 
							p_hivdisclose_friend 
							p_hivdisclose_cowork 
							p_hivdisclose_nosecret 
							;
							
		global hivstigma 	p_hivstigma_index 
							p_hivstigma_notfired 
							p_hivstigma_yesbus 
							p_hivstigma_notfired_norm 
							;
		*/
		
		/* Covariates */	
		global cov_always	i.block_as									
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
							;
