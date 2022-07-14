
/* Calculate RI p-value */

/* one sided */
local rip_count = 0


forval j = 1 / $rerandcount {

gen hetfx_`j' = treat_`j' * $covar
	
if "${hetfx_test}" == "onesided" {

		qui xi: reg $dv treat_`j' `covar' hetfx_`j' ${cov_always}, cluster(id_village_n)
			matrix RIP = r(table)
			local coef_ri = RIP[1,3]
			if ${hetfx_coef} < `coef_ri' { 	  
					local rip_count = `rip_count' + 1	
			}
	}	


if "${hetfx_test}" == "onesidedneg" {
	
		qui xi: reg $dv treat_`j' `covar' hetfx_`j' ${cov_always}, cluster(id_village_n)
			matrix RIP = r(table)
			local coef_ri = RIP[1,3]
			if ${hetfx_coef} > `coef_ri' { 	  
					local rip_count = `rip_count' + 1	
			}
	}	


if "${hetfx_test}" == "twosided" {
	
		qui xi: reg $dv treat_`j' `covar' hetfx_`j' ${cov_always}, cluster(id_village_n)
			matrix RIP = r(table)
			local coef_ri = RIP[1,3]
			if abs(${hetfx_coef}) < abs(`coef_ri') { 	  
				local rip_count = `rip_count' + 1	
			}
	}
	
	
drop hetfx_`j'

}

	di "`rip_count' AND $rerandcount"
	global hetfx_helper_ripval = `rip_count' / $rerandcount
	
	
		
	