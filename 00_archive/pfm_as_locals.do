	#d ;

		/* Outcomes */
		local fm			fm_reject
							fm_reject_long 
							/*fm_partner_reject*/									// Not in friend
							fm_friend_reject
							;
		local em_attitude	em_reject_index
							em_reject_religion_dum 
							em_reject_money_dum
							/*
							em_reject_noschool_dum								// Not in friend
							em_reject_pregnant_dum								// Not in friend
							em_reject_needhus_dum								// Not in friend
							*/
							;
		local em_norm 		em_norm_reject_dum
							;
		local em_report  	em_report
							em_report_norm
							;
		local em_record 	em_record_reject
							em_record_shareany
							em_record_shareany_name
							;
		local pref 			em_elect
							ptixpref_efm 
							ptixpref_efm_first 
							ptixpref_efm_topthree 
							ptixpref_efm_notlast 
							/*ptixpref_partner_efm*/							// Original and partner only
							;
		local wpp 			wpp_attitude_dum 
							wpp_behavior
							wpp_partner
							;
		local gender		ge_index
							/*ge_earning*/											// Friends only
							ge_school 
							ge_work 
							ge_leadership 
							ge_business
							;
		local ipv 			ipv_rej_disobey	
							ipv_rej_hithard
							ipv_rej_persists
							ipv_norm_rej	
							ipv_report
							;	
	#d cr