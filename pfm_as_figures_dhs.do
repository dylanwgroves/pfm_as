/* _____________________________________________________________________________

	Project: Wellspring Tanzania
	Author: Beatrice Montano, bm2955@columbia.edu

	Date: 2022/06/24
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	set maxvar 32767 

	tempfile dta_dhs_tz

/* _____________________________________________________________________________
																			
   Figures from DHS about early marriage
______________________________________________________________________________*/	
	
	use "${data_as}/TZ_2015-16_DHS_06212022_1434_111200/TZIR7BDT/TZIR7BFL.DTA" , clear
	
	do "${data_as}/TZ_2015-16_DHS_06212022_1434_111200/TZIR7BDT/TZIR7BFL.DO" 

/*	Information about DHS vars to use

	label variable v000     "Country code and phase"
	label variable v001     "Cluster number"
	label variable v002     "Household number"
	label variable v003     "Respondent's line number"
	label variable v004     "Ultimate area unit"
	
	label variable v005     "Women's individual sample weight (6 decimals)"

	label variable v021     "Primary sampling unit"
	label variable v022     "Sample strata for sampling errors"
	label variable v023     "Stratification used in sample design"
	label variable v024     "Region" 											// == 4 Tanga
	label variable v025     "Type of place of residence" 						// == 2 Rural

	label variable v010     "Respondent's year of birth"						// complete info
	label variable v508     "Year of first cohabitation"						// 74% complete
	label variable v511     "Age at first cohabitation"

	gen check = v508 - v010
	gen checkcheck = 1 if check != v511 // v511 considers also the month, so let's just do another one that considers only year as more sure.
	
	* https://dhsprogram.com/data/Guide-to-DHS-Statistics/Analyzing_DHS_Data.htm
	* The sum of the sample weights only equals the number of cases for the entire sample and not for subgroups such as urban and rural areas.
	
	*/

	gen wt  = v005/1000000	
		
	gen agecohab = v508 - v010
	replace agecohab = . if agecohab < 12		// these must be mistakes

	gen em = (agecohab <18 )
		replace em = . if agecohab == . 
	gen married = (agecohab != .)
	
	* restrict to women first married by the time they were 25 (so we control for an overall marriage rate without being biased by younger cohorts missing data)
	gen sample = 0
	replace sample = 1 if v010 < 1990 
	replace sample = 0 if agecohab > 25
	replace sample = . if married == 0

	save `dta_dhs_tz', replace

	* Tanzania * 
		
		use `dta_dhs_tz', clear
		count 																	// 13,266

		count if sample == 1
		local count `r(N)'
		di "`count'"
							
		* Calculate share of early marriages
		
			/* not weighted
				bys v010: egen meanyob_em = mean(em) if sample == 1
				scatter meanyob_em v010
				*/
			
			* TABLE: weighted average of early marriages across all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1 
				egen den = total(wt * !missing(em, wt)) if sample == 1
				gen mean_em_w = num/den
				drop num den

				sum mean_em_w
				global em_tz = `r(mean)'
				di "${em_tz}"

				
			* PLOT: weighted average of early marriages across each year of birth of all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(em, wt)) if sample == 1, by(v010) 
				gen meanyob_em_w = num/den
				drop num den
		
				bys v010: sum meanyob_em_w
				
				twoway (lowess meanyob_em_w v010 , lcolor(black) ) ///
					   (scatter meanyob_em_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(0/1)) xscale(range(1960/1990)) ///
							ylabel(0(0.1)1,     labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Share of Marriages that are Early, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title("Tanzania", color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_emshare_TZ.png", as(png) width(3000)   replace

		* Calculate average age of marriage
			
			/* not weighted
				bys v010: egen meanyob_agecohab = mean(agecohab) if sample == 1
				scatter meanyob_agecohab v010
				*/
			
			* TABLE: weighted average age at first marriage across all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1 
				gen mean_agecohab_w = num/den
				drop num den

				sum mean_agecohab_w
				global age_tz = `r(mean)'
				di "${age_tz}"
				
				
			* PLOT: weighted average age at first marriage across each year of birth of all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				gen meanyob_agecohab_w = num/den
				drop num den
		
				bys v010: sum meanyob_agecohab_w
				
				twoway (lowess meanyob_agecohab_w v010 , lcolor(black) ) ///
						(scatter meanyob_agecohab_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(16(1)22)) xscale(range(1965(5)1990)) ///
							ylabel(16(0.5)22, labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Average Age at First Marriage, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Tanzania, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_meanage_TZ.png", as(png) width(3000)   replace
				
				
	* Rural Tanzania * 															// I am not sure if there is a bias in the weights like this!
		
		use `dta_dhs_tz', clear

		keep if v025 == 2 
		count 																	// rural Tanzania 9.121

		count if sample == 1
		local count `r(N)'
									
		* Calculate share of early marriages
		
			/* not weighted
				bys v010: egen meanyob_em = mean(em) if sample == 1
				scatter meanyob_em v010
				*/
			
			* TABLE: weighted average of early marriages across all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1 
				egen den = total(wt * !missing(em, wt)) if sample == 1
				gen mean_em_w = num/den
				drop num den

				sum mean_em_w
				global em_tzrural = `r(mean)'
				di "${em_tzrural}"
				global em_tzrural_N = `r(N)'
				di "${em_tzrural_N}"
				
				
			* PLOT: weighted average of early marriages across each year of birth of all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(em, wt)) if sample == 1, by(v010) 
				gen meanyob_em_w = num/den
				drop num den
		
				bys v010: sum meanyob_em_w
								
				twoway (lowess meanyob_em_w v010 , lcolor(black) ) ///
					   (scatter meanyob_em_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(0/1)) xscale(range(1960/1990)) ///
							ylabel(0(0.1)1,     labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Share of Marriages that are Early, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Rural Tanzania, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_emshare_TZrural.png", as(png) width(3000)   replace

	 	* Calculate average age of marriage
			
			/* not weighted
				bys v010: egen meanyob_agecohab = mean(agecohab) if sample == 1
				scatter meanyob_agecohab v010
				*/
			
			* TABLE: weighted average age at first marriage across all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1 
				gen mean_agecohab_w = num/den
				drop num den

				sum mean_agecohab_w
				global age_tzrural = `r(mean)'
				di "${age_tzrural}"
				global age_tzrural_N = `r(N)'
				di "${age_tzrural_N}"
			
			* PLOT: weighted average age at first marriage across each year of birth of all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				gen meanyob_agecohab_w = num/den
				drop num den
		
				bys v010: sum meanyob_agecohab_w
								
				twoway (lowess meanyob_agecohab_w v010 , lcolor(black) ) ///
						(scatter meanyob_agecohab_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(16(1)22)) xscale(range(1965(5)1990)) ///
							ylabel(16(0.5)22, labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Average Age at First Marriage, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Rural Tanzania, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_meanage_TZrural.png", as(png) width(3000)   replace
	

	* Tanga * 																	// since strata included region, this is not biased with weights!
		
		use `dta_dhs_tz', clear
		
		keep  if v024 == 4 
		count 																	// Tanga N 465

		count if sample == 1
		local count `r(N)'
										
		* Calculate share of early marriages
		
			/* not weighted
				bys v010: egen meanyob_em = mean(em) if sample == 1
				scatter meanyob_em v010
				*/
			
			* TABLE: weighted average of early marriages across all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1 
				egen den = total(wt * !missing(em, wt)) if sample == 1
				gen mean_em_w = num/den
				drop num den

				sum mean_em_w
				global em_tanga = `r(mean)'
				di "${em_tanga}"
				
			* PLOT: weighted average of early marriages across each year of birth of all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(em, wt)) if sample == 1, by(v010) 
				gen meanyob_em_w = num/den
				drop num den
		
				bys v010: sum meanyob_em_w
								
				twoway (lowess meanyob_em_w v010 , lcolor(black) ) ///
					   (scatter meanyob_em_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(0/1)) xscale(range(1960/1990)) ///
							ylabel(0(0.1)1,     labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Share of Marriages that are Early, size(small)) xtitle(Woman Year of Birth , size(small))  /// 
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Tanga, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_emshare_Tanga.png", as(png) width(3000)   replace

		* Calculate average age of marriage
			
			/* not weighted
				bys v010: egen meanyob_agecohab = mean(agecohab) if sample == 1
				scatter meanyob_agecohab v010
				*/
			
			* TABLE: weighted average age at first marriage across all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1 
				gen mean_agecohab_w = num/den
				drop num den

				sum mean_agecohab_w
				global age_tanga = `r(mean)'
				di "${age_tanga}"
				
			* PLOT: weighted average age at first marriage across each year of birth of all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				gen meanyob_agecohab_w = num/den
				drop num den
		
				bys v010: sum meanyob_agecohab_w
								
				twoway (lowess meanyob_agecohab_w v010 , lcolor(black) ) ///
						(scatter meanyob_agecohab_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(16(0.5)22)) xscale(range(1965(5)1990)) ///
							ylabel(16(0.5)22, labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Average Age at First Marriage, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Tanga, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_meanage_Tanga.png", as(png) width(3000)   replace
			
				
	* Rural Tanga * 															// I am not sure if there is a bias in the weights like this!
		
		use `dta_dhs_tz', clear
		
		keep if v024 == 4 & v025 == 2 
		count 																	// rural Tanga N 322

		count if sample == 1
		local count `r(N)'
		di "`r(N)'"
										
		* Calculate share of early marriages
		
			/* not weighted
				bys v010: egen meanyob_em = mean(em) if sample == 1
				scatter meanyob_em v010
				*/
			
			* TABLE: weighted average of early marriages across all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1 
				egen den = total(wt * !missing(em, wt)) if sample == 1
				gen mean_em_w = num/den
				drop num den

				sum mean_em_w
				global em_tangarural = `r(mean)'
				di "${em_tangarural}"
				
			* PLOT: weighted average of early marriages across each year of birth of all women first married by the time they were 25 
				egen num = total(em * wt * !missing(em, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(em, wt)) if sample == 1, by(v010) 
				gen meanyob_em_w = num/den
				drop num den
		
				bys v010: sum meanyob_em_w
								
				twoway (lowess meanyob_em_w v010 , lcolor(black) ) ///
					   (scatter meanyob_em_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(0/1)) xscale(range(1960/1990)) ///
							ylabel(0(0.1)1,     labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Share of Marriages that are Early, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Rural Tanga, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_emshare_Tangarural.png", as(png) width(3000)   replace
	
		* Calculate average age of marriage
			
			/* not weighted
				bys v010: egen meanyob_agecohab = mean(agecohab) if sample == 1
				scatter meanyob_agecohab v010
				*/
			
			* TABLE: weighted average age at first marriage across all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1 
				gen mean_agecohab_w = num/den
				drop num den

				sum mean_agecohab_w
				global age_tangarural = `r(mean)'
				di "${age_tangarural}"			
				
			* PLOT: weighted average age at first marriage across each year of birth of all women first married by the time they were 25 
				egen num = total(agecohab * wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				egen den = total(wt * !missing(agecohab, wt)) if sample == 1, by(v010) 
				gen meanyob_agecohab_w = num/den
				drop num den
		
				bys v010: sum meanyob_agecohab_w
								
				twoway (lowess meanyob_agecohab_w v010 , lcolor(black) ) ///
						(scatter meanyob_agecohab_w v010 , mcolor(gs15) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)), ///
							ysize(3) xsize(3) yscale(range(16(1)22)) xscale(range(1965(5)1990)) ///
							ylabel(16(0.5)22, labsize(small) grid glwidth(thin) glcolor(white)) /// 
							xlabel(1960(5)1990, labsize(small) grid glwidth(thin) glcolor(white)) ///
							legend(off) ytitle(Average Age at First Marriage, size(small)) xtitle(Woman Year of Birth , size(small))  ///
							bgcolor(white) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white) margin(zero)) ///
							title(Rural Tanga, color(black)) subtitle("N: `count' ")
				graph export "${as_clean_figures}/figure_dhs_meanage_Tangarural.png", as(png) width(3000)   replace
	
