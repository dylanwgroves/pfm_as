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

	
/* Run Prelim File _____________________________________________________________ // Don't have to always re-run this but do have to re-run after an update	

	do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/../pfm_audioscreening/pfm_as_prelim.do"
*/


	
/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear
			
		
/* Define Globals and Locals ___________________________________________________*/
	#d ;
		/* Set seed */
		set seed 			1956
							;
		
		/* Parnter Survey or No? */
		local partner 		0													// SET TO 1 IF YOU WANT TO RUN FOR PARTNER SURVEY
							;
		
		/* Rerandomization count */
		local rerandcount	1000	
							;

		/* Covariates */	
		global cov_always	i.block_as											// Covariates that are always included
							received_radio
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
							b_em_comreject_pct 
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

estimates clear

	foreach var of local dv {
		qui xi : regress `var' b_fm_reject treat ${cov_always}, cluster(id_village_n)
		estimates store sb_`var'
	}	
		
estimates table sb_*, keep(treat) b(%7.4f) se(%7.4f)  p(%7.4f) stats(N r2_a)

stop
*/

/* Adjust for Partner Survey ___________________________________________________*/

	if `partner' > 0	 {														// Need to change variable titles if partner survey
		local dv_p
		foreach var of local dv {
			local dv_p `dv_p' p_`var'
			}
		local dv `dv_p'
	}


/* Define Matrix _______________________________________________________________

	This section prepares an empty matrix to hold results
*/

	local var_list `dv'
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

	
/* Basic Regression  ___________________________________________________________*/

	/* Run basic regression */
	qui xi: reg `dv' treat ${cov_always}, cluster(${cluster})					// This is the core regression
		
		/* Save Coefficient */
		matrix table = r(table)
		local coef = table[1,1]
		
		/* Save beta on treat, se, R, N, means (save space for pval!) */
		mat R[`i',1]= table[1,1]    											//beta
		mat R[`i',2]= table[2,1]   												//se	
		local basic_pval = table[4,1]											//pval
		mat R[`i',5]= `e(r2_a)' 												//r-squared
		mat R[`i',6]= e(N) 													//N
		
		/* Calculate RI p-value */
		local rip_count = 0
		forval j = 1 / `rerandcount' {
			qui xi: reg `dv' treat_`j' ${cov_always}, cluster(${cluster})
				matrix RIP = r(table)
				local coef_ri = RIP[1,1]
				if abs(`coef') < abs(`coef_ri') { 	  						// If coefficient is in expected direction
						local rip_count = `rip_count' + 1	
					}
				}
		mat R[`i',3] = `rip_count' / `rerandcount'								//ri pval	
		mat R[`i',4]= 	`basic_pval'   												//p-val
		di "*** Basic coef is `coef'"
		di "*** Basic pval is `basic_pval'"
		di "*** Basic ripval is `rip_count' / `rerandcount'	"
		di "****************************************"

		
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
		local pval = 0
		local basic_pval = 0
		
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
	
	if `partner' > 0 {
		export excel using "${as_tables}/pfm_as_rawresults_partner", sheetreplace firstrow(variables)
	}
	if `partner' < 1 {
		export excel using "${as_tables}/pfm_as_rawresults", sheetreplace firstrow(variables)
	}





















