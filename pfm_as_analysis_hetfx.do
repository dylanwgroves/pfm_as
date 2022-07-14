
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
	
/* Run Prelim File _____________________________________________________________*/ // comment out if you dont need to rerun prelim cleaning	

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_covars.do"
	*do "${code}/pfm_audioscreening_efm/pfm_as_prelim.do"


/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear

	// IMPORTANT NOTE: we do not use for attrition, attendance, and uptake											
	keep if m_comply_attend == 1 | (m_comply_attend != 1 & comply_true == 1)	


/* Define Parameters ___________________________________________________*/

	#d ;
		
		/* set seed */
		set seed 			1956
							;
							
		/* rerandomization count */
		global rerandcount	200	
							;
		
		/* survey */
		global survey 		main
							;
							/*
							main	
							partner
							friend
							kid
							*/	
					
		/* Indices */			
		local index_list	mid_fm 
							mid_em 
							mid_norm 
							mid_report 
							mid_priority 
							mid_gender 
							mid_ipv
							fm  
							em 
							norm 
							em_report 
							em_record 
							priority 
							wpp 
							gender 
							ipv
							/*
							attrition // NOTE only use this independently, and run among entire sample instead of just compliers	
							attendance // Note only use this separate from other indices, and run on entire sample instead of just compliers
							uptake
							fm
							em
							norm
							em_report 
							em_record 
							priority
							wpp 
							gender 	
							ipv
							mid_fm
							mid_em
							mid_norm
							mid_report
							mid_priority
							mid_gender
							mid_ipv
							*/
							;
							
							
		/* Indices */			
		global hetfx_var	resp_muslim
							/*
							attrition // NOTE only use this independently, and run among entire sample instead of just compliers	
							attendance // Note only use this separate from other indices, and run on entire sample instead of just compliers
							uptake
							fm
							em
							norm
							em_report 
							em_record 
							priority
							wpp 
							gender 	
							ipv
							mid_fm
							mid_em
							mid_norm
							mid_report
							mid_priority
							mid_gender
							mid_ipv
							*/
							;
	#d cr

	
/* Run Do File ______________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_${survey}.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_labels.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_twosided.do"
			
			
/* Run for each Covar __________________________________________________________*/

foreach covar of global hetfx_var {

	replace `covar' = . if `covar' != 1 & `covar' != 0

	/* HetFX Var Summary Stats _____________________________________________*/

		/* variable */
		global covar `covar'
		
		/* Variable name */
		qui ds `covar'
			global covar_variable = "`r(varlist)'"  

		/* Variable label */
		global covar_varlabel : var label `covar'
		
		/* Set test */
		if strpos("${hetfx_onesided}", "`covar'") { 
			global hetfx_test onesided
		} 
			else {
				global hetfx_test twosided
			}

		/* Covar mean */
		qui sum `covar'
			global covar_mean `r(mean)'
			global covar_sd `r(sd)'
			
		/* Control village sd */
		preserve
		qui collapse (mean) `covar' treat, by(id_village_uid)
		qui sum `covar' if treat == 0
			global vill_sd : di %6.3f r(sd)
		restore

		/* Variable range */	
		qui sum `covar' 
			global covar_min = r(min)
			global covar_max = r(max)

			
/* Run for each DV _____________________________________________________________*/

	foreach index of local index_list {

	/* Drop Macros */
	macro drop lasso_ctls 
	macro drop lasso_ctls_num 
	macro drop lasso_ctls_int
	
	macro drop lasso_ctls_replacement
	macro drop lasso_ctls_num_replacement 
	macro drop lasso_ctls_int_replace
	
	macro drop helper_pval
	macro drop helper_ripval
	macro drop helper_lasso_pval
	macro drop helper_lasso_ripval
	
	macro drop test
	
	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${as_tables}/pfm_as_analysis_${survey}_hetfx_${hetfx_var}.xlsx", sheet(`index', replace) modify
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		qui putexcel C1 = ("covar_variable")
		qui putexcel D1 = ("covar_label")
		qui putexcel E1 = ("coef")
		qui putexcel F1 = ("se")
		qui putexcel G1 = ("pval")
		qui putexcel H1 = ("ripval")
		qui putexcel I1 = ("r2")
		qui putexcel J1 = ("N")
		qui putexcel K1 = ("covar_coef")
		qui putexcel L1 = ("covar_se")
		qui putexcel M1 = ("covar_pval")
		qui putexcel N1 = ("covar_ripval")
		qui putexcel O1 = ("hetfx_coef")
		qui putexcel P1 = ("hetfx_se")
		qui putexcel Q1 = ("hetfx_pval")
		qui putexcel R1 = ("hetfx_ripval")
		qui putexcel S1 = ("lasso_r2")
		qui putexcel T1 = ("lasso_N")
		qui putexcel U1 = ("lasso_ctls")
		qui putexcel V1 = ("lasso_ctls_num")
		qui putexcel X1 = ("treat_mean")
		qui putexcel Y1 = ("treat_sd")
		qui putexcel Z1 = ("ctl_mean")
		qui putexcel AA1 = ("ctl_sd")
		qui putexcel AB1 = ("vill_sd")
		qui putexcel AC1 = ("covar_mean")
		qui putexcel AD1 = ("covar_sd")
		qui putexcel AE1 = ("covar_vill_sd")
		qui putexcel AF1 = ("min")
		qui putexcel AG1 = ("max")
		qui putexcel AH1 = ("covar_min")
		qui putexcel AI1 = ("covar_max")
		qui putexcel AJ1 = ("test")

		
	/* Main Variable Summary Stats _____________________________________________*/

		/* Set locals */
		local var_list ${`index'}												// Variables
		local row = 2															// Row for exporting to matrix
		foreach dv of local var_list  {
		
		/* variable */
		global dv `dv'
		
		/* set test */
		if strpos("$twosided", "`dv'") { 
			global test twosided
		} 
			else {
				global test onesided
			}
		
		/* Variable name */
		qui ds `dv'
			global variable = "`r(varlist)'"  

		/* Variable label */
		global varlabel : var label `dv'
		
		/* Treatment mean */
		qui sum `dv' if treat == 0 
			global ctl_mean `r(mean)'
			global ctl_sd `r(sd)'

		/* Control mean */
		qui sum `dv' if treat == 1 
			global treat_mean `r(mean)'
			global treat_sd `r(sd)'
			
		/* Control village sd */
		preserve
		qui collapse (mean) `dv' treat, by(id_village_uid)
		qui sum `dv' if treat == 0
			global vill_sd : di %6.3f r(sd)
		restore

		/* Variable range */	
		qui sum `dv' 
			global min = r(min)
			global max = r(max)
			
	/* Generate HetFX Var */
	cap drop hetfx
	gen hetfx = treat*${covar}

	/* Basic Regression ________________________________________________________*/

		xi: reg ${dv} treat `covar' hetfx ${cov_always}, cluster(id_village_n)									// This is the core regression
			matrix table = r(table)
			
			/* Save values from regression */
			global coef = table[1,1]    	//beta
			global se 	= table[2,1]		//pval
			global t 	= table[3,1]		//tstat
			global pval = table[4,1]		//tstat
			
			global covar_coef 	= table[1,2]    	//beta
			global covar_se 	= table[2,2]		//pval
			global covar_t 		= table[3,2]		//tstat
			global covar_pval = table[4,2]		//tstat
			
			global hetfx_coef 	= table[1,3]    	//beta
			global hetfx_se 	= table[2,3]		//pval
			global hetfx_t 		= table[3,3]		//tstat
			global hetfx_pval = table[4,3]		//tstat
			
			global r2 	= `e(r2_a)' 		//r-squared
			global N 	= e(N) 				//N
			global df 	= e(df_r)
			
			/* Calculate pvalue 
			do "${code}/pfm_audioscreening_efm/01_helpers/pfm_helper_pval_hetfx.do"
			global pval = ${helper_pval}
			global covar_pval = ${covar_helper_pval}
			global hetfx_pval = ${hetfx_helper_pval}
			*/
			/* Calculate RI-pvalue */
			do "${code}/pfm_audioscreening_efm/01_helpers/pfm_helper_pval_ri_hetfx.do"
			global hetfx_ripval = ${hetfx_helper_ripval}

	/* Lasso Regression  _______________________________________________________

		qui lasso linear `dv' ${cov_lasso}										// set this up as a separate do file
			global lasso_ctls = e(allvars_sel)										
			global lasso_ctls_num = e(k_nonzero_sel)

	
		if ${lasso_ctls_num} != 0 {												// If lassovars selected	
			qui regress `dv' treat ${cov_always} ${lasso_ctls}, cluster(id_village_n)
				matrix table = r(table)
			}
			
			else if ${lasso_ctls_num} == 0 {									// If no lassovars selected
				qui regress `dv' treat ${cov_always}, cluster(id_village_n)
					matrix table = r(table)
			}	
		
			/* Save Coefficient */
			local lasso_coef = table[1,1]
				
			/* Save values from regression */
			global lasso_coef 	= table[1,1]    	//beta
			global lasso_se 	= table[2,1]		//pval
			global lasso_t 		= table[3,1]		//pval
			global lasso_r2 	= `e(r2_a)' 		//r-squared
			global lasso_n 		= e(N) 				//N			
			global lasso_df 	= e(df_r)

			/* Calculate one-sided pvalue */				
			do "${code}/pfm_audioscreening_efm/01_helpers/pfm_helper_pval_lasso.do"
			global lasso_pval = ${helper_lasso_pval}
			
			/* Calculate Lasso RI-pvalue */
			do "${code}/pfm_audioscreening_efm/01_helpers/pfm_helper_pval_ri_lasso.do"
			global lasso_ripval = ${helper_lasso_ripval}
	*/
	
	
	
	/* Export to Excel _________________________________________________________*/ 
		
		di "Variable is ${varname}, coefficient is ${coef}, pval is ${pval} / ripval is ${ripval}, N = ${n}"
		di "LASSO: Variable is ${varname}, coefficient is ${lasso_coef}, lasso pval is ${lasso_pval} / lasso ripval is ${lasso_ripval}, N = ${lasso_n}"
		di "LASSO vars were ${lasso_ctls}"

		/* Set Put Excel File Name */		
		qui putexcel A`row' = ("${variable}")
		qui putexcel B`row' = ("${variablelabel}")
		qui putexcel C`row' = ("${covar_variable}")
		qui putexcel D`row' = ("${covar_label}")
		qui putexcel E`row' = ("${coef}")
		qui putexcel F`row' = ("${se}")
		qui putexcel G`row' = ("${pval}")
		*qui putexcel H`row' = ("${ripval}")
		qui putexcel I`row' = ("${r2}")
		qui putexcel J`row' = ("${N}")
		qui putexcel K`row' = ("${covar_coef}")
		qui putexcel L`row' = ("${covar_se}")
		qui putexcel M`row' = ("${covar_pval}")
		*qui putexcel N`row' = ("${covar_ripval}")
		qui putexcel O`row' = ("${hetfx_coef}")
		qui putexcel P`row' = ("${hetfx_se}")
		qui putexcel Q`row' = ("${hetfx_pval}")
		qui putexcel R`row' = ("${hetfx_ripval}")
		qui putexcel S`row' = ("${lasso_r2}")
		qui putexcel T`row' = ("${lasso_N}")
		qui putexcel U`row' = ("${lasso_ctls}")
		qui putexcel V`row' = ("${lasso_ctls_num}")
		qui putexcel X`row' = ("${treat_mean}")
		qui putexcel Y`row' = ("${treat_sd}")
		qui putexcel Z`row' = ("${ctl_mean}")
		qui putexcel AA`row' = ("${ctl_sd}")
		qui putexcel AB`row' = ("${vill_sd}")
		qui putexcel AC`row' = ("${covar_mean}")
		qui putexcel AD`row' = ("${covar_sd}")
		qui putexcel AE`row' = ("${covar_vill_sd}")
		qui putexcel AF`row' = ("${min}")
		qui putexcel AG`row' = ("${max}")
		qui putexcel AH`row' = ("${covar_min}")
		qui putexcel AI`row' = ("${covar_max}")
		qui putexcel AJ`row' = ("${test}")
		
		/* Update locals ___________________________________________________________*/
		
		local row = `row' + 1
		}
		
	}
}






















