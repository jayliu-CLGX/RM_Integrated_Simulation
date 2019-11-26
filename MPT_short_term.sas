**********************************************************************************************************************;
**********************************************************************************************************************;
%macro sim_macros;
	%global path indir outdir outd cprcdr rollrate cprcdr1 rollrate1 cprcdr2 rollrate2 errorpath dirid wdirid logpath logfile;
	%global csfpath csf_path resultp projname;
	
	%let path		 = &foldpath/&loan_type._&product;

	%let logpath	 = &path./LOG/&testname/&testdate./&simjob1;
	%let logfile  = &logpath./&act..log;
	/*	proc printto log = "&logfile" NEW; run;*/


	%LET INDIR		 = &path./DATA/&testname./&testdate;
	*let outd		 = &path./perfdata/&testname/&testdate.;
	%let outdir  	 = &path./Simulation/&testname/&testdate.;
	%let cprcdr		 = &path./perf_act/&testname/&testdate./cprcdr;
	%let rollrate	 = &path./perf_act/&testname/&testdate./rollrate;
	%let cprcdr1	 = &path./results/&testname/&testdate./sas_CPRCDR/&simjob1;
	%let rollrate1	 = &path./results/&testname/&testdate./sas_rollrates/&simjob1;
	%let cprcdr2	 = &path./results/&testname/&testdate./Excel_CPRCDR/&simjob1;
	%let rollrate2	 = &path./results/&testname/&testdate./Excel_rollrates/&simjob1;
	%let errorpath	 = &logpath/errorreport;
	%let dirID 		 = &INDIR;
	%let wdirID 	 = &INDIR;

	*DIRECTORY TO STORE .csv FILES FOR CONVERSION;
	%let csf_path	 = &RMfile;

	*FOLDERPATH FOR .CSF FILE FOR RM CONVERSION;
	/*%let csfpath 	 = &csf_path./&hist._text.csf; *SPECIFIED CSF FILE FOR THE CURRENT MODEL;*/
	%let csfpath 	 = &csf_path./hist_text10SEP12.csf;
	%let resultp	= &path./results/&testname/&testdate.;
	%let projname    = &testname._&loan_type._&product;

%mend sim_macros;

%macro sim_libs;
	*libname outd "&outd";			*LIBRARY for perf. data;
	libname cprcdr "&cprcdr";		*LIBRARY TO STORE observed cprcdr sas data;
	libname rollrate "&rollrate";	*LIBRARY TO STORE observed rollrate sas data;
	libname result2 "&cprcdr1";		*LIBRARY TO STORE combined cprcdr sas data;
	libname result1 "&rollrate1";	*LIBRARY TO STORE combined rollrate sas data;
%mend sim_libs;

%macro runtest(loan, armfrm, lien, histid, year1, year2);

	data _null_;
		m=symget('loan');

		if m = '1' then
			call symput('loan_type','PRIME');
		else if m = '3' then
			call symput('loan_type','FHA');
		else call symput('loan_type','VA');
		n=symget ('ARMFRM');

		if n=1 then
			call symput ('product','ARM');
		else call symput ('product','FRM');

		if &histid=1 then
			call symput ('hist','hist');
		else call symput ('hist','nohist');
	run;

	%sim_macros;

	/*
	x "md &outdir";
	x "md &indir";
	x "md &outd";
	x "md &cprcdr";
	x "md &&rollrate";
	x "md &cprcdr1";
	x "md &rollrate1";
	x "md &cprcdr2";
	x "md &rollrate2";
	x "md &errorpath";
	*/
	
	data _null_;
		x "mkdir -p &path./Simulation/&testname./&testdate./&projname./&simjob1.";
		x "mkdir -p &path./DATA/&testname./&testdate.";
		x "mkdir -p &path./perfdata/&testname./&testdate.";
		x "mkdir -p &path./perf_act/&testname./&testdate./cprcdr &path./perf_act/&testname./&testdate./rollrate";
		x "mkdir -p &resultp./sas_CPRCDR/&simjob1 &resultp./sas_rollrates/&simjob1 &resultp./Excel_CPRCDR/&simjob1 &resultp./Excel_rollrates/&simjob1";
		x "mkdir -p &path./LOG/&testname./&testdate./&simjob1/errorreport";
	run;

	%include "&macrodir.macro_dir_linuxtowindows.sas";
	*let wdirid=Z:\Projects\Agency_2018\MPT\MPT_201910_LLMA_NOMOD\PRIME_FRM\DATA\shortterm\asofperiod339;
	*let wdatadir=%dir_linuxtowindows(linuxdir=&datadir);
	*let woutd=%dir_linuxtowindows(linuxdir=&outd);

	data simconfig;
		length name $30 value $300;
		name="rmfolder"; value="&RM_folder."; output;
		name="pbase"; value="&pbase."; output;
		name="macrofolder"; value="&macrodir."; output;
		name="rmpfolder"; value="&path./Simulation/&testname./&testdate./&projname./&simjob1."; output;
		name="rmpfolder_win"; value="%dir_linuxtowindows(linuxdir=&path./Simulation/&testname./&testdate./&projname./&simjob1.)"; output;
		name="projname"; value="&projname."; output;
		%do a=&year2 %to &year1 %by -1;
			name="rmpfile";
			value="&simjob1._year&a.";
			output;
		%end;
	run;
 
	%sim_libs;
	
	%do a=&year2 %to &year1 %by -1;

		%let testperiod=(year=&a);
		%let dataperiod = %eval(&endperiod-&as_of_period);

		*Observed performance PERIODS USED FOR Comparison;
		%let file = year&a.;

		%let logfile  = &logpath.\&loan_type._&product._output_&file..log;
		proc printto log = "&logfile" NEW; run;
		
		%backtest_perf(midid  =  &loan, ARM_FRM  =  &armfrm, negamID  =  &negam, lientype  =  &lien);
	%end;

	proc printto; run;

%mend runtest;

**********************************************************************************************************************;

options mprint symbolgen mlogic;

/*options noxwait xsync;*/
*options obs=1000;
options obs=max;

*let act=%sysget(act);
*put The current action is &act.!;
*let act=rpt;
%let pbase=/RiskModel1/Projects/Agency_2018/;

*let pbase=/work/jayliu/projects/Agency_2018/;
*** YOUR FOLDER PATH FOR RM SOFTWARE;
%let RM_folder  =  D:\RiskModel\RiskModel 5.3;
%let RMfile = /RiskModel1/Projects/Agency_2018/Files/;
%let hpipath = &RMfile\HPI_path_forwardtest.csv;
%let proj = backtest;

*PROJECT NAME -- PREFIX;
*let macro = Z:\Projects\Agency_2018\MPT\code\macro;
%let macrodir = /work/jayliu/projects/Agency_2018/MPT/Code/;

*include "Z:\Projects\Agency_2018\MPT\code\macro\macro2\MACRO_backtest_update.sas";
%include "&macrodir.macro_backtest_update.sas";

*libname loss 'X:\Projects\MultiperiodTesting\file\';
*Loss Table;
*%let losstable = Loss_bc_table_02012011;
%let modmodel = 0;

*0 = nonmod,1 = mod;
%let modelid = 3;

*1 = createdials, 	2 = forwardtest,		3 = backtest;
%let numsimjob = 1;
%let numberofrun = 50;
%let testperiod2 =;
%let maxpid=1;

*let foldpath = Z:\Projects\Agency_2018\MPT\MPT_201910_LLMA_NOMOD;
%let foldpath = &pbase.MPT/MPT_201910_LLMA_NOMOD;
%let aod = 201703;
%let endperiod = 351;
%let simulationperiod = 12;

*Simulation period for performance comparison, can be longer;
%let as_of_period=%eval(&endperiod-&simulationperiod);
%let testdate=asofperiod&as_of_period.;
%let testname = shortterm;

* change simjob1 to create a new output file - do not overwrite old simjob1 file;
* vtest = Rm version = 9300 , ctest = coefficient file version = 0528;
* vtest example v9300_c0528;
%let simjob1 = v9427_test01;

/*runtest(loan, armfrm, lien, histid, year1, year2, insample);*/
%let numberofrun = 50;
%let numberofrun = 2;

%let year_start=2016;
%let year_end=2016;

*PRIME FRM;
*runtest(1, 2, '1', 1, &year_start, &year_end);

**********************************************************************************************************************;
%macro results(loan, armfrm, negam, lien, year1, year2);

	data _null_;
		m = symget('loan');

		if m = '1' then
			call symput('loan_type','PRIME');
		else if m = '3' then
			call symput('loan_type','FHA');
		else call symput('loan_type','VA');
		n=symget ('ARMFRM');

		if n=1 then
			call symput ('prod','&prod1');
		else call symput ('prod','&prod2');

		if n=1 then
			call symput ('productID','ARM');
		else call symput ('productID','FRM');

		if n=1 then
			call symput ('product','ARM');
		else call symput ('product','FRM');
	run;

	%sim_macros;
	%sim_libs;
	
	%let logfile  = &logpath./&act..log;
	/*	proc printto log = "&logfile" NEW; run;*/

	%do a=&year2 %to &year1 %by -1;

		%let testperiod=(year=&a);
		%let dataperiod = %eval(&endperiod-&as_of_period);

		*Observed performance PERIODS USED FOR Comparison;
		%let file = year&a.;
		
		%backtest_perf_rpt(midid  =  &loan, ARM_FRM  =  &armfrm, negamID  =  &negam, lientype  =  &lien);
	%end;
	
	%include "&macrodir.macro_backtest_result.sas";

	%results_rollrate(&foldpath, &loan_type, &product, &year1, &year2);
	%results_cprcdr(&foldpath, &loan_type, &product, &year1, &year2);

	proc printto; run;

%mend results;

/* results(loan, armfrm, negam, lien, year1, year2);*/
*let year_start=2005;
*let year_end=2006;
*PRIME FRM;
*results(1, 2, '1', 1, &year_start, &year_end));

/*******************************PARAMETER EXPLAINATION;**************************************************
NOTE: NEGAM:  SET NEGAMID = 1 AND ARM_FRM = 1 AND LIENTYPE = 1 AND MIDID = 1.
 SECOND: SET NEGAMID = 0 AND ARM_FRM = 2 AND LIENTYPE = 2 AND MIDID = 2.
 ARM:    SET NEGAMID = 0 AND ARM_FRM = 1 AND LIENTYPE = 1.
 FRM:    SET NEGAMID = 0 AND ARM_FRM = 2 AND LIENTYPE = 1.

%let midid = 1;											*1 - Alt-A, 		2 - SubPrime, 		3 - Prime;
%let ARM_FRM = 1;										*1 - ARM, 			2 - FRM ;
%let negamID = 0;										*1 - NEGAM, 		0 - ALL OTHERS;
%let lientype = 1;										*1 - FIRST LIENS,	2 - SECOND LIENS;
%let histid = 0;										*HISTORY VS. NO HISTORY MODEL;
%let as_of_period = 231; 								*SIMULATION START PERIOD;

***********************************************************************************************************/
%macro mpt_test;

	%if &act=dat %then
		%do;
			%runtest(1, 2, '1', 1, &year_start, &year_end);
		%end;
	%else %if &act=rpt %then
		%do;
			%results(1, 2, '1', 1, &year_start, &year_end);
		%end;
%mend mpt_test;

*let act=dat;
*let act=rpt;
*mpt_test;

**********************************************************************************************************************;
**********************************************************************************************************************;