**********************************************************************************************************************;
**********************************************************************************************************************;

%macro RM_autoconvert(datadir,filename);

*********Auto Conversion Process ***************************************;
data xml3; 
infile "&RMfile.\conv_csv2csv.xml" dsd missover 
lrecl =1000 firstobs=1; 
length var1 $600.;
input var1 $; 
run;

%do i= 1 %to &maxpid;

data xml4;
set xml3;
if substr(var1,1,26)='<Source_Connection_String>' then 
var1='<Source_Connection_String>Provider=MSDASQL.1;Persist Security Info=False;
Extended Properties="DBQ='||"&datadir"||';
Driver={Microsoft Text Driver (*.txt; *.csv)}"</Source_Connection_String>';
if substr(var1,1,19)='<Source_Table_Name>' then 
var1='<Source_Table_Name>'||"&filename.&i"||'.csv</Source_Table_Name>';
if substr(var1,1,12)='<AS_OF_DATE>' then var1='<AS_OF_DATE>'||substr(left(&aod),1,6)||'</AS_OF_DATE>';
if substr(var1,1,16)='<Directory_Path>' then var1='<Directory_Path>'||"&datadir"||'</Directory_Path>';
if substr(var1,1,10)='<CSF_Path>' then var1='<CSF_Path>'||"&csfpath"||'</CSF_Path>';
if substr(var1,1,13)='<Output_Path>' then var1='<Output_Path>'||"&datadir."||'</Output_Path>';
/*if substr(var1,1,9) ='<QA_Path>' then var1='<QA_Path>'||"&rm_folder.\NonHeloc.qa"||'</QA_Path>';*/
if substr(var1,1,9) ='<QA_Path>' then var1='<QA_Path>'||"&rm_folder.\Mortgage.qa"||'</QA_Path>';
run;

data _null_;
set xml4;
file "&RM_folder.\conv_csv2csv.xml" lrecl=1000;
put var1;
run;

x "cd &datadir.";
X "del &filename.&i._rm.csv";
x "cd &RM_folder.";
x 'conversionwizard.exe conv_csv2csv.xml';
x "cd &datadir.";
x 'del *.XML';

%end;

x "cd &datadir.";


data _null_;
set xml4;
file "&datadir.\conv_csv2csv.xml" lrecl=1000;
put var1;
run;

%MEND;


**********************************************************************************************************************;
%macro RM_autoconvert_forward(datadir,filename,csf_path);

*********Auto Conversion Process ***************************************;

data xml3; 
infile "&RMfile.\conv_csv2csv.xml" dsd missover 
lrecl =1000 firstobs=1; 
length var1 $600.;
input var1 $; 
run;
%do i= 1 %to &maxpid;

data xml4;
set xml3;
if substr(var1,1,26)='<Source_Connection_String>' then 
var1='<Source_Connection_String>Provider=MSDASQL.1;Persist Security Info=False;
Extended Properties="DBQ='||"&datadir"||';
Driver={Microsoft Text Driver (*.txt; *.csv)}"</Source_Connection_String>';
if substr(var1,1,19)='<Source_Table_Name>' then 
var1='<Source_Table_Name>'||"&filename.&i"||'.csv</Source_Table_Name>';
if substr(var1,1,12)='<AS_OF_DATE>' then var1='<AS_OF_DATE>'||substr(left(&aod),1,6)||'</AS_OF_DATE>';
if substr(var1,1,16)='<Directory_Path>' then var1='<Directory_Path>'||"&datadir"||'</Directory_Path>';
if substr(var1,1,10)='<CSF_Path>' then var1='<CSF_Path>'||"&csf_path"||'</CSF_Path>';
if substr(var1,1,13)='<Output_Path>' then var1='<Output_Path>'||"&datadir."||'</Output_Path>';
if substr(var1,1,9) ='<QA_Path>' then var1='<QA_Path>'||"&rm_folder.\NonHeloc.qa"||'</QA_Path>';

run;

data _null_;
set xml4;
file "&RM_folder.\conv_csv2csv.xml" lrecl=1000;
put var1;
run;

x "cd &RM_folder.";
x 'conversionwizard.exe conv_csv2csv.xml';
x "cd &datadir.";
x 'del *.XML';

%end;

%MEND;



%macro modifyIRandHPI();
/*modify HPI Setting*/
data xml5;
set xml5;
retain startProcessing 0;
if t1='HPIStochasticInformation' then startProcessing=1;
if startProcessing=1 and t1='HpiOption' then 
	var1= "<"||trim(t1)||">"||"SpecifiedHpiPathFile"||"</"||trim(t1)||">";
if startProcessing=1 and t1='HpiPathFile' then 
	var1= "<"||trim(t1)||">"||"&hpipath."||"</"||trim(t1)||">";
drop startProcessing;
run;
/*modify Interest Rate setting; removed so that in the future rate can be set outside of the code*/
/*data xml5;
set xml5;
retain startProcessing 0;
if t1="InterestRate" then startProcessing=1;
if startProcessing=1 and t1='Model' then 
	var1= "<"||trim(t1)||">"||"HJM"||"</"||trim(t1)||">";
if startProcessing=1 and t1="HjmSettings" then startProcessing=2;
if startProcessing=2 and t1='HistoricalVolatilityShort' then 
	var1= "<"||trim(t1)||">"||"0"||"</"||trim(t1)||">";
if startProcessing=2 and t1='HistoricalVolatilityLong' then 
	var1= "<"||trim(t1)||">"||"0"||"</"||trim(t1)||">";
drop startProcessing;
run;*/

%mend modifyIRandHPI;

***********************************Amit's Backtest Process to call Dials************************************************;

/*complete import of rmp and dials file and common jobs for all model*/
%macro dialinit(ppdials,dqdials);

/*proc import datafile="&ppdials"
out=pp_dials replace;
run;
*/

data pp_dials;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile "&ppdials"
delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;


informat	var_id	best32.	;
informat	value	best32.	;
informat	adjust  best32.;
informat	model	$20.00 	;
informat	pp_mult best8.;
informat	pp_add  best8.;
informat    defaultvalue $16. ;

format	var_id	best32.	;
format	value	best32.	;
format	adjust  best32.;
format	model	$20.00 	;
format	pp_mult best8.;
format	pp_add  best8.;
format  defaultvalue $16. ;

input
var_id
value
adjust
model
pp_mult
pp_add
defaultvalue
;
if _ERROR_ then call symput('_EFIERR_',1);  /* set ERROR detection macro variable */

Run;

data dq_dials;
	%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
	infile "&dqdials"
	delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2 ;

informat	var_id	best32.	;
informat	value	best32.	;
informat	AdjustCurToCur	best32.	;
informat	AdjustCurToThirty	best32.	;
informat	AdjustThirtyToCur	best32.	;
informat	AdjustThirtyToThirty	best32.	;
informat	AdjustThirtyToSixty	best32.	;
informat	AdjustThirtyToForeclosure	best32.	;
informat	AdjustSixtyToCurrent	best32.	;
informat	AdjustSixtyToThirty	best32.	;
informat	AdjustSixtyToSixty	best32.	;
informat	AdjustSixtyToNinety	best32.	;
informat	AdjustSixtyToForeclosure	best32.	;
informat	AdjustNinetyToCurrent	best32.	;
informat	AdjustNinetyToThirty	best32.	;
informat	AdjustNinetyToSixty	best32.	;
informat	AdjustNinetyToNinety	best32.	;
informat	AdjustNinetyToForeclosure	best32.	;
informat	AdjustNinetyToReo	best32.	;
informat	AdjustNinetyToForeclosureSale	best32.	;
informat	AdjustForeclosureToCurrent	best32.	;
informat	AdjustForeclosureToThirty	best32.	;
informat	AdjustForeclosureToSixty	best32.	;
informat	AdjustForeclosureToNinety	best32.	;
informat	AdjustForeclosureToForeclosure	best32.	;
informat	AdjustForeclosureToReo	best32.	;
informat	AdjustForeclosureToFC	best32.	;
informat	AdjustReoToReo	best32.	;
informat	AdjustReoToReoSale	best32.	;
informat	model	$20.00 	;
informat 	defaultvalue $16. ;

format	var_id	best12.	;
format	value	best12.	;
format	AdjustCurToCur	best12.	;
format	AdjustCurToThirty	best12.	;
format	AdjustThirtyToCur	best12.	;
format	AdjustThirtyToThirty	best12.	;
format	AdjustThirtyToSixty	best12.	;
format	AdjustThirtyToForeclosure	best12.	;
format	AdjustSixtyToCurrent	best12.	;
format	AdjustSixtyToThirty	best12.	;
format	AdjustSixtyToSixty	best12.	;
format	AdjustSixtyToNinety	best12.	;
format	AdjustSixtyToForeclosure	best12.	;
format	AdjustNinetyToCurrent	best12.	;
format	AdjustNinetyToThirty	best12.	;
format	AdjustNinetyToSixty	best12.	;
format	AdjustNinetyToNinety	best12.	;
format	AdjustNinetyToForeclosure	best12.	;
format	AdjustNinetyToReo	best12.	;
format	AdjustNinetyToForeclosureSale	best12.	;
format	AdjustForeclosureToCurrent	best12.	;
format	AdjustForeclosureToThirty	best12.	;
format	AdjustForeclosureToSixty	best12.	;
format	AdjustForeclosureToNinety	best12.	;
format	AdjustForeclosureToForeclosure	best12.	;
format	AdjustForeclosureToReo	best12.	;
format	AdjustForeclosureToFC	best12.	;
format	AdjustReoToReo	best12.	;
format	AdjustReoToReoSale	best12.	;
format	model	$20.00 	;
format	defaultvalue	$16.	;

input
var_id
value
AdjustCurToCur
AdjustCurToThirty
AdjustThirtyToCur
AdjustThirtyToThirty
AdjustThirtyToSixty
AdjustThirtyToForeclosure
AdjustSixtyToCurrent
AdjustSixtyToThirty
AdjustSixtyToSixty
AdjustSixtyToNinety
AdjustSixtyToForeclosure
AdjustNinetyToCurrent
AdjustNinetyToThirty
AdjustNinetyToSixty
AdjustNinetyToNinety
AdjustNinetyToForeclosure
AdjustNinetyToReo
AdjustNinetyToForeclosureSale
AdjustForeclosureToCurrent
AdjustForeclosureToThirty
AdjustForeclosureToSixty
AdjustForeclosureToNinety
AdjustForeclosureToForeclosure
AdjustForeclosureToReo
AdjustForeclosureToFC
AdjustReoToReo
AdjustReoToReoSale
model $
defaultvalue $
     ;
if _ERROR_ then call symput('_EFIERR_',1);  /* set ERROR detection macro variable */
run;

*get the RMP file to be modified;

%MEND;


/*modify the dials prepayment factors*/
%macro modifyPPfactors(model,period);

data tmp1;
set pp_dials;
where model="&model." and value=&period.;
run;

data xml5;
set xml5;
format t1 - t10 $100.;
array arr(*) t1 - t10;
do i = 1 to 10;
arr(i) = scan(var1,i,' <>/="');
end;
run;

data xml5;
set xml5;
	if _N_=1 then set tmp1;
retain startProcessing 0;
retain count 0;
array arr{*} t1-t10;

do i = 1 to dim(arr) - 2;

if upcase(arr(i)) = "PREPAYMENTMODEL" and upcase(arr(i+1)) = "NAME" and 
	upcase(arr(i+2)) = upcase("&model.")
	then do;
		startProcessing=1;
		leave;
	end;
	if startProcessing=1 and upcase(arr(i)) = "PREPAYMENTFACTOR" 
		and upcase(arr(i+1)) = "VALUE" and upcase(arr(i+2)) = "&period." then do; 
			startProcessing=2;
	end;
	if startProcessing=2 then do;
		var1="<"||trim(t1)||" "|| trim(t2)||"="||'"'||trim("&period.")||'" '||'DefaultValue="">' ||trim(adjust)|| "</"||trim(t1)||">";
	end;

	if startProcessing=2 and upcase(arr(i)) = "PREPAYMENTFACTOR" then do;
		startProcessing=0;
		count=0;
		leave;
	end;
end;


drop i;
run;

data xml5;
set xml5;
drop startProcessing count adjust;
run;


%mend modifyPPfactors;

/*Modify the dials DQ factors*/
%macro modifyDQFactors(model,period);

data tmp1;
set dq_dials;
where model="&model." and value=&period.;
run;

proc contents data=dq_dials out=dq_ct(keep=name npos) noprint;
run;

proc sort data=dq_ct; by npos;run;

%global list;

proc sql noprint;
select name into: list separated by ' ' from dq_ct where name like 'Adjust%';
quit;

data xml5;
retain startProcessing count;
array names{*} &list.;

set xml5;
if _N_=1 then set tmp1;

retain startProcessing 0;
retain count 0;
array arr{*} t1-t10;

if startProcessing=2 and count < dim(names) then do;
	val = startProcessing;
	count=count+1;
	test2=names(count);
	if upcase(t1) ne "DEFAULTFACTOR" then 
		var1=compress("<"||t1||">" ||names(count)|| "</"||t3||">");
end;

do i = 1 to dim(arr) - 2;

if upcase(arr(i)) = "DEFAULTMODEL" and upcase(arr(i+1)) = "NAME" and 
	upcase(arr(i+2)) = upcase("&model.")
	then do;
		startProcessing=1;
		leave;
	end;
	if startProcessing=1 and upcase(arr(i)) = "DEFAULTFACTOR" 
		and upcase(arr(i+1)) = "VALUE" and upcase(arr(i+2)) = "&period." then do; 
			startProcessing=2;
			leave;
	end;
	
	if startProcessing=2 and upcase(arr(i)) = "DEFAULTFACTOR" then do;
		startProcessing=0;
		count=0;
		leave;
	end;
end;

drop i;
run;

data xml5;
set xml5;
array names{*} &list.;
drop startProcessing count val &list.;
run;

%mend;

***********************************Amit's Backtest Process to call Dials************************************************;
%macro RM_autosimulate(datadir,outd,filename,JOB,ppdials,dqdials,dialedid,lssoff);
*datadir=folder for converted RM input file;
*outd=output file folder for simulation results;
*filename=RM input file name Prefix (i.e., id);
*job=simulation job name;
*ppdials=prepay dials file name and location;
*dqdials=dq dials file name and location;
*dialedid=1 is for dialed model & 0 for undialed model;
*lssoff=1 for nohistory or lssoff and 0 for history of lsson;
*macro variable dial period is used to change dials application period;
*********Auto Simulation Process ***************************************;

data xml5; 
	  infile "&RMfile.\&proj..rmp" missover 
      lrecl =1000 firstobs=1; 
      length var1 $10000.;
      input var1 & $;      
	  var1=left(trim(var1)); 
run;


data xml5;
set xml5;
format t1 - t10 $100.;
array arr(*) t1 - t10;
do i = 1 to 10;
arr(i) = scan(var1,i,' <>/="');
end;
run;

data xml5;
	set xml5;

if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"false"||'</UseDefaultAdjustments>';
if substr(var1,1,26)='<UsePrepaymentAdjustments>'	then var1='<UsePrepaymentAdjustments>'||"false"||'</UsePrepaymentAdjustments>';
if substr(var1,1,24)='<UseSeverityAdjustments>' 	then var1='<UseSeverityAdjustments>'||"false"||'</UseSeverityAdjustments>';*new;

if substr(var1,1,20)="<SimulationJob Name=" 		then var1='<SimulationJob Name="'||"&projname."||'">';
if substr(var1,1,15)="<Scenario Name=" 				then var1='<Scenario Name="'||"&JOB"||'">';
    
  if substr(var1,1,18)='<ConnectionString>' then
var1='<ConnectionString>Provider=Microsoft.Jet.OLEDB.4.0;Data Source='||"&datadir"||';Extended Properties="text;HDR=Yes;FMT=Delimited"</ConnectionString>';

	if substr(var1,1,31)='<SimulationIntervalNbrOfMonths>' then var1='<SimulationIntervalNbrOfMonths>'||"&simulationperiod"||'</SimulationIntervalNbrOfMonths>';

%if &lssoff=1 %then %do;
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"1"||'</NumberOfRuns>';
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"false"||'</SimulateLoanStates>';
%end;%else %do;
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"true"||'</SimulateLoanStates>';
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"&numberofrun"||'</NumberOfRuns>';
%end;
run;
	
%if &dialedid=1 %then %do;*updated;

	%dialinit(&ppdials,&dqdials);

	proc sql noprint;
	select distinct model into:model separated by ' ' from pp_dials where SUBSTR(model,1,7) NE "DEFAULT" ;
	quit;

	proc sql noprint;
	select count( distinct model) into : modelCount from pp_dials where SUBSTR(model,1,7) NE "DEFAULT";
	quit;

	data xml5; 
	set xml5;
	if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"true"||'</UseDefaultAdjustments>';
	if substr(var1,1,26)='<UsePrepaymentAdjustments>' 	then var1='<UsePrepaymentAdjustments>'||"true"||'</UsePrepaymentAdjustments>';
	run;
	
		%do j = 1 %to &modelCount.;
	%let model1 = %scan(&model.,&j.);
	%put model is &model1.;
	%modifyPPFactors(&model1.,1);
	%if &lientype=2 %then %do;
		%modifyPPFactors(&model1.,24);
	%end;%else %do;
		%modifyPPFactors(&model1.,&dialperiod);
	%end;
	%modifyDQFactors(&model1.,1);
	%if &lientype=2 %then %do;
		%modifyDQFactors(&model1.,24);
	%end;%else %do;
		%modifyDQFactors(&model1.,&dialperiod);
	%end;
		%End;
%end;

%if &modelid=2  %then %do;
*	%modifyPPFactors(&model1.,24);
*	%modifyDQFactors(&model1.,24);
	%modifyIRandHPI;
%end;

%else %do;
data xml5; set xml5;
if substr(var1,1,11)='<HpiOption>'		then var1='<HpiOption>'||"HistoricalValues"||'</HpiOption>';*new;
*if substr(var1,1,12)='<RateOption>'		then var1='<RateOption>'||"HistoricalRatePaths"||'</RateOption>';*new;
run;
%end;
      
  %do i= 1 %to &maxpid;

Data xml6(drop=startprocessing flag flagmodel flag1); 
	set xml5;
    retain startprocessing flag flagmodel flag1;
    if _n_=1 then do;startprocessing=0;flag=0;flagmodel=0;flag1=0;
	end;
    if substr(var1,1,7)='<Model>' and flagmodel=0 then do;
        var1='<Model>'||"&loan_type"||'</Model>';
			if &lientype=2 then do;
				var1='<Model>'||"ALTA"||'</Model>';
			end;
        flagmodel=1;
    end;

if var1='<DataViews>' then startprocessing=1;
else	
	if startprocessing=1 then do;
		var1='<DataView Name="'||"&filename.&i"||'_RM#csv">';
		startprocessing=2;
	end;
	else
	if startprocessing=2 then do;
      startprocessing=3;
    end;
	else
	if startprocessing=3 then do;
	var1='<DataMember>'||"&filename.&i"||'_RM#csv</DataMember>';
	  startprocessing=4;
	end;
	else
	if startprocessing=4 then do;
	  var1='<DataAsOf>'||substr(left(&aod),1,6)||'</DataAsOf>';
	  startprocessing=5;
	end;

if var1='<ElementType>Scenario</ElementType>' then flag=1;
  else 
	if flag=1 then do;
	var1='<Name>'||"&job"||'</Name>';
	flag=0;
   end;

if var1='<ElementType>LoanData</ElementType>' then flag1=1;
  else 
	if flag1=1 then do;
	var1='<Name>'||"&filename.&i"||'_RM#csv</Name>';
	flag1=0;
	end;
 
 if substr(var1,1,17)='<DirectoryOption>' then var1='<DirectoryOption>'||"Specified"||'</DirectoryOption>';
 if substr(var1,1,11)='<Directory>' then var1='<Directory>'||"&outd."||'</Directory>';

run;

data _null_; 
	set xml6;
     file "&outd.\&projname..rmp" lrecl=1000;
     put var1;
	 replace;
run;

    x "cd &rm_folder.";
    x "processrmp.exe &outd.\&projname..rmp &projname [/v]";
    
%end;

data _null_; 
	set xml6;
     file "&outd.\&projname.\&job.\&job..rmp" lrecl=1000;
     put var1;
	 replace;
run;

%mend;

**********************************************************************************************************************;
%macro RM_autosimulate_44(datadir,outd,filename,JOB,ppdials,dqdials,dialedid,lssoff);
*datadir=folder for converted RM input file;
*outd=output file folder for simulation results;
*filename=RM input file name Prefix (i.e., id);
*job=simulation job name;
*ppdials=prepay dials file name and location;
*dqdials=dq dials file name and location;
*dialedid=1 is for dialed model & 0 for undialed model;
*lssoff=1 for nohistory or lssoff and 0 for history of lsson;
*macro variable dial period is used to change dials application period;
*********Auto Simulation Process ***************************************;

data xml5; 
	  infile "&RMfile.\&proj..rmp" missover 
      lrecl =1000 firstobs=1; 
      length var1 $10000.;
      input var1 & $;      
	  var1=left(trim(var1)); 
run;


data xml5;
set xml5;
format t1 - t10 $100.;
array arr(*) t1 - t10;
do i = 1 to 10;
arr(i) = scan(var1,i,' <>/="');
end;
run;

data xml5;
	set xml5;

if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"false"||'</UseDefaultAdjustments>';
if substr(var1,1,26)='<UsePrepaymentAdjustments>'	then var1='<UsePrepaymentAdjustments>'||"false"||'</UsePrepaymentAdjustments>';
if substr(var1,1,24)='<UseSeverityAdjustments>' 	then var1='<UseSeverityAdjustments>'||"false"||'</UseSeverityAdjustments>';*new;

if substr(var1,1,20)="<SimulationJob Name=" 		then var1='<SimulationJob Name="'||"&projname."||'">';
if substr(var1,1,15)="<Scenario Name=" 				then var1='<Scenario Name="'||"&JOB"||'">';
    
  if substr(var1,1,18)='<ConnectionString>' then
var1='<ConnectionString>Provider=Microsoft.Jet.OLEDB.4.0;Data Source='||"&datadir"||';Extended Properties="text;HDR=Yes;FMT=Delimited"</ConnectionString>';

	if substr(var1,1,31)='<SimulationIntervalNbrOfMonths>' then var1='<SimulationIntervalNbrOfMonths>'||"&simulationperiod"||'</SimulationIntervalNbrOfMonths>';

%if &lssoff=1 %then %do;
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"1"||'</NumberOfRuns>';
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"false"||'</SimulateLoanStates>';
%end;%else %do;
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"true"||'</SimulateLoanStates>';
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"&numberofrun"||'</NumberOfRuns>';
%end;

run;
	
%if &dialedid=1 %then %do;*updated;

	data xml5; 
	set xml5;
	if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"true"||'</UseDefaultAdjustments>';
	if substr(var1,1,26)='<UsePrepaymentAdjustments>' 	then var1='<UsePrepaymentAdjustments>'||"true"||'</UsePrepaymentAdjustments>';
  	if substr(var1,1,29)='<DefaultAdjustmentsSetupFile>' then var1='<DefaultAdjustmentsSetupFile>'||"&dqdials"||'</DefaultAdjustmentsSetupFile>';
  	if substr(var1,1,32)='<PrepaymentAdjustmentsSetupFile>' then var1='<PrepaymentAdjustmentsSetupFile>'||"&ppdials"||'</PrepaymentAdjustmentsSetupFile>';
	run;
%end;


%if &modelid=2  %then %do;
	%modifyIRandHPI;
%end;

%else %do;
data xml5; set xml5;
retain counter 0;
if substr(var1,1,14)='<InterestRate>'	then counter=counter+1;

if substr(var1,1,11)='<HpiOption>'		then var1='<HpiOption>'||"HistoricalValues"||'</HpiOption>';*new;
if substr(var1,1,12)='<RateOption>'	and counter <>0	then var1='<RateOption>'||"HistoricalRatePaths"||'</RateOption>';*new;

run;
%end;
 
  %do i= 1 %to &maxpid;

Data xml6(drop=startprocessing flag flagmodel flag1); 
	set xml5;
    retain startprocessing flag flagmodel flag1;
    if _n_=1 then do;startprocessing=0;flag=0;flagmodel=0;flag1=0;
	end;
    if substr(var1,1,7)='<Model>' and flagmodel=0 then do;
        var1='<Model>'||"&loan_type"||'</Model>';
			if &lientype=2 then do;
				var1='<Model>'||"ALTA"||'</Model>';
			end;
        flagmodel=1;
    end;

if var1='<DataViews>' then startprocessing=1;
else	
	if startprocessing=1 then do;
		var1='<DataView Name="'||"&filename.&i"||'_RM#csv">';
		startprocessing=2;
	end;
	else
	if startprocessing=2 then do;
      startprocessing=3;
    end;
	else
	if startprocessing=3 then do;
	var1='<DataMember>'||"&filename.&i"||'_RM#csv</DataMember>';
	  startprocessing=4;
	end;
	else
	if startprocessing=4 then do;
	  var1='<DataAsOf>'||substr(left(&aod),1,6)||'</DataAsOf>';
	  startprocessing=5;
	end;

if var1='<ElementType>Scenario</ElementType>' then flag=1;
  else 
	if flag=1 then do;
	var1='<Name>'||"&job"||'</Name>';
	flag=0;
   end;

if var1='<ElementType>LoanData</ElementType>' then flag1=1;
  else 
	if flag1=1 then do;
	var1='<Name>'||"&filename.&i"||'_RM#csv</Name>';
	flag1=0;
	end;
 
 if substr(var1,1,17)='<DirectoryOption>' then var1='<DirectoryOption>'||"Specified"||'</DirectoryOption>';
 if substr(var1,1,11)='<Directory>' then var1='<Directory>'||"&outd."||'</Directory>';

run;

data _null_; 
	set xml6;
     file "&outd.\&projname..rmp" lrecl=1000;
     put var1;
	 replace;
run;

    x "cd &rm_folder.";
    x "processrmp.exe &outd.\&projname..rmp &projname [/v]";
    
%end;

data _null_; 
set xml6;
file "&outd.\&projname.\&job.\&job..rmp" lrecl=1000;
put var1;
replace;
run;

%mend;

**********************************************************************************************************************;
%macro RM_autosimulate_agency(datadir,outd,filename,JOB,ppdials,dqdials,dialedid,lssoff);
*datadir=folder for converted RM input file;
*outd=output file folder for simulation results;
*filename=RM input file name Prefix (i.e., id);
*job=simulation job name;
*ppdials=prepay dials file name and location;
*dqdials=dq dials file name and location;
*dialedid=1 is for dialed model & 0 for undialed model;
*lssoff=1 for nohistory or lssoff and 0 for history of lsson;
*macro variable dial period is used to change dials application period;

*** Linux and Windows dirs;
%include "&macrodir.macro_dir_linuxtowindows.sas";
*let wdirid=Z:\Projects\Agency_2018\MPT\MPT_201910_LLMA_NOMOD\PRIME_FRM\DATA\shortterm\asofperiod339;
%let wdatadir=%dir_linuxtowindows(linuxdir=&datadir);
%let woutd=%dir_linuxtowindows(linuxdir=&outd);

*********Auto Simulation Process ***************************************;

data xml5; 
	  infile "&RMfile.&proj..rmp" missover 
      lrecl =1000 firstobs=1; 
      length var1 $10000.;
      input var1 & $;      
	  var1=left(trim(var1)); 
run;


data xml5;
	set xml5;
	format t1 - t10 $100.;
	array arr(*) t1 - t10;
	do i = 1 to 10;
		arr(i) = scan(var1,i,' <>/="');
	end;
run;

data xml5;
	set xml5;

if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"false"||'</UseDefaultAdjustments>';
if substr(var1,1,26)='<UsePrepaymentAdjustments>'	then var1='<UsePrepaymentAdjustments>'||"false"||'</UsePrepaymentAdjustments>';
if substr(var1,1,24)='<UseSeverityAdjustments>' 	then var1='<UseSeverityAdjustments>'||"false"||'</UseSeverityAdjustments>';*new;

if substr(var1,1,20)="<SimulationJob Name=" 		then var1='<SimulationJob Name="'||"&projname."||'">';
if substr(var1,1,15)="<Scenario Name=" 				then var1='<Scenario Name="'||"&JOB"||'">';
    
  if substr(var1,1,18)='<ConnectionString>' then
var1='<ConnectionString>Provider=Microsoft.Jet.OLEDB.4.0;Data Source='||"&wdatadir"||';Extended Properties="text;HDR=Yes;FMT=Delimited"</ConnectionString>';

	if substr(var1,1,31)='<SimulationIntervalNbrOfMonths>' then var1='<SimulationIntervalNbrOfMonths>'||"&simulationperiod"||'</SimulationIntervalNbrOfMonths>';

%if &lssoff=1 %then %do;
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"1"||'</NumberOfRuns>';
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"false"||'</SimulateLoanStates>';
%end;%else %do;
	if substr(var1,1,20)='<SimulateLoanStates>' then var1='<SimulateLoanStates>'||"true"||'</SimulateLoanStates>';
	if substr(var1,1,14)='<NumberOfRuns>' then var1='<NumberOfRuns>'||"&numberofrun"||'</NumberOfRuns>';
%end;

run;
	
%if &dialedid=1 %then %do;*updated;

	data xml5; 
	set xml5;
	if substr(var1,1,23)='<UseDefaultAdjustments>' 		then var1='<UseDefaultAdjustments>'||"true"||'</UseDefaultAdjustments>';
	if substr(var1,1,26)='<UsePrepaymentAdjustments>' 	then var1='<UsePrepaymentAdjustments>'||"true"||'</UsePrepaymentAdjustments>';
  	if substr(var1,1,29)='<DefaultAdjustmentsSetupFile>' then var1='<DefaultAdjustmentsSetupFile>'||"&dqdials"||'</DefaultAdjustmentsSetupFile>';
  	if substr(var1,1,32)='<PrepaymentAdjustmentsSetupFile>' then var1='<PrepaymentAdjustmentsSetupFile>'||"&ppdials"||'</PrepaymentAdjustmentsSetupFile>';
	run;
%end;

%if &modelid=2  %then %do;
	%modifyIRandHPI;
%end;
%else %do;
	data xml5; 
		set xml5;
		retain counter 0;
		if substr(var1,1,14)='<InterestRate>'	then counter=counter+1;

		if substr(var1,1,11)='<HpiOption>'		then var1='<HpiOption>'||"HistoricalValues"||'</HpiOption>';*new;
		if substr(var1,1,12)='<RateOption>'	and counter <>0	then var1='<RateOption>'||"HistoricalRatePaths"||'</RateOption>';*new;

	run;
%end;
/*proc print data=xml5;run;*/
 
%do i= 1 %to &maxpid;

	Data xml6(drop=startprocessing flag flagmodel flag1); 
		set xml5;
		retain startprocessing flag flagmodel flag1;
		if _n_=1 then do;startprocessing=0;flag=0;flagmodel=0;flag1=0;
		end;
		if substr(var1,1,7)='<Model>' and flagmodel=0 then do;
			var1='<Model>'||"AGENCY"||'</Model>';
				if &lientype=2 then do;
					var1='<Model>'||"ALTA"||'</Model>';
				end;
			flagmodel=1;
		end;

	if var1='<DataViews>' then startprocessing=1;
	else	
		if startprocessing=1 then do;
			var1='<DataView Name="'||"&filename.&i"||'_RM#csv">';
			startprocessing=2;
		end;
		else
		if startprocessing=2 then do;
		  startprocessing=3;
		end;
		else
		if startprocessing=3 then do;
		var1='<DataMember>'||"&filename.&i"||'_RM#csv</DataMember>';
		  startprocessing=4;
		end;
		else
		if startprocessing=4 then do;
		  var1='<DataAsOf>'||substr(left(&aod),1,6)||'</DataAsOf>';
		  startprocessing=5;
		end;

	if var1='<ElementType>Scenario</ElementType>' then flag=1;
	  else 
		if flag=1 then do;
		var1='<Name>'||"&job"||'</Name>';
		flag=0;
	   end;

	if var1='<ElementType>LoanData</ElementType>' then flag1=1;
	  else 
		if flag1=1 then do;
		var1='<Name>'||"&filename.&i"||'_RM#csv</Name>';
		flag1=0;
		end;
	 
	 if substr(var1,1,17)='<DirectoryOption>' then var1='<DirectoryOption>'||"Specified"||'</DirectoryOption>';
	 if substr(var1,1,11)='<Directory>' then var1='<Directory>'||"&woutd."||'</Directory>';

	run;

	/*
	data _null_; 
		set xml6;
		file "&outd./&projname..rmp" lrecl=1000;
		put var1;
		replace;
	run;
	*/
	
	/*
    x "cd &rm_folder.";
    x "processrmp.exe &outd./&projname..rmp &projname";
    */
	/*
	x "ssh windows; processrmp.exe &outd./&projname..rmp &projname";
	*/
	
	data _null_; 
		set xml6;
		file "&outd./&projname./&job./&job._&filename..rmp" lrecl=1000;
		put var1;
		replace;
	run;

%end;

/*
data _null_; 
	set xml6;
	file "&outd./&projname./&job./&job..rmp" lrecl=1000;
	put var1;
	replace;
run;
*/

%mend RM_autosimulate_agency;

**********************************************************************************************************************;
**********************************************************************************************************************;
