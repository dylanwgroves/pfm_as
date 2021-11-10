/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Radio Distribution Experiment
Purpose: Balance
Author: dylan groves, dylanwgroves@gmail.com
Date: 2021/04/01
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)


/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear

	
/* Run Prelim Do File __________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_${survey}.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_labels.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_twosided.do"


	
/* Define Globals and Locals ____________________________________________________*/

	/* Set seed */
	set seed 			1956
	
	/* Set seed */
	global rerandcount 	1000

	/* Outcomes */
	#d ;
	local base_vars		resp_female 
						resp_muslim
						b_resp_religiosity
						b_values_likechange 
						b_values_techgood 
						b_values_respectauthority 
						b_values_trustelders
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
						b_resp_nevervisittown
						b_resp_married 
						b_resp_hhh 
						b_resp_numkid
						b_resp_numhh
						b_resp_numolder
						b_resp_numyounger
						b_resp_kidsever
						b_resp_yrsvill
						b_fm_reject
						b_resp_samevillage
						b_radio_stations_clouds
						b_radio_stations_pfm
						b_radio_stations_tbc
						b_radio_community_ever
						b_radio_call_ever
						b_hiv_aware
						b_hiv_exctot
						b_hiv_safe
						b_hiv_bus
						b_mob_falseaccuse
						b_mob_accuseresponse
						b_asset_multiplehuts
						b_asset_walls
						b_asset_radio
						b_asset_radio_listen
						b_asset_tv
						b_asset_cell
						b_asset_cellint
						b_asset_battery
						b_svy_otherspresent
						;
	#d cr
	
/* Define Matrix _______________________________________________________________*/
		
	/* Set Put Excel File Name */
	putexcel clear
	putexcel set "${as_tables}/pfm_as_balance_long.xlsx", replace 
	
	putexcel A1 = ("variable")
	putexcel B1 = ("variablelabel")
	putexcel C1 = ("treatmean")
	putexcel D1 = ("treatsd")
	putexcel E1 = ("controlmean")
	putexcel F1 = ("controlsd")
	putexcel G1 = ("coef")
	putexcel H1 = ("pval")
	putexcel I1 = ("ripval")
	putexcel J1 = ("N")
	putexcel K1 = ("min")
	putexcel L1 = ("max")
	putexcel M1 = ("samplemean")

	
/* Export Regression ___________________________________________________________*/

	/* Set locals */
	local i = 1
	local row = 2

	/* Run and save for each variable */
	foreach dv of local base_vars  {
	
		/* Set global */
		global dv `dv'

		/* Variable Name */
		qui ds `dv'
			global varname = "`r(varlist)'"  
			
		/* Variable Label */
		global varlabel : var label `dv'
			
		/* Treatment / Control Mean */
		qui sum `dv' if treat == 0 
			global control_mean `r(mean)'
			global control_sd `r(sd)'

		qui sum `dv' if treat == 1 
			global treat_mean `r(mean)'
			global treat_sd `r(sd)'
			
		qui sum `dv'
			global sample_mean `r(mean)'

		/* Variable Range */	
		qui sum `dv' 
			global min = r(min)
			global max = r(max)

		/* Regression  */
		qui xi: reg `dv' treat ${cov_always}		
		
			matrix table = r(table)
				
			/* Save values from regression */
			global coef = table[1,1]    	//beta
			global pval = table[4,1]		//pval
			global r2 	= `e(r2_a)' 		//r-squared
			global n 	= e(N) 				//N
			
		/* RI */
		do "${code}/pfm_audioscreening/01_helpers/pfm_helper_ri_balance.do"
		global ripval = ${helper_ripval}
			
			/* Put excel */
			putexcel A`row' = ("${varname}")
			putexcel B`row' = ("${varlabel}")
			putexcel C`row' = ("${treat_mean}")
			putexcel D`row' = ("${treat_sd}")
			putexcel E`row' = ("${control_mean}")
			putexcel F`row' = ("${control_sd}")
			putexcel G`row' = ("${coef}")
			putexcel H`row' = ("${pval}")
			putexcel I`row' = ("${ripval}")
			putexcel J`row' = ("${n}")
			putexcel K`row' = ("${min}")
			putexcel L`row' = ("${max}")
			putexcel M`row' = ("${sample_mean}")

	/* Update locals */
	local row = `row' + 1
	local i = `i' + 1 
}	



	

















