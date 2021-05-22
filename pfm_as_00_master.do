
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution
	Purpose: Master
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2021/04/26
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956

/* Paths and master ____________________________________________________________*/	

	do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_.master/pfm_master.do"

	
/* RD prelim ___________________________________________________________________*/

	do "${code}/pfm_as/pfm_as_prelim.do"

	
/* Balance _____________________________________________________________________*/

	do "${code}/pfm_as/pfm_as_02_balance.do"
	
/* Analysis ____________________________________________________________________*/

	do "${code}/pfm_as/pfm_as_03_analysis.do"
	
/* Tables ______________________________________________________________________*/

	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_01_balance.texdoc"
	
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_02_compliance.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_02_uptake.texdoc"

	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_fm_em.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_fm_em_mid.texdoc"
	
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_norm_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_norm.texdoc"

		
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_report_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_report.texdoc"
	
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_priority_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_priority.texdoc"
	
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_gender.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_gender_mid.texdoc"

	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_ipv.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_ipv_mid.texdoc"
	
	/* HetFX */
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_hetfx_fm_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_04_results_hetfx_fm.texdoc"
	



	
	/* Forced Marriage
	
	
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_samplesum.texdoc"
	texdoc do "${code}/pfm_audioscreening/pfm_as_04_tables_02_compliance	.texdoc"
	
	** Prejudice
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_02_uptake_topics.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_prejudice_nbr.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_prejudice_marry.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_prejudice_thermo.texdoc"
	
	** Gender
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_wpp_ge.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_ipv.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_fm_em.texdoc"
	
	** Political Interest and Knowledge
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_ptixknow.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_ptixint_ptixpart.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_healthknow.texdoc"

	/* Values and Preferences */
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_values.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_ptixpref1.texdoc"
	texdoc do "${code}/pfm_radiodistribution/pfm_rd_04_tables_03_ptixpref2_ranks.texdoc"

		
	
	
	