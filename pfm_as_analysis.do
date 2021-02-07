/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Analysis
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/12/23
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)

	
/* Run Prelim File _____________________________________________________________ // comment out if you dont need to rerun prelim cleaning	

	*do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/../pfm_audioscreening/pfm_as_prelim.do"
*/

/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear

keep if comply_true == 1 | comply_true == .

/* Define Globals and Locals ___________________________________________________*/
	#d ;
		
		/* Parnter Survey or No? */
		local partner 		1													// set to 1 for partner survey
							;
		
		
		/* Sandbox */															// Set if you just want to see the immediate results without export
		local sandbox		1
							;
		
		
		/* Rerandomization count */
		local rerandcount	10
							;
			
			
		/* Set seed */
		set seed 			1956
							;
							
			
		/* Indices */		
		local index_list	/*fm*/
							em_attitude
							/*)
							em_norm 
							em_report 
							em_record 
							pref 
							wpp 
							gender 
							ipv
							*/
							;
							
		/* Outcomes */
		local fm			fm_reject
							fm_reject_long 
							fm_partner_reject
							;
		local em_attitude	em_reject_index
							em_reject_religion 
							em_reject_noschool 
							em_reject_pregnant 
							em_reject_money 
							em_reject_needhusband
							;
		local em_norm 		em_norm_reject_bean
							em_norm_reject_dum
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
							ptixpref_partner_efm
							;
		local wpp 			wpp_attitude_dum 
							wpp_behavior
							wpp_partner
							;
		local gender		ge_index
							ge_school 
							ge_work 
							ge_leadership 
							ge_business
							;
		local ipv 			ipv_rej_disobey	
							ipv_norm_rej	
							ipv_report
							;	
		/* Covariates */	
		global cov_always	i.block_as											// Covariates that are always included
							i.rd_group
							;	
		/* Cluster */
		global cluster		id_village_n
							;	
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
							
		/* Lasso Covariates - Partner */
		global cov_lasso_partner	p_resp_age 
							p_resp_urbanvisit 
							p_resp_religiousschool 
							p_resp_religiosity 
							p_resp_female 
							p_resp_muslim
							resp_female 
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

if `sandbox' > 0 {


	estimates clear

	foreach index of local index_list {

		** Main Effect
		foreach var of local `index' {
			xi : regress p_`var' treat ${cov_always} i.svy_enum, cluster(id_village_n)
			estimates store sb_`var'
		}
		
		
	estimates table sb_*, keep(treat) b(%7.4f) se(%7.4f)  p(%7.4f) stats(N r2_a) model(20)
	
	estimates clear
	
		** Interaction Effect
		gen interact = treat*resp_female
		
		foreach var of local `index' {
			xi : regress p_`var' treat resp_female interact ${cov_always}, cluster(id_village_n)
			estimates store sb_`var'
		}
	
	estimates table sb_*, keep(treat resp_female interact) b(%7.4f) se(%7.4f)  p(%7.4f) stats(N r2_a) model(20)
	
	estimates clear
	}
}
stop	

/* Run for Each Index __________________________________________________________*/

foreach index of local index_list {


	/* Adjust for Partner Survey ___________________________________________________*/

		if `partner' > 0 {														// Need to change variable titles if partner survey
			local dv_p
			foreach var of local `index' {
				local dv_p `dv_p' p_`var'
				}
			local newindex `dv_p'
			local var_list `newindex'
		}


	/* Define Matrix _______________________________________________________________

		This section prepares an empty matrix to hold results
	*/
		if `partner' < 1 {
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

		if `partner' > 0 {
			qui lasso linear `dv' ${cov_lasso_partner}
		}
		if `partner' < 1 {
			qui lasso linear `dv' ${cov_lasso}
		}
		
			local lassovars = e(allvars_sel)
			local lassovars_num  = e(k_nonzero_sel)

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
			mat R[`i',14]= `treat_mean'    											// treat mean
			mat R[`i',15]= `treat_sd'    											// treat sd		
			mat R[`i',16]= `control_mean'    										// control mean
			mat R[`i',17]= `control_sd'    											// control sd
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
		if `partner' > 0 {
			save "${data_as}/`index'_partner", replace
			export excel using "${as_tables}/pfm_as_rawresults_partner", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
		}
		if `partner' < 1 {
			save "${data_as}/`index'", replace
			export excel using "${as_tables}/pfm_as_rawresults", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
		}
		restore

}

	














