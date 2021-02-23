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

/* Run Prelim File _____________________________________________________________	

	do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_audioscreening/pfm_as_prelim.do"
*/


/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear
	
	keep if comply_attend == 1

	
/* Define Globals and Locals ___________________________________________________*/
	#d ;
		
		/* Set seed */
		set seed 			1956
							;
							
			
		/* Indices */		
		local index_list	
							efm 
							wpp 
							gender
							ipv
							;
							
		/* Outcomes */
		local efm			fm_reject
							fm_reject_long 
							em_reject_money_dum
							em_reject_religion_dum
							em_reject_pregnant_dum 
							em_norm_reject_dum 
							em_report 
							em_report_norm 
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
	
							
		/* Cluster */
		global cluster		id_village_n
							;	
							
		/* Lasso Covariates */
		global cov_vars		i.block_as											// Covariates that are always included
							i.rd_group
							;
							
		/* Statitistics of interest */
		local stats_list 	
							coefficient											//1
							se													//2
							pval
							ctl_mean											
							ctl_sd	
							ctl_n
							treat_mean											
							treat_sd	
							treat_n
							min													
							max													
							;
	#d cr

	
/* Run for Each Index __________________________________________________________*/

foreach index of local index_list {

	/* Define Matrix ___________________________________________________________*/

		local var_list ``index''
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

	/* Basic Regression  _______________________________________________________*/

		/* Run basic regression */
		xi: reg `dv' treat ${cov_vars}, cluster(${cluster})						// This is the core regression
			
			/* Save beta on treat, se, R, N, means (save space for pval!) */
			matrix table = r(table)
			
			local coef = table[1,1]    											//beta
			local stderr = table[2,1]   										//se	
			local pval = table[4,1]												//pval
	
	
	/* Gather Summary Statistics _______________________________________________*/
		
		/* Treat/Control Mean */
		qui sum `dv' if treat == 0 
			local control_mean `r(mean)'
			local control_sd `r(sd)'
			local control_n `r(N)'
		qui sum `dv' if treat == 1 
			local treat_mean `r(mean)'
			local treat_sd `r(sd)'
			local treat_n `r(N)'

		/* Variable Range */
		qui sum `dv' 
			local min = r(min)
			local max = r(max)
		
		/* Save variable summaries */
			mat R[`i',1]= `coef'    											// treat mean
			mat R[`i',2]= `stderr'    											// treat sd		
			mat R[`i',3]= `pval'    											// pval
			mat R[`i',4]= `control_mean'    									// control mean
			mat R[`i',5]= `control_sd'    										// control_sd	
			mat R[`i',6]= `control_n'    										// control_n	
			mat R[`i',7]= `treat_mean'    										// treat mean
			mat R[`i',8]= `treat_sd'    										// treat sd
			mat R[`i',9]= `treat_n'    											// treat n
			mat R[`i',10]= `min'  												// min
			mat R[`i',11]= `max'  												// max

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


/* Export ______________________________________________________________________*/
			
	/* Main */
	export excel using "${uzikwasa}/pfm_as_tables.xlsx", sheet(`index') sheetreplace firstrow(variables) keepcellfmt
			
	restore

	}

	



