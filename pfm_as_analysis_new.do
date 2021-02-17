/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening Spillover (Partner + Friend + Kids)
Purpose: Analysis
Author: dylan groves, dylanwgroves@gmail.com
Date: 2021
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)

	
/* Run Prelim File _____________________________________________________________ // comment out if you dont need to rerun prelim cleaning	

	*do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_audioscreening/pfm_as_prelim.do"
*/

/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis_kids.dta", clear							// Only use for Kids							
	*use "${data_as}/pfm_as_analysis.dta", clear								// Use for all non-kids analysis

	keep if comply_true == 1 | comply_true == .
	*keep if p_resp_age != .													// People with partner
	*keep if p_resp_age == .													// People with no partner

/* Define Globals and Locals ___________________________________________________*/

	#d ;
		
		/* Parnter Survey or No? */
		local partner 		0													// set to 1 for partner survey
							;
		
		/* Friends Survey or No? */
		local friend 		0													// set to 1 for friend survey
							;
		
		/* Kid Survey or No? */
		local kid 			1													// set to 1 for kid survey
							;
		
		
		/* Sandbox */															// Set if you just want to see the immediate results without export
		local sandbox		0
							;
		
		
		/* Rerandomization count */
		local rerandcount	10
							;
			
			
		/* Set seed */
		set seed 			1956
							;
							
			
		/* Indices */		
		local index_list	
							fm_kid
							ge_kid
							em_att_kid
							pref_kid
							/*Index Options
							fm
							em_attitude
							em_norm 
							em_report 
							em_record 
							pref 
							wpp 
							gender 
							ipv
							fm_kid
							ge_kid
							em_att_kid
							pref_kid
							*/
							;

		/* Outcomes */
		local fm			fm_reject
							fm_reject_long 
							/*fm_partner_reject									// Not in friend
							fm_friend_reject*/
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
							/*
							ptixpref_efm 
							ptixpref_efm_first 
							ptixpref_efm_topthree 
							ptixpref_efm_notlast 
							ptixpref_partner_efm*/							// Original and partner only
							;
		local wpp 			wpp_attitude_dum 
							wpp_behavior
							wpp_partner
							;
		local gender		ge_index
							/*ge_earning*/										// Friends only
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
		local ge_kid		ge_index
							ge_wep_dum 
							ge_earning 
							ge_school
							;
		local fm_kid		fm_reject
							fm_reject_long 
							fm_parent_reject
							;
							
		local em_att_kid	em_reject_index
							em_reject_religion_dum 
							em_reject_money_dum
							;
		local pref_kid		em_elect
							;
		/* Covariates */	
		global cov_always	i.block_as											// Covariates that are always included
							i.rd_group
							;	
							
		/* Cluster */
		global cluster		id_village_n
							;	
							
		/* Lasso Covariates */
		global cov_lasso	
							resp_female 
							resp_muslim
							p_resp_age
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
							
		/* Friend Lasso Covariates */
		global cov_lasso_friend	
							f_resp_female
							f_resp_age
							f_resp_earnmoney
							f_resp_muslim
							f_resp_edu
							f_resp_readandwrite
							f_resp_evercity
							f_resp_yrsinvill
							;
							
		/* Kid Lasso Covariates */
		global cov_lasso_kid	
							k_resp_female 
							k_resp_age 
							k_resp_readandwrite 
							k_resp_muslim 
							k_resp_religiousschool
							;
							
		
		/* Statitistics of interest */
		local stats_list 	coefficient											//1
							se													//2
							ripval												//3
							pval												//4
							controls_num										//5
							r2													//6
							N 													//7
							basic_coefficient									//8
							basic_se											//9
							basic_ripval										//10
							basic_pval											//11
							basic_r2											//12
							basic_N												//13
							ctl_mean											//14
							ctl_sd												//15
							treat_mean											//16
							treat_sd											//17
							vill_sd												//18													
							min													//19
							max													//20
							;
	#d cr

/* Sandbox _____________________________________________________________________*/

recode treat (0=1)(1=0)
reg k_hivknow_arv_survive treat##c.parent_currentevents ${cov_always}, cluster(id_village_n)
stop
if `sandbox' > 0 {

	estimates clear

	foreach index of local index_list {
/**/
		** Main Effect
		foreach var of local `index' {
			xi : regress `var' treat ${cov_always} i.svy_enum, cluster(id_village_n)
			estimates store sb_`var'
		}
		
		
	estimates table sb_*, keep(treat) b(%7.4f) se(%7.4f)  p(%7.4f) stats(N r2_a) model(20)	
	estimates clear
	
		** Interaction Effect
		gen interact = treat*rd_treat
		
		foreach var of local `index' {
			xi : regress `var' treat rd_treat interact ${cov_always}, cluster(id_village_n)
			estimates store sb_`var'
		}
	
	estimates table sb_*, keep(treat rd_treat interact) b(%7.4f) se(%7.4f)  p(%7.4f) stats(N r2_a) model(20)
	
	estimates clear
	drop interact
	}
}


/* Run for Each Index __________________________________________________________*/

foreach index of local index_list {


	/* Adjust for Partner Survey _______________________________________________*/

		if `partner' > 0 {														// Need to change variable titles if partner survey
			local dv_p
			foreach var of local `index' {
				local dv_p `dv_p' p_`var'
				}
			local newindex `dv_p'
			local var_list `newindex'
		}
		
	/* Adjust for Friend Survey ________________________________________________*/

		if `friend' > 0 {														// Need to change variable titles if partner survey
			local dv_f
			foreach var of local `index' {
				local dv_f `dv_f' f_`var'
				}
			local newindex `dv_f'
			local var_list `newindex'
		}
		
	/* Adjust for Kid Survey ________________________________________________*/

		if `kid' > 0 {															// Need to change variable titles if partner survey
			local dv_k
			foreach var of local `index' {
				local dv_k `dv_k' k_`var'
				}
			local newindex `dv_k'
			local var_list `newindex'
		}


	/* Define Matrix ____________________________________________________________

		This section prepares an empty matrix to hold results
	*/
		if `partner' < 1 & `friend' < 1 & `kid' < 1 {
				local var_list ``index''
		}
		
		local varnames ""   
		local varlabs ""   
		local mat_length `: word count `var_list'' 
		local mat_width `: word count `stats_list'' 
		mat R =  J(`mat_length', `mat_width', .)

		
	/* Export Regression ___________________________________________________________*/

	local i = 1

	foreach dv of local var_list  {

		/* Variable Name */
		qui ds `dv'
			local varname = "`r(varlist)'"  
			*local varlab: var label `var'  										// Could capture variable label in future	
			local varnames `varnames' `varname'   
			*local varlabs `varlabs' `varlab' 

	/* Lasso Regression  _______________________________________________________*/

		/* Run Lasso on Appropriate Variables */
		if `partner' > 0 {
			qui lasso linear `dv' ${cov_lasso_partner}							// Place holder if we want to create separate covariates
		}
		if `friend' > 0 {
			qui lasso linear `dv' ${cov_lasso_friend}
		}
		if `kid' > 0 {
			qui lasso linear `dv' ${cov_lasso_kid}
		}		
		if `partner' < 1 & `friend' < 1 & `kid' < 1 {
			qui lasso linear `dv' ${cov_lasso}
		}

			/* Collect Lassos from Variables */
			local lassovars = e(allvars_sel)
			local lassovars_num  = e(k_nonzero_sel)

		/* Run Lasso Regressions */
		if `lassovars_num' != 0 {	
			reg `dv' treat `lassovars' ${cov_always}, cluster(${cluster})
				matrix table = r(table)
			}
			else if "`lassovars_num'" == "0" {
				qui reg `dv' treat ${cov_always}, cluster(${cluster})
					matrix table = r(table)
			}	
			
			/* Save Coefficient */
			local lasso_coef = table[1,1]
				
			/* Save beta on treatment, standard error, r-squared, and N */
			mat R[`i',1]= table[1,1]    											//beta
			mat R[`i',2]= table[2,1]   												//se
			local pval = table[4,1]													//pval
				if `lasso_coef' > 0 {
					local pval = `pval'/2
				}
			mat R[`i',5]= `lassovars_num'											//lassovars Number
			mat R[`i',6]= `e(r2_a)' 												//r-squared
			mat R[`i',7]= e(N)   													//N 
				
			/* Calculate Lasso RI p-value */										// Move to program (and is it faster to do the export to excel strategy?)
			local lasso_rip_count = 0
			forval k = 1/`rerandcount' {
				if `lassovars_num' != 0 {											
					qui reg `dv' treat_`k' `lassovars' ${cov_always}, cluster(${cluster})
						matrix RIP = r(table)
					}
					else if "`lassovars_num'" == "0" {
						qui reg `dv' treat_`k' ${cov_always}, cluster(${cluster})
							matrix RIP = r(table)
					}	
					local lasso_coef_ri = RIP[1,1]
						if `lasso_coef' > 0 {
							if `lasso_coef' < `lasso_coef_ri' { 	  
								local lasso_rip_count = `lasso_rip_count' + 1	
							}
						}
						if `lasso_coef' < 0 {
							if abs(`lasso_coef') < abs(`lasso_coef_ri') { 	  
								local lasso_rip_count = `lasso_rip_count' + 1		
							}
						}
			}
			mat R[`i',3] = `lasso_rip_count' / `rerandcount'	
			mat R[`i',4] = `pval'	
			
			di "****************************************"
			di "*** Variable is `dv'"
			di "*** N is `e(N)'"
			di "*** coef is `lasso_coef'"
			di "*** pval is `pval'"
			di "*** ripval is `lasso_rip_count' / `rerandcount'	"
			di "*** Lasso vars are `lassovars' "
		
	/* Basic Regression  _______________________________________________________*/

		/* Run basic regression */
		qui xi: reg `dv' treat ${cov_always}, cluster(${cluster})				// This is the core regression
			
			/* Save Coefficient */
			matrix table = r(table)
			local coef = table[1,1]
			
			/* Save beta on treat, se, R, N, means (save space for pval!) */
			mat R[`i',8]= table[1,1]    										//beta
			mat R[`i',9]= table[2,1]   											//se	
			local basic_pval = table[4,1]										//pval
				if `coef' > 0 {
					local basic_pval = `basic_pval'/2
				}
			mat R[`i',12]= `e(r2_a)' 											//r-squared
			mat R[`i',13]= e(N) 												//N
			
			/* Calculate RI p-value */
			local rip_count = 0
			forval j = 1 / `rerandcount' {
				qui xi: reg `dv' treat_`j' ${cov_always}, cluster(${cluster})
					matrix RIP = r(table)
					local coef_ri = RIP[1,1]
					if `coef' > 0 {
						if `coef' < `coef_ri' { 								// If coefficient is in expected direction  
							local rip_count = `rip_count' + 1
						}
					}
					if `coef' < 0 {
						if abs(`coef') < abs(`coef_ri') { 	  					// If coefficient is in expected direction
							local rip_count = `rip_count' + 1	
						}
					}
			}
			mat R[`i',10] = `rip_count' / `rerandcount'							//ri pval	
			mat R[`i',11]= 	`basic_pval'   										//p-val
			di "*** Basic coef is `coef'"
			di "*** Basic pval is `basic_pval'"
			di "*** Basic ripval is `rip_count' / `rerandcount'	"
			di "****************************************"
	
			
	/* Gather Summary Statistics _______________________________________________*/
		
		/* Treat/Control Mean */
		qui sum `dv' if treat == 0 
			local control_mean `r(mean)'
			local control_sd `r(sd)'
		qui sum `dv' if treat == 1 
			local treat_mean `r(mean)'
			local treat_sd `r(sd)'

		/* Variable Range */
		qui sum `dv' 
			local min = r(min)
			local max = r(max)
					
		/* Village SD */
			preserve
			qui collapse (mean) `dv' treat, by(${cluster})
		qui sum `dv' if treat == 0
			local sd `r(sd)'
			restore
		
		/* Save variable summaries */
			mat R[`i',14]= `control_mean'    											// treat mean
			mat R[`i',15]= `control_sd'    											// treat sd		
			mat R[`i',16]= `treat_mean'    										// control mean
			mat R[`i',17]= `treat_sd'    											// control sd
			mat R[`i',18]= `sd'   													// village-sd
			mat R[`i',19]= `min'  													// min
			mat R[`i',20]= `max'  													// max

		/* Reset Locals */
			capture macro drop pval
			capture macro drop basic_pval
			capture macro drop lassovars_num
			
	local i = `i' + 1 
	}

		
	/* Export Matrix _______________________________________________________________*/ 
		preserve 
		
		/* Row Names */
		mat rownames R = `varnames'  

		/* Transfer matrix to using dataset */
		clear
		svmat R, names(name)

		/* Create a variable for each outcome */
		gen outcome = "" 
		order outcome, before(name1)
		local i = 1 
		foreach var in `var_list' { 
			replace outcome="`var'" if _n==`i' 
			local ++i
		}

		/* Label regression statistics variables */
		local i 1 
		foreach col in `stats_list' { 
			cap confirm variable name`i' 	
			if _rc==0 {
				rename name`i' `col'
				local ++i
			} 
		}  


		/* Export */
			
			/* Partner */
			if `partner' > 0 {
				save "${data_as}/`index'_partner", replace
				export excel using "${as_tables}/pfm_as_rawresults_partner", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			}
			
			/* Friend */
			if `friend' > 0 {
				save "${data_as}/`index'_friend", replace
				export excel using "${as_tables}/pfm_as_rawresults_friend", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			}
			
			/* Kid */
			if `kid' > 0 {
				save "${data_as}/`index'_kid", replace
				export excel using "${as_tables}/pfm_as_rawresults_kid", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			}		
			
			/* Main */
			if `partner' < 1 & `friend' < 1 & `kid' < 1 {
				save "${data_as}/`index'", replace
				*export excel using "${as_tables}/pfm_as_rawresults_pplwNOpartners", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
				*export excel using "${as_tables}/pfm_as_rawresults_pplwpartners", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
				export excel using "${as_tables}/pfm_as_rawresults", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			}
			restore

	}

	














