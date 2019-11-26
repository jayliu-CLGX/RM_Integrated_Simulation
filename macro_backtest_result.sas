**********************************************************************************************************************;
*** macro backtest_result;
**********************************************************************************************************************;
*libname file "X:\Projects\MultiperiodTesting\file\template";
libname file "/RiskModel3/Projects/MultiperiodTesting/file/template";

**********************************************************************************************************************;
%macro copyfile;
	%global outdirid outdir results;

	*let indirID = Z:\Projects\surveillance_2012\template\multiperiod\&testname\&filename;
	*let outdirid = &folder\&loan_type._&product.\results\&testname\&testdate\Excel_&filename.\&simjob1;
	%let indirID = /RiskModel1/Projects/surveillance_2012/template/multiperiod/&testname/&filename;
	%let outdirid = &folder/&loan_type._&product./results/&testname/&testdate/Excel_&filename./&simjob1.;
	%put &outdirid;

	data _null_;
		x "mkdir -p &outdirid";
		x "cp &indirID/*.* &outdirid";
	run;

	%macro namesn(name, y1, y2);
		%do k=&y1 %to &y2;
			&name&k
		%end;
	%mend namesn;

	%let outdir=&folder/&loan_type._&product./results/&testname/&testdate/Excel_&filename./&simjob1.;
	%let results= &folder/&loan_type._&product./results/&testname/&testdate/sas_&filename./&simjob1.;
	libname results "&folder/&loan_type._&product./results/&testname/&testdate/sas_&filename./&simjob1.";

	data format1;
		set file.backtest1_&filename.;
	run;

	proc transpose data=format1 out=format;
	run;

	data format;
		set format(where=(_name_='period'));
		drop _label_;
		format year 4.;
	run;

	proc sql;
		create table format as select a.year, 'quarter' as quarter, b.* 
		from format(keep=year) a, format(drop=year) b;
	quit;

	data format;
		set format;

		%macro col;
			%do i=118 %to 200;
				COL&i.=COL5;
				COL&i.=&i;
			%end;
		%mend;

	%col;
	run;

	*i=115 %to 180 for forwardtest;
%mend copyfile;

**********************************************************************************************************************;
%MACRO RESULTS_rollrate(folder, LOANTYPE, PRODUCT, minyr, maxyr);

	%let filename=rollrates;

	%copyfile;

	%do year=&minyr %to &maxyr;

		data &filename.&year.;
			set results.&filename._year&year.;
			year=&year;
		run;

		proc transpose data=&filename.&year. out=trans_&filename._year&year.;
		run;

		proc sql;
			create table year&year. as select &year as year, * from trans_&filename._year&year.;
		quit;

	%end;

	data &filename;
		set  %namesn(&filename,&minyr,&maxyr);
	run;

	data trans_&filename;
		set %namesn(year,&minyr,&maxyr);
	run;

	%macro trans(transfrom,transto);

		data &filename._&transfrom.&transto.;
			set trans_&filename(where=(_name_ in ("actual_&transfrom.&transto.","S_&transfrom._&transto")));
		run;

		data &filename._&transfrom.&transto;
			set FORMAT &filename._&transfrom.&transto;
		run;

		proc export data=&filename._&transfrom.&transto
			DBLABEL outfile= "&OUTDIRid./Rollrate_T&transfrom..xlsx" dbms=xlsx replace;
			SHEET="DATA_T&transfrom.&Transto._Raw";
		run;

	%mend trans;

	%trans(C,0);
	%trans(C,3);
	%trans(3,0);
	%trans(3,C);
	%trans(3,3);
	%trans(3,6);
	%trans(6,0);
	%trans(6,C);
	%trans(6,3);
	%trans(6,6);
	%trans(6,9);
	%trans(6,F);
	%trans(9,P);
	%trans(9,C);
	%trans(9,3);
	%trans(9,6);
	%trans(9,F);
	%trans(9,9);
	%trans(9,R);
	%trans(9,L);
	%trans(F,P);
	%trans(F,C);
	%trans(F,3);
	%trans(F,6);
	%trans(F,9);
	%trans(F,R);
	%trans(F,F);
	%trans(F,L);
	%trans(R,0);

	*This is for consolidating the rollrate report pivot table;
	data d1;
		set rollrates(keep=year runid period 
			actual_cc actual_c3 actual_C0 
			actual_3c actual_33 actual_36 actual_30
			actual_6c actual_63 actual_66 actual_69 actual_6f actual_60
			actual_9c actual_93 actual_96 actual_99 actual_9f actual_9r actual_9l actual_9p
			actual_fc actual_f3 actual_f6 actual_f9 actual_ff actual_fr actual_fl actual_fp
			actual_rr actual_r0 
			)
		;
		group='actuals';
		rename 
			actual_cc=TCC actual_c3=TC3 actual_C0=TC0
			actual_3c=T3C actual_33=T33 actual_36=T36 actual_30=T30
			actual_6c=T6C actual_63=T63 actual_66=T66 actual_69=T69 actual_6f=T6F actual_60=T60
			actual_9c=T9C actual_93=T93 actual_96=T96 actual_99=T99 actual_9f=T9F actual_9r=T9R actual_9l=T9L actual_9p=T9P
			actual_fc=TFC actual_f3=TF3 actual_f6=TF6 actual_f9=TF9 actual_ff=TFF actual_fr=TFR actual_fl=TFL actual_fp=TFP
			actual_rr=TRR actual_r0=TR0
		;
	run;

	data d2;
		set rollrates(keep=year runid period 
			S_C_C S_C_3 S_C_0
			S_3_C S_3_3 S_3_6 S_3_0
			S_6_C S_6_3 S_6_6 S_6_9 S_6_F S_6_0
			S_9_C S_9_3 S_9_6 S_9_9 S_9_F S_9_R S_9_L S_9_P
			S_F_C S_F_3 S_F_6 S_F_9 S_F_F S_F_R S_F_L S_F_P
			S_REO_REO S_R_0 
			)
		;
		group='predicted';
		rename 
			S_C_C=TCC S_C_3=TC3 S_C_0=TC0
			S_3_C=T3C S_3_3=T33 S_3_6=T36 S_3_0=T30
			S_6_C=T6C S_6_3=T63 S_6_6=T66 S_6_9=T69 S_6_F=T6F S_6_0=T60
			S_9_C=T9C S_9_3=T93 S_9_6=T96 S_9_9=T99 S_9_F=T9F S_9_R=T9R S_9_L=T9L S_9_P=T9P
			S_F_C=TFC S_F_3=TF3 S_F_6=TF6 S_F_9=TF9 S_F_F=TFF S_F_R=TFR S_F_L=TFL S_F_P=TFP
			S_REO_REO=TRR S_R_0=TR0
		;
	run;

	data d0;
		set rollrates(keep=year runid period n_C_observed n_3_observed n_6_observed n_9_observed n_F_observed n_R_observed );
	run;

	data d3
		(rename=runid=Quarter)
	;
		format group $12.;
		set d1 d2;
	run;

	proc sort data=d3;
		by year quarter period;
	run;

	data d3;
		merge d3 d0(rename=runid=Quarter);
		by year quarter period;
	run;

	proc sort data=d3;
		by group year quarter period;
	run;

	Proc export data=d3 outfile="&OUTDIRid./Rollrates.xlsx" DBLABEL dbms=xlsx replace;
		SHEET="data_raw";
	run;

%mend RESULTS_rollrate;

**********************************************************************************************************************;
%MACRO RESULTS_cprcdr(folder, LOAN_TYPE, PRODUCT, minyr, maxyr);
	%let filename=CPRCDR;

	%copyfile;

	%do year=&minyr %to &maxyr;

		data &filename.&year.;
			set results.&filename._year&year.;
			year=&year;
		run;

		proc transpose data=&filename.&year. out=trans_&filename._year&year.;
		run;

		proc sql;
			create table year&year. as select &year as year, * from trans_&filename._year&year.;
		quit;

		data last&year.;
			set &filename.&year.;
			by runid period;
			if last.runid;
		run;

	%end;

	data &filename;
		set %namesn(&filename,&minyr,&maxyr);
	run;

	data trans_&filename;
		set %namesn(year,&minyr,&maxyr);
	run;

	data alllast;
		set %namesn(last,&minyr,&maxyr);
	run;

	%macro trans(metric);

		data &filename._&metric.;
			set trans_&filename(where=(_name_ in ("&metric._act","&metric._pred")));
		run;

		data &filename._&metric.;
			set FORMAT &filename._&metric.;
		run;

		proc export data=&filename._&metric.
			DBLABEL outfile= "&OUTDIRid./cprcdr.xlsx" dbms=xlsx replace;
			SHEET="DATA_&metric._Raw";
		run;

		quit;

	%mend trans;

	**********************************************************************************************************************;
	%trans(CPR);
	%trans(CDR);
	%trans(cumdflt_rate);
	%trans(cumPrepay_rate);

	data last;
		format year 4.;
		set alllast;
		keep year cumPrepay_rate_act cumPrepay_rate_pred cumdflt_rate_act cumdflt_rate_pred;
	run;

	proc export data=last
		DBLABEL outfile= "&outdirid./cprcdr.xlsx" dbms=xlsx replace;
		SHEET="summary_raw";
	run;

	quit;

	%macro transX(metric);

		data &filename._&metric.;
			set trans_&filename(where=(_name_ in ("&metric._rate_act","&metric._rate_pred")));
		run;

		data &filename._&metric.;
			set FORMAT &filename._&metric.;
		run;

		proc export data=&filename._&metric.
			DBLABEL outfile= "&OUTDIRid./statereport.xlsx" dbms=XLSX replace;
			SHEET="DATA_&metric._Raw";
		run;

		quit;

	%mend transX;

	%transX(TC);
	%transX(T3);
	%transX(T6);
	%transX(T9);
	%transX(TFC);
	%transX(TREO);
	%transX(T6p);

%mend RESULTS_cprcdr;

**********************************************************************************************************************;
**********************************************************************************************************************;