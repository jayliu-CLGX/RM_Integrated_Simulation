@echo off

::Run complete simulation (default)
::Ex, to run complete simualtion as set up in sas code
::	cscript.exe rm_sim_spt.vbs W:\Users\JayLiu\Projects\Agency_2018\MPT\Code\MPT_short_term.sas
::	cscript.exe rm_sim_spt.vbs C:\JayC\Projects\Agency_2018\MPT\Code\MPT_short_term.sas

::Run individual component only - V1.1 and after
::1/2/3 for data/simulation/report only , 0 or missing for complete run
::Ex, to run simulation only
::	cscript.exe rm_sim_spt.vbs W:\Users\JayLiu\Projects\Agency_2018\MPT\Code\MPT_short_term.sas 2
::cscript.exe rm_sim_spt.vbs W:\Users\JayLiu\Projects\Agency_2018\MPT\Code\MPT_short_term.sas 3
cscript.exe rm_sim_spt.vbs C:\JayC\Projects\Agency_2018\MPT\MPT_short_term.sas 1