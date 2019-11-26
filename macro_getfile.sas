
/*************************************************************************************************/

%macro names(name,maxname);

%do k=1 %to &maxname;
&name&k
%end;

%mend names;

/*************************************************************************************************/

%macro fileimport(infile,name);

%do i= 1 %to &maxpid;

data &NAME.&i;
infile "&infile./&name.&i._RM.csv"
delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

informat AMORT_TERM best32. ;
informat APP_VALUE best32. ;
informat AVM_CONF_LVL $10.;
informat AVM_FSD $10.;
informat BALANCE best32. ;
informat COMBINED_BALANCE best32. ;
informat CUR_HOUSE_PRICE best32. ;
informat CURRENT_PAYMENT best32. ;
informat CURRENT_RATE best32. ;
informat DATA_TYPE best32. ;
informat DELINQ_STATUS best32. ;
informat DIAL_ID $32. ;
informat DIAL_ID2 $32. ;
informat DOCUMENTATION best32. ;
informat FICO_SCORE best32. ;
informat FIRST_PAY_DATE mmddyy10. ;
informat FIRST_RATE_RESET best32. ;
informat FIRST_RESET_CAP best32. ;
informat HISTORY $32. ;
informat INDEX_ID best32. ;
informat INIT_INT_RATE best32. ;
informat IO_TERM best32. ;
informat L_RATE_CAP best32. ;
informat L_RATE_FLOOR best32. ;
informat LIEN_POSITION best32. ;
informat LOAN_MOD_FLAG best32. ;
informat LOAN_NO $16. ;
/*informat LOAN_NO best32. ;*/
informat LPI_DATE mmddyy10. ;
informat MARGIN best32. ;
informat MI_CODE $10. ;
informat MI_COVERAGE $10. ;
informat MOD_DATE mmddyy10. ;
informat MOD_TYPE best32. ;
informat NEGAM_CAP best32. ;
informat OCCUPANCY best32. ;
informat ORIG_AMOUNT best32. ;
informat ORIG_CLTV best32. ;
informat ORIG_DATE mmddyy10. ;
informat ORIG_LTV best32. ;
informat P_PAY_CAP best32. ;
informat P_PAY_FLOOR best32. ;
informat P_RATE_CAP best32. ;
informat P_RATE_FLOOR best32. ;
informat PAY_RESET_FREQ best32. ;
informat PAYAMTFREQ $10. ;
informat POOL_DESC $10.;
informat PPENDDATE mmddyy10. ;
informat PPPENALTY best32. ;
informat PRODUCT_TYPE best32. ;
informat PROP_TYPE best32. ;
informat PURPOSE best32. ;
informat RATE_RESET_FREQ best32. ;
informat SALE_PRICE best32. ;
informat SECURITIES_DESC $10. ;
informat STATE $4. ;
informat STATUS_AT_MOD $1. ;
informat TERM best32. ;
informat ZIP $7. ;
informat USER_VAR1 best32. ;
informat USER_VAR2 best32. ;
informat USER_VAR3 $16. ;
informat USER_VAR4 $16. ;
informat WORST_RESET_STATUS $1. ;
informat DELETED best32. ;
informat DEL_DESC $40. ;
informat AS_OF_DATE $8. ;

format AMORT_TERM best32. ;
format APP_VALUE best32. ;
format AVM_CONF_LVL $10.;
format AVM_FSD $10.;
format BALANCE best32. ;
format COMBINED_BALANCE best32. ;
format CUR_HOUSE_PRICE best32. ;
format CURRENT_PAYMENT best32. ;
format CURRENT_RATE best32. ;
format DATA_TYPE best32. ;
format DELINQ_STATUS best32. ;
format DIAL_ID $32. ;
format DIAL_ID2 $32. ;
format DOCUMENTATION best32. ;
format FICO_SCORE best32. ;
format FIRST_PAY_DATE mmddyy10. ;
format FIRST_RATE_RESET best32. ;
format FIRST_RESET_CAP best32. ;
format HISTORY $32. ;
format INDEX_ID best32. ;
format INIT_INT_RATE best32. ;
format IO_TERM best32. ;
format L_RATE_CAP best32. ;
format L_RATE_FLOOR best32. ;
format LIEN_POSITION best32. ;
format LOAN_MOD_FLAG best32. ;
format LOAN_NO $16. ;
/*format LOAN_NO best32. ;*/
format LPI_DATE mmddyy10. ;
format MARGIN best32. ;
format MI_CODE $10. ;
format MI_COVERAGE $10. ;
format MOD_DATE mmddyy10. ;
format MOD_TYPE best32. ;
format NEGAM_CAP best32. ;
format OCCUPANCY best32. ;
format ORIG_AMOUNT best32. ;
format ORIG_CLTV best32. ;
format ORIG_DATE mmddyy10. ;
format ORIG_LTV best32. ;
format P_PAY_CAP best32. ;
format P_PAY_FLOOR best32. ;
format P_RATE_CAP best32. ;
format P_RATE_FLOOR best32. ;
format PAY_RESET_FREQ best32. ;
format PAYAMTFREQ $10. ;
format POOL_DESC $10.;
format PPENDDATE mmddyy10. ;
format PPPENALTY best32. ;
format PRODUCT_TYPE best32. ;
format PROP_TYPE best32. ;
format PURPOSE best32. ;
format RATE_RESET_FREQ best32. ;
format SALE_PRICE best32. ;
format SECURITIES_DESC $10. ;
format STATE $4. ;
format STATUS_AT_MOD $1. ;
format TERM best32. ;
format ZIP $7. ;
format USER_VAR1 best32. ;
format USER_VAR2 best32. ;
format USER_VAR3 $16. ;
format USER_VAR4 $16. ;
format WORST_RESET_STATUS $1. ;
format DELETED best32. ;
format DEL_DESC $40. ;
format AS_OF_DATE $8. ;

input
AMORT_TERM
APP_VALUE
AVM_CONF_LVL $
AVM_FSD $
BALANCE
COMBINED_BALANCE
CUR_HOUSE_PRICE
CURRENT_PAYMENT
CURRENT_RATE
DATA_TYPE
DELINQ_STATUS
DIAL_ID $
DIAL_ID2 $
DOCUMENTATION
FICO_SCORE
FIRST_PAY_DATE
FIRST_RATE_RESET
FIRST_RESET_CAP
HISTORY $
INDEX_ID
INIT_INT_RATE
IO_TERM $
L_RATE_CAP
L_RATE_FLOOR
LIEN_POSITION
LOAN_MOD_FLAG
LOAN_NO $
LPI_DATE
MARGIN
MI_CODE $
MI_COVERAGE $
MOD_DATE
MOD_TYPE
NEGAM_CAP
OCCUPANCY
ORIG_AMOUNT
ORIG_CLTV
ORIG_DATE
ORIG_LTV
P_PAY_CAp
P_PAY_FLOOR
P_RATE_CAP
P_RATE_FLOOR
PAY_RESET_FREQ
PAYAMTFREQ $
POOL_DESC $
PPENDDATE
PPPENALTY
PRODUCT_TYPE
PROP_TYPE
PURPOSE
RATE_RESET_FREQ
SALE_PRICE
SECURITIES_DESC $
STATE $
STATUS_AT_MOD $
TERM
ZIP $
USER_VAR1
USER_VAR2
USER_VAR3 $
USER_VAR4 $
WORST_RESET_STATUS $
DELETED
DEL_DESC $
AS_OF_DATE $
;

run;

%end;

%mend;

/*************************************************************************************************/

%macro getfile_rm43 (dir, filename);

%fileimport (&dir, &filename);

%do i= 1 %to &maxpid;

%if &modelid~=1 %then %do;

data &filename.&i (keep = loan_no runid del_desc deleted orig_amount o_year);
set &filename.&i;
runid = &i;
o_year = year(orig_date);
run;

data &filename.&i (keep  =  loan_no runid orig_Amount o_year);
set &filename.&i;
if deleted = 1 then delete;
run;

%end;

%else %do;

data &filename.&i (keep = loan_id runid del_desc deleted DELINQ_STATUS o_year dial_id);
set &filename.&i;
*loan_id = input(loan_no,16.);
loan_id = loan_no;
runid = &i;
dialid = dial_id;
run;

proc freq data = &filename.&i;
table del_desc deleted/missing;
title "&i";
run;

data &filename.&i(keep = loan_id runid o_year DELINQ_STATUS dialid);
set &filename.&i;
if deleted = 1 then delete;
run;

%global totloan&i;

proc sql;
select count(*) into: totloan&i from &syslast; 
quit; 
run;
	
%end;

%end;

%macro names(name,maxname);

%do k=1 %to &maxname;
&name&k
%end;

%mend names;

data id;
set %names(&filename,&maxpid);
run;

proc sort data = id;
by loan_no;
run;

proc freq data = id;
table runid;
run;

%if &modelid~=1 %then %do;

proc sql;
create table sumobs as
select count(*) as n_obs,
sum(orig_amount) as origamt,
runid
from id
group by runid;
quit;
run;

%end;

%mend;

/*************************************************************************************************/

%macro getfile_rollrate(dir,filename,name);
	%do i= 1 %to &maxpid;
		proc import datafile="&dir/&filename.&i._RM#csv/Rollrate.csv"
			out= &NAME.&i replace;
		run;

		data &name.&i;
			set &name.&i;
			runid=&i;
			if period<=&dataperiod.;
		run;
	%end;

	%macro names2(name,maxname);
		%do k=1 %to &maxname;
			&name&k
		%end;
	%mend names2;


	data &name.;
		set %names2(&NAME,&maxpid);
	run;

%mend;

/*************************************************************************************************/

%macro getfile_trans(dir,filename,NAME);
%do i= 1 %to &maxpid;
proc import datafile="&dir/&filename.&i._RM#csv/Trans.csv"
out= tmp&i replace;
run;

data &name.&i;
set tmp&i;
runid=&i;
where pctl=-1;
if period<=&dataperiod.;
run;

%end;

data &name.;
set %names(&NAME,&maxpid);
run;
%mend;

/*************************************************************************************************/

%macro getfile_trans_forward(dir,filename,NAME,simjob);
%do i= 1 %to &maxpid;
proc import datafile="&dir/&filename.&i._RM#csv/Trans.csv"
out= tmp&i replace;
run;

data &fileNAME.&i(drop=segment);
set tmp&i;
if pctl=-1;
runid=&i;
run;
%end;

data &NAME (keep=runid  period cpr cumdflt cumloss sr0 spay sfc sf0 scur s90 s60 s30 sREO period cumpayoff cdr
rename=(cpr=cpr_&&simjob cdr=cdr_&&simjob cumdflt=cumdflt_&simjob cumloss=cumloss_&simjob ));
set %names(&fileNAME,&maxpid);
run;

%mend;

/*************************************************************************************************/

%macro getfile_period(dir,filename,NAME);

%do i= 1 %to &maxpid;

proc import datafile="&dir/&filename.&i._RM#csv/Period.csv"
out= tmp&i replace;
run;

data &fileNAME.&i(drop=segment);
set tmp&i;
if pctl=-1;
runid=&i;
run;

%end;

data &NAME (keep=runid period pctl CDR CPR DFLT  prepay S_C_C S_C_3 S_C_P0 S_3_C S_3_3 S_3_6 S_3_P0 S_6_P0 S_6_C S_6_3 S_6_6 S_6_9 S_6_FC S_9_C S_9_3 
S_9_6 S_9_9 S_9_FC S_9_P0 S_9_F0 S_9_REO S_FC_C S_FC_3 S_FC_6 S_FC_9 S_FC_FC S_FC_P0 S_FC_REO S_REO_REO S_REO_R0);
set %names(&fileNAME,&maxpid);
run;

%mend;

/*************************************************************************************************/

%macro getfile_balances(dir,filename);
%do i= 1 %to &maxpid;
proc import datafile="&dir/&filename.&i._RM#csv/Balances.csv"
out= bal replace;
run;
%end;
%mend;

/*************************************************************************************************/

%macro getfile_trans_backtest(dir,filename,NAME,maxjob);

%do j=1 %to &maxjob;
	%do i= 1 %to &maxpid;
	proc import datafile="&dir/&&simjob&j./&filename.&i._RM#csv/Trans.csv"
	out= tmp&i replace;
	run;

	data &fileNAME.&i(drop=segment);
	set tmp&i;
	if pctl=-1;
	runid=&i;
	run;
	%end;

	data &NAME.&j. ;
	set %names(&fileNAME,&maxpid);
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

/*************************************************************************************************/

%macro getfile_rollrate_forward(dir,filename,name);
%do i= 1 %to &maxpid;
proc import datafile="&dir/&filename.&i._RM#csv/Rollrate.csv"
out= &NAME.&i replace;
run;

data &NAME.&i;
set &NAME.&i;
runid=&i;
run;

%end;

data &name ;
set %names(&NAME,&maxpid);
run;

%mend;

/*************************************************************************************************/

%macro getfile_trans_forward_mod(dir,filename,NAME,maxjob);

%do j=1 %to &maxjob;
	%do i= 1 %to &maxpid;
	proc import datafile="&dir/&&simjob&j./&filename.&i._RM#csv/Trans.csv"
	out= tmp&i replace;
	run;

	data &fileNAME.&i;
	set tmp&i;
	if pctl=-1;
	runid=&i;
	run;
	%end;

	data &NAME.&j. ;
	set %names(&fileNAME,&maxpid);
	run;

	data &syslast;
	set &syslast(keep=runid  period cpr cumdflt cumloss cdr cumpayoff scur s30 s60 s90 sf0 sfc spay sr0 SREO rename=
		(scur=scur_&&simjob&j. s30=s30_&&simjob&j. s60=s60_&&simjob&j. s90=s90_&&simjob&j. sf0=sf0_&&simjob&j. sfc=sfc_&&simjob&j. sr0=sr0_&&simjob&j. 
		sreo=sreo_&&simjob&j. spay=spay_&&simjob&j. cpr=cpr_&&simjob&j.  cumdflt=cumdflt_&&simjob&j. cumloss=cumloss_&&simjob&j. cdr=cdr_&&simjob&j.
		cumpayoff =cumpayoff_&&simjob&j.));
	run;

	data &name.&j.;************to get o_year;
	merge outd.lookupagg(in=a) &name.&j.(in=b);
	by runid;
	run;

	data &name.&j;
merge &name.&j sumobs;
by runid;
cumdflt_&&simjob&j.._active= cumdflt_&&simjob&j. / n_obs *100;
cumloss_&&simjob&j.._active=(cumloss_&&simjob&j.*1000) / origamt*100;
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

/*************************************************************************************************/

