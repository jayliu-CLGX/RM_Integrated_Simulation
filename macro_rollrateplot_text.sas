**********************************************************************************************************************;
%macro setrollrate_backtest2;

%do J=1 %to &numsimjob.;

%macro names(name,maxname);	%do k=1 %to &maxname;	&name&k 	%end;	%mend names;
	%getfile_rollrate(&&RM_DIR&J..,&file,roll);				*GET ROLLARATE.CSV FILES FROM RM SIMULATION RESULTS;

data &file._&&simjob&J.;
	/*set roll(drop=runid rename=(s_c_c=&&simjob&J.._CC s_c_3=&&simjob&J.._C3 s_c_p0=&&simjob&J.._c0 s_3_c=&&simjob&J.._3c s_3_6=&&simjob&J.._36 s_3_3=&&simjob&J.._33 s_3_p0=&&simjob&J.._30));*/
	set roll(drop=segment segname );run;

proc sort data=&syslast;by runid period;run;

%macro names(name,minname,maxname);	%do k=&minname %to &maxname;	&name&k 	%end;	%mend names;

data rollrate.rollrates_&file;set %names(rollrate.rollrates_&file,1,&maxpid);run;

data rollrate_&file rollrate.rollrates_&file;set rollrate.rollrates_&file(rename=runid=runid1);
	runid2=substr(left(runid1),9,1);runid=runid2*1;drop runid2 runid1; period=period-&as_of_period;run;

proc sort data=rollrate_&file;by runid period;run;
data roll_&file;	length runid 3.;	merge rollrate_&file(in=a) &file._&&simjob&J..(in=b);	by runid period; if a and b;year=&a;run;

proc sql ;
create table result1.rollrates_&file as select 
year,runid,period, 

actual_CC,S_C_C,actual_C3,S_C_3,actual_C0,S_C_P0 as S_C_0,          
  
actual_3C,S_3_C,actual_33,S_3_3,actual_36,S_3_6,actual_30,S_3_P0 as S_3_0, 

actual_6C,S_6_C,actual_63,S_6_3,actual_66,S_6_6,actual_69,S_6_9,actual_6F,S_6_FC as S_6_F,actual_60,S_6_P0 as S_6_0, 

actual_9C,S_9_C,actual_93,S_9_3,actual_96,S_9_6,actual_99,S_9_9,actual_9F,S_9_FC as S_9_F,actual_9R,S_9_REO as S_9_R ,actual_9L,S_9_F0 as S_9_L,
	actual_9P,S_9_P0 as S_9_P,

actual_FC,S_FC_C as S_F_C,actual_F3,S_FC_3 as S_F_3,actual_F6,S_FC_6 as S_F_6,actual_F9,S_FC_9 as S_F_9,actual_FF,S_FC_FC as S_F_F
	,actual_FR,S_FC_REO as S_F_R,actual_FL,S_FC_F0 as S_F_L,actual_FP,S_FC_P0 as S_F_P,

actual_RR,S_REO_REO,actual_R0,S_REO_R0 as S_R_0,

n_C_observed,n_3_observed,n_6_observed,n_9_observed,n_F_observed,n_R_observed  

from roll_&file
	order by year,runid,period;
quit;

%end;

%mend;
**********************************************************************************************************************;

%macro setperiod_backtest2;

%do J=1 %to &numsimjob.;
%macro names(name,maxname);	%do k=1 %to &maxname;	&name&k 	%end;	%mend names;

	%getfile_period(&&rm_dir&j..,&file,trans);

	data &file._&&simjob&J.;	set trans;	run;

data &syslast;	length runid 3.;set  &syslast(rename=runid=runid1);runid=runid1*1;drop runid1;run;
	proc sort data=&syslast;by runid period;run;

%macro names(name,minname,maxname);	%do k=&minname %to &maxname;	&name&k 	%end;	%mend names;


data cprcdr.cprcdr_&file;set %names(cprcdr.cprcdr_&file,1,&maxpid);run;
data cprcdr_&file; 	set cprcdr.cprcdr_&file(rename=runid=runid1); ;
	runid2=substr(left(runid1),9,1);runid=runid2*1;drop runid2 runid1; period=period-&as_of_period;run;
proc sort data=cprcdr_&file;by runid period;run;
proc contents data=cprcdr_&file;run;
proc contents data=&file._&&simjob&J..;run;

data cprcdr1_&file;	length runid 3.;merge cprcdr_&file(in=a) &file._&&simjob&J..(in=b);	by runid period; if a and b;year=&a;run;


proc sql ;
create table result2.cprcdr_&file as select 
year,runid,period, 

cpr_observed as CPR_act,CPR as CPR_pred,
cdr_observed as CDR_act,CDR as CDR_pred,

cumdflt_observed_active as cumdflt_rate_act, dflt*100 as cumdflt_rate_pred,  
cumPrepay_observed_active as cumPrepay_rate_act, prepay*100 as cumPrepay_rate_pred,

numloan as numloan_act from cprcdr1_&file	order by year,runid,period;
quit;

%end;

%mend;

**********************************************************************************************************************;
%macro settrans_backtest2;

%do J=1 %to &numsimjob.;
%macro names(name,maxname);	%do k=1 %to &maxname;	&name&k 	%end;	%mend names;

	%getfile_trans(&&rm_dir&j..,&file,trans);

	data &file._&&simjob&J.;	set trans;	run;

data &syslast;	length runid 3.;set  &syslast(rename=runid=runid1);runid=runid1*1;drop runid1;run;
	proc sort data=&syslast;by runid period;run;

	%getfile_balances(&&rm_dir&j..,&file);
	proc sql; select count into :numloan_RM from bal; quit;

%macro names(name,minname,maxname);	%do k=&minname %to &maxname;	&name&k 	%end;	%mend names;

data cprcdr.cprcdr_&file;set %names(cprcdr.cprcdr_&file,1,&maxpid);run;

data cprcdr_&file; 	set cprcdr.cprcdr_&file(rename=runid=runid1); ;
	runid2=substr(left(runid1),9,1);runid=runid2*1;drop runid2 runid1; period=period-&as_of_period;run;

proc sort data=cprcdr_&file;by runid period;run;
proc contents data=cprcdr_&file;run;
proc contents data=&file._&&simjob&J..;run;
data cprcdr1_&file;	length runid 3.;merge cprcdr_&file(in=a) &file._&&simjob&J..(in=b);	by runid period; if a and b;year=&a;run;

proc sql ;
create table result2.cprcdr_&file as select 
year,runid,period, 
TC as TC_act,SCUR as TC_pred, 
T3 as T3_act,S30 as T3_pred,  
T6 as T6_act,S60 as T6_pred, 
T_60P as T6p_act, (S60+S90+SFC+SREO) as T6p_pred,
T9 as T9_act,S90 as T9_pred,  
TF as TF_act,SFC as TF_pred,  
TR as TR_act,SREO as TR_pred, 
TF0 as TF0_act,SF0 as TF0_pred, CUMFCF0 as TF0_pred2,
TR0 as TR0_act,SR0 as TR0_pred, CUMREOR0 as TR0_pred2,

prepay as cumpayoff_act,CUMPAYOFF as cumpayoff_pred,SPAY as cumpayoff_pred2,

DEFAULT as cumdflt_act,CUMDFLT as cumdflt_pred,

cpr_observed as CPR_act,CPR as CPR_pred,
cdr_observed as CDR_act,CDR as CDR_pred,

TC_observed_active as TC_rate_act, (SCUR/&numloan_RM)*100 as TC_rate_pred,
T30_observed_active as T3_rate_act, (S30/&numloan_RM)*100 as T3_rate_pred,
T60_observed_active as T6_rate_act, (S60/&numloan_RM)*100 as T6_rate_pred,
T60p_observed_active as T6p_rate_act, ((S60+S90+SFC+SREO)/&numloan_RM)*100 as T6p_rate_pred,
T90_observed_active as T9_rate_act, (S90/&numloan_RM)*100 as T9_rate_pred,
TFC_observed_active as TFC_rate_act, (SFC/&numloan_RM)*100 as TFC_rate_pred,
TREO_observed_active as TREO_rate_act, (SREO/&numloan_RM)*100 as TREO_rate_pred,

cumdflt_observed_active as cumdflt_rate_act, (CUMDFLT/&numloan_RM)*100 as cumdflt_rate_pred,  
cumPrepay_observed_active as cumPrepay_rate_act, (CUMPAYOFF/&numloan_RM)*100 as cumPrepay_rate_pred,

TCpay as CUMCURPAY_act,CUMCURPAY as CUMCURPAY_pred,
T3pay as CUM30PAY_act,CUM30PAY as CUM30PAY_pred,
T6pay as CUM60PAY_act,CUM60PAY as CUM60PAY_pred,
T9pay as CUM90PAY_act,CUM90PAY as CUM90PAY_pred,
TFpay as CUMFCPAY_act,CUMFCPAY as CUMFCPAY_pred,

numloan as numloan_act, &numloan_RM as numloan_pred

/*CUMLOSS,PLOSSOBAL,PLOSSUPBD,SERDEL,CPRTOT,SEGMENT,SEGNAME,PCTL*/     

from cprcdr1_&file
	order by year,runid,period;
quit;

%end;

%mend;
**********************************************************************************************************************;

/*%let maxperiod=%eval(&dataperiod+1);
symbol1 c=black   w=2  v=none    i=join l=1  r=1;
Symbol2 c=red	 w=2  v=none  	i=join l=2  r=1;    
symbol3 c=blue  w=2  v=star    i=join l=2  r=1;
symbol4 c=green  w=2  v=star    i=join l=1  r=1;
symbol5 c=purple w=2  v=star    i=join l=1  r=1;

legend1 position=(bottom center outside) ;
axis1 value=(angle = 45) order = (1 to &MAXPERIOD by 1);
*/

**********************************************************************************************************************;
%macro setrollrate_backtest;

%do J=1 %to &numsimjob.;

	%getfile_rollrate(&&RM_DIR&J..,&file,roll);				*GET ROLLARATE.CSV FILES FROM RM SIMULATION RESULTS;

	data &file._&&simjob&J.;
	/*set roll(drop=runid rename=(s_c_c=&&simjob&J.._CC s_c_3=&&simjob&J.._C3 s_c_p0=&&simjob&J.._c0 s_3_c=&&simjob&J.._3c s_3_6=&&simjob&J.._36 s_3_3=&&simjob&J.._33 s_3_p0=&&simjob&J.._30));*/
	set roll(drop=runid segment segname); 	
	runid="&file"; 
	run;

	data rollRATE_&file; 
		set rollrate.rollRATEs_&file(drop=runid); 
		runid="&file";
		period=period-&as_of_period;
	run;

	data rollRATE_&file;	
		merge rollrate_&file(in=a) &file._&&simjob&J..(in=b);	
		by runid period;
		if a and b; 
		year=&a;
	run;

	/*
	proc sql ;
	create table results.rollrates_&file as
	select year,runid,period, actual_xx, s_x_X,........ n_x_observed,....
	from rollrates_&file
	order by year,runid,period;
	quit;
	*/

	proc sql ;
	create table result1.rollrates_&file as select 
	year,runid,period, 
	actual_CC,S_C_C,actual_C3,S_C_3,actual_C0,S_C_P0 as S_C_0,
	actual_3C,S_3_C,actual_33,S_3_3,actual_36,S_3_6,actual_30,S_3_P0 as S_3_0, 
	actual_6C,S_6_C,actual_63,S_6_3,actual_66,S_6_6,actual_69,S_6_9,actual_6F,
	S_6_FC as S_6_F,actual_60,S_6_P0 as S_6_0, 
	actual_9C,S_9_C,actual_93,S_9_3,actual_96,S_9_6,actual_99,S_9_9,actual_9F,
	S_9_FC as S_9_F,actual_9R,S_9_REO as S_9_R ,actual_9L,S_9_F0 as S_9_L,
	actual_9P,S_9_P0 as S_9_P,actual_FC,S_FC_C as S_F_C,actual_F3,S_FC_3 as S_F_3,
	actual_F6,S_FC_6 as S_F_6,actual_F9,S_FC_9 as S_F_9,actual_FF,S_FC_FC as S_F_F,
	actual_FR,S_FC_REO as S_F_R,actual_FL,S_FC_F0 as S_F_L,actual_FP,S_FC_P0 as S_F_P,
	actual_RR,S_REO_REO,actual_R0,S_REO_R0 as S_R_0,
	n_C_observed,n_3_observed,n_6_observed,n_9_observed,n_F_observed,n_R_observed  
	from rollrate_&file
	order by year,runid,period;
	quit;

%end;

%mend;

**********************************************************************************************************************;

%macro settrans_backtest;

%do J=1 %to &numsimjob.;

	%getfile_trans(&&rm_dir&j..,&file,trans);

	data &file._&&simjob&J.;
	set trans(drop=runid); runid="&file"; 
	run;

	data cprcdr_&file; 
	set cprcdr.cprcdr_&file(drop=runid); runid="&file";
	period=period-&as_of_period;
	run;

	data cprcdr_&file;	
	merge cprcdr_&file(in=a) &file._&&simjob&J..(in=b);	
	by runid period;
	if a and b; 
	year=&a;
	run;

	%getfile_balances(&&rm_dir&j..,&file);

	proc sql; 
	select count into :numloan_RM from bal; 
	quit;

	proc sql ;
	create table result2.cprcdr_&file as select 
	year,runid,period, 
	TC as TC_act,SCUR as TC_pred, 
	T3 as T3_act,S30 as T3_pred,  
	T6 as T6_act,S60 as T6_pred, 
	T_60P as T6p_act, (S60+S90+SFC+SREO) as T6p_pred,
	T9 as T9_act,S90 as T9_pred,  
	TF as TF_act,SFC as TF_pred,  
	TR as TR_act,SREO as TR_pred, 
	TF0 as TF0_act,SF0 as TF0_pred, 
	CUMFCF0 as TF0_pred2,
	TR0 as TR0_act,SR0 as TR0_pred, 
	CUMREOR0 as TR0_pred2,
	prepay as cumpayoff_act,
	CUMPAYOFF as cumpayoff_pred,
	SPAY as cumpayoff_pred2,
	DEFAULT as cumdflt_act,
	CUMDFLT as cumdflt_pred,
	cpr_observed as CPR_act,
	CPR as CPR_pred,
	cdr_observed as CDR_act,
	CDR as CDR_pred,
	TC_observed_active as TC_rate_act, 
	(SCUR/&numloan_RM)*100 as TC_rate_pred,
	T30_observed_active as T3_rate_act, 
	(S30/&numloan_RM)*100 as T3_rate_pred,
	T60_observed_active as T6_rate_act, 
	(S60/&numloan_RM)*100 as T6_rate_pred,
	T60p_observed_active as T6p_rate_act, 
	((S60+S90+SFC+SREO)/&numloan_RM)*100 as T6p_rate_pred,
	T90_observed_active as T9_rate_act, 
	(S90/&numloan_RM)*100 as T9_rate_pred,
	TFC_observed_active as TFC_rate_act, 
	(SFC/&numloan_RM)*100 as TFC_rate_pred,
	TREO_observed_active as TREO_rate_act, 
	(SREO/&numloan_RM)*100 as TREO_rate_pred,
	cumdflt_observed_active as cumdflt_rate_act, 
	(CUMDFLT/&numloan_RM)*100 as cumdflt_rate_pred,  
	cumPrepay_observed_active as cumPrepay_rate_act, 
	(CUMPAYOFF/&numloan_RM)*100 as cumPrepay_rate_pred,
	/*cumloss_observed_active as cumloss_rate_act, */
	PLOSSOBAL*100 as cumloss_rate_pred,	
	TCpay as CUMCURPAY_act,
	CUMCURPAY as CUMCURPAY_pred,
	T3pay as CUM30PAY_act,
	CUM30PAY as CUM30PAY_pred,
	T6pay as CUM60PAY_act,
	CUM60PAY as CUM60PAY_pred,
	T9pay as CUM90PAY_act,
	CUM90PAY as CUM90PAY_pred,
	TFpay as CUMFCPAY_act,
	CUMFCPAY as CUMFCPAY_pred,
	numloan as numloan_act, 
	&numloan_RM as numloan_pred
	/*CUMLOSS,PLOSSOBAL,PLOSSUPBD,SERDEL,CPRTOT,SEGMENT,SEGNAME,PCTL*/     
	from cprcdr_&file
	order by year,runid,period;
	quit;

%end;

%mend;
**********************************************************************************************************************;

%macro setrollrate_backtest1;

%do J=1 %to &numsimjob.;

%macro names(name,maxname);	%do k=1 %to &maxname;	&name&k 	%end;	%mend names;
	%getfile_rollrate(&&RM_DIR&J..,&file,roll);				*GET ROLLARATE.CSV FILES FROM RM SIMULATION RESULTS;

data &file._&&simjob&J.;
	/*set roll(drop=runid rename=(s_c_c=&&simjob&J.._CC s_c_3=&&simjob&J.._C3 s_c_p0=&&simjob&J.._c0 s_3_c=&&simjob&J.._3c s_3_6=&&simjob&J.._36 s_3_3=&&simjob&J.._33 s_3_p0=&&simjob&J.._30));*/
	set roll(drop=segment segname );run;

proc sort data=&syslast;by runid period;run;

%macro names(name,minname,maxname);	%do k=&minname %to &maxname;	&name&k 	%end;	%mend names;

data rollrate.rollrates1_&file;set %names(rollrate.rollrates_&file,1,9);run;

data rollrate.rollrates1_&file;set rollrate.rollrates1_&file(rename=runid=runid1);
	runid2=substr(left(runid1),9,1);runid=runid2*1;drop runid2 runid1;run;

data rollrate.rollrates2_&file;set %names(rollrate.rollrates_&file,10,12);run;

data rollrate.rollrates2_&file;set  rollrate.rollrates2_&file(rename=runid=runid1);
	runid2=substr(left(runid1),9,2);runid=runid2*1;drop runid2 runid1;run;

data rollrate.rollrates_&file;set rollrate.rollrates1_&file rollrate.rollrates2_&file;run;

data rollRATE_&file; set rollrate.rollRATEs2_&file rollrate.rollRATEs1_&file; period=period-&as_of_period;run;

proc sort data=rollrate_&file;by runid period;run;
data roll_&file;	length runid 3.;	merge rollrate_&file(in=a) &file._&&simjob&J..(in=b);	by runid period; if a and b;year=&a;run;

proc sql ;
create table result1.rollrates_&file as select 
year,runid,period, 

actual_CC,S_C_C,actual_C3,S_C_3,actual_C0,S_C_P0 as S_C_0,          
  
actual_3C,S_3_C,actual_33,S_3_3,actual_36,S_3_6,actual_30,S_3_P0 as S_3_0, 

actual_6C,S_6_C,actual_63,S_6_3,actual_66,S_6_6,actual_69,S_6_9,actual_6F,S_6_FC as S_6_F,actual_60,S_6_P0 as S_6_0, 

actual_9C,S_9_C,actual_93,S_9_3,actual_96,S_9_6,actual_99,S_9_9,actual_9F,S_9_FC as S_9_F,actual_9R,S_9_REO as S_9_R ,actual_9L,S_9_F0 as S_9_L,
	actual_9P,S_9_P0 as S_9_P,

actual_FC,S_FC_C as S_F_C,actual_F3,S_FC_3 as S_F_3,actual_F6,S_FC_6 as S_F_6,actual_F9,S_FC_9 as S_F_9,actual_FF,S_FC_FC as S_F_F
	,actual_FR,S_FC_REO as S_F_R,actual_FL,S_FC_F0 as S_F_L,actual_FP,S_FC_P0 as S_F_P,

actual_RR,S_REO_REO,actual_R0,S_REO_R0 as S_R_0,

n_C_observed,n_3_observed,n_6_observed,n_9_observed,n_F_observed,n_R_observed  

from roll_&file
	order by year,runid,period;
quit;

%end;

%mend;
**********************************************************************************************************************;

%macro settrans_backtest1;

%do J=1 %to &numsimjob.;
%macro names(name,maxname);	%do k=1 %to &maxname;	&name&k 	%end;	%mend names;

	%getfile_trans(&&rm_dir&j..,&file,trans);

	data &file._&&simjob&J.;	set trans;	run;

data &syslast;	length runid 3.;set  &syslast(rename=runid=runid1);runid=runid1*1;drop runid1;run;
	proc sort data=&syslast;by runid period;run;

	%getfile_balances(&&rm_dir&j..,&file);
	proc sql; select count into :numloan_RM from bal; quit;

%macro names(name,minname,maxname);	%do k=&minname %to &maxname;	&name&k 	%end;	%mend names;

data cprcdr.cprcdr1_&file;set %names(cprcdr.cprcdr_&file,1,9);run;
data cprcdr.cprcdr2_&file;set %names(cprcdr.cprcdr_&file,10,12);run;

/*data cprcdr.cprcdr1_&file;set  cprcdr.cprcdr1_&file(rename=runid=runid1);
	runid2=substr(left(runid1),9,1);runid=runid2*1;drop runid2 runid1;run;
data cprcdr.cprcdr2_&file;set  cprcdr.cprcdr2_&file(rename=runid=runid1);
	runid2=substr(left(runid1),9,2);runid=runid2*1;drop runid2 runid1;run;*/

data cprcdr_&file; 	length runid 3.;set cprcdr.cprcdr1_&file cprcdr.cprcdr2_&file ;period=period-&as_of_period;run;
proc sort data=cprcdr_&file;by runid period;run;

data cprcdr1_&file;	length runid 3.;merge cprcdr_&file(in=a) &file._&&simjob&J..(in=b);	by runid period; if a and b;year=&a;run;

proc sql ;
create table result2.cprcdr_&file as select 
year,runid,period, 
TC as TC_act,SCUR as TC_pred, 
T3 as T3_act,S30 as T3_pred,  
T6 as T6_act,S60 as T6_pred, 
T_60P as T6p_act, (S60+S90+SFC+SREO) as T6p_pred,
T9 as T9_act,S90 as T9_pred,  
TF as TF_act,SFC as TF_pred,  
TR as TR_act,SREO as TR_pred, 
TF0 as TF0_act,SF0 as TF0_pred, CUMFCF0 as TF0_pred2,
TR0 as TR0_act,SR0 as TR0_pred, CUMREOR0 as TR0_pred2,

prepay as cumpayoff_act,CUMPAYOFF as cumpayoff_pred,SPAY as cumpayoff_pred2,

DEFAULT as cumdflt_act,CUMDFLT as cumdflt_pred,

cpr_observed as CPR_act,CPR as CPR_pred,
cdr_observed as CDR_act,CDR as CDR_pred,

TC_observed_active as TC_rate_act, (SCUR/&numloan_RM)*100 as TC_rate_pred,
T30_observed_active as T3_rate_act, (S30/&numloan_RM)*100 as T3_rate_pred,
T60_observed_active as T6_rate_act, (S60/&numloan_RM)*100 as T6_rate_pred,
T60p_observed_active as T6p_rate_act, ((S60+S90+SFC+SREO)/&numloan_RM)*100 as T6p_rate_pred,
T90_observed_active as T9_rate_act, (S90/&numloan_RM)*100 as T9_rate_pred,
TFC_observed_active as TFC_rate_act, (SFC/&numloan_RM)*100 as TFC_rate_pred,
TREO_observed_active as TREO_rate_act, (SREO/&numloan_RM)*100 as TREO_rate_pred,

cumdflt_observed_active as cumdflt_rate_act, (CUMDFLT/&numloan_RM)*100 as cumdflt_rate_pred,  
cumPrepay_observed_active as cumPrepay_rate_act, (CUMPAYOFF/&numloan_RM)*100 as cumPrepay_rate_pred,

TCpay as CUMCURPAY_act,CUMCURPAY as CUMCURPAY_pred,
T3pay as CUM30PAY_act,CUM30PAY as CUM30PAY_pred,
T6pay as CUM60PAY_act,CUM60PAY as CUM60PAY_pred,
T9pay as CUM90PAY_act,CUM90PAY as CUM90PAY_pred,
TFpay as CUMFCPAY_act,CUMFCPAY as CUMFCPAY_pred,

numloan as numloan_act, &numloan_RM as numloan_pred

/*CUMLOSS,PLOSSOBAL,PLOSSUPBD,SERDEL,CPRTOT,SEGMENT,SEGNAME,PCTL*/     

from cprcdr1_&file
	order by year,runid,period;
quit;

%end;

%mend;
**********************************************************************************************************************;

%macro settrans(name);

%do J=1 %to &numsimjob.;

	%getfile_trans(&&rm_dir&j..,&file,&file2)

	data &NAME.&j. ;
	set &file2;
	run;

	data &syslast;
	set &syslast(keep=runid  period cpr cumdflt cumloss cdr cumpayoff scur s30 s60 s90 sf0 sfc spay sr0 SREO rename=
		(scur=scur_&&simjob&j. s30=s30_&&simjob&j. s60=s60_&&simjob&j. s90=s90_&&simjob&j. sf0=sf0_&&simjob&j. sfc=sfc_&&simjob&j. sr0=sr0_&&simjob&j. 
		sreo=sreo_&&simjob&j. spay=spay_&&simjob&j. cpr=cpr_&&simjob&j.  cumdflt=cumdflt_&&simjob&j. cumloss=cumloss_&&simjob&j. cdr=cdr_&&simjob&j.
		cumpayoff =cumpayoff_&&simjob&j.) where=(period<=&dataperiod. ));
		run;

	data &name.&j.;************to get o_year;
	merge outd.lookupagg(in=a) &name.&j.(in=b);
	by runid;
	run;

%if &j=1 %then %do;
data &name;set &name.1;run; *set up initial agg file;
%end;

data &name; **********recursively merge the agg file from different simulation jobs;
	merge &name(in=a) &name.&j.(in=b);
	by runid period;
	if a and b;
run;

proc sort data=&name nodupkey; by runid period;run;

%end;

%mend;


************************************************************************************************************************************************;
%macro mergedata3(var1,min,max,name,maxjob,dir);
%do year=&min %to &max;
	%macro varlist(max,var);
		%do i=1 %to &max;
		&var._&&simjob&i
		%end;
	%mend;

data orig&year. ; 
	
merge actual_perf(in=a rename=(cumdflt_observed_active=observed_cumdflt T60p_observed_active=observed_60p
					T30_observed_active=observed_30 TC_observed_active=observed_C 
					cpr_observed=observed_CPR CDr_observed=observed_CDR) 
					keep=&var1. period numloan cdr_observed cpr_observed TC_observed_active T30_observed_active T60p_observed_active cumdflt_observed_active)
		&name.(in=b) ; 
	by &var1. period;
	if a and b ;
	if &var1.=&year.;
	where period<=&dataperiod.;
%do i=1 %to &maxjob;
	rename cpr_&&simjob&i.		=	pred_cpr_&&simjob&i..;
	rename cdr_&&simjob&i.		=	pred_cdr_&&simjob&i..;
	pred_cumdflt_&&simjob&i..	=	cumdflt_&&simjob&i.. /numloan*100;
	Pred_60p_&&simjob&i..		=	(s60_&&simjob&i.. +s90_&&simjob&i..+sfc_&&simjob&i..+sreo_&&simjob&i..)/numloan*100;
	Pred_30_&&simjob&i..		=	(s30_&&simjob&i../numloan) *100;
	Pred_C_&&simjob&i..			=	(scur_&&simjob&i../numloan) *100;
%end;
	drop %varlist(&maxjob,cumdflt);
	drop %varlist(&maxjob,s30);
	drop %varlist(&maxjob,s60);
	drop %varlist(&maxjob,s90);
	drop %varlist(&maxjob,sfc);
	drop %varlist(&maxjob,sreo);
	drop %varlist(&maxjob,scur);
	drop %varlist(&maxjob,sf0);
	drop %varlist(&maxjob,sr0);
	drop %varlist(&maxjob,spay);
	drop %varlist(&maxjob,cumloss);
	drop %varlist(&maxjob,cumpayoff);
run;
%end;

	%macro names(name,minname,maxname);
	%do k=&minname %to &maxname;
	&name&k
	%end;
	%mend names;

data outd.&LOAN_TYPE._&PRODUCT._trans;
set %names(orig,&min,&max);
run;

	proc export data=outd.&LOAN_TYPE._&PRODUCT._trans 
		outfile="&dir/&LOAN_TYPE._&PRODUCT._Trans.csv" replace;
	run;

%mend;
************************************************************************************************************************************************;

%macro plot_backtest(min,max);
options orientation=landscape;
ods pdf file= "&outdir./&loan_type. &product. Predicted vs. Observed.pdf";
options orientation=landscape;
ods listing close;
ods printer close;

%macro graph(minyear,maxyear,trans);

	%DO I=1 %TO &NUMSIMJOB.;
		%IF &I=1 %THEN %DO;
			%LET JOB=Pred_&trans._&simjob1.;
		%END;%ELSE %DO;
			%LET JOB=%STR(&JOB. Pred_&trans._&&SIMJOB&I.);
		%END;
	%END;

	%do year=&minyear. %to &maxyear. %by 1;
		proc gplot data=orig&YEAR.;
			plot  (&job observed_&trans.)* period  / overlay legend = legend1 ;

		%if &lientype=2 %then %do;
			title "&product. Dialed vs. Observed &trans. __&year. Vintage";
		%end;%else %do;
			title "&LOAN_TYPE. &Product Dialed vs. Observed &trans. __&year. Vintage";
		%end;
		format period segf.;
		run;
	%end;
%mend;

%graph(&min,&max,C);

%graph(&min,&max,30);

%graph(&min,&max,60p);

%graph(&min,&max,cumdflt);

%graph(&min,&max,CPR);

%graph(&min,&max,CDR);

ods pdf close;
ods listing;
data _null_;
set _null_;
%mend;
************************************************************************************************************************************************;


%macro setrollrate;

%do J=1 %to &numsimjob.;
	%getfile_rollrate(&&RM_DIR&J..,&file,&FILE1);				*GET ROLLARATE.CSV FILES FROM RM SIMULATION RESULTS;

data roll_&&simjob&J. (keep=&&simjob&J.._CC &&simjob&J.._C3 &&simjob&J.._c0 &&simjob&J.._3C &&simjob&J.._33 
						&&simjob&J.._36 &&simjob&J.._30 period runid);
	set roll(where=(period<=&dataperiod)
			rename=(s_c_c=&&simjob&J.._CC s_c_3=&&simjob&J.._C3 s_c_p0=&&simjob&J.._c0 
					s_3_c=&&simjob&J.._3c s_3_6=&&simjob&J.._36 s_3_3=&&simjob&J.._33 s_3_p0=&&simjob&J.._30));
run;

%if &J=1 %then %do;
data rollRATE;set roLL_&simjob1;run; *set up initial agg file;
%end;

data rollRATE;
	merge rollRATE(in=a) roll_&&simjob&J..(in=b);
	by runid period;
*	if a and b;
run;

proc sort data=rollRATE nodupkey; by runid period;run;

%end;

DATA ROLL;SET ROLLRATE;RUN;
%mend;

************************************************************************************************************************************************;
%macro rollrateplot_TC(groupby,plotby,dir);

proc sort data=roll; by runid;run;
data roll;
	merge outd.lookupagg(in=a keep=runid o_year) roll(in=b);
	by runid;
	if a and b;
run;

proc sort data=roll;by o_year period;run;

data tmp1;
set performance;
by loan_id period;
if period>1 and first.loan_id then lagstat=.;
run;

data tmp1;
set performance(where=( mba_stat in('C','3','0') and lagstat= 'C'));
by loan_id period;
tc0=mba_stat='0';
tC3=mba_stat='3';
tCC=mba_stat='C';
run;

proc sort data=tmp1 nodupkey;by loan_id  period;run;

proc sql;
create table act_rollC as
select count(*) as numloans, mean(tc0) as actual_c0,
mean(tC3) as actual_C3,
mean(tCC) as actual_CC,
runid,&groupby,period
from tmp1
group by runid,period,&groupby.;
quit;
run;

data tmp3;
set performance;
where mba_stat in('C','3','0','6') and lagstat= '3';
t30=mba_stat='0';
t33=mba_stat='3';
t3c=mba_stat='C';
t36=mba_stat='6';
run;
proc sql;
create table act_roll3 as
select count(*) as numloans_3,
mean(t30) as actual_30,
mean(t33) as actual_33,
mean(t3c) as actual_3c,
mean(t36) as actual_36,
runid,&groupby.,period
from tmp3
group by runid,period,&groupby.;
quit;
run;

data act_roll;
merge act_rollC(in=a) act_roll3(in=b);
by runid period;
*if a and b;
run;

data act_roll;merge act_roll(in=a) outd.lookupagg(in=b);by runid;if a and b;run;

proc sort data=act_roll;by &groupby period;run;

proc sort data=roll;by &groupby period;run;

data rollrates;
merge act_roll(in=a) roll(in=b);
	 	 by &groupby period;
	if a and b;
			if substr(left(REVERSE(dialid)),1,7)="CODLLUF" then type="Current_no Prev DQ_Owner_Fulldoc";else
			if substr(left(REVERSE(dialid)),1,6)="CODWOL"  then type="Current_no Prev DQ_Owner_Lowdoc"; else
			if substr(left(REVERSE(dialid)),1,6)="TSEVNI"  then type="no Prev DQ_Investor";				else
			if substr(left(REVERSE(dialid)),1,6)="QDVERP"  then type="PREVDQ at Simulation Start";		else
			if substr(left(REVERSE(dialid)),1,2)="QD" 	   then type="DQ at Simulation Start";			
type=trim(type);	
run;

data outd.rollrates;set rollrates;run;

proc sort data=outd.rollrates; by &groupby period;run;

proc export data=outd.rollrates
outfile="&dir./&LOAN_TYPE._&PRODUCT._Rollrates.csv" replace;
run;

		
******************************Create graphs comparing observed,  vs. dialed;
options orientation=landscape;
ods pdf file= "&dir./&loan_type._&product._rollrate1.pdf";
options orientation=landscape;
ods listing close;
ods printer close;
%macro plot(max,transition,plotby);

%DO I=1 %TO &NUMSIMJOB.;
	%IF &I=1 %THEN %DO;
%LET JOB=&SIMJOB1._&TRANSITION;
%END;%ELSE %DO;
%LET JOB=%STR(&JOB. &&SIMJOB&I.._&TRANSITION.);
%END;
%END;

%do i=1 %to &max;

%global year;
data _null_;
set outd.rollrates(where=(runid=&i));
call symput ('year',o_year);
%put year=&year.;
run;

%if &lientype=0 %then %do;
	data _null_;
	set outd.rollrates(where=(runid=&i));
	call symput ('segid',trim(type));
	%put product=&product.;
	run;
	title "&Loan_type. &product. &segid.__Trans &transition.";
%end;%else %if &lientype=2 %then %do;
	title "&product. Dialed vs. Observed__&transition. in &year.";
%end;%else %if &allproduct=1 %then %do;
	title "&LOAN_TYPE. Dialed vs. Observed__&transition. in &year.";
%end;%else %do;
	title "&LOAN_TYPE. &product. Dialed vs. Observed__&transition. in &year.";
%end;

proc gplot data=outd.rollrates(where=(runid=&i));
	plot ( &JOB. actual_&transition) * &plotby. / overlay legend=legend1;
	format &plotby. segf.;
run;
%end;
%mend;


%plot(&maxpid,CC,period);
%plot(&maxpid,C3,period);
%plot(&maxpid,C0,period);
%plot(&maxpid,30,period);
%plot(&maxpid,33,period);
%plot(&maxpid,3C,period);
%plot(&maxpid,36,period);
ods pdf close;
ods listing;
data _null_;
set _null_;
run;

%MEND;

************************************************************************************************************************************************;
/******************************************************************;*/
%macro plot_distribution(min,max);


options orientation=landscape;
ods pdf file= "&outdir./&loan_type. &product. Predicted vs. Observed.pdf";
options orientation=landscape;
ods listing close;
ods printer close;
%macro graph(minyear,maxyear,trans);
%do year=&minyear. %to &maxyear. %by 1;
proc gplot data=orig&YEAR.;
	plot  (pred_&trans._&simjob1._&year.  pred_&trans._&simjob2._&year. pred_&trans._&simjob3._&year. observed_&trans._&year.  )* period  / overlay legend = legend1 ;
	
%if &lientype=2 %then %do;
title "&product. Dialed vs. Observed__Mod in &year.";
%end;%else %if &allproduct=1 %then %do;
title "&LOAN_TYPE. Dialed vs. Observed__Mod in &year.";
%end;%else %do;
title "&LOAN_TYPE. &product. Dialed vs. Observed__Mod in &year.";
%end;
	format period segf.;
run;
%end;
%mend;


%graph(&min,&max,60p);

%graph(&min,&max,cumdflt);

%graph(&min,&max,CPR);

%graph(&min,&max,CDR);

%graph(&min,&max,C);

%graph(&min,&max,30);
ods pdf close;
ods listing;
data _null_;
set _null_;
%mend;


%macro plot_backtest1(var1,min,max,dir);
options orientation=landscape;
ods pdf file= "&dir./&loan_type. &product. Predicted vs. Observed.pdf";
options orientation=landscape;
ods listing close;
ods printer close;

%macro graph(minyear,maxyear,trans);
	%DO I=1 %TO &NUMSIMJOB.;
		%IF &I=1 %THEN %DO;
			%LET JOB=Pred_&trans._&simjob1.;
		%END;%ELSE %DO;
			%LET JOB=%STR(&JOB. Pred_&trans._&&SIMJOB&I.);
		%END;
	%END;
%do var1=&minyear. %to &maxyear. %by 1;

data orig&var1;
	set orig&var1;
			if substr(left(REVERSE(dialid)),1,7)="CODLLUF" then type="Current_no Prev DQ_Owner_Fulldoc";else
			if substr(left(REVERSE(dialid)),1,6)="CODWOL"  then type="Current_no Prev DQ_Owner_Lowdoc"; else
			if substr(left(REVERSE(dialid)),1,6)="TSEVNI"  then type="no Prev DQ_Investor";				else
			if substr(left(REVERSE(dialid)),1,6)="QDVERP"  then type="PREVDQ at Simulation Start";		else
			if substr(left(REVERSE(dialid)),1,2)="QD" 	   then type="DQ at Simulation Start";								
type=trim(type);
run;
data orig&var1;
	set orig&var1;
	call symput('segment',trim(type));
	call symput('orig_year',o_year);
	%put segment=&segment;
run;

	proc gplot data=orig&&var1.;
			plot  (&job observed_&trans.)* period  / overlay legend = legend1 ;
			title "&LOAN_TYPE. &Product &segment.__&trans.";
		format period segf.;
		run;
%end;
%mend;

%graph(&min,&max,C);
%graph(&min,&max,30);
%graph(&min,&max,60p);
%graph(&min,&max,cumdflt);
%graph(&min,&max,CPR);
%graph(&min,&max,CDR);

ods pdf close;
ods listing;
data _null_;
set _null_;
%mend;

%macro mergedata2(min,max,name,maxjob,dir);
%do year=&min %to &max;

data orig&year. (drop=tc t3 t6 t9 tf tr);
	
merge actual_perf(in=a rename=(cumdflt_observed_active=observed_cumdflt_&year. T60p_observed_active=observed_60p_&year. 
					T30_observed_active=observed_30_&year. TC_observed_active=observed_C_&year.
					cpr_observed=observed_CPR_&year. CDr_observed=observed_CDR_&year.))
		&name.(in=b) ; 
	by o_year period;
	if a and b ;
	if o_year=&year;
	where period<=&dataperiod.;
%do i=1 %to &maxjob;
	
	Pred_Obs_C_&&simjob&i.._&year. =scur_&&simjob&i../tc;
	Pred_Obs_30_&&simjob&i.._&year.=s30_&&simjob&i../t3;
	Pred_Obs_60_&&simjob&i.._&year.=s60_&&simjob&i../t6;
	Pred_Obs_90_&&simjob&i.._&year.=s90_&&simjob&i../t9;
	Pred_Obs_FC_&&simjob&i.._&year.=sFC_&&simjob&i../tf;

	pred_cpr_&&simjob&i.._&year.=cpr_&&simjob&i.;
	pred_cdr_&&simjob&i.._&year.=cdr_&&simjob&i.;
	pred_cumdflt_&&simjob&i.._&year.	= cumdflt_&&simjob&i.. /numloan*100;
	Pred_60p_&&simjob&i.._&year.=(s60_&&simjob&i.. +s90_&&simjob&i..+sfc_&&simjob&i..+sreo_&&simjob&i..)/numloan*100;
	Pred_30_&&simjob&i.._&year.	=(s30_&&simjob&i../numloan) *100;
	Pred_C_&&simjob&i.._&year.	=(scur_&&simjob&i../numloan) *100;
%end;
run;
%end;

%macro names(name,minname,maxname);
%do k=&minname %to &maxname;
&name&k
%end;
%mend names;

data outd.&LOAN_TYPE._&PRODUCT._trans;
set %names(orig,&min,&max);
run;

proc export data=outd.&LOAN_TYPE._&PRODUCT._trans 
outfile="&dir/&LOAN_TYPE._&PRODUCT._Trans.csv";
run;

%mend;



%macro mergedata1(name,maxjob,dir);

data trans (drop=tc t3 t6 t9 tf tr);
	
merge actual_perf(in=a rename=(cumdflt_observed_active=observed_cumdflt T60p_observed_active=observed_60p
					T30_observed_active=observed_30 TC_observed_active=observed_C 
					cpr_observed=observed_CPR CDr_observed=observed_CDR )
					keep=seg&w o_year numloan period cdr_observed cpr_observed TC_observed_active T30_observed_active T60p_observed_active cumdflt_observed_active)
		&name.(in=b rename= (dialid=seg&w.)) ; 
	by seg&w period;

where period<=&dataperiod.;

%do i=1 %to &maxjob;

	pred_cpr_&&simjob&i..=cpr_&&simjob&i.;
	pred_cdr_&&simjob&i..=cdr_&&simjob&i.;
	pred_cumdflt_&&simjob&i..= cumdflt_&&simjob&i.. /numloan*100;
	Pred_60p_&&simjob&i..=(s60_&&simjob&i.. +s90_&&simjob&i..+sfc_&&simjob&i..+sreo_&&simjob&i..)/numloan*100;
	Pred_30_&&simjob&i..=(s30_&&simjob&i../numloan) *100;
	Pred_C_&&simjob&i..	=(scur_&&simjob&i../numloan) *100;
%end;
run;

data outd.&LOAN_TYPE._&PRODUCT._trans;
set trans;
run;

proc export data=outd.&LOAN_TYPE._&PRODUCT._trans replace
outfile="&dir/&LOAN_TYPE._&PRODUCT._Trans.csv";
run;

%mend;


%macro rollrateplot_TCnew(groupby,plotby,dir);

proc sort data=roll; by runid;run;
data roll;
	merge outd.lookupagg(in=a keep=runid o_year) roll(in=b);
	by runid;
	if a and b;
run;

proc sort data=roll;by o_year period;run;

%macro data(input, output);
data tmp1;
set &input.;
by loan_id period;
if period>1 and first.loan_id then lagstat=.;
run;

data tmp1;
set tmp1(where=( mba_stat in('C','3','0') and lagstat= 'C'));
by loan_id period;
tc0=mba_stat='0';
tC3=mba_stat='3';
tCC=mba_stat='C';
run;

proc sort data=tmp1 nodupkey;by loan_id  period;run;

proc sql;
create table &output. as
select count(*) as numloans, mean(tc0) as actual_c0,
mean(tC3) as actual_C3,
mean(tCC) as actual_CC,
runid,o_year,period
from tmp1
group by runid,period,&groupby.;
quit;
run;

proc sort data=&output.;by runid;run;

data &output.;merge &output.(in=a) outd.lookupagg(in=b);by runid;if a and b;run;

proc sort data=&output.;by o_year period;run;

%mend;

%data(performance_gt6,act_roll_gt6);
%data(performance_age5,act_roll_age5);
%data(performance_all,act_roll);

data rollrates;
merge roll(in=a) act_roll_gt6(in=b rename=(actual_c0=act_c0_gt6 actual_C3=act_C3_gt6 actual_CC=act_CC_gt6))
		 act_roll_age5(rename=(actual_c0=act_c0_age5 actual_C3=act_C3_age5 actual_CC=act_CC_age5) in=c)
	 	 act_roll(in=d);
by o_year period;
	if a and b and c;
run;

data outd.rollrates;set rollrates;run;

proc sort data=outd.rollrates; by o_year period;run;

******************************Create graphs comparing observed,  vs. dialed;
options orientation=landscape;
ods pdf file= "&dir./rollrate1.pdf";
options orientation=landscape;
ods listing close;
ods printer close;
%macro plot(max,transition,plotby);
%do i=1 %to &max;
proc gplot data=outd.rollrates(where=(runid=&i));
plot ( dial_&transition ndial_&transition actual_&transition act_&transition._age5 act_&transition._gt6) * &plotby. / overlay legend=legend1
haxis= 1 to 10 by 1;
format period segf.;
title "&Loan_type. &Product. Dialed vs. Observed_&transition.";
run;
%end;
%mend;

%plot(&maxpid,c0,period);
%plot(&maxpid,C3,period);
%plot(&maxpid,CC,period);
ods pdf close;
ods listing;
data _null_;
set _null_;
run;

%MEND;

****This is to comparing TC transition graphs across different cohort (Runid), or across different period***************;
****This is to comparing T3 transition graphs across different cohort (Runid), or across different period***************;



%macro T3_trans_mod(dir,dir1,groupby,plotby);

data tmp1;
set performance;
where mba_stat in('C','3','0','6') and lagstat= '3';
t30=mba_stat='0';
t33=mba_stat='3';
t3c=mba_stat='C';
t36=mba_stat='6';
run;
proc sql;
create table agg1 as
select mean(t30) as actual_30,
mean(t33) as actual_33,
mean(t3c) as actual_3c,
mean(t36) as actual_36,
runid
from tmp1
group by &groupby.;
quit;
run;
data tmp2b;
set roll(where=(period<=&dataperiod) rename=(s_3_p0=predicted_30 s_3_c=predicted_3c s_3_3=predicted_33
s_3_6=predicted_36));
predicted_30=predicted_30*s30 /sum3ob;
predicted_33=predicted_33*s30 /sum3ob;
predicted_3c=predicted_3c*s30 /sum3ob;
predicted_36=predicted_36*s30 /sum3ob;
run;
proc sql;
create table agg2 as
select sum(predicted_30) as dialed_30,
sum(predicted_33) as dialed_33,
sum(predicted_3c) as dialed_3c,
sum(predicted_36) as dialed_36,
runid
from tmp2b
group by &groupby.;
quit;
run;
data tmp2b;
set rollnd(where=(period<=&dataperiod) rename=(s_3_p0=predicted_30 s_3_c=predicted_3c s_3_3=predicted_33
s_3_6=predicted_36));
predicted_30=predicted_30*s30 /sum3ob;
predicted_33=predicted_33*s30 /sum3ob;
predicted_3c=predicted_3c*s30 /sum3ob;
predicted_36=predicted_36*s30 /sum3ob;
run;
proc sql;
create table agg3 as
select sum(predicted_30) as nodialed_30,
sum(predicted_33) as nodialed_33,
sum(predicted_3c) as nodialed_3c,
sum(predicted_36) as nodialed_36,
runid
from tmp2b
group by &groupby.;
quit;
run;

data &dir.agg3;
merge agg1 agg2 agg3;
run;
options orientation=landscape;
ods pdf file= "&dir1./trans3.pdf";
options orientation=landscape;
ods listing close;
ods printer close;
proc gplot data=&dir.agg3;
plot (actual_30 dialed_30 nodialed_30) * &plotby. / overlay legend=legend1
haxis= 1 to 5 by 1;
title '';
run;
proc gplot data=&dir.agg3;
plot (actual_3c dialed_3c nodialed_3c) * &plotby. / overlay legend=legend1
haxis= 1 to 5 by 1;
title '';
run;
proc gplot data=&dir.agg3;
plot (actual_33 dialed_33 nodialed_33) * &plotby. / overlay legend=legend1
haxis= 1 to 5 by 1;
title '';
run;
proc gplot data=&dir.agg3;
plot (actual_36 dialed_36 nodialed_36) * &plotby./ overlay legend=legend1
haxis= 1 to 5 by 1;
title '';
run;
ods pdf close;
ods listing;
data _null_;
set _null_;
run;

%mend;
*************************************************;
%macro c_trans_mod(dir,dir1,groupby,plotby);
data tmp1;
set performance;
where mba_stat in('C','3','0') and lagstat= 'C';
tc0=mba_stat='0';
tC3=mba_stat='3';
tCC=mba_stat='C';
run;

proc sql;
create table agg1 as
select mean(tc0) as actual_c0,
mean(tC3) as actual_C3,
mean(tCC) as actual_CC,
runid
from tmp1
group by &groupby.; *group by runid, period, etc.;
quit;
run;

data tmp2b;
set roll(where=(period<=&dataperiod) rename=(s_c_p0=predicted_c0 s_c_c=predicted_CC s_C_3=predicted_C3));
predicted_c0=predicted_c0*scur/sumCob;
predicted_C3=predicted_C3*scur/sumCob;
predicted_CC=predicted_CC*scur/sumCob;
run;

proc sql;
create table agg2 as
select sum(predicted_c0) as dialed_c0,
sum(predicted_C3) as dialed_C3,
sum(predicted_CC) as dialed_CC,
runid
from tmp2b
group by &groupby.; *group by runid, period, etc.;
quit;
run;

data tmp2b;
set rollnd(where=(period<=&dataperiod) rename=(s_c_p0=predicted_c0 s_c_c=predicted_CC s_C_3=predicted_C3));
predicted_c0=predicted_c0*scur/sumCob;
predicted_C3=predicted_C3*scur/sumCob;
predicted_CC=predicted_CC*scur/sumCob;
run;
proc sql;
create table agg3 as
select sum(predicted_c0) as nodialed_c0,
sum(predicted_C3) as nodialed_C3,
sum(predicted_CC) as nodialed_CC,
runid
from tmp2b
group by &groupby.; *group by runid, period, etc.;
quit;
run;


data &dir..aggC;
merge agg1 agg2 agg3;
run;


options orientation=landscape;
ods pdf file= "&dir1./transc.pdf";
options orientation=landscape;
ods listing close;
ods printer close;
proc gplot data=&dir..aggC;
plot (actual_c0 dialed_c0 nodialed_c0) * &plotby.  / overlay legend=legend1
haxis= 1 to 5 by 1;
*format runid segf.;
title '';
run;
proc gplot data=&dir..aggC;
plot (actual_C3 dialed_C3 nodialed_C3) * &plotby.  / overlay legend=legend1
haxis= 1 to 5 by 1;
*format runid segf.;
title '';
run;
proc gplot data=&dir..aggC;
plot (actual_CC dialed_CC nodialed_CC) * &plotby.  / overlay legend=legend1
haxis= 1 to 5 by 1;
*format runid segf.;
title '';
run;
ods pdf close;
ods listing;
data _null_;
set _null_;
run;

%mend;

**********************************************************************************************************************;
