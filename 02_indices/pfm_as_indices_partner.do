

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
		
		global takeup		/* Takeup */
							p_rd_receive
							p_radio_ever
							p_radio_listen_twoweek
							p_radio_listen_hrperday
							p_radio_listen_hrs
							;
							
		global pint			/* Political Interest */
							p_ptixpart_interest
							p_radio_locleader 
							p_radio_natleader 
							;
							
		global healthknow 	/* Health Knowledge */
							p_resp_ppe
							p_healthknow_notradmed 
							p_healthknow_nowitchcraft 
							p_healthknow_vaccines 
							p_healthknow_vaccines_imp 
							;
							
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
							
		global prej_nbr		/* Prejudice */
							p_prej_yesnbr_index
							p_prej_yesnbr_aids 
							p_prej_yesnbr_homo 
							p_prej_yesnbr_alcoholic 
							p_prej_yesnbr_unmarried 
							;
							
		global prej_marry 	p_prej_kidmarry_index
							p_prej_kidmarry_nottribe 
							p_prej_kidmarry_notrelig 
							p_prej_kidmarry_nottz
							p_prej_kidmarry_notrural 
							;
							
		global prej_thermo 	p_prej_thermo_city 
							p_prej_thermo_chinese 
							p_prej_thermo_kenyan 
							p_prej_thermo_out_rel 
							p_prej_thermo_out_eth
							;
							
		global values	 	/* Values */
							p_values_tzovertribe_dum
							p_values_urbangood 
							p_resp_urbanvisit
							p_resp_religiosity
							;
							
		global ppref	   	/* Political Preferences */
							p_values_dontquestion
							p_ptixknow_trustnat 
							p_ptixknow_trustloc
							p_ptixknow_trustrel
							p_ptixpref_global_approve
							p_ptixpref_respnat
							p_ptixpref_resploc
							p_ptixpref_respcom
							;
							
		global ppart 		/* Political Participation */
							p_ptixpart_villmeet
							p_ptixpart_collact
							p_ptixpart_vote
							;
							
		global wpp 			p_wpp_attitude_dum 
							p_wpp_norm_dum 
							p_wpp_behavior 
							;
		/*					
		global hivknow		hivknow_index 
							hivknow_arv_survive 
							hivknow_arv_nospread 
							hivknow_transmit 
							;
							
		global hivdisclose	hivdisclose_index 
							hivdisclose_fam 
							hivdisclose_friend 
							hivdisclose_cowork 
							hivdisclose_nosecret 
							;
							
		global hivstigma 	hivstigma_index 
							hivstigma_notfired 
							hivstigma_yesbus 
							hivstigma_notfired_norm 
							;
		*/
		
		/* Covariates */	
		global cov_always	i.id_village_uid_c									
							;					

		
	
		/* Lasso Covariates - Partner */
		global cov_lasso	p_resp_age 
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
							b_fm_reject
							;
