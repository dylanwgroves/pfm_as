/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Natural Experiment
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

	
/* Run Prelim File ______________________________________________________________*/	

	do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/../pfm_audioscreening/pfm_as_prelim.do"

	
/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear
		
		
/* Define Globals and Locals ___________________________________________________*/
	#d ;
	
		/* Rerandomization count */
		local rerandcount	1000
							;
		
		/* Outcomes */
		global dv			p_fm_reject
							p_fm_reject_long 
							p_fm_partner_reject
							p_em_reject
							p_em_reject_index
							p_em_norm_reject_bean
							p_em_report
							p_em_report_norm
							p_em_record_reject
							p_em_record_shareany
							p_em_elect
							p_ptixpref_rank_efm
							p_wpp_attitude_dum 
							p_wpp_behavior
							p_wpp_partner
							p_ge_index
							p_ipv_rej_disobey	
							p_ipv_norm_rej
							;	

		/* Covariates */	
		global cov_always	i.block_as											// Covariates that are always included
							received_radio
							;	
							
		/* Lasso Covariates */
		global cov_lasso	resp_female 
							resp_muslim
							b_resp_numkid
							;
	
		/* Statitistics of interest */
		local stats_list 	coefficient											//1
							se													//2
							ripval												//3
							pval												//4
							controls_num										//5
							r2													//6
							N 													//7
							basic_coefficient									
							basic_se
							basic_ripval
							basic_pval											//11
							basic_r2
							basic_N
							ctl_mean
							ctl_sd
							treat_mean											//16
							treat_sd
							vill_sd												
							min		
							max
							;
	#d cr


/* Sandbox _____________________________________________________________________

foreach var of varlist p_em_reject_all {
	reg `var' treat received_radio i.block_as, cluster(id_village_uid)	
}

*/
	
	
/* Define Matrix _______________________________________________________________

	This section prepares an empty matrix to hold results
*/

	local var_list ${dv}
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

/* Lasso Regression  ___________________________________________________________*/

	qui lasso linear `dv' ${cov_lasso}
		local lassovars = e(allvars_sel)
		local lassovars_num  = e(k_nonzero_sel)

	if `lassovars_num' != 0 {	
		qui reg `dv' treat `lassovars' ${cov_always}, cluster(id_village_n)
			matrix table = r(table)
		}
		else if "`l_`i''" == "" {
			qui reg `dv' treat ${cov_always}, cluster(id_village_n)
				matrix table = r(table)
		}	
		
		/* Save Coefficient */
		local lasso_coef = table[1,1]
			
		/* Save beta on treatment, standard error, r-squared, and N */
		mat R[`i',1]= table[1,1]    	//beta
		mat R[`i',2]= table[2,1]   		//p
		mat R[`i',4]= table[4,1]   		//se
		mat R[`i',5]= `lassovars_num'	//Lassovars Number
		mat R[`i',6]= `e(r2_a)' 		//r-squared
		mat R[`i',7]= e(N)   			//N 
			
		/* Calculate Lasso RI p-value */										// Move to program (and is it faster to do the export to excel strategy?)
		local lasso_rip_count = 0
		forval k = 1/`rerandcount' {
			if `lassovars_num' != 0 {											
				qui reg `dv' treat_`k' `lassovars' ${cov_always}, cluster(id_village_n)
					matrix RIP = r(table)
				}
				else if "`l_`i''" == "" {
					qui reg `dv' treat_`k' ${cov_always}, cluster(id_village_n)
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
		
		
/* Basic Regression  ___________________________________________________________*/

	/* Run basic regression */
	qui xi: reg `dv' treat ${cov_always}, cluster(id_village_n)					// This is the core regression
		
		/* Save Coefficient */
		matrix table = r(table)
		local coef = table[1,1]
		
		/* Save beta on treatment, se, R, N, control mean, (save space for ri p-val!) */
		mat R[`i',8]= table[1,1]    	//beta
		mat R[`i',9]= table[2,1]   		//se
		mat R[`i',11]= table[4,1]   	//p-val
		mat R[`i',12]= `e(r2_a)' 		//r-squared
		mat R[`i',13]= e(N) 			//N
		
		/* Calculate RI p-value */
		local rip_count = 0
		forval j = 1 / `rerandcount' {
			qui xi: reg `dv' treat_`j' ${cov_always}, cluster(id_village_n)
				matrix RIP = r(table)
				local coef_ri = RIP[1,1]
				if `coef' > 0 {
					if `coef' < `coef_ri' { 	  
						local rip_count = `rip_count' + 1	
					}
				}
				if `coef' < 0 {
					if abs(`coef') < abs(`coef_ri') { 	  
						local rip_count = `rip_count' + 1	
					}
				}
		}
		mat R[`i',10] = `rip_count' / `rerandcount'	
		
/* Gather Summary Statistics ___________________________________________________*/
	
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
		qui collapse (mean) `dv' treat, by(id_village_n)
	qui sum `dv' if treat == 0
		local sd `r(sd)'
		restore
	
	/* Save variable summaries */
		mat R[`i',14]= `treat_mean'    		// treat mean
		mat R[`i',15]= `treat_sd'    		// treat sd		
		mat R[`i',16]= `control_mean'    	// control mean
		mat R[`i',17]= `control_sd'    		// control mean
		mat R[`i',18]= `sd'   				// village-sd
		mat R[`i',19]= `min'  				// min
		mat R[`i',20]= `max'  				// max

local i = `i' + 1 
}

	
/* Export Matrix _______________________________________________________________*/ 

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
	foreach index in `stats_list' { 
		cap confirm variable name`i' 
		if _rc==0 {
			rename name`i' `index'
			local ++i
		} 
	}  

	/* Export */
	export excel using "${as_tables}/pfm_as_rawresults_partner", sheetreplace firstrow(variables)





















