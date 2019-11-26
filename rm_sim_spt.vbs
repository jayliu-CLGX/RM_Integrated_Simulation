'*********************************************************************************************************************
'*********************************************************************************************************************
'RiskModel Integrated Simulation
'Windows VB script to integrate SAS Grid (via SAS EG) and Windows application for automation
'Version 1.1
'Update
'	--- Jay Liu/20191121/v1.1: add flexibility to run for specific component, data/simulation/report
'	--- Jay Liu/20191110/v1.0: integrated RiskModel simulation using SAS EG (SAS Grid) and RiskModel (Windows)
'********************************************************************************************************************
Option Explicit

Dim sasfile		' Simulation SAS file name

If WScript.Arguments.Count = 0 Then
	WScript.Echo "ERROR: Expecting the full path name of a SAS simulation file"
	WScript.Quit -1
Else
	WScript.Echo "RiskModel Simulation"
	WScript.Echo "Simulation code: " & WScript.Arguments.Item(0)
	WScript.Echo ""
	If WScript.Arguments.Count = 1 Then
		WScript.Echo "Run Complete Simulation: data, simulation, reports"
		WScript.Echo
		WScript.Echo "Step 1: Preparing data... "
		sasfile = WScript.Arguments.Item(0)
		call SASEG_Data(sasfile, "dat")
		WScript.Echo

		WScript.Echo "Step 2: Running Simulation... "
		call RM_Simulation()
		WScript.Echo

		WScript.Echo "Step 3: Generating reports... "
		WScript.Echo
		call SASEG_Data(sasfile, "rpt")
	ElseIf WScript.Arguments.Count = 2 Then
		If WScript.Arguments.Item(1) = 1 Then
			WScript.Echo "Step 1 only: Preparing data... "
			sasfile = WScript.Arguments.Item(0)
			call SASEG_Data(sasfile, "dat")
			WScript.Echo
		ElseIf WScript.Arguments.Item(1) = 2 Then
			WScript.Echo "Step 2 only: Running Simulation... "
			call RM_Simulation()
			WScript.Echo
		ElseIf WScript.Arguments.Item(1) = 3 Then
			WScript.Echo "Step 3 only: Generating reports... "
			call SASEG_Data(sasfile, "rpt")
			WScript.Echo
		End If
	End If
End If

'*********************************************************************************************************************
'SAS sub
Sub SASEG_Data(sasfile, act)

	Dim Application ' Application
	Dim Project     ' Project object
	Dim sasProgram  ' Code object (SAS program)
	Dim n           ' Counter

	Set Application = CreateObject("SASEGObjectModel.Application.7.1")
	' Set to your metadata profile name, or "Null Provider" for just Local server
	Application.SetActiveProfile ("Titan")
	' Create a new Project
	Set Project = Application.New
	' add a new code object to the Project
	Set sasProgram = Project.CodeCollection.Add

	' Set the results types, overriding Application defaults
	sasProgram.UseApplicationOptions = False
	sasProgram.GenListing = True
	sasProgram.GenSasReport = False

	' Set the server (by Name) and text for the code
	sasProgram.Server = "SASApp"
	' Create the SAS program to run
	'sasProgram.Text = sasProgram.text & "data work.cars; set sashelp.cars; if ranuni(0)<0.85; run;"
	'sasProgram.Text = sasProgram.text & " proc means; run;"
	sasProgram.Text = sasProgram.text & getSAScode(WScript.Arguments.Item(0))
	sasProgram.text = sasProgram.text & "%let act=" & act & ";"
	'sasProgram.text = sasProgram.text & "%put act=" & act & ";"
	sasProgram.Text = sasProgram.text & "%mpt_test;"

	' Run the code
	sasProgram.Run
	'Return=(sasProgram.Run, 1, true)
	'WScript.Echo "SAS Program return: " & Return

	' Save the log file to LOCAL disk
	sasProgram.Log.SaveAs getCurrentDirectory & "\" & WScript.ScriptName & ".log"

	' Save all output data as local Excel files
	For n = 0 To (sasProgram.OutputDatasets.Count - 1)
		Dim dataName
		dataName = sasProgram.OutputDatasets.Item(n).Name
		'Wscript.Echo dataName
		'sasProgram.OutputDatasets.Item(n).SaveAs getCurrentDirectory & "\" & dataName & ".xlsx"
		If dataName = "SIMCONFIG" Then
			Dim configfile
			configfile = getCurrentDirectory & "\" & dataName & ".csv"
			Dim fso
			Set fso = CreateObject("Scripting.FileSystemObject")
			If fso.FileExists(configfile) Then
				fso.DeleteFile configfile
				'WScript.Echo "Simulation configfile exists. Deleted"
				'WScript.Sleep 10000
			End If
			sasProgram.OutputDatasets.Item(n).SaveAs configfile
			'WScript.Echo "New simulation configfile created!"
		End if
	Next

	' Filter through the results and save just the LISTING type
	For n = 0 To (sasProgram.Results.Count - 1)
		' Listing type is 7
		If sasProgram.Results.Item(n).Type = 7 Then
		' Save the listing file to LOCAL disk
		sasProgram.Results.Item(n).SaveAs getCurrentDirectory & "\" & WScript.ScriptName & ".lst"
		End If
	Next

	Application.Quit
	' function to fetch the current directory

End Sub 

'*********************************************************************************************************************
'Simulation sub
Sub RM_Simulation()
	Dim simconfigfile
	Dim simconfig
	Dim rmfolder
	Dim rmpfolder
	Dim rmpfolder_win
	Dim conf
	Dim user
	Dim projname
	Dim rmname
	Dim rmpname
	Dim Return
	
	simconfigfile = getCurrentDirectory & "\SIMCONFIG.csv"
	'Wscript.Echo "Simulation config file is " & simconfigfile
	set simconfig = getArrayFromCsv(simconfigfile)

	Dim oShell
	Set oShell = WScript.CreateObject ("WSCript.shell")
	
	For Each conf In simconfig
		user = split(conf,",")
		'WScript.Echo "name is: " & user(0) & " ; " & "value is: " & user(1)  
		If user(0) = "rmfolder" Then
			rmfolder = user(1)
			'WScript.Echo "RM Folder is: " & rmfolder
			rmname = rmfolder & "\processrmp.exe"
			'WScript.Echo "RM Name is: " & rmname
		ElseIf user(0) = "rmpfolder_win" Then
			rmpfolder_win = user(1)
			'WScript.Echo "Simulation Folder is: " & rmpfolder_win
		ElseIf user(0) = "projname" Then
			projname = user(1)
			'WScript.Echo "Projname is: " & projname
		ElseIf user(0) = "rmpfile" Then
			rmpname = rmpfolder_win & "\" & user(1) & ".rmp"
			'WScript.Echo "RMP Name is: " & rmpname
			'WScript.Echo "	Current file: " & user(1) & ".rmp"
			Wscript.Stdout.Write ("	Current file: " & user(1) & ".rmp ....... ")
			oShell.CurrentDirectory = rmfolder
	'		WScript.Echo oShell.CurrentDirectory
			Dim simcmd
			simcmd= "processrmp.exe" & " " & rmpname & " " & projname
			Return = oShell.Run(simcmd, 1, true)
			If Return = 0 Then
				'WScript.Echo "sucessful!"
				Wscript.Stdout.Write ("successful!" & vbCrLf)
			Else
				Wscript.Stdout.Write ("oops, there might be a problem!" & vbCrLf)
			End If
			'Set oShell = Nothing
		End If				
	Next
	WScript.Echo

	'This also works
	'Dim simcmd
	'simcmd="""" & rmname & """" & " " & rmpname & " " & projname
	'WScript.Echo simcmd
	'Return=oShell.Run(simcmd, 1, true)
	'WScript.Echo Return
	
	Set oShell = Nothing
	
End Sub

'*********************************************************************************************************************
' Supporting subs
Function getCurrentDirectory()
    Dim oFSO
    Set oFSO = CreateObject("Scripting.FileSystemObject")
    getCurrentDirectory = oFSO.GetParentFolderName(WScript.ScriptFullName)
End Function

Function getSAScode(myfile)
	'Read RM SAS Simualation code

	Const ForReading = 1
	Dim objFSO
	Dim objTextFile
	Dim strText

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	'Set objTextFile = objFSO.OpenTextFile("C:\JayC\Projects\Agency_2018\MPT\MPT_short_term_test.sas", ForReading)
	Set objTextFile = objFSO.OpenTextFile(myfile, ForReading)
	strText = objTextFile.ReadAll

	objTextFile.Close
	
	'Print
	'Dim arrComputers
	'Dim strComputer
	'arrComputers = Split(strText, vbCrLf)
	'For Each strComputer in arrComputers
	'	Wscript.Echo strComputer
	'Next

	getSAScode = strText
	
End Function

'Function to read file and load into an array
Function getArrayFromCsv(filepath)    

	Const ForReading = 1    ' Declare constant for reading for more clarity
	Dim objFSO
	Dim inputFile
	Dim userArrayList
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")	
	Set inputFile = objFSO.OpenTextFile(filepath, ForReading, True) ' Set inputFile as file to be read from
	
	Set userArrayList = CreateObject("System.Collections.ArrayList")
	
	Dim strNextLine
	Do Until inputFile.AtEndOfStream 
		strNextLine = inputFile.Readline 
		userArrayList.add strNextLine
	Loop 
	
	inputFile.close
	
	set getArrayFromCsv = userArrayList
	
End Function

'Check if file exist;
Function FileExists(FilePath)
	Dim fso
	Set fso = CreateObject("Scripting.FileSystemObject")
	If fso.FileExists(FilePath) Then
		FileExists=CBool(1)
	Else
		FileExists=CBool(0)
	End If
End Function
'*********************************************************************************************************************
'*********************************************************************************************************************