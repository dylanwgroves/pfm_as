

* Coeficient
if "$test" == "onesided" {

	/* Calculate one-side pvalue */
	if $coef > 0 {
		global helper_pval = ttail(${df},abs(${t})) 
	}
	else if $coef < 0 {
		global helper_pval = 1-ttail(${df},abs(${t}))
	}

}
	
if "$test" == "twosided" {

	/* Calculate two-side pvalue */
	global helper_pval = 2*ttail(${df},abs(${t})) 

}


* Covar
	/* Calculate two-side pvalue */
	global covar_helper_pval = 2*ttail(${df},abs(${covar_t})) 

	
	
* HetFX
if "$hetfx_test" == "onesided" {

	/* Calculate one-side pvalue */
	if ${hetfx_coef} > 0 {
		global hetfx_helper_pval = ttail(${df},abs(${hetfx_t})) 
	}
	else if $coef < 0 {
		global hetfx_helper_pval = 1-ttail(${df},abs(${hetfx_t}))
	}

}
	
if "$hetfx_test" == "twosided" {

	/* Calculate two-side pvalue */
	global hetfx_helper_pval = 2*ttail(${df},abs(${hetfx_t})) 

}
di "$helper_pval"
