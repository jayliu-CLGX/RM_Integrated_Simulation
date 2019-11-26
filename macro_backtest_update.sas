**********************************************************************************************************************;
**********************************************************************************************************************;
*** backtest performance simulation data preparation;
%macro backtest_perf(midid, ARM_FRM, negamID, lientype);

	%include "&macrodir.macro_RM_automation_forwardtest.sas";

	%let projname = &testname._&loan_type._&product;

	%do y = 1 %to &numsimjob;
		%let RM_dir&y = &outdir./&projname./&&simjob&y.; 	*OUTPUT PATH FOR RM SIMULATION RESULTS;
	%end;

	%let lss = %eval(1 - &histid);

	%RM_autosimulate_agency(&dirid, &outdir, &file, &simjob1,,, dialedid=0, lssoff=&lss);

%mend backtest_perf;

**********************************************************************************************************************;
*** backtest performance report;
%macro backtest_perf_rpt(midid, ARM_FRM, negamID, lientype);

	%include "&macrodir.macro_getfile.sas";
	%include "&macrodir.macro_observed_rollrates.sas";
	%include "&macrodir.macro_calc_cprcdr.sas";
	%include "&macrodir.macro_rollrateplot_text.sas";
	%include "&macrodir.macro_erroreport.sas";

	%let projname = &testname._&loan_type._&product;

	%do y = 1 %to &numsimjob;
		%let RM_dir&y = &outdir./&projname./&&simjob&y.; 	*OUTPUT PATH FOR RM SIMULATION RESULTS;
	%end;

	*let lss = %eval(1 - &histid);

	%setrollrate_backtest;
	%settrans_backtest;

	/*
	proc datasets;
	save  sasmacr;
	quit;

	%erroreport_text(&logpath, &loan_type._&product._output_&file.3.log, errorreport_&loan_type._&product._&file.3);
	*/

%mend backtest_perf_rpt;

**********************************************************************************************************************;
*** Previous version;
%macro backtest_perf_backup20191030(midid, ARM_FRM, negamID, lientype);

%include "&macrodir.macro_RM_automation_forwardtest.sas";
%include "&macrodir.macro_getfile.sas";
%include "&macrodir.macro_observed_rollrates.sas";
%include "&macrodir.macro_calc_cprcdr.sas";
%include "&macrodir.macro_rollrateplot_text.sas";
%include "&macrodir.macro_erroreport.sas";

%let projname = &testname._&loan_type._&product;

%do y = 1 %to &numsimjob;
	%let RM_dir&y = &outdir./&projname./&&simjob&y.; 	*OUTPUT PATH FOR RM SIMULATION RESULTS;
%end;

%let lss = %eval(1 - &histid);

%RM_autosimulate_agency(&dirid, &OUTDIR, &file, &simjob1,,, dialedid=0, lssoff=&lss);

%setrollrate_backtest;

%settrans_backtest;

proc datasets;
save  sasmacr;
quit;

%erroreport_text(&logpath, &loan_type._&product._output_&file.3.log, errorreport_&loan_type._&product._&file.3);

%mend backtest_perf_backup20191030;

**********************************************************************************************************************;
**********************************************************************************************************************;
