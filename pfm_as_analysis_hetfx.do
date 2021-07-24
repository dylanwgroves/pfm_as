
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

	*do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_audioscreening/pfm_as_prelim.do"
*/

/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear

	keep if m_comply_attend == 1													// For compliance and attendance, don't want to leave this out

/* Define Parameters ___________________________________________________*/

	#d ;
		
		/* set seed */
		set seed 			1956
							;
							
		/* rerandomization count */
		global rerandcount	100
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
		local index_list	
							attrition
							attendance
							uptake
							fm
							em_attitude
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
							mid_ipv
							mid_gender
							/*
							attrition
							attendance
							uptake
							fm
							em_attitude
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
							mid_ipv
							mid_gender
							*/
							;
		/* Het FX Variale */			
		local hetfx_list	
			
	#d cr


/* Run Do File ______________________________________________________________*/

	do "${code}/pfm_audioscreening/02_indices/pfm_as_indices_${survey}.do"
	do "${code}/pfm_audioscreening/02_indices/pfm_as_labels.do"
	do "${code}/pfm_audioscreening/02_indices/pfm_as_twosided.do"


/* Run for Each Index __________________________________________________________*/

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
		putexcel set "${as_tables}/pfm_as_analysis_${survey}.xlsx", sheet(`index', replace) modify
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		qui putexcel C1 = ("coef")
		qui putexcel D1 = ("se")
		qui putexcel E1 = ("pval")
		qui putexcel F1 = ("coef_cov")
		qui putexcel G1 = ("se_cov")
		qui putexcel H1 = ("pval_cov")
		qui putexcel I1 = ("coef_hetfx")
		qui putexcel J1 = ("se_hetfx")
		qui putexcel K1 = ("pval_hetfx")
		qui putexcel L1 = ("ripval_hetfx")
		qui putexcel M1 = ("r2")
		qui putexcel N1 = ("n")
		qui putexcel O1 = ("lasso_coef")
		qui putexcel P1 = ("lasso_se")
		qui putexcel Q1 = ("lasso_pval")
		qui putexcel R1 = ("lasso_coef_cov")
		qui putexcel S1 = ("lasso_se_cov")
		qui putexcel T1 = ("lasso_pval_cov")
		qui putexcel U1 = ("lasso_coef_hetfx")
		qui putexcel V1 = ("lasso_se_hetfx")
		qui putexcel W1 = ("lasso_pval_hetfx")
		qui putexcel X1 = ("lasso_ripval_hetfx")
		qui putexcel Y1 = ("lasso_r2")
		qui putexcel Z1 = ("lasso_n")
		qui putexcel AA1 = ("treat_mean")
		qui putexcel AB1 = ("treat_sd")
		qui putexcel AC1 = ("ctl_mean")
		qui putexcel AD1 = ("ctl_sd")
		qui putexcel AE1 = ("min")	
		qui putexcel AF1 = ("max")
		qui putexcel AG1 = ("lasso_ctls")
		qui putexcel AH1 = ("lasso_ctls_num")

	
	/* Summary Stats ___________________________________________________________*/

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
			global varname = "`r(varlist)'"  

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

			
	/* Basic INTERACT Regression ________________________________________________________*/

		qui xi: reg `dv' treat##`hetfx_var' ${cov_vill}, cluster(id_village_c2)									// This is the core regression
			matrix table = r(table)
						
			/* Save values from regression */
			global coef = table[1,2]    	//beta
			global se 	= table[2,2]		//pval	
			global pval = table[4,2]
			
			global coef_cov = table[1,3]
			global se_cov 	= table[2,3]
			global pval_cov	= table[4,3]
			
			global coef_hetfx	= table[1,5]
			global se_hetfx		= table[2,5]
			global pval_hetfx	= table[4,5]
			
			global r2 	= `e(r2_a)' 		//r-squared
			global n 	= e(N) 				//N
			
			/* Calculate pvalue 
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval.do"
			global pval = ${helper_pval}
			*/
			
			/* Calculate RI-pvalue 
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_ri.do"
			global ripval = ${helper_ripval}
			*/

	/* Lasso Regression  ___________________________________________________________*/

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
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_lasso.do"
			global lasso_pval = ${helper_lasso_pval}
			
			/* Calculate Lasso RI-pvalue */
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_ri_lasso.do"
			global lasso_ripval = ${helper_lasso_ripval}
		
	/* Export to Excel _________________________________________________________*/ 
		
		di "Variable is ${varname}, coefficient is ${coef}, pval is ${pval} / ripval is ${ripval}, N = ${n}"
		di "LASSO: Variable is ${varname}, coefficient is ${lasso_coef}, lasso pval is ${lasso_pval} / lasso ripval is ${lasso_ripval}, N = ${lasso_n}"
		di "LASSO vars were ${lasso_ctls}"

		qui putexcel A`row' = ("${varname}")
		qui putexcel B`row' = ("${varlabel}")
		qui putexcel C`row' = ("${coef}")
		qui putexcel D`row' = ("${se}")
		qui putexcel E`row' = ("${pval}")
		qui putexcel F`row' = ("${ripval}")
		qui putexcel G`row' = ("${r2}")
		qui putexcel H`row' = ("${n}")
		qui putexcel I`row' = ("${lasso_coef}")
		qui putexcel J`row' = ("${lasso_se}")
		qui putexcel K`row' = ("${lasso_pval}")
		qui putexcel L`row' = ("${lasso_ripval}")
		qui putexcel M`row' = ("${lasso_r2}")
		qui putexcel N`row' = ("${lasso_n}")
		qui putexcel O`row' = ("${lasso_ctls}")
		qui putexcel P`row' = ("${lasso_ctls_num}")
		qui putexcel Q`row' = ("${treat_mean}")
		qui putexcel R`row' = ("${treat_sd}")
		qui putexcel S`row' = ("${ctl_mean}")
		qui putexcel T`row' = ("${ctl_sd}")
		qui putexcel U`row' = ("${vill_sd}")
		qui putexcel V`row' = ("${min}")
		qui putexcel W`row' = ("${max}")
		qui putexcel X`row' = ("${test}")
		
		/* Update locals ___________________________________________________________*/
		
		local row = `row' + 1
		}
}



















