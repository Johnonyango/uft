'----------------------'
'-----Declaration------'
'----------------------'
Public testDir , testSuitControllerFile ,configSheet , controllerSheet , environmentSheet , testScript ,TCStatus , qtApp, test
Public iTCExecuted_1 , iStartTime_1 , iEndTime_1 , strMailTO_1 , strMailCC_1 , MyFile_1
Dim strURL_1 , strZipWithDateTimeStamp_1
Public reportingMode , attachmentMode , strSummaryReportFile , attachmentData , strSharepointLink 


On error resume next
'--------------------------------------------------------
'-------------------Clean up the process ----------------
'--------------------------------------------------------
Dim oShell : Set oShell = CreateObject("WScript.Shell")

'Kill prcocess 
'oShell.Run "taskkill /f /im excel.exe"
oShell.Run "taskkill /f /im uft.exe"
'oShell.Run "taskkill /f /im chrome.exe"

WScript.Sleep 3000

'---------------------------------------------------'
'------- Finding Path and Variable declaration------'
'---------------------------------------------------'
testDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
testSuitControllerFile = testDir & "\" & "Controller.xlsx"
tempFolder = CreateObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%")
ResultFolder =  "C:\ResultFolder.xls"
Set fso = CreateObject("Scripting.FileSystemObject")
strResultPath = testDir & "\TestResults\" &  "Execution_Summary_" & Month(Now) & "_" & Day(Now) & "_" & Year(Now) & "_" & Hour(Now) & "_" & Minute(Now) & "_" & Second(Now)
If (fso.FolderExists (strResultPath) = False) Then
		Set fFolder = fso.CreateFolder (strResultPath)
End If
Set fso= Nothing
	
set objExcel = CreateObject("Excel.Application")
objExcel.Application.DisplayAlerts = False
set objWorkbook=objExcel.workbooks.add()
objExcel.cells(1,1).value = strResultPath
objWorkbook.Saveas ResultFolder
objWorkbook.Close
objExcel.workbooks.close
objExcel.quit
set objExcel = nothing 

	
iPTCExecuted = 0
iPTCFailCount = 0
iPTCPassCount = 0

iTCExecuted = 0
iTCFailCount = 0
iTCPassCount = 0
'Dim qtApp			 'As QuickTest.Application Declare the Application object variable
Dim qtTest			 'As QuickTest.Test Declare a Test object variable
Dim qtResultsOpt  		' Declare a Run Results Options object variable	
Set qtApp = CreateObject("QuickTest.Application") 			' Create the Application object
qtApp.Launch 												' Start QuickTest
qtApp.Visible = True									' Make the QuickTest application visible
Set qtTest = qtApp.Test	


'-------------------------------------'
'------- Accessing Excel Controller Sheet -------'
'-------------------------------------'
Set objExcel = CreateObject("Excel.Application") 
objExcel.Application.DisplayAlerts = False
objExcel.Visible = True 
Set controllerFile = objExcel.Workbooks.Open( testSuitControllerFile ) 
Set controllerSheet = controllerFile.Sheets("Controller") 
rowCountController = controllerSheet.UsedRange.Rows.Count 
Set configSheet = controllerFile.Sheets("Config")
rowCountConfig = configSheet.UsedRange.Rows.Count
set intRow = 0
reportingMode = configSheet.cells(2,3).value
'attachmentMode = configSheet.cells(2,4).value
'strSharepointLink = configSheet.cells(2,5).value


'-----------------'
'---Timer Starts---'
'-----------------'
iStartTime = Now

'--------------------------------------------------'
'------- Running the Scripts From Controller-------'
'--------------------------------------------------'
For intRow = 2 to rowCountController
	If ucase(controllerSheet.cells(intRow,4).value) = "YES" Then
		testScript = controllerSheet.cells(intRow,3).value	

		'---------------------------'
		'----Execute Test Scripts---'
		'---------------------------'
		ExecuteTestScripts(testScript)		

	End If
	'-------To Avoid Server Unreachable error message--------'
Next


'----------------'
'---Timer Ends---'
'----------------'
iEndTime = now




'------------------------------------------------------------------'
'-------Call Function to Create Test Suite Summary html------------'
'------------------------------------------------------------------'
controllerFile.Saveas testSuitControllerFile
objExcel.Quit
WScript.Sleep 3000

CreateTestSuiteSummary()


'----------------------------------------'
'------------Releasing Objects-----------'
'----------------------------------------'

	Set controllerFile  		= Nothing 	' Release testSuitControllerFile Object
	Set controllerSheet 		= Nothing 	' Release the controller Sheet  object
	Set configSheet 			= Nothing 	' Release the config Sheet object
	Set objExcel				= Nothing
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}" & "!\\.\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * From Win32_Process")
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("EXCEL.EXE") OR LCase(objProcess.Name) = LCase("EXCEL.EXE *32") Then
       ' objProcess.Terminate()
        ' MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("WerFault.exe") OR LCase(objProcess.Name) = LCase("WerFault.exe *32") Then
        objProcess.Terminate()
        ' MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	
	
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}" & "!\\.\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * From Win32_Process")
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("EXCEL.EXE") OR LCase(objProcess.Name) = LCase("EXCEL.EXE *32") Then
       ' objProcess.Terminate()
        ' MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("WerFault.exe") OR LCase(objProcess.Name) = LCase("WerFault.exe *32") Then
        'objProcess.Terminate()
        ' MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	
	
	
	
set objFSO = CreateObject("Scripting.FileSystemObject")

if (objFSO.FileExists(ResultFolder)) then
   'objFSO.DeleteFile(ResultFolder) 
end if

	
'-----------------------------------------'
'------------Script END Notification------'
'-----------------------------------------'
Msgbox("Your Test Suite has been EXECUTED")
WScript.Quit





' ================================================================================================
'  NAME			: ExecuteTestScripts
'  DESCRIPTION 	  	: This invokes QTP, opens & executes the test. This would call functions to write the summary report & email the samel
'  PARAMETERS		: testScript - Test script name to be executed
'
' ================================================================================================

Public Sub ExecuteTestScripts(testScript)

	test = testDir  & "\" & "Scripts" & "\" & testScript
	qtApp.Open test, False 							' Open the test in read-only mode
	
	' If Test does not exist then log error and execute next script
	If (Err.Description <> "Cannot open test.") Then
		On Error Goto 0
		qtApp.Test.Settings.Launchers("Web").CloseOnExit = False
		
		Set qtLibraries = qtApp.Test.Settings.Resources.Libraries ' Get the libraries collection object
		qtLibraries.Add testDir & "\Library\CommonLib.vbs", 1 ' Add the library to the collection
		qtLibraries.Add testDir & "\Library\AppLib.vbs", 2 ' Add the library to the collection
		qtLibraries.Add testDir & "\Library\ReportLib.vbs", 3 ' Add the library to the collection
	    Wscript.sleep 1000		
		On error resume next
		
		qtApp.Test.Run, True
		Wscript.sleep 1000
		
		If Err.Number Then   
			WScript.Sleep 200   
			Err.Clear   
			qtApp.Test.Run , True    
			Counter = 0
			FLag = 0
			Do while Flag = 0 AND Counter < 5
				If Err.Number then   
					Err.Clear   
					qtApp.Test.Run , True  
					Counter = Counter + 1
					WScript.Sleep 200 					
				Else
				    Flag = 1
				End if			
			Loop

			WScript.Sleep 200
		End If
		
		iTCExecuted = iTCExecuted + 1
		iPTCExecuted = iPTCExecuted + 1
		sTCRunStatus = qtApp.Test.LastRunResults.Status		' Get Test Script Result Status
		'msgbox sTCRunStatus
	                
		
		'Set objContExcel = CreateObject("Excel.Application")
		'Set objWorkbook = objContExcel.Workbooks.Open(testSuitControllerFile)
		If (sTCRunStatus = "Failed") Then
			iTCFailCount = iTCFailCount + 1
			controllerSheet.cells(intRow,5).value = "FAIL"
			If UCASE(controllerSheet.cells(intRow,5).value) = "PASS" Then
				iPTCPassCount = iPTCPassCount + 1
			ElseIf UCASE(controllerSheet.cells(intRow,5).value) = "FAIL" Then
				iPTCFailCount = iPTCFailCount + 1
			End If
						
		ElseIf (sTCRunStatus = "Passed") Then
			iTCPassCount = iTCPassCount + 1
			controllerSheet.cells(intRow,5).value = "PASS"
 			If UCASE(controllerSheet.cells(intRow,5).value) = "PASS" Then
				iPTCPassCount = iPTCPassCount + 1
			ElseIf UCASE(controllerSheet.cells(intRow,5).value) = "FAIL" Then
				iPTCFailCount = iPTCFailCount + 1
			End If
		Else
			controllerSheet.Cells(intRow,5).Value = sTCRunStatus
		End If
		qtApp.Test.Close	' Close Test Script
	Else
		' Set objContExcel = CreateObject("Excel.Application")
		' Set objWorkbook = objContExcel.Workbooks.Open(testSuitControllerFile)
		iTCExecuted = iTCExecuted + 1
		iTCFailCount = iTCFailCount + 1
		controllerSheet.Cells(intRow, 5).Value = Err.Description & " " & test
		On Error Goto 0
		qtApp.Test.Close	' Close Test Script		
	End If
	'Release the allocated objects
	'Close the files
	qfile.Close
	Set qfile=nothing
	Set fso=nothing
	controllerSheet.Save
	' objWorkbook.Save	' Save Controller File
	' objWorkbook.Close '  Close the excel report
	' objContExcel.Quit					' Quit Excel Object
	' Set objContExcel = Nothing
	' Set objWorkbook = Nothing
	qtApp.Close
	qtApp.Quit
End Sub


' ================================================================================================
'  NAME			: CreateTestSuiteSummary
'  DESCRIPTION 	  	: This function is to create a test Suite summary report
'  PARAMETERS		: sControllerFile - test controller file
' ================================================================================================

Public Function CreateTestSuiteSummary ()


	Set App = CreateObject("QuickTest.Application")
	'strGblTestName = App.Test.Name
	Dim objNet
	' create a network object
	Set objNet = CreateObject("WScript.NetWork")
	' show the user name
	strGlbUserName = objNet.UserName 
	' show the computer name
	strGlbComputerName = objNet.ComputerName
	' show the domain name
	'strGlbUserDomain = objNet.UserDomain		
	' destroy the object
	Set objNet = Nothing 
	WScript.Sleep 3000
	filename = "\TestSuite_Execution_Summary.htm"
	strSummaryReportFile = strResultPath &   filename
	Set fso1 = CreateObject("Scripting.FileSystemObject")
	Set MyFile = fso1.CreateTextFile(strSummaryReportFile,True)
	Set objRepExcel = CreateObject("Excel.Application")
	Set objRepWorkbook = objRepExcel.Workbooks.Open(testSuitControllerFile)
    Set objRepControllerSheet = objRepExcel.Sheets("Controller")
	iRowNum = 2
	
	' WRITE HEADER
	'Pie Chart'
	MyFile.WriteLine("<html><head>  <script type='text/javascript' src='https://www.gstatic.com/charts/loader.js'></script>")
    MyFile.WriteLine("<script type='text/javascript'>")
    MyFile.WriteLine("  google.charts.load('current', {packages:['corechart']}); ")
    MyFile.WriteLine("  google.charts.setOnLoadCallback(drawChart); ")
    MyFile.WriteLine("  function drawChart() { ")
    MyFile.WriteLine("    var data = google.visualization.arrayToDataTable([ ")
    MyFile.WriteLine("      ['Status', 'No.'], ")
    MyFile.WriteLine("      ['Pass',     " & iTCPassCount & "],")
    MyFile.WriteLine("      ['Fail',      " & iTCFailCount & "], ")
   ' MyFile.WriteLine("      ['Un-Executed',  2], ")
   ' MyFile.WriteLine("      ['Blocked', 2],")
    MyFile.WriteLine("    ]); ")
    MyFile.WriteLine("    var options = { ")
    MyFile.WriteLine("      title: 'Test Summary', ")
    MyFile.WriteLine("      is3D: true, ")
    MyFile.WriteLine("    }; ")
    MyFile.WriteLine("    var chart = new google.visualization.PieChart(document.getElementById('piechart_3d')); ")
    MyFile.WriteLine("    chart.draw(data, options); }")
 
    MyFile.WriteLine("</script>  <title>Test Suite Summary Report</title></head>")
	MyFile.WriteLine("<body><div align='center'><center>")

	
	'Outer table'
	MyFile.WriteLine("<table border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' height='116'><tr><td width='70%'>")
	
	'Header
	MyFile.WriteLine("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' height='116'>")
	MyFile.WriteLine("<tr><td width='100%' colspan='2' bgcolor='#828385' height='36'>")
	MyFile.WriteLine("<p align='center'><font face='Verdana' size='5' color='#FFFFFF'>Test Suite Summary Report</font></td></tr>")
	'Date and Time of Execution
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Execution Date &amp; Time</font></b></td>")
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & FormatDateTime (Date, 1) & " " & FormatDateTime (Time, 0) & "</font></td></tr>")

	''''URL
	''MyFile.WriteLine("<tr><td width='19%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Test URL</font></b></td>")
	''MyFile.WriteLine("<td width='81%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>"& strURLtoLog &"</font></td></tr>")
	
	'User Name
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Executed By</font></b></td>")
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & ucase(strGlbUserName) & "</font></td></tr>")
	'Machine Name
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Executed Machine</font></b></td>")
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & strGlbComputerName & "</font></td></tr>")
	
	''Test Case Executed
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Test Case (s) Executed</font></b></td>")	
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'>" & iTCExecuted & "</td></tr>")
	
	''Test Case PASS
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Test Case (s)<font color='#05A251'>PASS</font></font></b></td>")
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & iTCPassCount & "</font></td></tr>")
	
	
	''Test Case FAIL
	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Test Case (s)<font color='#FF0000'>FAIL</font></font></b></td>")
	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & iTCFailCount & "</font></td></tr>")

		''Test Case PASS
	'	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Last Run Test Case (s)<font color='#05A251'>PASS</font></font></b></td>")
	'	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & iPTCPassCount & "</font></td></tr>")
	
	
	''Test Case FAIL
	'	MyFile.WriteLine("<tr><td width='30%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Last Run Test Case (s)<font color='#FF0000'>FAIL</font></font></b></td>")
	'	MyFile.WriteLine("<td width='70%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & iPTCFailCount & "</font></td></tr>")

	MyFile.WriteLine("</table></center></div>")
	MyFile.WriteLine("<p style='margin-left: 5'>&nbsp;</p> </td>")
	
	'Pie Chart'
	MyFile.Writeline("<td width='30%'><div id='piechart_3d' style='width: 500px; height: 300px;' align='Right'></div> </td></tr></table>")
	
	''WRITE TEST SCRIPT STATUS
	MyFile.WriteLine("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' height='89'>")
	MyFile.WriteLine("<td width='7%' height='25'align='center' bgcolor='#828385'><b><font face='Verdana' size='2'>Sl. No.</font></b></td>")
	MyFile.WriteLine("<td width='50%' height='29' align='center' bgcolor='#828385'><b><font face='Verdana' size='2'>Test Script Name</font></b></td>")
	MyFile.WriteLine("<td width='10%' height='29' align='center' bgcolor='#828385'><b><font face='Verdana' size='2'>Execution Status</font></b></td>")
	MyFile.WriteLine("<td width='10%' height='29' align='center' bgcolor='#828385'><b><font face='Verdana' size='2'>Environment</font></b></td></tr>")
		
	Do Until objRepControllerSheet.Cells(iRowNum,1).Value = ""
		If UCase(TRIM(objRepControllerSheet.Cells(iRowNum,4).Value)) = "YES" Then
			 testScript     = objRepControllerSheet.Cells(iRowNum, 3).Value
			 sPTCStatus      = objRepControllerSheet.Cells(iRowNum, 5).Value
			 sTCStatus      = objRepControllerSheet.Cells(iRowNum, 6).Value
			'Sl No
			
			MyFile.WriteLine("<td width='7%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & iRowNum - 1 & "</font></td>")
			' TEST SCRIPT NAME
			MyFile.WriteLine("<td width='50%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>" & testScript & "</font></td>")
			' PREVIOUS STATUS
			If UCase(sPTCStatus) = "" Then
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2'> &nbsp; Not Executed </font></td>")
			ElseIf (UCase(sPTCStatus) = "FAIL") Then 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2' color='#FF0000'>&nbsp;" & sPTCStatus & "</font></td>")
			ElseIf (UCase(sPTCStatus) = "PASS") Then 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2' color='#05A251'>&nbsp;" & sPTCStatus & "</font></td>")
			Else 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2'>&nbsp;" & sPTCStatus & "</font></td>")
			End If
			' STATUS
			If UCase(sTCStatus) = "" Then
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2'> &nbsp; Not Executed </font></td></tr>")
			ElseIf (UCase(sTCStatus) = "FAIL") Then 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2' color='#FF0000'>&nbsp;" & sTCStatus & "</font></td></tr>")
			ElseIf (UCase(sTCStatus) = "PASS") Then 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2' color='#05A251'>&nbsp;" & sTCStatus & "</font></td></tr>")
			Else 
				MyFile.WriteLine("<td width='10%' height='25'><p style='margin-center: 5' align='center'><font face='Verdana' size='2'>&nbsp;" & sTCStatus & "</font></td></tr>")
			End If
		End If
		iRowNum = iRowNum + 1	' Increment Excel Row count	
	Loop
		
	MyFile.WriteLine("</table>")
	MyFile.WriteLine("<p>&nbsp;</p>")
	MyFile.WriteLine("<table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='36%' align='Left'>")
	''WRITE START / END TIMES
	''START TIME	
	MyFile.WriteLine("<tr><td width='25%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>Start Time</font></b></td>")
	MyFile.WriteLine("<td width='75%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>&nbsp;" & iStartTime & "</font></td></tr>")
	
	''END TIME
	MyFile.WriteLine("<tr><td width='25%' height='25'><p style='margin-left: 5'><b><font face='Verdana' size='2'>End Time</font></b></td>")
	MyFile.WriteLine("<td width='75%' height='25'><p style='margin-left: 5'><font face='Verdana' size='2'>&nbsp;" & iEndTime &"</font></td></tr>")
	MyFile.WriteLine("</table></body></html>")
	objRepWorkbook.Close
	objRepExcel.Quit      
	Set objRepWorkbook = Nothing	' Quit Excel Object
	Set objRepExcel = Nothing
	
End Function
