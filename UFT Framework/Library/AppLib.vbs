' ***********************************************************************************************
'
' 						A P P L I C A T I O N      L I B R A  R Y  
'
' ***********************************************************************************************

' ================================================================================================
'  NAME 	: testCleanUp
'  DESCRIPTION 	: This function is used to write the summary part of the report & close all teh browsers.
'  PARAMETERS	:  
' ================================================================================================

Public randomUserName, randomSchemeName, skipFailure, randomBankName
skipFailure = False
strMember_Onboarding_ExcelFilePath = "C:\Users\Administrator\Documents\UftTemplates\UftTemplates\MEMBER_ONBOARDING TEMPLATE.xls"
strMemberExcelFilePath = "C:\Users\Administrator\Documents\UftTemplates\UftTemplates\BatchDistricts.xlsx"
strPathToTemplate = "C:\Users\Administrator\Documents\UftTemplates\UftTemplates\BatchTraditionalAuthority.xlsx"
strMemberEndorseTemplatFilePath = "C:\Users\Administrator\Documents\UftTemplates\UftTemplates\NEW MEMBER UPDATE TEMPLATE.xls"
'=================================================================================================
Public Function testCleanUp()
	'systemutil.CloseProcessByName("FIREFOX.EXE")
	systemutil.CloseProcessByName("IEXPLORE.EXE")
	systemutil.CloseProcessByName("CHROME.EXE")
	'systemutil.CloseProcessByName("EXCEL.EXE")
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}" & "!\\.\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * From Win32_Process")
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("EXCEL.EXE") OR LCase(objProcess.Name) = LCase("EXCEL.EXE *32") Then
			'objProcess.Terminate()
			'MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	TestCaseExecutiveSummary ()
End Function




' ================================================================================================
'  NAME			    : invokeBrowser
'  DESCRIPTION 	  	: This function delete cookies, close previously open browsers and opens the app url
'  PARAMETERS		: 
' ================================================================================================
Function invokeBrowser()
	WebUtil.DeleteCookies 	'Delete cookies
	systemutil.CloseProcessByName("iexplore.exe")
	systemutil.CloseProcessByName("chrome.exe")
	systemutil.CloseProcessByName("firefox.exe")
													
													
	Dim mode_Maximized, mode_Minimized
	mode_Maximized = 3 'Open in maximized mode
	mode_Minimized = 2 'Open in minimized mode
	
	
	If UCASE(strBrowser) = "IE" Then						'open Browser according to XLS sheet
		SystemUtil.Run "iexplore.exe", strURL , , ,mode_Maximized 
	End If
	
	If UCASE(strBrowser) = "CHROME" Then
		SystemUtil.Run "chrome.exe", strURL , , ,mode_Maximized
	End If
	
	If UCASE(strBrowser) = "FIREFOX" Then
		SystemUtil.Run "firefox,.exe", strURL , , ,mode_Maximized
	End If
	
	wait(5)
	Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Sync
	If Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Exist(5) Then
		invokeBrowser = true
	Else
		invokeBrowser = false
	End If
End Function

Function getEnvUrl()
	strFrameworkPath = getFrameworkpath()
	strTestDataPath = strFrameworkPath(0) & "UFT Framework\Controller.xlsx"
	DataTable.AddSheet "Environment"
	DataTable.ImportSheet strTestDataPath, "Environment", "Environment"
	strURL = Trim(DataTable.GetSheet("Environment").GetParameter("AppURL").Value)
	getEnvUrl = strURL
End Function

Function fundMaster_login()
	strFrameworkPath = getFrameworkpath()
	strTestDataPath = strFrameworkPath(0) & "UFT Framework\TestData\CommonTestData.xlsx"
	DataTable.AddSheet "LogIn"
	DataTable.ImportSheet strTestDataPath, "LogIn", "LogIn"
	dtUsername = Trim(DataTable.GetSheet("LogIn").GetParameter("UserName").Value)
	dtPassword= Trim( DataTable.GetSheet("LogIn").GetParameter("Password").Value)
	sUsername = dtUsername
	sPassword = dtPassword
	strAppUrl = getEnvUrl()
	Browser("brwFundMaster").Maximize
	Browser("brwFundMaster").Navigate(strAppUrl)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If Browser("brwFundMaster").Page("pgFundMaster").Exist(10) Then
		Browser("brwFundMaster").Page("pgFundMaster").WebEdit("txtUserName").Set sUsername
		Browser("brwFundMaster").Page("pgFundMaster").WebEdit("txtPassword").Set sPassword
		Browser("brwFundMaster").Page("pgFundMaster").WebElement("welLoginButton").Click
		Browser("brwFundMaster").Page("pgFundMaster").Sync
		wait 2
		Reporter.ReportEvent micPass,1 ,"Login page appeared, credentials entered"
		LogResult micPass , "Login Page Should Appear" , "Login Page appeared Successfully"
	Else
		Reporter.ReportEvent micFail, "Login Page Should Appear" ,"Login page did NOT Appeared"
    		LogResult micFail , "Login Page Should Appear" , "Login page did NOT Appeared"
    		testCleanUp()
 		ExitTest
	End If
End Function

Public Function saveForm()
	Set saveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	Call objectExistanceCheckAndClick(saveBatch,"Save Button")
End Function

Public Function refreshPage()
	Set elmRefreshButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRefreshButton")
	Call objectExistanceCheckAndClick(elmRefreshButton,"Refresh Button")
End Function
'================================================================================================
'Function Name		  :	clickAndNavigate
'Function Description : This function is used to Click on the required object and then verify the required navigation page on a given web page											
'Parameters	          : strClickObjName - 			Name of the Object to Click (String type)
'  				  		strPageName - 				Name Of the Page we are getting navigated (String type)
'				  		objToClick - 				Object To Click 
'				  		objChkAfterNavigation - 	Object Existance to be Validated After Navigation
' ================================================================================================
Function clickAndNavigate(strPageName,strClickObjName,objToClick,objChkAfterNavigation)

	If objToClick.Exist(5) Then
		objToClick.Click
		If objChkAfterNavigation.Exist(5) Then
			LogResult micPass, "User should be navigated to " & strPageName & " page ", "User navigated to " & strPageName & " page"
		Else
			LogResult micFail, "User should be navigated to " & strPageName & " page", "User not navigated to " & strPageName & "page" & VbcrLf & " - Exit test execution"
			testCleanUp()
			ExitTest
		End if	
	Else
		LogResult micFail, strClickObjName & " is not available", "User not navigated to " & strPageName & " page" & VbcrLf & " -Test Execution Terminating"
		testCleanUp()
		ExitTest
	End If
	
	Set strPageName = Nothing
	Set strClickObjName = Nothing
	Set objToClick = Nothing
	Set objChkAfterNavigation = Nothing

End Function





' ================================================================================================
'  NAME         : objectExistanceCheck
'  DESCRIPTION  : This function is used to check the existance of a Object in a Page                                                                                                    
'  PARAMETERS   : objPage - Page Object, 
'				  objObject - Web Object 
'				  strPageName - Logical Display Name of the Page
'				  strObjectName - Logical Display Name of the Object
' ================================================================================================
Public Function objectExistanceCheckAndClick(objObject , strObjectName)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(10) Then
	       'Setting.WebPackage("ReplayType") = 2
		objObject.highlight()
		objObject.click()
		'Setting.WebPackage("ReplayType") = 1
		LogResult micpass , " Click on " & UCASE(strObjectName) & "." , " Clicked on  " & UCASE(strObjectName) & " Successfully"
	Else
		LogResult micFail ,  " Click on " & UCASE(strObjectName) & "." , UCASE(strObjectName) & " Not EXIST"
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function
'Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("elmFinancialPeriodsCheckbox").Highlight

Public Function objectExistanceCheckAndHoover(objObject , strObjectName)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(10) Then
	       'Setting.WebPackage("ReplayType") = 2
		objObject.highlight()
		objObject.HoverTap()
		'Setting.WebPackage("ReplayType") = 1
		LogResult micpass , " Click on " & UCASE(strObjectName) & "." , " Clicked on  " & UCASE(strObjectName) & " Successfully"
	Else
		LogResult micFail ,  " Click on " & UCASE(strObjectName) & "." , UCASE(strObjectName) & " Not EXIST"
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function

Public Function clickOnCheckBox(objObject , strObjectName)
	       Setting.WebPackage("ReplayType") = 2
		objObject.highlight()
		objObject.click()
		Setting.WebPackage("ReplayType") = 1
		LogResult micpass , " Click on " & UCASE(strObjectName) & "." , " Clicked on  " & UCASE(strObjectName) & " Successfully"
End Function

Public Function objectExistanceCheckAndDoubleClick(objObject , strObjectName)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(10) Then
		objObject.highlight()
		objObject.doubleClick()
		LogResult micpass , " Click on " & UCASE(strObjectName) & "." , " Clicked on  " & UCASE(strObjectName) & " Successfully"
	Else
		LogResult micFail ,  " Click on " & UCASE(strObjectName) & "." , UCASE(strObjectName) & " Not EXIST"
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function

Public Function verifyObjectExist(objObject , strMsg)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(3) Then
		objObject.highlight()
		LogResult micpass , " Verify  " & strMsg ,  " Verified  " & strMsg & "  exist Successfully"
	Else
		LogResult micFail ,  " Verify  " & strMsg , " Verified  " & strMsg & "   not exist"
		If skipFailure  <> true Then
			ExitTest
		End If
	End If
End Function

Public Function clickOnObjectIfExist(objObject , strMsg)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(10) Then
		objObject.highlight()
		objObject.click()
		LogResult micpass , " Verify  " & strMsg ,  " Verified  " & strMsg & "  exist Successfully"
		LogResult micpass , " Click on " & UCASE(strObjectName) & "." , " Clicked on  " & UCASE(strObjectName) & " Successfully"
	End  If	
End Function

Public Function verifyObjectNotExist(objObject , strMsg)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(3) Then
		objObject.highlight()
		LogResult micFail ,  " Verify  " & strMsg , " Verified  " & strMsg & "    exist"	
	Else
		LogResult micpass , " Verify  " & strMsg ,  " Verified  " & strMsg & " Not  exist "
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function


Public Function objectExistanceCheckAndEnter(objObject , strObjectName, strValue)
	 Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(10) Then
		objObject.highlight()
		objObject.set strValue
		LogResult micpass , " Enter " & strValue & "." , " Entered  " & UCASE(strValue) & " Successfully"
	Else
		LogResult micFail ,  " Click on " & UCASE(strObjectName) & "." , UCASE(strObjectName) & " Not EXIST"
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function


' ================================================================================================
'  NAME         : getExcelDataObject
'  DESCRIPTION  : This function is used to get the excel object of the Test Case itself.                                                                                                
'  PARAMETERS   : sheetName - Data Object
' ================================================================================================
Public Function getExcelDataObject(strSheetName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	strLoginDataPath = strTestDataPath & Environment.Value("TestName") & ".xlsx"
	Set dataWorkbook = objExcel.Workbooks.Open( strLoginDataPath ) 
	Set excelDataObject = dataWorkbook.Sheets(strSheetName)
	Set getExcelDataObject = excelDataObject
End Function

Public Function gotoMemberImportPage()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	set objEleImportMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welImportMembers")
       set objEleMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       Call objectExistanceCheckAndClick(objEleMemberRegister,"Member Register")
       Call objectExistanceCheckAndClick(objEleImportMember,"Import Member")
End Function


Public Function gotoMemberPage()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
       set objEleMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       Call objectExistanceCheckAndClick(objEleMemberRegister,"Member Register")
End Function

Public Function gotoContributeNewBatchPage()
	set objContributeNewBatch = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welNew Batch")
       set objEleMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       Call objectExistanceCheckAndClick(objEleMemberRegister,"Member Register")
       Call objectExistanceCheckAndClick(objContributeNewBatch,"Contribute -> New Batch")
End Function

Public Function uploadMemberExcelFile()
	Call updateTemplateForMemberOboarding()
	call browserAndUpload(strMember_Onboarding_ExcelFilePath)
	Set chkBox01 =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set btnSaveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	Set elmSuccessMsg = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessMsg")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	wait 10
	Call objectExistanceCheckAndClick(chkBox01, "Check box")
	Call objectExistanceCheckAndClick(btnSaveBatch, "Save")
	Call objectExistanceCheckAndClick(elmSuccessMsg, "Success Message")
	Call objectExistanceCheckAndClick(btnClose, "Close")
End Function

Public Function updateTemplateForMemberOboarding()
	Call updateExcel( strMember_Onboarding_ExcelFilePath,11,"" ,8)
	Call updateExcel( strMember_Onboarding_ExcelFilePath,14,"T_" ,8)
	Call updateExcel( strMember_Onboarding_ExcelFilePath,2,"Name_" ,8)
End Function

Public Function uploadAddBatchScheduleExcelFile()
	strTempleFilePath = "C:\Users\Administrator\Documents\UftTemplates\UftTemplates\NEW CONTRIBUTION TEMPLATE.xls"
	Set tblContribution = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tblContribution")
	Set chkBox01 =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set elmApplyThisSheet = Browser("brwFundMaster").Page("pgFundMaster").WebElement("sheetExcel-btnInnerEl")
	Set tblContributionData = Browser("brwFundMaster").Page("pgFundMaster").WebTable("batchcontributionuploadgridvie")
	Set chkBox02 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox02")
	Set btnSaveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	Set elmSuccessMsg = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessMsg")
	Call browserAndUpload(strTempleFilePath)
'	Call verifyObjectExist(tblContribution," Contribution uploaded table")
	Call objectExistanceCheckAndClick(chkBox01, "Check box")
	Call objectExistanceCheckAndClick(elmApplyThisSheet, "Apply to this Sheet")
	Call verifyObjectExist(tblContributionData," Contribution  table")
	Call objectExistanceCheckAndClick(chkBox02, "Check box")
	Call objectExistanceCheckAndClick(btnSaveBatch, "Save Batch")
	Call objectExistanceCheckAndClick(elmSuccessMsg, "Success Message")

End Function

Public  Function browserAndUpload(strFilePath)
	set objBtnBrowse = Browser("brwFundMaster").Page("pgFundMaster").WebFile("welBrowse_FileUpload")
	set objBtnOpen	=	Window("FilePicker").Dialog("Open").WinButton("Open")
	set objtxtEdit = Window("FilePicker").Dialog("Open").WinEdit("File name:")
	Set btnUpload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUpload")
      	Call objectExistanceCheckAndClick(objBtnBrowse,"Browse File")
      	Call clickOnUpload()
       Call objectExistanceCheckAndEnter(objtxtEdit,"File path",strFilePath )
       Call objectExistanceCheckAndClick(objBtnOpen,"Open File")
       Call objectExistanceCheckAndClick(btnUpload,"Upload button")
End Function

Public Function clickOnUpload()
	set objBtnBrowse = Browser("brwFundMaster").Page("pgFundMaster").WebFile("welBrowse_FileUpload")
	Setting.WebPackage("ReplayType") = 2
	objBtnBrowse.Click
	wait 1
	Setting.WebPackage("ReplayType") = 1
End Function

Public Function fillBatchDetails()
	strContrValue =  "Normal Contributions"
	strCostCenter = "QA Systech Sponsor Cost Center"
	strSponsorName  = "QA Systech Sponsor"
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	set edtContrType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.type")
	Set elmDatePicker = Browser("brwFundMaster").Page("pgFundMaster").WebElement("datePicker")
	Set elmTodayDate = Browser("brwFundMaster").Page("pgFundMaster").WebElement("datePickerToday")
	set edtDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.date")
	set edtSponsorName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.sponsorId")
	set edtCostCenter = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.companyId")
	set edtMonth = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.month")
	set edtYear = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("batch.year")
	set btnAddBatchSchedule = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnAddBatchSchedule")
	Call objectExistanceCheckAndEnter(edtContrType,"Contribution Type",strContrValue )
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	'Call objectExistanceCheckAndClick(elmDatePicker,"Date Picker")
	'Call objectExistanceCheckAndClick(elmTodayDate,"Today's date")
	Call objectExistanceCheckAndEnter(edtDate,"11/16/2021","11/16/2021")
	Call objectExistanceCheckAndEnter(edtSponsorName,"Sponsor name",strSponsorName )
	Call objectExistanceCheckAndEnter(edtCostCenter,"Cost Center",strCostCenter )
	Call objectExistanceCheckAndEnter(edtMonth,"Month","May" )
	Call objectExistanceCheckAndEnter(edtYear,"Year","2023" )
	wait 3
	Call clickOnObjectIfExist(btnPopupOk,"Popup")
	wait 3
	Call objectExistanceCheckAndClick(btnAddBatchSchedule, "Add batch Schedule")
End Function

Public Function gotoAdministrativeProfilePermissionPage()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set eleProfilePermission  = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfilePermissions")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(eleProfilePermission, "Add Profile Permissions")
End Function

Public Function gotoSchemePage()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	Set elmSchemeSetup = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeSetup")
	Set elmScheme = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmScheme")
       Call objectExistanceCheckAndClick(elmSchemeSetup, "SchemeSetup")
       Call objectExistanceCheckAndClick(elmScheme, "Scheme")
End Function

Public Function gotoApproveScheme()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	Set elmApproveSchemes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmApproveSchemes")
	Set elmSchemeApproval = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeApproval")
       Call objectExistanceCheckAndClick(elmSchemeApproval, "elmSchemeApproval")
       Call objectExistanceCheckAndClick(elmApproveSchemes, "elmApproveSchemes")
End Function


Public Function verifyAdministrativeProfilePermissionFilters()
       Set edtSelectModule = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtSelectModule")
	Set edtSelectProfile = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtSelectProfile")
	Set btnFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
	Set tableHeader = Browser("brwFundMaster").Page("pgFundMaster").WebTable("tableHeader")
	Set tableFooter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tableFooter")
	Set tableResults = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tableResults")
	Call objectExistanceCheckAndEnter(edtSelectProfile,"Profile type","System Administrators")
	Call objectExistanceCheckAndEnter(edtSelectModule,"Profile module", "Scheme Setup")
	Call objectExistanceCheckAndClick(btnFilter, "Fillter button")
	Call verifyObjectExist(tableHeader, "Result table header ")
	Call verifyObjectExist(tableResults, "Result table Body ")
	Call verifyObjectExist(tableFooter, "Result table footer ")
End Function


Public Function verifyProfileEnabled()
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
       Set btnEnable = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnEnable")
       Set eleMsgProfilePermissionsEnabled = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleMsgProfilePermissionsEnabled")
       Set btnFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
       Set elmProfileEnabledYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileEnabledYes")
      ' Setting.WebPackage("ReplayType") = 2
      ' Call objectExistanceCheckAndClick(elmProfileChkbx, "Check box")
      ' Setting.WebPackage("ReplayType") = 1
       Call objectExistanceCheckAndClick(btnEnable, "Enable Button")
       Call verifyObjectExist(eleMsgProfilePermissionsEnabled, "Profile Permissions Enabled")
       Call objectExistanceCheckAndClick(btnFilter, "Fillter button")
       Call verifyObjectExist(elmProfileEnabledYes, "Profile enabled - Yes")
End Function


Public Function verifyProfileDisabled()
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
       Set btnDisable = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnDisable")
       Set eleMsgProfilePermissionsDisabled = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleMsgProfilePermissionsDisabled")
       Set btnFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
       Set elmProfileEnabledNo = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileEnabledNo")
       Setting.WebPackage("ReplayType") = 2
       Call objectExistanceCheckAndClick(elmProfileChkbx, "Check box")
       Setting.WebPackage("ReplayType") = 1
       Call objectExistanceCheckAndClick(btnDisable, "Disable Button")
       Call verifyObjectExist(eleMsgProfilePermissionsDisabled, "Profile Permissions Disabled")
       Call objectExistanceCheckAndClick(btnFilter, "Fillter button")
       Call verifyObjectExist(elmProfileEnabledNo, "Profile enabled - No")
End Function


Public Function verifyInheritPermissions()
	Set eleInheritPermissions = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleInheritPermissions")
	Set edtInheritFromProfileId = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtInheritFromProfileId")
	Set btnProceed= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnProceed")
	Set eleMsgUserSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleMsgUserSavedSuccessfully")
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
	' Setting.WebPackage("ReplayType") = 2
      ' Call objectExistanceCheckAndClick(elmProfileChkbx, "Check box")
      ' Setting.WebPackage("ReplayType") = 1
	Call objectExistanceCheckAndClick(eleInheritPermissions, "Inherit Permissions button")
	Call objectExistanceCheckAndEnter(edtInheritFromProfileId, "Profile ID", "Workflow")
	Call objectExistanceCheckAndClick(btnProceed, "Procced button")
	Call verifyObjectExist(eleMsgUserSavedSuccessfully, "Msg User Saved Successfully")
End Function

Public Function verifyInheritRollbackPermissions()
	Set eleRollbackInheritedPermissions = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleRollbackInheritedPermissions")
	Set edtInheritFromProfileId = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtInheritFromProfileId")
	Set btnProceed= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnProceed")
	Set eleMsgUserSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleMsgUserSavedSuccessfully")
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
	' Setting.WebPackage("ReplayType") = 2
       'Call objectExistanceCheckAndClick(elmProfileChkbx, "Check box")
       'Setting.WebPackage("ReplayType") = 1
	Call objectExistanceCheckAndClick(eleRollbackInheritedPermissions, "Rollback Inherited Permissions button")
	Call objectExistanceCheckAndEnter(edtInheritFromProfileId, "Profile ID", "Workflow")
	Call objectExistanceCheckAndClick(btnProceed, "Procced button")
	Call verifyObjectExist(eleMsgUserSavedSuccessfully, "Msg User Saved Successfully")
End Function


Public Function gotoAdministrativePasswordPolicySetting()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set elePasswordPolicySettings = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elePasswordPolicySettings")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(elePasswordPolicySettings, "Password Policy Settings")
End Function


Public Function updatePasswordPolicySetting()
	Set elePassowrdpolicysettingwindow =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elePassowrdpolicysettingwindow")
	Set policy_passwordLength = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtpolicy.passwordLength")
	Set policy_strength = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtpolicy.strength")
	Set policy_changeFreq =  Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtpolicy.changeFreq")
	Set rdopolicy_passwordHistory = Browser("brwFundMaster").Page("pgFundMaster").WebRadioGroup("policy.passwordHistory")
	Set policy_historyLength= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtpolicy.historyLength")
	Set policy_loginRetryCount= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtpolicy.loginRetryCount")
	Set rdopolicy_allowMultipleSessions=Browser("brwFundMaster").Page("pgFundMaster").WebRadioGroup("policy.allowMultipleSessions")
	Set eleMsgSettingsSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleMsgSettingsSavedSuccessfully")
	Set btnProceed= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnProceed")
	
	Call verifyObjectExist(elePassowrdpolicysettingwindow, "Passowrd policy setting window")
	Call objectExistanceCheckAndEnter(policy_passwordLength, "policy_passwordLength","7")
	Call objectExistanceCheckAndEnter(policy_strength,"policy_strength","Mixed Case + Special Characters + Numerals")
	Call objectExistanceCheckAndEnter(policy_changeFreq, "policy_changeFreq","Yearly")
	rdopolicy_passwordHistory.Select  "#0"
	Call objectExistanceCheckAndEnter(policy_historyLength, "policy_historyLength","3")
	Call objectExistanceCheckAndEnter(policy_loginRetryCount, "policy_loginRetryCount","3")
	rdopolicy_allowMultipleSessions.Select  "#0"
	Call objectExistanceCheckAndClick(btnProceed, "Proceed Button")
	Call verifyObjectExist(eleMsgSettingsSavedSuccessfully, "Msg Settings Saved Successfully")
End Function

Public Function gotoAdministrativeAuditTrail()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set eleUserAuditTrails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleUser AuditTrails")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(eleUserAuditTrails, "Audit Trails")
End Function

Public Function verifyAuditTrailUserDetails()
	Set elmProfileChkbx =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
	Set eleAudittrailprocessdetail_header = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleAudittrailprocessdetail_header")
	Set eleDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleDetails")
	Set eleAudittrailprocessdetail_Body = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleAudittrailprocessdetail_Body")
	 Setting.WebPackage("ReplayType") = 2
       Call objectExistanceCheckAndClick(elmProfileChkbx, "Check box")
       Setting.WebPackage("ReplayType") = 1
	Call objectExistanceCheckAndClick(eleDetails, "Details Button")
	Call verifyObjectExist(eleAudittrailprocessdetail_header, "Audit trail process detail_header")
	Call verifyObjectExist(eleAudittrailprocessdetail_Body, "Audit trail process detail_Body")
End Function

Public Function gotoAdministrativeProfile()
       Browser("brwFundMaster").Page("pgFundMaster").Sync
       wait 2
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set eleProfile = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfiles")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(eleProfile, "Profile")
End Function

Public Function gotoAdministrativeSystemRights()
       Browser("brwFundMaster").Page("pgFundMaster").Sync
       wait 2
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set elmSystemRights = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSystemRights")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(elmSystemRights, "System Rights")
End Function

Public Function gotoAdministrativeExistingUser()
       Browser("brwFundMaster").Page("pgFundMaster").Sync
       wait 2
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Set elmExistingUsers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmExistingUsers")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
       Call objectExistanceCheckAndClick(elmExistingUsers, "Existing User")
End Function

Public Function gotoAdministrative()
       Browser("brwFundMaster").Page("pgFundMaster").Sync
       wait 2
	Set eleAdmin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdministrativePanel")
       Call objectExistanceCheckAndClick(eleAdmin, "Administrative Panel")
End Function

Public Function  CreateNewSystemRights()
	Set elmNewPermission =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewPermission")
	Set edtPermissionId = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtperm.permissionId")
	Set edtPermNam= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtperm.name")
	Set edtPermGroup = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtperm.group")
	Set edtbuttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgPermissionSavedSuccessfully= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgPermissionSavedSuccessfully")
	
	Call objectExistanceCheckAndClick(elmNewPermission, "New Permission")
	Call objectExistanceCheckAndEnter(edtPermissionId, "Permission ID","Test")
	Call objectExistanceCheckAndEnter(edtPermNam, "Permission Name","Test")
	Call objectExistanceCheckAndEnter(edtPermGroup, "Permission Group","Test")
	Call objectExistanceCheckAndClick(edtbuttonSave, "Save")
	Call verifyObjectExist(elmMsgPermissionSavedSuccessfully,"Permission Saved Successfully")
	 
End Function

Public Function	searchAndRemoveSystemRights()
	Set edtPermissionSearch = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtPermissionSearch")
	Set btnFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
	Set elmPermissionSearchResults1 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPermissionSearchResults3")
	set chkbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPermissionSearchResults3")
	'Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("elmPermissionSearchResults3").Click
	''Set elmPermissionSearchResults2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPermissionSearchResults2")
	Set btnRemoveSelected = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnRemoveSelected")
	Set elmRemovePopupYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRemovePopupYes")
	Set elmRemoveDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRemoveDone")
	Set elmRemoveDoneOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRemoveDoneOk")
	Set elmRemovePopup = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRemovePopup")
	'	elmPermissionSearchResults
	Call objectExistanceCheckAndEnter(edtPermissionSearch, "Permission Name","Test")
	Call objectExistanceCheckAndClick(btnFilter,"Filter button")
	Call verifyObjectExist(elmPermissionSearchResults1,"Permission Search Results")
	wait 2
	Setting.WebPackage("ReplayType") = 2
      	 'Call objectExistanceCheckAndClick(elmPermissionSearchResults1, "Permission check box")
      	Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPermissionSearchResults3").Click
       Setting.WebPackage("ReplayType") = 1
       Call objectExistanceCheckAndClick(btnRemoveSelected,"Remove Selected")
       Call verifyObjectExist(elmRemovePopup,"Remove Selected confirmation popup")
       Call objectExistanceCheckAndClick(elmRemovePopupYes,"Remove selected confimation Yes Button")
       Call verifyObjectExist(elmRemoveDone,"Removed Confirmation button")
       Call objectExistanceCheckAndClick(elmRemoveDoneOk,"Remove Done ")
       Call objectExistanceCheckAndClick(btnFilter,"Filter button")
       Call verifyObjectNotExist(elmPermissionSearchResults1,"Permission Search Results")
End  Function



Public Function createNewUserProfile()
	Set btnNewProfile = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnNewProfile")
	Set edtName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtProfile.name")
	Set edtProfileDes= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtprofile.desc")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set btnCancel = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnCancel")
	Call objectExistanceCheckAndClick(btnNewProfile,"New Profile")
	Call objectExistanceCheckAndEnter(edtName, "Profile Name", "Test Profile")
	Call objectExistanceCheckAndEnter(edtProfileDes,"Profile Description", "Test Profile")
	Call objectExistanceCheckAndClick(buttonSave,"Save Button")
	Call objectExistanceCheckAndClick(btnCancel,"Close Button")
End Function

Public Function reloadUserProfilePage()
	Set elmCloseTab = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCloseTab")
       Set eleProfile = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfiles")
       Call objectExistanceCheckAndClick(elmCloseTab, "Close Tab")
       Call objectExistanceCheckAndClick(eleProfile, "Profile")
       Browser("brwFundMaster").Page("pgFundMaster").Sync
End Function

Public Function viewAndEditProfile()
	Set elmTestProfile = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmTestProfile")
	Set btnProfileDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnProfileDetails")
	Set edtName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtProfile.name")
	Set edtProfileDes= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtprofile.desc")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set btnCancel = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnCancel")
	Setting.WebPackage("ReplayType") = 2
	elmTestProfile.Click
	Setting.WebPackage("ReplayType") = 1
	Call objectExistanceCheckAndClick(btnProfileDetails, "Details button")
	Call objectExistanceCheckAndEnter(edtName, "Profile Name", "QA Profile")
	Call objectExistanceCheckAndEnter(edtProfileDes,"Profile Description", "QA Profile")
	Call objectExistanceCheckAndClick(buttonSave,"Save Button")
	Call objectExistanceCheckAndClick(btnCancel,"Close Button")
End Function

Public Function verifyProfileNameUpdated()
       Set elmNewProfileName = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmQAProfile")
	Call verifyObjectExist(elmNewProfileName , "Updated Profile Name")
End Function

Public Function removeProfile()
	Set elmNewProfileName = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmQAProfile")
	Set btnRemoveSelected = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnRemoveSelected")
	set elmMsgRemoveProfile =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgRemoveProfile")
	Set elmRemovePopupYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRemovePopupYes")
	Set elmMsgProfileDeleted = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgProfileDeleted")
	Setting.WebPackage("ReplayType") = 2
	elmNewProfileName.Click
	Setting.WebPackage("ReplayType") = 1
	'	Call objectExistanceCheckAndClick(elmNewProfileName , "Updated Profile Name")
	Call objectExistanceCheckAndClick(btnRemoveSelected, "Remove Profile")
	Call verifyObjectExist(elmMsgRemoveProfile, "remove profile confirmation Msg")
	Call objectExistanceCheckAndClick(elmRemovePopupYes, "remove profile confirmation Msg - YES")
	Call verifyObjectExist(elmMsgProfileDeleted , "Profile - Delted - confirmation - Msg")
End Function

Public Function registerNewUser()
	Set edtUsername = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.username")
	Set edtSurname = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.surname")
	Set edtUserInitials = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.userInitials")
	Set edtOthernames =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.othernames")
	Set edtemail = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.email")
	Set edtmobileNumber = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.mobileNumber")
	Set edtProfileId = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.profileId")
	Set edtAdmin =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.admin")
	Set edtDefaultModule = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.defaultModule")
	Set edtallowAccountsModuleAccess = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowAccountsModuleAccess")
	Set edtallowFeesAndCommissionsMo =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowFeesAndCommissionsMo")
	Set edtallowMembersModuleAccess =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowMembersModuleAccess")
	Set edtallowPensionersModuleAcce =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowPensionersModuleAcce")
	Set edtallowInvestmentsModuleAcc =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowInvestmentsModuleAcc")
	Set edtallowSchemeSetupModule =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.allowSchemeSetupModule")
	Set edtbusinessName =Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.businessName")
	Set edtapprovalLimit= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.approvalLimit")
	Set edtcertificationLimit = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("user.certificationLimit")
	Set btnSaveUser = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set btnNewUser= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnNewUser")
	Set elmUserSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmUserSavedSuccessfully")
'	
'	Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebEdit("user.reportsToId").Set
'	Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebEdit("user.schemeId").Set
'	Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebEdit("user.serviceProviderId").Set
	randomUserName = "TestUser_" & fnRandomNumberWithDateTimeStamp()
	Call objectExistanceCheckAndClick(btnNewUser, "New User")
	Call objectExistanceCheckAndEnter(edtSurname , "Surname ", "Test")
	Call objectExistanceCheckAndEnter(edtOthernames ,  "Othernames ", "Testing" )
	Call objectExistanceCheckAndEnter(edtUserInitials , "UserInitials ", "TT" )
	Call objectExistanceCheckAndEnter(edtUsername , " User Name ", randomUserName )
	Call objectExistanceCheckAndEnter(edtemail , "email ", "test@gmail.com" )
	Call objectExistanceCheckAndEnter(edtmobileNumber , "mobileNumber", "256712001619" )
	Call objectExistanceCheckAndEnter(edtProfileId , "ProfileId", "System Administrators" )
	Call objectExistanceCheckAndEnter(edtAdmin , "Admin ", "Yes" )
	Call objectExistanceCheckAndEnter(edtDefaultModule , "DefaultModule", "None" )
	Call objectExistanceCheckAndEnter(edtallowAccountsModuleAccess , "allowAccountsModuleAccess", "No" )
	Call objectExistanceCheckAndEnter(edtallowFeesAndCommissionsMo , "allowFeesAndCommissionsMo","No" )
	Call objectExistanceCheckAndEnter(edtallowMembersModuleAccess , "allowMembersModuleAccess","No" )
	Call objectExistanceCheckAndEnter(edtallowPensionersModuleAcce , "allowPensionersModuleAcce","No" )
	Call objectExistanceCheckAndEnter(edtallowInvestmentsModuleAcc , "allowInvestmentsModuleAcc","No" )
	Call objectExistanceCheckAndEnter(edtallowSchemeSetupModule , "allowSchemeSetupModule ","No" )
	'Call objectExistanceCheckAndEnter(edtbusinessName , " ", "" )
	Call objectExistanceCheckAndEnter(edtapprovalLimit, "pprovalLimit", "10000000" )
	Call objectExistanceCheckAndEnter(edtcertificationLimit , "certificationLimit", "10000000" )
	Call objectExistanceCheckAndClick(btnSaveUser, "Save User")
	Call verifyObjectExist(elmUserSavedSuccessfully, "UserSavedSuccessfully Msg")
	wait 3
	'Call objectExistanceCheckAndClick(edtProfileUserName, "User profile name" ,randomUserName )
	registerNewUser=randomUserName
End Function

Public Function enterProfileNameAndSearch(strUserName)
	Set edtProfileUserName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtProfileUserName")
	Call objectExistanceCheckAndEnter(edtProfileUserName, "User profile name" ,strUserName )
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	edtProfileUserName.Highlight
	edtProfileUserName.Click
	wait 2
	'edtProfileUserName.FireEvent
	mySendKeys.SendKeys"{ENTER}"
End Function

Public Function verifyUserDetails(strUserName)
	Call enterProfileNameAndSearch(strUserName)
	Set tblUserProfileResults = Browser("brwFundMaster").Page("pgFundMaster").WebTable("tblUserProfileResults")
	Set chkBox01 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	
	Call verifyObjectExist(tblUserProfileResults, "User Profile Search Results")
	Call objectExistanceCheckAndClick(chkBox01, "Check box")
	Call gotoUserDetails()
End Function

Public Function gotoUserDetails()
	Set btnUserProfileDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUserProfileDetails")
	Set elmuserForm = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmuserForm")
	Call objectExistanceCheckAndClick(btnUserProfileDetails, "Profile details")
	Call objectExistanceCheckAndClick(elmuserForm, "User form details")
End Function

Public Function assignSchemeToUser(strSchemeName)
	Set tabAllowedSchemes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tab-AllowedSchemes")
	Set elmAssignSchemestoUser = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAssignSchemestoUser")
	Set edtSchemeNameFieldUnderUsersinput = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtSchemeNameFieldUnderUsers-inpu")
	Set btnFilter= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
	Set elmQaScheme = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmQaScheme")
	Set chkBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Set toolbar = Browser("brwFundMaster").Page("pgFundMaster").WebElement("toolbar")
	Set elmAllowSelectedSchemes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAllowSelectedSchemes")
	Set elmMsgActionCompletedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgActionCompletedSuccessfully")
	Set elmCloseWindow= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCloseWindow")
	Set btnSaveUser= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmUserSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmUserSavedSuccessfully")
	
	Call objectExistanceCheckAndClick( tabAllowedSchemes, "tab Allowed Schemes")
	Call objectExistanceCheckAndClick( elmAssignSchemestoUser, "Assign Schemes to User")
	Call objectExistanceCheckAndEnter(edtSchemeNameFieldUnderUsersinput, "Scheme Name" ,strSchemeName )
	Call objectExistanceCheckAndClick( btnFilter, "Filter Button")
	'Call verifyObjectExist(elmQaScheme, "Qa Scheme" )
	Call objectExistanceCheckAndClick(chkBox, "Check box" )
	Call objectExistanceCheckAndClick(toolbar, "Tool bar" )
	Call objectExistanceCheckAndClick(elmAllowSelectedSchemes, "AllowSelectedSchemes" )
	Call verifyObjectExist(elmMsgActionCompletedSuccessfully, "MsgActionCompletedSuccessfully" )
	Call objectExistanceCheckAndClick(elmCloseWindow, "CloseWindow" )
	Call objectExistanceCheckAndClick(btnSaveUser, "Save User")
	Call verifyObjectExist(elmUserSavedSuccessfully, "UserSavedSuccessfully Msg")
End Function

Public Function assignAddAllowedMemberClasses()
	Set tabAllowedMemberClasses = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tabAllowedMemberClasses")
	Set btnAddAllowedMemberClasses = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnAddAllowedMemberClasses")
	Set edtSeachMemberClassName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtSeachMemberClassName-inputEl")
	Set elmAllowSelectedMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAllowSelectedMember")
	Set elmQASchemeSponsorMEMBER = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmQASchemeSponsorMEMBER")
	Set chkBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Set toolbar = Browser("brwFundMaster").Page("pgFundMaster").WebElement("toolbar")
	Set elmAllowSelectedMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAllowSelectedMember")
	Set elmMsgActionCompletedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgActionCompletedSuccessfully")
	Set elmCloseWindow= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCloseWindow")
	Set btnSaveUser= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmUserSavedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmUserSavedSuccessfully")
	Call objectExistanceCheckAndClick(tabAllowedMemberClasses, "AllowedMemberClasses")
	Call objectExistanceCheckAndClick(btnAddAllowedMemberClasses, "AddAllowedMemberClasses")
	Call objectExistanceCheckAndEnter(edtSeachMemberClassName, "QA Scheme Sponsor MEMBER CLASS" , "QA Scheme Sponsor MEMBER CLASS")
	'press enter
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	edtSeachMemberClassName.Highlight
	edtSeachMemberClassName.Click
	wait 2
	mySendKeys.SendKeys"{ENTER}"
	Call objectExistanceCheckAndClick(chkBox, "Check box" )
	Call objectExistanceCheckAndClick(toolbar, "Tool bar" )
	Call objectExistanceCheckAndClick(elmAllowSelectedMember, "elmAllowSelectedMember")
	Call verifyObjectExist(elmMsgActionCompletedSuccessfully, "MsgActionCompletedSuccessfully" )
	Call objectExistanceCheckAndClick(elmCloseWindow, "CloseWindow" )
	Call objectExistanceCheckAndClick(btnSaveUser, "Save User")
	Call verifyObjectExist(elmUserSavedSuccessfully, "UserSavedSuccessfully Msg")
End Function


Public Function lockUserAndVerify()
	Set btnAccountControl = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnAccountControl")
	Set lnkLock = Browser("brwFundMaster").Page("pgFundMaster").Link("lnkLock")
	Set elmMsgUserAccountLockedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgUserAccountLockedSuccessfully")
	Set elmLOCKED = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmLOCKED")
	
	Call objectExistanceCheckAndClick(btnAccountControl, "AccountControl")
	Call objectExistanceCheckAndClick(lnkLock, "Lock")
	Call verifyObjectExist(elmMsgUserAccountLockedSuccessfully, "MsgUserAccountLockedSuccessfully")
	Call verifyObjectExist(elmLOCKED, "Account status Locked")
End Function


Public Function unlockUserAndVerify()
	Set btnAccountControl = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnAccountControl")
	Set elmUnlock = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmUnlock")
	Set elmMsgUserAccountUnlockedSuccessfully =Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgUserAccountUnlockedSuccessfully")
	Set elmACTIVE = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmACTIVE")
	
	Call objectExistanceCheckAndClick(btnAccountControl, "AccountControl")
	Call objectExistanceCheckAndClick(elmUnlock, "Unlock")
	Call verifyObjectExist(elmMsgUserAccountUnlockedSuccessfully, "MsgUserAccountUnlockedSuccessfully")
	Call verifyObjectExist(elmACTIVE, "Account status Active")
End Function

Public Function filterAuditTrail()
	Set edtModule = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtModule")
	Set edtCrudeTypetf = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCrudeTypetf")
	Set tblAuditTable = Browser("brwFundMaster").Page("pgFundMaster").WebTable("tblAuditTable")
	Set btnFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
	Set btnResetFilter = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnResetFilter")
	Set tblStatusLogin = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tblStatusLogin")
'	Set elmtblStatusUPDATE = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmtblStatusUPDATE").Click

	Call objectExistanceCheckAndEnter(edtModule, "Module" , "Administrative")
	Call objectExistanceCheckAndEnter(edtCrudeTypetf, "CrudeType" , "Login")
	Call objectExistanceCheckAndClick(btnFilter,"Filter button")
	Call verifyObjectExist(tblAuditTable,"AuditTable")
	Call verifyObjectExist(tblStatusLogin,"Table Login details")
	
End Function

Public Function CreateNewScheme()
	Set elmNewScheme = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewScheme")
	Set elmSchemeform = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeform")
	Set edtschemeNam = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemeNam")
	Set edtschemeNumber = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeNumber")
	Set edtschemeTyp = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemeTyp")
	Set edtplanType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.planType")
	Set edtdtSchemeDatePicker = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.dateComme")
	Set edtbaseCurre = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.baseCurre")
	Set rdoEnableChecklist = Browser("brwFundMaster").Page("pgFundMaster").WebRadioGroup("chkEnableChecklist")
	Set chkMonthly = Browser("brwFundMaster").Page("pgFundMaster").WebCheckBox("chkMonthly")
	Set btnSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmMsgSaveSuccessful =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful")
	Call objectExistanceCheckAndClick(elmNewScheme,"NewScheme")
	Call verifyObjectExist(elmSchemeform,"Scheme form")
	randomSchemeName = "QAScheme_" & fnRandomNumberWithDateTimeStamp()
	Call objectExistanceCheckAndEnter(edtschemeNam, "scheme Name" , randomSchemeName)
	'Call objectExistanceCheckAndEnter(edtschemeNumber, "schemeNumber" , "1948")
	Call objectExistanceCheckAndEnter(edtschemeTyp, "scheme type" , "Pension Fund")
	Call objectExistanceCheckAndEnter(edtplanType, "scheme  plan type" , "Defined Benefit")
	Call objectExistanceCheckAndEnter(edtdtSchemeDatePicker, "scheme Date picker" , "01/01/2020")
	Call objectExistanceCheckAndEnter(edtbaseCurre, "scheme base currency" , "US DOLLAR")
	Call objectExistanceCheckAndClick(rdoEnableChecklist,"Documentation Before approval")
	chkMonthly.Set "ON"
	Call objectExistanceCheckAndClick(btnSave,"Save button")
	Call verifyObjectExist(elmMsgSaveSuccessful,"MsgSaveSuccessful")
	CreateNewScheme = randomSchemeName
End Function

Public Function searchScheme()
	Set schemeName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("schemeNameField-inputEl")
	Set elmSchemeChkBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeChkBox")
	Call objectExistanceCheckAndEnter(schemeName, "scheme name" ,randomSchemeName)
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	schemeName.Highlight
	schemeName.Click
	wait 2
	mySendKeys.SendKeys"{ENTER}"
	wait 1
	Call objectExistanceCheckAndClick(elmSchemeChkBox,"Check box")
End Function

Public Function doCheckListVerification()
	Set btnChecklistVerification = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnChecklistVerification")
	Set chkBoxChecklistVerification_1 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBoxChecklistVerification_1")
	Set chkBoxChecklistVerification_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBoxChecklistVerification_2")
	Set chkBoxChecklistVerification_3 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBoxChecklistVerification_3")
	
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	Set btnProcess = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnProcess")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone")

	Call objectExistanceCheckAndClick(btnChecklistVerification,"ChecklistVerification")
	
	'Call verifyObjectExist(chkBoxChecklistVerification_1,Checkbox)
	Call clickOnCheckBox(chkBoxChecklistVerification_1,"Checkbox 1")
	Call uploadCheckList()
	Call objectExistanceCheckAndClick(btnProcess,"Process")
	Call verifyObjectExist(elmMsgDone,"Msg Done")
	
	'Call verifyObjectExist(chkBoxChecklistVerification_2,"Checkbox 2")
	Call clickOnCheckBox(chkBoxChecklistVerification_2,"Checkbox 2")
	Call uploadCheckList()
	Call objectExistanceCheckAndClick(btnProcess,"Process")
	Call verifyObjectExist(elmMsgDone,"Msg Done")
	
	'Call verifyObjectExist(chkBoxChecklistVerification_3,"Checkbox 3")
	Call clickOnCheckBox(chkBoxChecklistVerification_3,"Checkbox 3")
	Call uploadCheckList()
	Call objectExistanceCheckAndClick(btnProcess,"Process")
	Call verifyObjectExist(elmMsgDone,"Msg Done")
	
	Call objectExistanceCheckAndClick(btnClose,"Close")
End Function

Public Function uploadCheckList()
	strFilePath = "C:\Users\Administrator\Documents\MemberUpload.xlsx"
	Set elmReceiveDocument = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmReceiveDocument")
	Set edtdateReceived = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("dateReceived")
	Set edtcomments = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("comments")
	Set uploadDocument = Browser("brwFundMaster").Page("pgFundMaster").WebFile("uploadDocument")
	Call objectExistanceCheckAndClick(elmReceiveDocument,"ReceiveDocument")
	Call objectExistanceCheckAndEnter(edtdateReceived, "dateReceived" , "01/01/2020")
	Call objectExistanceCheckAndEnter(edtcomments, "comments" ,"Test comments")
	Call browserAndUploadCheckListDoc(strFilePath)
End Function

Public  Function browserAndUploadCheckListDoc(strFilePath)
	set objBtnBrowse =Browser("brwFundMaster").Page("pgFundMaster").WebFile("uploadDocument")
	set objBtnOpen	=	Window("FilePicker").Dialog("Open").WinButton("Open")
	set objtxtEdit = Window("FilePicker").Dialog("Open").WinEdit("File name:")
	Set btnUpload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUpload")
	Setting.WebPackage("ReplayType") = 2
	objBtnBrowse.Click
	Setting.WebPackage("ReplayType") = 1
       Call objectExistanceCheckAndEnter(objtxtEdit,"File path",strFilePath )
       Call objectExistanceCheckAndClick(objBtnOpen,"Open File")
End Function

Public Function certifyScheme()
	Set elmCertification = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCertification")
	Set elmCertify = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCertify")
	Set elmMsgCertifiedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgCertifiedSuccessfully")
	Call objectExistanceCheckAndClick(elmCertification,"Certification")
	Call objectExistanceCheckAndClick(elmCertify,"Certify")
	Call verifyObjectExist(elmMsgCertifiedSuccessfully,"MsgCertifiedSuccessfully")
End Function

Public Function approveScheme()
	Set elmCertification = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCertification")
	Set elmApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmApprove")
	Set elmMsgApprovedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgApprovedSuccessfully")
	Call objectExistanceCheckAndClick(elmCertification,"Certification")
	Call objectExistanceCheckAndClick(elmApprove,"Approve")
	Call verifyObjectExist(elmMsgApprovedSuccessfully,"MsgApprovedSuccessfully")
End Function

Public Function gotoMainMenu()
	Set elmMainMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMainMenu")
       Call objectExistanceCheckAndClick(elmMainMenu,"MainMenu")
End Function

Public Function switchToScheme(strSchemeName)
	Set elmSwitchScheme= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSwitchScheme")
	Set schemeNameField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("schemeNameField-inputEl")
	Set btnFilter= Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFilter")
	Set chkBox01= Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	
	Set  btnSetasWorkingScheme = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSetasWorkingScheme")
	Set msgBoxConfirm = Browser("brwFundMaster").Page("pgFundMaster").WebElement("msgBoxConfirm")
	Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	
	Call objectExistanceCheckAndClick(elmSwitchScheme,"SwitchScheme")
	Call objectExistanceCheckAndEnter(schemeNameField,"Scheme Name",strSchemeName )
	Call objectExistanceCheckAndClick(btnFilter,"Filter")
	Call objectExistanceCheckAndClick(chkBox01,"CheckBox")
 	Call objectExistanceCheckAndClick(btnSetasWorkingScheme,"Set as Working Scheme")
 	Call verifyObjectExist(msgBoxConfirm,"msgBoxConfirm")
 	Call objectExistanceCheckAndClick(btnYes,"btnYes")
End Function
Public Function verifySchemeNameChanged(expectedName)
	Set expectedSchemeName = Browser("brwFundMaster").Page("pgFundMaster").WebElement("expectedSchemeName")
	Call verifyObjectExist(expectedSchemeName,"Scheme Name")
	If InStr(expectedSchemeName.GetROProperty("innertext"), expectedName) > 0 Then
		LogResult micpass , " Verify  " & expectedName ,  " Verified  " & expectedName & "  exist Successfully"
	Else
		LogResult micFail ,  " Verify  " & expectedName , " Verified  " & expectedName & "   not exist"
		If skipFailure <> true Then
			ExitTest
		End If
	End If
End Function

Public Function cloneAndVerify()
	Set btnCloneConfigs = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnCloneConfigs")
	Set btnFindScheme = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnFindScheme")
	Set searchSchemeName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("searchSchemeName-inputEl")
	Set chkBox03 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Set btnCloneFromSelected = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnCloneFromSelected")
	Set btnClone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClone")
	Set elmMsgCloneSuccessful = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgCloneSuccessful")
	
	Call objectExistanceCheckAndClick(btnCloneConfigs,"CloneConfigs")
	Call objectExistanceCheckAndClick(btnFindScheme,"btnFindScheme")
	Call objectExistanceCheckAndEnter(searchSchemeName, "searchSchemeName" ,"")
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	searchSchemeName.Highlight
	searchSchemeName.Click
	wait 2
	mySendKeys.SendKeys"{ENTER}"
	wait 1
	Call objectExistanceCheckAndClick(chkBox03,"chkBox03")
	Call objectExistanceCheckAndClick(btnCloneFromSelected,"btnCloneFromSelected")
	Call objectExistanceCheckAndClick(btnClone,"btnClone")
	Call verifyObjectExist(elmMsgCloneSuccessful,"MsgCloneSuccessful")
End Function

Public Function createBasicScheme()
	Set elmBasicSchemeDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBasicSchemeDetails")
	Set eleschemeNam = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemeNam")
	Set eleschemeTyp = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemeTyp")
	Set eleSchemeplanType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.planType")
	Set eleschemePin = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemePin")
	Set eleSchemeMod = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.schemeMod")
	Set eleSchemecontribut = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.contribut")
	Set elesponsrCon = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.sponsrCon")
	Set eleSchemeremittanc = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.remittanc")
	Set eleSchemebaseCurre = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.baseCurre")
	Set eleSchemebaseTaxRe = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.baseTaxRe")
	Set eleSchemeoffshoreC = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.offshoreC")
	Set eleSchemedateComme = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.dateComme")
	Set eletakeOnDat = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.schemeDetails.takeOnDat")
	
	Set eleSchemepostalAddress = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.address.postalAddress")
	Set eleSchemebuilding = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.address.building")
	Set eleSchemetown = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.address.town")
	
	Set btnSaveUser = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmMsgSaveSuccessful  = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful")
	strBasicSchemeName = "QA Scheme_" & fnRandomNumberWithDateTimeStamp()
	Call objectExistanceCheckAndClick(elmBasicSchemeDetails,"BasicSchemeDetails")
	Call objectExistanceCheckAndEnter(eleschemeNam, "scheme Name" ,strBasicSchemeName)
	
	Call objectExistanceCheckAndEnter(eleschemeTyp, "scheme Type" ,"Pension Fund")
	Call objectExistanceCheckAndEnter(eleSchemeplanType, "Scheme planType" ,"Defined Contribution")
	Call objectExistanceCheckAndEnter(eleschemePin, "scheme Pin" ,"12345678912")
	Call objectExistanceCheckAndEnter(eleSchemeMod, "Scheme Mode" ,"Single")
	Call objectExistanceCheckAndEnter(eleSchemecontribut, "Scheme contribute" ,"Monthly")

	Call objectExistanceCheckAndEnter(elesponsrCon, "sponsor Contribution holiday" ,"Yes")
	Call objectExistanceCheckAndEnter(eleSchemeremittanc, "Scheme remittanc" ,"In Arrears")
	Call objectExistanceCheckAndEnter(eleSchemebaseCurre, "SchemebaseCurre" ,"KENYA SHILLINGS")
	Call objectExistanceCheckAndEnter(eleSchemebaseTaxRe, "SchemebaseTaxRe" ,"Kenya")
	Call objectExistanceCheckAndEnter(eleSchemeoffshoreC, "Scheme off shoreC" ,"US DOLLAR")
	Call objectExistanceCheckAndEnter(eleSchemedateComme, "SchemedateComme" ,"01/01/2020")
	Call objectExistanceCheckAndEnter(eletakeOnDat, "eletakeOnDat" ,"12/31/2019")
	Call objectExistanceCheckAndEnter(eleSchemepostalAddress, "SchemepostalAddress" ,"Test")
	Call objectExistanceCheckAndEnter(eleSchemebuilding, "Schemebuilding" ,"Test")
	Call objectExistanceCheckAndEnter(eleSchemetown, "Schemetown" ,"Test")
	
	Call objectExistanceCheckAndClick(btnSaveUser,"btn Save")
	Call verifyObjectExist(elmMsgSaveSuccessful,"MsgSaveeSuccessful")
End Function


Public Function addModuleAllowanceConfigurations()
	Set elmModulesAllowanceConfiguration = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmModulesAllowanceConfiguration")
	Set elmModuleAllowanceHeader = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmModuleAllowanceHeader")
	Set benefitsLogCh = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("modulesAllowance.benefitsLogCh")
	Set allowMemberLo = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("modulesAllowance.allowMemberLo")
	Set allowFeesAndC = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("modulesAllowance.allowFeesAndC")
	Set allowStaffPay = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("modulesAllowance.allowStaffPay")
	Set btnSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set btnMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone")
	
	Call objectExistanceCheckAndClick(elmModulesAllowanceConfiguration,"Modules Allowance Configuration")
	Call verifyObjectExist(elmModuleAllowanceHeader,"Module Allowance Header")
	
	Call objectExistanceCheckAndEnter(benefitsLogCh, "benefitsLog" ,"No")
	Call objectExistanceCheckAndEnter(allowMemberLo, "MemberL" ,"No")
	Call objectExistanceCheckAndEnter(allowFeesAndC, "FeesAndCommission" ,"Yes")
	Call objectExistanceCheckAndEnter(allowStaffPay, "Staff Payroll" ,"No")
	
	Call objectExistanceCheckAndClick(btnSave,"btn Save")
	Call verifyObjectExist(btnMsgDone,"Msg Done")
End Function

Public Function addDateAndInsuranceCovers()
	Set elmSchemeConfigurations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeConfigurations")
	Set elmSchemeDatesandInsuranceCoversConfigurations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeDatesandInsuranceCoversConfigurations")
	Set edtBox1 = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.insuranceCover.register")
	Set edtBox2= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.insuranceCover.exemptFr")
	Set edtBox3= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.insuranceCover.lastExpe")
	Set edtBox4 = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.insuranceCover.trustLia")
	Set edtBox5 = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("scheme.insuranceCover.lifeCove")
	Set btnSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmMsgSaveSuccessful =Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	
	Call objectExistanceCheckAndClick(elmSchemeConfigurations,"Scheme Configurations")
	Call objectExistanceCheckAndClick(elmSchemeDatesandInsuranceCoversConfigurations,"SchemeDatesandInsuranceCoversConfigurations")
	
	Call objectExistanceCheckAndEnter(edtBox1, "edtBox1" ,"No")
	Call objectExistanceCheckAndEnter(edtBox2, "edtBox2" ,"No")
	Call objectExistanceCheckAndEnter(edtBox3, "edtBox3" ,"No")
	Call objectExistanceCheckAndEnter(edtBox4, "edtBox4" ,"No")
	Call objectExistanceCheckAndEnter(edtBox5, "edtBox5" ,"No")
	Call objectExistanceCheckAndClick(btnSave,"btn Save")
	Call verifyObjectExist(elmMsgSaveSuccessful,"MsgSaveSuccessful")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
	
End Function

Public Function gotoSponsorList()
	Set elmSponsor = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsor")
	Set  elmSponsorsList = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorsList")
	Call objectExistanceCheckAndClick(elmSponsor,"Sponsor")
	Call objectExistanceCheckAndClick(elmSponsorsList,"elmNewSponsor")
End Function

Public Function createNewSponsor()
	Set elmNewSponsor = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewSponsor")
	Set elmSponsorDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorDetails")
	Set edtname= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.name")
	Set edtapplicationDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.applicationDate")
	Set edtemployerRefNo= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.employerRefNo")
	Set edtpin = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.pin")
	Set edtsector = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.sector")
	Set edtsponsorBillingMode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("config.sponsorBillingMode")
	Set edtbuilding = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.address.building")
	Set edttown = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.address.town")
	Set edtcellPhone = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsor.address.cellPhone")
	Set btnSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmMsgSaveSuccessful =Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	randomSponsorName = "QASponsor_" & fnRandomNumberWithDateTimeStamp()
	Call objectExistanceCheckAndClick(elmNewSponsor,"NewSponsor")
	Call verifyObjectExist(elmSponsorDetails,"SponsorDetails")
	Call objectExistanceCheckAndEnter(edtname, "Sponsor Name" ,randomSponsorName)
	Call objectExistanceCheckAndEnter(edtapplicationDate, "Application date" ,"08/07/2022")
	Call objectExistanceCheckAndEnter(edtpin, "Tax no" ,"112233")
	Call objectExistanceCheckAndEnter(edtemployerRefNo, "Emp no" ,"112233")
	Call objectExistanceCheckAndEnter(edtsector, "Sector" ,"NGO")
	Call objectExistanceCheckAndEnter(edtsponsorBillingMode, "Billing mode" ,"Per Sponsor")
	Call objectExistanceCheckAndEnter(edtbuilding, "Building" ,"Test")
	Call objectExistanceCheckAndEnter(edttown, "town" ,"Test")
	Call objectExistanceCheckAndEnter(edtcellPhone, "Cell" ,"1234567890")
	Call objectExistanceCheckAndClick(btnSave,"btn Save")
	Call verifyObjectExist(elmMsgSaveSuccessful,"MsgSaveSuccessful")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
	Call objectExistanceCheckAndClick(btnClose,"button Close")
	createNewSponsor = randomSponsorName
End Function

Public Function gotoSponsorApproval()
	Set elmSponsorsApproval= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorsApproval")
	Call objectExistanceCheckAndClick(elmSponsorsApproval,"Sponsors Approval")
End Function

Public Function verifySponsorDetails(strSponsorName)
	Set sponsorNameFieldUA = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("sponsorNameFieldUA-inputEl")
	Set chkBox01 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set btnDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnDetails")
	Set elmSponsorDetailsHeader = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorDetailsHeader")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	Call objectExistanceCheckAndEnter(sponsorNameFieldUA, "sponsor Name" ,strSponsorName)
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	sponsorNameFieldUA.Highlight
	sponsorNameFieldUA.Click
	wait 2
	'edtProfileUserName.FireEvent
	mySendKeys.SendKeys"{ENTER}"
	Call objectExistanceCheckAndClick(chkBox01,"chkBox01")
	Call objectExistanceCheckAndClick(btnDetails,"btnDetails")
	Call verifyObjectExist(elmSponsorDetailsHeader,"SponsorDetailsHeader")
	Call objectExistanceCheckAndClick(btnClose,"btnClose")
End Function

Public Function removeSponsor()
	Set btnRemoveSelected = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnRemoveSelected")
	Set elmPopupAreYouSure = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPopupAreYouSure")
	Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	Set btnMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_2")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	
	Call objectExistanceCheckAndClick(btnRemoveSelected,"RemoveSelected")
	Call verifyObjectExist(elmPopupAreYouSure,"PopupAreYouSure")
	Call objectExistanceCheckAndClick(btnYes,"btnYes")
	Call verifyObjectExist(btnMsgDone,"Msg Done")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
End Function

Public Function approveSponsor()
	Set btnApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnApprove")
	Set elmMsgDoneSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDoneSuccessfully")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Set elmSuccessMsg = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessMsg")

	Call objectExistanceCheckAndClick(btnApprove, "btnApprove")
	''Call verifyObjectExist(elmSuccessMsg,"elmSuccessMsg")
	Call verifyObjectExist(elmMsgDoneSuccessfully,"elmMsgDoneSuccessfully")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
End Function

Public Function gotoCostCenters()
	Set elmCostCenters= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCostCenters")
	Call objectExistanceCheckAndClick(elmCostCenters,"CostCenters")
End Function

Public Function UpdateCostCenter(strSponsorName)
	Set sponsorName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("ccNameField-inputEl")
	Set chkBox01 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set btnDetails =Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnCCDetails")

	Set elmCostCenterDetailsHeader = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCostCenterDetailsHeader")
	Set code = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("company.code")
	Set name = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("company.name")
	Set desc = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("company.desc")
	Set sponsorId = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("company.sponsorId")

	Set btnSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnSaveUser")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	Call objectExistanceCheckAndEnter(sponsorName, "sponsor Name" ,strSponsorName)
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	sponsorName.Highlight
	sponsorName.Click
	wait 2
	'edtProfileUserName.FireEvent
	mySendKeys.SendKeys"{ENTER}"
	Call objectExistanceCheckAndClick(chkBox01,"chkBox01")
	Call objectExistanceCheckAndClick(btnDetails,"btnDetails")
	
	Call verifyObjectExist(elmCostCenterDetailsHeader,"CostCenterDetailsHeader")

	Call objectExistanceCheckAndEnter(code, "code" ,strSponsorName + "_Updated")
	Call objectExistanceCheckAndEnter(name, "name" ,strSponsorName + "_Updated")
	Call objectExistanceCheckAndEnter(desc, "desc" ,strSponsorName + "_Updated")
	Call objectExistanceCheckAndEnter(sponsorId, "sponsorId" ,strSponsorName+" Sponsor")
	
	Call objectExistanceCheckAndClick(btnSave,"btnSave")
	Call verifyObjectExist(elmMsgDone,"elmMsgDone")
	Call objectExistanceCheckAndClick(btnClose,"button Close")
End Function


Public Function gotoSchemeSetupConfigurations()
	Set elmSchemConfigIcon = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemConfigIcon")
	Call objectExistanceCheckAndClick(elmSchemConfigIcon,"Scheme Config button")
End Function

Public Function createSchemeConfiguration()
	Set elmSchemeSetupConfig = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeSetupConfig")
	Call objectExistanceCheckAndClick(elmSchemeSetupConfig,"Schem Setup Config button")
	Set edtSchemeStatusField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtSchemeStatusField")
	Call objectExistanceCheckAndEnter(edtSchemeStatusField, "Scheme Status Field" ,"Paid Up Scheme")
	Call objectExistanceCheckAndEnter(edtSchemeStatusField, "Scheme Status Field" ,"Open Scheme")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function

Public Function checkMemberSchemeConfiguration()
	Set elmMemberConfig = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberConfig")
	Call objectExistanceCheckAndClick(elmMemberConfig,"Member Config button")
	Set edtMemberUndecidedAnnuitiesTextfield =  Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberUndecidedAnnuitiesTextfield")
	Call objectExistanceCheckAndEnter(edtMemberUndecidedAnnuitiesTextfield, "Member Undecided Annuity Field" ,"Annuity to remain on the Same Scheme and Continue to earn interest")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function

Public Function checkContributionsAndBalancesConfigurations()
	Set elmContributionAndBalancesConfigButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionAndBalancesConfigButton")
	Set edtInterestFormularTextfield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtInterestFormularTextfield")
	Set edtInterestModeTextfield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtInterestModeTextfield")
	Call objectExistanceCheckAndClick(elmContributionAndBalancesConfigButton,"Contributions and Balances button")
	Call objectExistanceCheckAndEnter(edtInterestFormularTextfield, "Interest Fomular Field" ,"Compound Interest(Daily Compounding)")
	Call objectExistanceCheckAndEnter(edtInterestModeTextfield, "Interest Mode Field" ,"Annual Interest")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function


Public Function checkClaimsAndPensionersConfigs()
	Set elmClaimsAndPensionersConfigsButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmClaimsAndPensionersConfigsButton")
	Call objectExistanceCheckAndClick(elmClaimsAndPensionersConfigsButton,"Claims and PEnsioners Configs button")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function

Public Function checkSchemeDatesAndInsuranceCoversConfigs()
       Set edtDateApprovedDatefield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDateApprovedDatefield")
       Set edtDateRegisterdDateField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDateRegisterdDateField")
       Set edtIsSchemeRegisteredField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtIsSchemeRegisteredField")
       Set edtIsLifeCoverProvidedTextfield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtIsLifeCoverProvidedTextfield")
       Set elmDatesAndInsuranceCovers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDatesAndInsuranceCovers")
       Set edtLifeCoverProvidedTextfield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtLifeCoverProvidedTextfield")
       Call objectExistanceCheckAndClick(elmDatesAndInsuranceCovers,"Dates and Insurance Covers Configs button")
	Call objectExistanceCheckAndEnter(edtIsSchemeRegisteredField, "Is Scheme Registered Textfield" ,"Yes")
	Call objectExistanceCheckAndEnter(edtIsSchemeRegisteredField, "Is Scheme Registered Textfield" ,"No")
	Call objectExistanceCheckAndEnter(edtDateRegisterdDateField, "Date Registered" ,"08/16/2022")
	Call objectExistanceCheckAndEnter(edtDateApprovedDatefield, "Date Approved" ,"08/16/2022")
	Call objectExistanceCheckAndEnter(edtLifeCoverProvidedTextfield, "Is Life Cover Provided Field" ,"Yes")
	Call objectExistanceCheckAndEnter(edtLifeCoverProvidedTextfield, "Is Life Cover Provided Field" ,"No")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function

Public Function checkBenefitsConfigs()
	Set elmMonthDaysMode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmMonthDaysMode")
       Set edtLineraInterpolationModeTextfield = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtLineraInterpolationModeTextfield")
       Set elmYearDaysMode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmYearDaysMode")
       Set elmBenefitsConfigsButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBenefitsConfigsButton")
      	Call objectExistanceCheckAndClick(elmBenefitsConfigsButton,"Benefits Configs button")
      	Call objectExistanceCheckAndEnter(edtLineraInterpolationModeTextfield, "Linear Interpolation Mode" ,"Monthly")
      	Call objectExistanceCheckAndEnter(elmYearDaysMode, "Days Of the Mode" ,"365")
       Call objectExistanceCheckAndEnter(elmMonthDaysMode, "Days Of the Month" ,"30")
       Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
	Set edtDeathBenefitPaymentModeTextField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDeathBenefitPaymentModeTextField")
	Set elmDeathClaimConfiguration = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDeathClaimConfiguration")
	Call objectExistanceCheckAndClick(elmDeathClaimConfiguration,"Death Claim Configs")
	Call objectExistanceCheckAndEnter(edtDeathBenefitPaymentModeTextField, "Death Benefit Payment Mode" ,"Death gratuity plus other benefits(Pension)")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
	Set elmRetirementConfigs = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRetirementConfigs")
	Call objectExistanceCheckAndClick(elmRetirementConfigs,"Retirement Configurations")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")

	Set elmTrivialPEnsionConfigs = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmTrivialPEnsionConfigs")
	Set edtTrivialPensionLumpsum = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTrivialPensionLumpsum")
	Set edtTrivialPensionMinimumAge = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTrivialPensionMinimumAge")
	Set edtTrivialPensionEffectiveDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTrivialPensionEffectiveDate")
	Set edtTrivialPensiondescription = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTrivialPensiondescription")
	Set edtTrivialPension = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTrivialPension")
	Set elmNewTrivialConfig = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewTrivialConfig")
	Set elmRetirementConfigs = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRetirementConfigs")
	Call objectExistanceCheckAndClick(elmTrivialPensionConfigs,"Trivial Configurations button")
	Call objectExistanceCheckAndClick(elmNewTrivialConfig,"New Trivial Configuration button")
	Call objectExistanceCheckAndEnter(edtTrivialPensionEffectiveDate, "Trivial Pension Effective Date" ,"08/16/2022")
	Call objectExistanceCheckAndEnter(edtTrivialPensiondescription, "Trivial Pension Description" ,"Trivial Pension")
	Call objectExistanceCheckAndEnter(edtTrivialPensionMinimumAge, "Trivial Pension Minimum Age" ,"50")
	Call objectExistanceCheckAndEnter(edtTrivialPensionLumpsum, "Trivial Pension Lumpsum" ,"11000000")
	Call objectExistanceCheckAndEnter(edtTrivialPension, "Trivial Pension" ,"110000")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")

	Set elmMedicalCoversConfigs = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMedicalCoversConfigs")
	Call objectExistanceCheckAndClick(elmMedicalCoversConfigs,"Medical Covers Configurations button")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
	Set edtYearsOfServiceTaxFreeRo = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtYearsOfServiceTaxFreeRo")
	Set elmClaimComputationConfigurationsButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmClaimComputationConfigurationsButton")
	Call objectExistanceCheckAndClick(elmClaimComputationConfigurationsButton,"Claim Computation Configurations button")
	Call objectExistanceCheckAndEnter(edtYearsOfServiceTaxFreeRo, "Years Of Service" ,"2")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
	Set elmBenefitsConfigsCloseBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBenefitsConfigsCloseBtn")
	Call objectExistanceCheckAndClick(elmBenefitsConfigsCloseBtn,"Benefit Configurations Close button")
End Function
''Browser("brwFundMaster").Page("FundMaster | Pension Administr_2").WebElement("elmMedicalCoversConfigs").Click
Public Function createServiceProviders()
	Set elmNewFundManagerButton =  Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewFundManagerButton")
       Set elmFundManagersIcon = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFundManagersIcon")
       Set elmServiceProviderIcon = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmServiceProviderIcon")
       Set elmSchemeList = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSchemeList")
	
	Call objectExistanceCheckAndClick(elmServiceProviderIcon,"Service Providers Icon")
	Call objectExistanceCheckAndClick(elmFundManagersIcon,"Fund Managers Icon Icon")
	Call objectExistanceCheckAndClick(elmSchemeList,"Scheme List for Fund Managers")
	Call objectExistanceCheckAndClick(elmNewFundManagerButton,"New Fund Manager")
	
	Set edtAddress = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtAddress")
	Set edtBasisOfRem = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtBasisOfRem")
	Set edtFundManagerAgreementStatusField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerAgreementStatusField")
	Set edtFundManagerAppointmentDateField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerAppointmentDateField")
	Set edtFundManagerCodeField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerCodeField")
	Set edtFundManagerContractEndDateField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerContractEndDateField")
	Set edtFundManagerContractStarDateField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerContractStarDateField")
	Set edtFundManagerFundsInvestedField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerFundsInvestedField")
	Set edtFundManagerLevyFrequencyField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerLevyFrequencyField")
	Set edtFundManagerNameField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerNameField")
	Set edtFundManagerAmountPayableField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerAmountPayableField")
	Set edtFundManagerReportFrequencyField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagerReportFrequencyField")
	Set edtTownField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTownField")
	Set edtTpinField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTpinField")
	
	Call objectExistanceCheckAndEnter(edtFundManagerNameField, "Fund Manager's Name Field" ,"Demo FM")
	Call objectExistanceCheckAndEnter(edtFundManagerCodeField, "Fund Manager's Code Field" ,"455")
	Call objectExistanceCheckAndEnter(edtTpinField, "Fund Manager's Tpin Field" ,"41124563521")
	Call objectExistanceCheckAndEnter(edtAddress, "Fund Manager's Address Field" ,"524")
	Call objectExistanceCheckAndEnter(edtTownField, "Fund Manager's Town Field" ,"Nairobi")
	Call objectExistanceCheckAndEnter(edtBasisOfRem, "Fund Manager's Basis of Remittance Field" ,"Fixed Amount")
	Call objectExistanceCheckAndEnter(edtFundManagerAmountPayableField, "Fund Manager's Amount Payable Field" ,"200000")
	Call objectExistanceCheckAndEnter(edtFundManagerAppointmentDateField, "Fund Manager's Date of Appointment" ,"08/26/2022")
	Call objectExistanceCheckAndEnter(edtFundManagerContractStarDateField, "Fund Manager's Contract Start Date" ,"08/26/2022")
	Call objectExistanceCheckAndEnter(edtFundManagerContractEndDateField, "Fund Manager's Contract End Date" ,"08/26/2027")
	Call objectExistanceCheckAndEnter(edtFundManagerFundsInvestedField, "Fund Manager's Percentage Invested" ,"70")
	Call objectExistanceCheckAndEnter(edtFundManagerLevyFrequencyField, "Fund Manager's Levy Frequency" ,"Daily")
	Call objectExistanceCheckAndEnter(edtFundManagerAgreementStatusField, "Fund Manager's Agreement Signed Status" ,"Yes")
	'Call objectExistanceCheckAndEnter(edtFundManagerAgreementStatusField, "Fund Manager's Agreement Signed Status" ,"Yes")
	Call objectExistanceCheckAndEnter(edtFundManagerReportFrequencyField, "Fund Manager's Report Frequency" ,"Daily")
	
	'Save Fund Manager Form
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
'	Do Fund Management Payment
'	Call payFundManagementFee()

End Function

Public Function payFundManagementFee()
	Set edtFundManagementRefNo = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementRefNo")
       Set edtFundManagementAmount = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementAmount")
       Set edtFundManagementCurrency = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementCurrency")
       Set edtFundManagementDateBooked = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementDateBooked")
       Set edtFundManagementMonth = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementMonth")
       Set edtFundManagementSpotRate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementSpotRate")
       Set edtFundManagementYear = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtFundManagementYear")
       Set edtManagementFeePaticularsField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtManagementFeePaticularsField")
       Set elmFundManagerManagementFeeBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFundManagerManagementFeeBtn")
       Set elmTopMostFundManagerBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmTopMostFundManagerBox")
       
      	Call objectExistanceCheckAndClick(elmTopMostFundManagerBox,"Fund Manager Checkbox")
    	Call objectExistanceCheckAndClick(elmFundManagerManagementFeeBtn,"Management Fee Payment Button")
    	Call objectExistanceCheckAndEnter(edtManagementFeePaticularsField, "Fund Management Fee parrticulars" ,"Payment01")
    	Call objectExistanceCheckAndEnter(edtFundManagementMonth, "Fund Management Fee Month" ,"March")
       Call objectExistanceCheckAndEnter(edtFundManagementYear, "Fund Management Fee Year" ,"2022")
       Call objectExistanceCheckAndEnter(edtFundManagementDateBooked, "Fund Management Fee DateBooked" ,"08/26/2022")
       Call objectExistanceCheckAndEnter(edtFundManagementAmount, "Fund Management Fee Amount" ,"8000")
       Call objectExistanceCheckAndEnter(edtFundManagementCurrency, "Fund Management Fee Currency" ,"Kenyan shilling")
       Call objectExistanceCheckAndEnter(edtFundManagementSpotRate, "Fund Management Spot Rate" ,"5")
       Call objectExistanceCheckAndEnter(edtFundManagementRefNo, "Fund Management Ref No" ,"050")
End Function

Public Function createCustodian()
	Set elmCustodiansBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCustodiansBtn")
	Set edtCustodianName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianName")
	Set edtCustodianAddress = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianAddress")
	Set edtCustodianAgreementStatus = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianAgreementStatus")
	Set edtCustodianContractEndDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianContractEndDate")
	Set edtCustodianContractStartDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianContractStartDate")
	Set edtCustodianLevyFeeFrequency = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianLevyFeeFrequency")
	Set edtCustodianPin = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianPin")
	Set edtCustodianTown = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtCustodianTown")
'	Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebRadioGroup("cust.allowNotifications").Select
	Set elmNewCustodianBtn = Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("elmNewCustodianBtn").Click
	
End Function

Public Function createNewMember()
	Set memberDateOfEmployment = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberDateOfEmployment")
	Set memberDateOfBirth = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberDateOfBirth")
	Set memberFirstname = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberFirstname")
	Set memberGender = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberGender")
	Set memberIdNo = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberIdNo")
	Set memberCurrentMaritalStatus = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberCurrentMaritalStatus")
	Set memberMaritalStatusAtEntry = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberMaritalStatusAtEntry")
	Set memberPinNo = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberPinNo")
	Set memberSurname = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberSurname")
	Set memberTitle = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberTitle")
	Set memberCostCenter = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberCostCenter")
	Set memberDateJoinedScheme = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberDateJoinedScheme")
	Set memberMemberClass = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberMemberClass")
	Set memberPrimaryPhoneNumber = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("memberPrimaryPhoneNumber")
	Set elmNewMemberBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewMemberBtn")
	Set elmMemberDropDownIcon = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberDropDownIcon")
	Set elmMemberApprovalBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApprovalBtn")
	Set elmTopCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmTopCheckbox")
	
	Set elmCertifyMember = Browser("brwFundMaster").Page("pgFundMaster").Link("elmCertifyMember")
	Set elmAcceptYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAcceptYes")
	Set elmAuthorizeMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorizeMember")
	Set elmMemberApproval = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApproval")
	Set elmMemberApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApprove")
	Set elmMemberApprovalBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApprovalBtn")
	

	
	Call objectExistanceCheckAndClick(elmMemberDropDownIcon,"Member Drop Down Icon")
      	Call objectExistanceCheckAndClick(elmNewMemberBtn,"New Member Button")
      	Call objectExistanceCheckAndEnter(memberTitle, "Member Title" ,"Mr.")
    	Call objectExistanceCheckAndEnter(memberSurname, "Member Surname" ,"Husein")
    	Call objectExistanceCheckAndEnter(memberFirstname, "Member First Name" ,"Marjan")
       Call objectExistanceCheckAndEnter(memberGender, "Gender" ,"Male")
       Call objectExistanceCheckAndEnter(memberCurrentMaritalStatus, "Current Marital Status" ,"Never Married")
       Call objectExistanceCheckAndEnter(memberMaritalStatusAtEntry, "Marital Status at Entry Date" ,"Never Married")
       Call objectExistanceCheckAndEnter(memberDateOfBirth, "Date Of Birth" ,"08/27/2004")
       Call objectExistanceCheckAndEnter(memberIdNo, "National Identification Number" ,"45555995")
       Call objectExistanceCheckAndEnter(memberPinNo, "Member Pin Number" ,"25365811222")
       Call objectExistanceCheckAndEnter(memberPrimaryPhoneNumber, "Member Primary Phone Number" ,"0412556235")
       Call objectExistanceCheckAndEnter(memberDateOfEmployment, "Date Of Employment" ,"08/10/2022")
       Call objectExistanceCheckAndEnter(memberDateJoinedScheme, "Date Of Joining Scheme" ,"08/10/2022")
       Call objectExistanceCheckAndEnter(memberCostCenter, "Member Cost Center" ,"QA scheme Cost Centre")
       Call objectExistanceCheckAndEnter(memberMemberClass, "Member Class" ,"QA Systech Sponsor MEMBER CLASS")
      	
      	
      	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
	
	Call objectExistanceCheckAndClick(elmMemberApprovalBtn,"Member Approval Button")
	Call clickOnCheckBox(elmTopCheckbox, "Checkbox Selection")
	Call objectExistanceCheckAndClick(elmMemberApproval,"Member Approval Button")
	Call objectExistanceCheckAndClick(elmCertifyMember,"Certify Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Authorize Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Call objectExistanceCheckAndClick(elmAuthorizeMember,"Authorize Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Call objectExistanceCheckAndClick(elmMemberApprove,"Approve Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
End Function


Public Function createPaypoints()
	Browser("brwFundMaster").Page("pgFundMaster").WebElement("schemeDropdownBtn").Click
	Set elmBankStatus = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmBankStatus")
	Set elmBankCode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmBankCode")
	Set elmBankName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmBankName")
	Set elmBankRegime = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmBankRegime")
	Set elmBankType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmBankType")
	Set elmNewPaypointBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewPaypointBtn")
	Set elmOtherSetupSchemeDropdown = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmOtherSetupSchemeDropdown")
	Set elmPayPointsBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPayPointsBtn")
	Set elmThirdPaypoint = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmThirdPaypoint")
	Set btnRemoveSelected = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnRemoveSelected")

	Call objectExistanceCheckAndClick(elmOtherSetupSchemeDropdown,"Other Setup")
	Call objectExistanceCheckAndClick(elmPayPointsBtn,"Pay Paypoints")
	Call objectExistanceCheckAndClick(elmNewPaypointBtn,"New Paypoint")
		randomBankName = "Bank_" & fnRandomNumberWithDateTimeStamp()
       Call objectExistanceCheckAndEnter(elmBankName, "Bank Name" ,randomBankName)
       	randomBankCode =  fnRandomNumberWithDateTimeStamp()
       Call objectExistanceCheckAndEnter(elmBankCode, "Bank Code" ,randomBankCode)
       Call objectExistanceCheckAndEnter(elmBankRegime, "Bank Regime" ,"Kenya")
       Call objectExistanceCheckAndEnter(elmBankType, "PayPoint Type" ,"Bank")
       Call objectExistanceCheckAndEnter(elmBankStatus, "PayPoint Status" ,"Active")
       
      Call saveForm()
      Call createPaypointBranches()
      	
'      	Remove Point & PAypoint Branches
	Call clickOnCheckBox(elmThirdPaypoint, "Checkbox Selection")
	Call objectExistanceCheckAndClick(btnRemoveSelected,"Remove Button")
	Set elmAcceptYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAcceptYes")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")

End Function

Public Function createPaypointBranches()
	Set elmPaypointBranchStatus = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmPaypointBranchStatus")
	Set elmPaybointBranchBank = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmPaybointBranchBank")
	Set elmPaypointBranchCode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmPaypointBranchCode")
	Set elmPaypointBranchLocation = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmPaypointBranchLocation")
	Set elmPaypointBranchName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmPaypointBranchName")
	Set elmNewPaypointBranchBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewPaypointBranchBtn")
	Set elmPaypointBranchesBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPaypointBranchesBtn")

	Call objectExistanceCheckAndClick(elmPaypointBranchesBtn,"Paypoint Branches")
	Call objectExistanceCheckAndClick(elmNewPaypointBranchBtn,"New Paypoint Branch")
		randomBankBranch = "BankBranch_" & fnRandomNumberWithDateTimeStamp()
       Call objectExistanceCheckAndEnter(elmPaypointBranchName, "Paypoint Branch Name" , randomBankBranch)
       Call objectExistanceCheckAndEnter(elmPaypointBranchCode, "Paypoint Branch Code" ,"253")
       Call objectExistanceCheckAndEnter(elmPaypointBranchLocation, "Paypoint Branch Location" ,"Nairobi")
       Call objectExistanceCheckAndEnter(elmPaybointBranchBank, "Paypoint Branch Selected Bank" , randomBankName)
       Call objectExistanceCheckAndEnter(elmPaypointBranchStatus, "Paypoint Branch Status" ,"Active")
       Call saveForm()
End Function

Public Function enableLocationBreakdown()
	Set elmSystemUtilities = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSystemUtilities")
	Set elmFormFieldsValidationMatrix = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFormFieldsValidationMatrix")
	Set fieldconfigsenableLocationBre = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("fieldconfigs.enableLocationBre")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
       Call objectExistanceCheckAndClick(elmSystemUtilities,"System Utilities")
       Call objectExistanceCheckAndClick(elmFormFieldsValidationMatrix,"FormFieldsValidationMatrix")
       Call objectExistanceCheckAndEnter(fieldconfigsenableLocationBre, "Enable location breakdown" ,"Yes")
       Call objectExistanceCheckAndClick(buttonSave,"Save button")
End Function

Public Function verifyLocationBreakdownExist()
	Set elmDistricts = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDistricts")
	Set elmVillages = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmVillages")
	Call verifyObjectExist(elmDistricts,"Districts")
	Call verifyObjectExist(elmVillages,"Village")
End Function

Public Function createNewDistrict()
	Set elmDistricts = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDistricts")
	Set btnOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnOperations")
	Set elmNewDistrict = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewDistrict")
	Set edtname = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("district.name")
	Set edtcode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("district.code")
	Set edtdescription = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("district.description")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgSavedSucccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSavedSucccessfully")
	Call objectExistanceCheckAndClick(elmDistricts,"Districts")
	Call objectExistanceCheckAndClick(btnOperations,"Operations")
	Call objectExistanceCheckAndClick(elmNewDistrict,"New District")
	Call objectExistanceCheckAndEnter(edtname, "Name" ,"Automation District Name")
	Call objectExistanceCheckAndEnter(edtcode, "Code", "Automation District Code")
	Call objectExistanceCheckAndEnter(edtdescription, "Desciption", "Automation District Desciption")
	
	Call objectExistanceCheckAndClick(buttonSave,"Save")
	Call objectExistanceCheckAndClick(elmMsgSavedSucccessfully,"Msgbox Saved Succcessfully")
End Function

Public Function createNewDistrictViaTemplate()
	Set elmDistricts = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDistricts")
	Call updateTemplateForBatchDistricts()
	Set btnOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnOperations")
	Set eleImportDistrictFromTemplates = Browser("brwFundMaster").Page("pgFundMaster").WebElement("eleImportDistrictFromTemplates")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_2")
	Set chkBox =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Call objectExistanceCheckAndClick(elmDistricts,"Districts")
	Call objectExistanceCheckAndClick(btnOperations,"Operations")
	Call objectExistanceCheckAndClick(eleImportDistrictFromTemplates,"Import District From Templates")
	Call browserAndUpload(strMemberExcelFilePath)
	wait 3
	Call objectExistanceCheckAndClick(chkBox, "Check box")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
	Call objectExistanceCheckAndClick(elmMsgDone,"Msgbox Done")
End Function

Public Function turnOffLocationBreakdown
	Set elmSystemUtilities = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSystemUtilities")
	Set elmFormFieldsValidationMatrix = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFormFieldsValidationMatrix")
	Set fieldconfigsenableLocationBre = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("fieldconfigs.enableLocationBre")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMainMenuDropdown = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMainMenuDropdown")
	Set elmAdminPanelInner = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAdminPanelInner")
	
	Call objectExistanceCheckAndClick(elmMainMenuDropdown,"Go to Main Menu Dropdown")    
       Call objectExistanceCheckAndClick(elmAdminPanelInner,"Go to Admin Panel")  
       Call objectExistanceCheckAndClick(elmSystemUtilities,"System Utilities")
       Call objectExistanceCheckAndClick(elmFormFieldsValidationMatrix,"FormFieldsValidationMatrix")
       Call objectExistanceCheckAndEnter(fieldconfigsenableLocationBre, "Enable location breakdown" ,"No")
       Call objectExistanceCheckAndClick(buttonSave,"Save button")   
End Function

Public Function AddTraditionalAuthorities()
	Set edtTraditionalAuthorityDescriptionField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTraditionalAuthorityDescriptionField")
	Set edtTraditionalAuthorityNameField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTraditionalAuthorityNameField")
	Set edtTraditionalAuthorityCodeField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtTraditionalAuthorityCodeField")

	Set elmBtnTraditionalAuthority = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBtnTraditionalAuthority")
	Set elmDistrictCheckboxSelection = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDistrictCheckboxSelection")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmDistricts = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDistricts")
	
	Call objectExistanceCheckAndClick(elmDistricts,"Districts")
	Call clickOnCheckBox(elmDistrictCheckboxSelection, "Checkbox Selection")
	Call objectExistanceCheckAndClick(elmBtnTraditionalAuthority,"Click on Traditional Authority")
	Call objectExistanceCheckAndEnter(edtTraditionalAuthorityNameField, "Name", "CC")
	Call objectExistanceCheckAndEnter(edtTraditionalAuthorityCodeField, "Code", "023")
	Call objectExistanceCheckAndEnter(edtTraditionalAuthorityDescriptionField, "Description", "County Commissioner")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
End Function

Public Function AddTraditionalAuthoritiesViaTemplate()
	Set elmImoprtAuthorityTemplateButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmImoprtAuthorityTemplateButton")
'	Set batchSchedule = Browser("brwFundMaster").Page("pgFundMaster").WebFile("batchSchedule")
	Set btnUpload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUpload")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
'	Set edtBatchSchedulePath = Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebEdit("edtBatchSchedulePath")
	Call objectExistanceCheckAndClick(elmImoprtAuthorityTemplateButton,"Click on Import T.Authority")
	Call browserAndUpload(strPathToTemplate)
	Call objectExistanceCheckAndClick(btnUpload,"Click Upload")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
End Function

Public Function saveForm()
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
	Set elmMsgSaveSuccessful_2 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgSaveSuccessful_2")
'	Call verifyObjectExist(elmMsgSaveSuccessful_2,"elmMsgSaveSuccessful_2")
End Function

Public Function gotoMembersDocumentsChecklist()
	Set elmMembersDocumentsChecklist  = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMembersDocumentsChecklist")
	Set elmMemberMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberMenu")
	Call objectExistanceCheckAndClick(elmMemberMenu,"Member Menu")
	Call objectExistanceCheckAndClick(elmMembersDocumentsChecklist,"Members Documents Checklist")
	
End Function

Public Function createNewMembersDocumentsChecklist()
	Set btnNew = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnNew")
	Set checklistType= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.checklistType")
	Set name= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.name")
	Set mandatory = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.mandatory")
	Set checklistOwner = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.checklistOwner")
	Set ageBracket = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.ageBracket")
	Set beneficiaryCategory = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.beneficiaryCategory")
	Set appliesForAll = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("checklist.appliesForAll")
	
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone")
	Call objectExistanceCheckAndClick(btnNew,"New")
	Call objectExistanceCheckAndEnter(checklistType, "checklist Type", "Nomination Form")
	Call objectExistanceCheckAndEnter(name, "checklist Name", "Automation")
	Call objectExistanceCheckAndEnter(mandatory, "checklist mandatory", "Yes")	
	Call objectExistanceCheckAndEnter(checklistOwner, "checklist Owner", "Beneficiary")	
	Call objectExistanceCheckAndEnter(beneficiaryCategory, "beneficiary Category", "Spouse")	
	Call objectExistanceCheckAndEnter(ageBracket, "checklist age Bracket", "Children Only")	
	Call objectExistanceCheckAndEnter(appliesForAll, "applies For All", "Yes")	
	Call objectExistanceCheckAndClick(buttonSave,"button Save")
	Call verifyObjectExist(elmMsgDone,"Message box Done")
End Function


Public Function gotoMemberBatchRegister()
	Set elmMemberMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberMenu")
	Set elmMemberBatchRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberBatchRegister")
	Call objectExistanceCheckAndClick(elmMemberMenu,"Member Menu")
	Call objectExistanceCheckAndClick(elmMemberBatchRegister,"Member Batch Register")
End Function

Public Function doBatchApproval()
	Set elmTopCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmTopCheckbox")
	Set elmAuthorization = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorization")
	Set elmCertifyMember = Browser("brwFundMaster").Page("pgFundMaster").Link("elmCertifyMember")
	Set elmAreYouSureYouWantToCertifyBatch = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgAreYouSureYouWantToCertifyBatch")
	Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	Set elmCertifiedSuccessfully= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCertifiedSuccessfully")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Set elmAuthorizeMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorizeMember")
	Set elmMsgAreYouSureYouWantToAuthorizeBatch = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgAreYouSureYouWantToAuthorizeBatch")
	Set elmMemberApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApprove")
	Set elmMsgAreYouSureYouWanttoApproveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgAreYouSureYouWanttoApproveBatch")
	Set elmMsgAuthorizedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgAuthorizedSuccessfully")
	Set elmMsgCertifiedSuccessfully = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgCertifiedSuccessfully")
	Set elmDoneApprovingMembers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDoneApprovingMembers")

	Call clickOnCheckBox(elmTopCheckbox, "Checkbox Selection")
	
	Call objectExistanceCheckAndClick(elmAuthorization,"Authorization")
	Call objectExistanceCheckAndClick(elmCertifyMember,"Certify")
	Call verifyObjectExist(elmAreYouSureYouWantToCertifyBatch,"Msg Are You Sure You Want To Certify Batch")
	Call objectExistanceCheckAndClick(btnYes,"Yes")
	Call objectExistanceCheckAndClick(btnPopupOk,"Ok")
	
	Call objectExistanceCheckAndClick(elmAuthorization,"Authorization")
	Call objectExistanceCheckAndClick(elmAuthorizeMember,"Authorize")
	Call verifyObjectExist(elmMsgAreYouSureYouWantToAuthorizeBatch,"Msg Are You Sure You Want To Authorize Batch")
	Call objectExistanceCheckAndClick(btnYes,"Yes")
	Call objectExistanceCheckAndClick(btnPopupOk,"Ok")
	
	Call objectExistanceCheckAndClick(elmAuthorization,"Authorization")
	Call objectExistanceCheckAndClick(elmMemberApprove,"Approve")
	Call verifyObjectExist(elmMsgAreYouSureYouWanttoApproveBatch,"Msg Are You Sure You Want To Approve Batch")
	Call objectExistanceCheckAndClick(btnYes,"Yes")
	Call objectExistanceCheckAndClick(btnPopupOk,"Ok")
End Function

Public Function clickOnDynamicBankName(bankName)
	Set objBankName = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmDynamicBankName")
	objBankName.SetTOProperty "innertext", bankName
	Call clickOnCheckBox(objBankName, "Dynamic Bank Name")
End Function

Public Function gotoMembersPage()
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	set objEleImportMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welImportMembers")
       set objEleMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       Set elmMemberRegisterInner = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberRegisterInner")
       Call objectExistanceCheckAndClick(objEleMemberRegister,"Member Register Module")
       Call objectExistanceCheckAndClick(elmMemberRegisterInner,"Member Register")
End Function

Public Function UpdateMemberDetails()
	Set edtMemberTelephone = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberTelephone")
	Set edtMemberDOBField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberDOBField")
	Set edtMEmberNationalIdField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMEmberNationalIdField")
	Set edtMemberPrimaryPhoneField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberPrimaryPhoneField")
	Set edtMemberSecPhoneField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberSecPhoneField")
	Set elmExistingMembers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmExistingMembers")
	Set elmMemberCheckBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberCheckBox")
	Set elmMemberDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberDetails")
	Set elmMemberOperationsBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberOperationsBtn")
	Set elmSponsorCheckBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorCheckBox")
	Set elmViewSponsorMembers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmViewSponsorMembers")
	Set saveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	
	
	Call gotoMembersPage()
	Call objectExistanceCheckAndClick(elmExistingMembers,"Existing MEmbers Button")
'	Call objectExistanceCheckAndClick(elmExistingMembers,"Existing MEmbers Button")
	Call clickOnCheckBox(elmSponsorCheckBox, "Sponsor Checkbox Selection")
	Call objectExistanceCheckAndClick(elmViewSponsorMembers,"View Members")
	Call clickOnCheckBox(elmMemberCheckBox, "Member Checkbox Selection")
	Call objectExistanceCheckAndClick(elmMemberOperationsBtn,"Member Operations Button")
	Call objectExistanceCheckAndClick(elmMemberDetails,"Member Details")
	Call objectExistanceCheckAndEnter(edtMemberDOBField, "Member DOB Field", "01/01/1962")	
	Call objectExistanceCheckAndEnter(edtMemberPrimaryPhoneField, "Primary Phone No Field", "0723787120")	
	Call objectExistanceCheckAndEnter(edtMemberSecPhoneField, "Secondary Phone No Field", "0723787120")	
'	Call objectExistanceCheckAndEnter(edtMemberTelephone, "Member Telephone Field", "0723787120")	
	Call objectExistanceCheckAndClick(saveBatch,"Save Button")
	
	
End Function

Public Function AddMemberNotes()
	Set elmMemberOperationsBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberOperationsBtn")
	Set elmMemberNoteTittle = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmMemberNoteTittle")
	Set elmMemberNoteBody = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmMemberNoteBody")
	Set elmAddMemberNotesBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAddMemberNotesBtn")
	Set saveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	
	Call objectExistanceCheckAndClick(elmMemberOperationsBtn,"Member Operations Button")
	Call objectExistanceCheckAndClick(elmAddMemberNotesBtn,"Member Notes Button")
	Call objectExistanceCheckAndEnter(elmMemberNoteTittle, "Member Notes Title Field", "Savings Policy")	
	Call objectExistanceCheckAndEnter(elmMemberNoteBody, "Member Notes Body Field", "Savings Policy is Saved in this note")	
	Call objectExistanceCheckAndClick(saveBatch,"Save Button")
End Function

Public Function AddBeneficiariesInBatch()
	Set elmMemberDropDownIcon = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberDropDownIcon")
	Set edtBeneficiaryTemplatePath = Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebEdit("edtBeneficiaryTemplatePath")
	Set elmBeneficiariesBtn = Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("elmBeneficiariesBtn")
	Set elmImportFromTemplatesDropdown = Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("elmImportFromTemplatesDropdown")
	Set btnUpload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUpload")

	Call objectExistanceCheckAndClick(elmMemberDropDownIcon,"Member Dropdown Button")
	Call objectExistanceCheckAndClick(elmMemberDropDownIcon,"Import From Templates Dropdown Button")
	Call objectExistanceCheckAndClick(elmBeneficiariesBtn,"Beneficiary Button")
	strBeneficiaryExcelFilePath = "C:\Users\Administrator\Documents\MemberUpload.xlsx"
	call browserAndUpload(strBeneficiaryExcelFilePath)
End Function


Public Function updateExcel(filePath,columnIndex,dynamicValue,recordCount)
	set objExcel = CreateObject("Excel.Application")
	objExcel.Application.DisplayAlerts = False
	set objWorkbook=objExcel.workbooks.Open(filePath)
	For Iterator = 1 To recordCount Step 1
		tempValue = dynamicValue  & fnRandomNumber()
		objExcel.cells(Iterator+1,columnIndex).value = tempValue
	Next
	objWorkbook.Save
	objWorkbook.Close
End Function

Public Function updateTemplateForBatchDistricts()
	Call updateExcel( strMemberExcelFilePath,1,"Name_" ,10)
	Call updateExcel( strMemberExcelFilePath,2,"Code_" ,10)
	Call updateExcel( strMemberExcelFilePath,3,"Description_" ,10)
End Function

'Contributions
Public Function setContributionRates()
	Set edtConRateMemberClass = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtConRateMemberClass")
	Set edtAdminFees = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtAdminFees")
	Set edtAVC = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtAVC")
	Set edtBrokerFees = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtBrokerFees")
	Set edtContRateEffectiveDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContRateEffectiveDate")
	Set edtContRateSponsor = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContRateSponsor")
	Set edtEmployeeRate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtEmployeeRate")
	Set edtEmployerRate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtEmployerRate")
	Set edtGeneralReserveInsuranceRate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtGeneralReserveInsuranceRate")
	Set edtGroupLifeInsuranceRate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtGroupLifeInsuranceRate")
	Set elmContributionRates = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionRates")
	Set elmNewContributionsRateBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewContributionsRateBtn")

	Call objectExistanceCheckAndClick(elmContributionRates,"Click onContribution Rates")
	Call objectExistanceCheckAndClick(elmNewContributionsRateBtn,"New Contribution Rates Button")
	Call objectExistanceCheckAndEnter(edtEmployeeRate, "Contribution Employee Rate", "5000")	
	Call objectExistanceCheckAndEnter(edtEmployerRate, "Contribution Employer Rate", "10000")	
	Call objectExistanceCheckAndEnter(edtAVC, "Contribution AVC", "0")	
	Call objectExistanceCheckAndEnter(edtAdminFees, "Contribution Admin Fees", "1")	
	Call objectExistanceCheckAndEnter(edtBrokerFees, "Contribution Broker Fees", "1")	
	Call objectExistanceCheckAndEnter(edtGroupLifeInsuranceRate, "Group Life Insurance Rate", "1")	
	Call objectExistanceCheckAndEnter(edtGeneralReserveInsuranceRate, "General Reserve Insurance Rate", "1")	
	Call objectExistanceCheckAndEnter(edtContRateEffectiveDate, "Contribution Rate Effective Date", "11/10/2022")	
	Call objectExistanceCheckAndEnter(edtContRateSponsor, "Contribution Rate Sponsor", "QA scheme sponsor2")	
	Call objectExistanceCheckAndEnter(edtConRateMemberClass, "Contribution Rate Member Class", "QA scheme MEMBER CLASS")	
	Call saveForm()
	Call refreshPage()
End Function


Public Function singleContribution()
	Set edtMemberStatusField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberStatusField")
	Set elmMemberRegisterInner = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberRegisterInner")
	Set elmMemberSelectCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberSelectCheckbox")
	Set elmMEmberStatusDropdown = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMEmberStatusDropdown")
	Set elmMemberOperationsBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberOperationsBtn")
	Set edtContributionComments = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionComments")
	Set edtContributionDatePaid = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionDatePaid")
	Set edtContributionEE = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionEE")
	Set edtContributionER = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionER")
	Set edtContributionMonth = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionMonth")
	Set edtContributionSalary = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionSalary")
	Set edtContributionType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionType")
	Set edtContributionYear = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtContributionYear")
	Set elmNewSingleContributionBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmNewSingleContributionBtn")
	Set elmContributionStatus = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmContributionStatus")
	Set elmContributionDropdown = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionDropdown")
	Set elmAuthorizationBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorizationBtn")
	Set elmContributionApproval =Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionApproval")
	Set elmContributionsCheckBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionsCheckBox")
	Set elmCertifyMember = Browser("brwFundMaster").Page("pgFundMaster").Link("elmCertifyMember")
	Set elmSponsorCheckBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSponsorCheckBox")
	Set elmViewSponsorMembers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmViewSponsorMembers")


	Call objectExistanceCheckAndClick(elmMemberRegisterInner,"Click on Member Register")
	Call clickOnCheckBox(elmSponsorCheckBox, "Sponsor Checkbox Selection")
	Call objectExistanceCheckAndClick(elmViewSponsorMembers,"Click on View Members")
	Call objectExistanceCheckAndEnter(edtMemberStatusField, "Member Status", "Active")
	wait 3
'	Call objectExistanceCheckAndClick(elmMemberSelectCheckbox, "Check box")
	Call clickOnCheckBox(elmMemberSelectCheckbox, "Member Checkbox Selection")
	Call objectExistanceCheckAndClick(elmMemberOperationsBtn,"Click Member Operations")
	Call objectExistanceCheckAndClick(elmNewSingleContributionBtn,"Click New Single Contribution")
	Call objectExistanceCheckAndEnter(edtContributionDatePaid, "Contribution Date", "03/10/2022")
	Call objectExistanceCheckAndEnter(edtContributionType, "Contribution Type", "Normal Contributions")		
	Call objectExistanceCheckAndEnter(edtContributionSalary, "Contribution Salary", "200000")	
	Call objectExistanceCheckAndEnter(edtContributionEE, "Contribution EE", "10000")	
	Call objectExistanceCheckAndEnter(edtContributionER, "Contribution ER", "20000")	
	Call objectExistanceCheckAndEnter(edtContributionMonth, "Contribution Month", "March")	
	Call objectExistanceCheckAndEnter(edtContributionYear, "Contribution Year", "2022")	
	Call objectExistanceCheckAndEnter(elmContributionStatus, "Contribution Status", "Registered")	
	Call objectExistanceCheckAndEnter(edtContributionComments, "Contribution Comments", "March 2022 Contribution")	
	Call saveForm()

'	Contribution Approval
	Call objectExistanceCheckAndClick(elmContributionDropdown,"Click on Contribution Dropdown")
	Call objectExistanceCheckAndClick(elmContributionApproval,"Click on Contribution Approval")
	Call approve()

'Contribution Posting
	Set elmPost = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPost")
	Call objectExistanceCheckAndClick(elmPost,"Click on Post")
	wait 2
	
End Function

Public Function approve()
	Set elmCertifyMember = Browser("brwFundMaster").Page("pgFundMaster").Link("elmCertifyMember")
	Set elmAcceptYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAcceptYes")
	Set elmAuthorizeMember = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorizeMember")
	Set elmMemberApproval = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApproval")
	Set elmMemberApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberApprove")
	Set elmAuthorizationBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAuthorizationBtn")
	Set elmContributionsCheckBox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionsCheckBox")
	Set elmMemberSelectCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberSelectCheckbox")
	Call clickOnCheckBox(elmContributionsCheckBox, "Checkbox Selection")
'	Call clickOnCheckBox(elmMemberSelectCheckbox, "Checkbox Selection")
	Call objectExistanceCheckAndClick(elmAuthorizationBtn,"Click on Authorization Button")
	Call objectExistanceCheckAndClick(elmCertifyMember,"Certify Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Authorize Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Call objectExistanceCheckAndClick(elmAuthorizeMember,"Authorize Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Call objectExistanceCheckAndClick(elmMemberApprove,"Approve Member")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Accept Certify Member")
	Set btnPopupOk = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnPopupOk")
	Call objectExistanceCheckAndClick(btnPopupOk,"btnPopupOk")
End Function

Public Function gotoBeneficiariesUpdate()
	Set elmMemberMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberMenu")
	Set elmMenuImportFromTemplate= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuImportFromTemplate")
	Set elmMenuBeneficiariesUpdate = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuBeneficiariesUpdate")
	Set elmUsingNominationFormNumber =Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmUsingNominationFormNumber")
	
	Call objectExistanceCheckAndClick(elmMemberMenu,"Member Menu")
	Call objectExistanceCheckAndClick(elmMenuImportFromTemplate,"Menu Import From Template")
	Call objectExistanceCheckAndClick(elmMenuBeneficiariesUpdate,"Menu Beneficiaries Update")
	Call objectExistanceCheckAndClick(elmUsingNominationFormNumber,"Using Nomination Form Number")
End Function

Public Function uploadBeneficiariesTemplates()
	Set batchSchedule = Browser("brwFundMaster").Page("pgFundMaster").WebFile("batchSchedule")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_2")
	Set chkBox =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	''Call objectExistanceCheckAndClick(batchSchedule,"Browse")
	Call browserAndUpload(strMemberExcelFilePath)
	wait 3
	Call objectExistanceCheckAndClick(chkBox, "Check box")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
	Call objectExistanceCheckAndClick(elmMsgDone,"Msgbox Done")
End Function

Public Function gotMemberImportPage()
	Set elmMemberUpdates = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberUpdates")
	Call objectExistanceCheckAndClick(elmMemberUpdates, "Member Updates")
End Function

Public Function gotoEnrolmentNominationForms() 
	Set elmEnrolmentNominationForms = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmEnrolmentNominationForms")
	Set elmMemberMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberMenu")
	Call objectExistanceCheckAndClick(elmMemberMenu,"Member Menu")
	Call objectExistanceCheckAndClick(elmEnrolmentNominationForms,"Enrolment Nomination Forms")
End Function
Public Function uploadMemberImportTemplates()
	Set batchSchedule = Browser("brwFundMaster").Page("pgFundMaster").WebFile("batchSchedule")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_2")
	Set chkBox =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Call browserAndUpload(strMemberExcelFilePath)
	wait 3
	Call objectExistanceCheckAndClick(chkBox, "Check box")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
	Call objectExistanceCheckAndClick(elmMsgDone,"Msgbox Done")
End Function

Public Function uploadMemberEndorseTemplates()
	Set batchSchedule = Browser("brwFundMaster").Page("pgFundMaster").WebFile("batchSchedule")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_2")
	Set chkBox =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox03")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	Call browserAndUpload(strMemberEndorseTemplatFilePath)
	wait 3
	'Call objectExistanceCheckAndClick(chkBox, "Check box")
	Call objectExistanceCheckAndClick(buttonSave,"Save")
	Call objectExistanceCheckAndClick(elmMsgDone,"Msgbox Done")
	Call objectExistanceCheckAndClick(btnClose,"Close")
End Function

'This function should be called after batch contributions(developed by Jeevan) for proper flow
Public Function showContributionBatchDetails()
	Set elmContributionDropdown = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionDropdown")
	Set elmBatchContributions = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBatchContributions")
	Set elmBatchContributionsCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBatchContributionsCheckbox")
	Set elmBatchContributionsRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBatchContributionsRegister")
	Set elmBurgerMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBurgerMenu")
	Set elmShowDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmShowDetails")
	Set elmBatchExceptions = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBatchExceptions")
	
	Call objectExistanceCheckAndClick(elmContributionDropdown,"Click on Contribution Dropdown")
	Call objectExistanceCheckAndClick(elmBatchContributionsRegister,"Click on Contribution Dropdown")
	Call clickOnCheckBox(elmBatchContributionsCheckbox, "Batch Contribution Checkbox Selection")
	Call clickBurgerMenuAndShowDetails()
	Call objectExistanceCheckAndClick(elmBatchContributions,"Click on Batch Contribution Details/Members")
	Call objectExistanceCheckAndClick(elmBatchExceptions,"Click on Batch Exceptions ")
End Function

Public Function clickBurgerMenuAndShowDetails
	Set elmBurgerMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBurgerMenu")
	Set elmShowDetails = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmShowDetails")
	Call objectExistanceCheckAndClick(elmBurgerMenu,"Click on Burger Menu")
	Call objectExistanceCheckAndClick(elmShowDetails,"Toggle on Show Details")	
End Function

Public Function tieContributionsToReceipt()
	Set elmContributionAndBalancesConfigButton = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionAndBalancesConfigButton")
	Call objectExistanceCheckAndClick(elmContributionAndBalancesConfigButton,"Contributions and Balances button")
	Set rdTieContToReceiptsMandatory = Browser("brwFundMaster").Page("pgFundMaster").WebRadioGroup("rdTieContToReceiptsMandatory")
	Set edtDeficitTreatMentMode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDeficitTreatMentMode")
	Set rdAllowSurplus_DeficitContribution = Browser("brwFundMaster").Page("pgFundMaster").WebRadioGroup("rdAllowSurplus_DeficitContribution")
	Set buttonSave = Browser("brwFundMaster").Page("pgFundMaster").WebElement("buttonSave")
	rdTieContToReceiptsMandatory.Select
	Call objectExistanceCheckAndEnter(edtDeficitTreatMentMode, "Deficit Treatment Mode", "Pro-Rated Deficit")	
	Call objectExistanceCheckAndEnter(edtDeficitTreatMentMode, "Deficit Treatment Mode", "Reserve Outflow")
	rdAllowSurplus_DeficitContribution.Select
	Call objectExistanceCheckAndClick(buttonSave,"buttonSave")
'	rdopolicy_passwordHistory.Select  "#0"
End Function

Public Function gotoContributionBilling()
       set welMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       set elmMenuContribution = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuContribution")
	set elmContributionsReceivables = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionsReceivables")
	set elmContributionsBilling = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmContributionsBilling")

       Call objectExistanceCheckAndClick(welMemberRegister,"Member Register")
       Call objectExistanceCheckAndClick(elmMenuContribution,"Menu Contribution")
       Call objectExistanceCheckAndClick(elmContributionsReceivables,"Contributions Receivables")
       Call objectExistanceCheckAndClick(elmContributionsBilling,"Contributions Billing")
End Function

Public Function generateContributionBill()
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	Set elmGenerateContributions = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmGenerateContributions")
	
	Set billDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("billDate")
	Set objMonth = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("month")
	Set objYear = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("year")
	Set expectedPaymentDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("expectedPaymentDate")
	Set billForAllSponsors = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("billForAllSponsors")
	Set ignoreScheme= Browser("brwFundMaster").Page("pgFundMaster").WebEdit("ignoreScheme")
	Set btnUpdateMemberSalaries=  Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnUpdateMemberSalaries-btnInn")
	Set elmMsgDone = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMsgDone_3")
	Set btnClose = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnClose")
	Set elmRunContributionBilling = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRunContributionBilling")
	Set elmBenefitsConfigsCloseBtn= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBenefitsConfigsCloseBtn")
	Set elmSuccessPopup= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessPopup")
	
	Call objectExistanceCheckAndClick(elmBillOperations,"Bill Operation")
       Call objectExistanceCheckAndClick(elmGenerateContributions,"Generate Contributions")
      

       Call objectExistanceCheckAndEnter(billDate, "bill Date", "11/02/2022")	
       Call objectExistanceCheckAndEnter(objMonth, "Month", "January")	
       Call objectExistanceCheckAndEnter(objYear, "Year", "2022")	
       Call objectExistanceCheckAndEnter(expectedPaymentDate, "expected Payment Date", "11/17/2022")	
       Call objectExistanceCheckAndEnter(ignoreScheme, "ignore Scheme", "No")	
       Call objectExistanceCheckAndEnter(billForAllSponsors, "bill For All Sponsors", "Yes")	
       Call objectExistanceCheckAndClick(btnUpdateMemberSalaries,"Update Member Salaries")
       Call verifyObjectExist(elmMsgDone, "Msg box Done")
       Call objectExistanceCheckAndClick(elmRunContributionBilling,"Run Contribution Billing")
       Call objectExistanceCheckAndClick(elmSuccessPopup,"Success Popup")
       Call objectExistanceCheckAndClick(elmBenefitsConfigsCloseBtn,"Clos eButton")
      ' Call objectExistanceCheckAndClick(btnClose,"Close")
End Function

Public Function certifyBill()
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	Set elmMenuCertification = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuCertification")
	Set lnkMenuCertify = Browser("brwFundMaster").Page("pgFundMaster").Link("lnkMenuCertify")
	Set elmAcceptYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAcceptYes")
	Set elmCertify = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmCertify")
	
	Call clickOnCheckBox(elmProfileChkbx,"Check box")
	Call clickOnCheckBox(elmBillOperations,"Bill Operations")
	Call clickOnCheckBox(elmMenuCertification,"Menu Certification")
	Call objectExistanceCheckAndClick(lnkMenuCertify,"Certify")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Yes")
	Call objectExistanceCheckAndClick(elmCertify,"Certify")
End Function


Public Function approveBill()
	Set elmProfileChkbx = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmProfileChkbx")
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	Set elmMenuApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuApprove")
	Set elmAcceptYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmAcceptYes")
	Set elmBtnApprove = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBtnApprove")
	Set elmMenuCertification = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuCertification")
	
	'Call clickOnCheckBox(elmProfileChkbx,"Check box")
	Call clickOnCheckBox(elmBillOperations,"Bill Operations")
	Call clickOnCheckBox(elmMenuCertification,"Menu Certification")
	
	Call objectExistanceCheckAndClick(elmMenuApprove,"Menu Approve")
	Call objectExistanceCheckAndClick(elmAcceptYes,"Yes")
	Call objectExistanceCheckAndClick(elmBtnApprove,"approve")
End Function

Public Function emailBill()
	Set elmMenuEmail = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuEmail")
	Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	Set elmBtnEmail= Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBtnEmail")
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	
	Call clickOnCheckBox(elmBillOperations,"Bill Operations")
	Call objectExistanceCheckAndClick(elmMenuEmail,"Menu email")
	Call objectExistanceCheckAndClick(btnYes,"Yes")
	Call objectExistanceCheckAndClick(elmBtnEmail,"email")
End Function

Public Function downloadGeneratedBill()
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	Set elmMenuDownload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuDownload")
	Set elmMenuValidate = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuGeneratedBill")
	
	Call clickOnCheckBox(elmBillOperations,"Bill Operations")
	Call clickOnCheckBox(elmMenuDownload,"Menu Download")
	Call clickOnCheckBox(elmMenuGeneratedBill,"Menu Generated bill")
	Call objectExistanceCheckAndClick(btnYes,"Yes")
End Function

Public Function downloadValidatedBill()
	Set elmBillOperations = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBillOperations")
	'Set elmMenuDownload = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuDownload")
	Set elmMenuValidateBill = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMenuValidatedBill")
	'Set btnYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("btnYes")
	Call clickOnCheckBox(elmBillOperations,"Bill Operations")
	'Call clickOnCheckBox(elmMenuDownload,"Menu Download")
	Call clickOnCheckBox(elmMenuValidateBill,"Menu Validate bill")
	'Call objectExistanceCheckAndClick(btnYes,"Yes")

End Function

Public Function runBalances()
	Set elmFinancialPeriodsCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFinancialPeriodsCheckbox")
	Set linkHooverBatchRun = Browser("brwFundMaster").Page("pgFundMaster").Link("linkHooverBatchRun")
	Set elmFinancialPeriodsRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFinancialPeriodsRegister")
	Set elmFundAccountsBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmFundAccountsBtn")
	Set elmHooverAllocationInterestRate = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmHooverAllocationInterestRate")
	Set elmHooverSelectedMembers = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmHooverSelectedMembers")
	Set elmPeriodEndProcesses = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmPeriodEndProcesses")
	Set elmHooverSchemeLevel = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmHooverSchemeLevel")
	Set edtRateType = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtRateType")
	Set elmConfirmYes = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmConfirmYes")
	Set edtAddMemberRunBalances = Browser("brwFundMaster").Page("pgFundMaster").WebElement("edtAddMemberRunBalances")
	Set elmMemberNo = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberNo")
	Set elmRunBalancesBtn = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmRunBalancesBtn")
	Set elmInteresAsAt = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmInteresAsAt")
	Set elmInterestTypeForBatch = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("elmInterestTypeForBatch")
	
	Call objectExistanceCheckAndClick(elmFundAccountsBtn,"Fund Accounts Button")
	Call objectExistanceCheckAndClick(elmFinancialPeriodsRegister,"Financial Periods Register")
	Call clickOnCheckBox(elmFinancialPeriodsCheckbox, "Financial Period Checkbox Selection")
	Call objectExistanceCheckAndClick(elmPeriodEndProcesses,"Click Period End Processes")
	
'	Run Batch
	Call objectExistanceCheckAndClick(elmPeriodEndProcesses,"Click Period End Processes")
	Call objectExistanceCheckAndHoover(elmHooverAllocationInterestRate,"Hoover on Income Allocation Using Interest Rate")
	Call objectExistanceCheckAndClick(linkHooverBatchRun,"Click on Batch Run")
	Call objectExistanceCheckAndHoover(elmHooverSchemeLevel,"Hoover on Scheme level")
	Call objectExistanceCheckAndClick(linkHooverBatchRun,"Click on Batch Run")
	Call objectExistanceCheckAndClick(linkHooverBatchRun,"Click on Batch Run")
End Function

Public Function initiateClaim()
	Set edtMemberStatusField = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtMemberStatusField")
	Set elmMemberSelectCheckbox = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmMemberSelectCheckbox")
	Set elmBurgerMenu = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmBurgerMenu")
	Set edtClaimPaymentMode = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtClaimPaymentMode")
	Set edtClaimNotificationDate = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtClaimNotificationDate")
	Set edtDateOfBenefitCalculation = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDateOfBenefitCalculation")
	Set edtDateOfExit = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtDateOfExit")
	Set edtExitRemarks = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtExitRemarks")
	Set edtReasonForExit = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtReasonForExit")
	
	
	Call objectExistanceCheckAndEnter(edtMemberStatusField, "Member Status", "Active")
	wait 3
	Call clickOnCheckBox(elmMemberSelectCheckbox, "Member Checkbox Selection")
	Call objectExistanceCheckAndClick(elmBurgerMenu,"Click on Burger Menu")
	Browser("brwFundMaster").Page("FundMaster | Pension Administr").Link("Movements").HoverTap
	Browser("brwFundMaster").Page("FundMaster | Pension Administr").WebElement("Initiate Movement/Claim").Click
       Call objectExistanceCheckAndEnter(edtReasonForExit, "Reason For Exit", "Normal Retirement")	
       Call objectExistanceCheckAndEnter(edtDateOfBenefitCalculation, "Date of Benefit Calculation", "11/23/2022")	
       Call objectExistanceCheckAndEnter(edtDateOfExit, "Date of Exit", "11/23/2022")	
       Call objectExistanceCheckAndEnter(edtClaimNotificationDate, "Claim Notification Date", "11/23/2022")	
       Call objectExistanceCheckAndEnter(edtExitRemarks, "Remarks", "Normal Retirement")	
       Call objectExistanceCheckAndEnter(edtClaimPaymentMode, "Payment Mode", "Cheque")	
      Call saveForm()
End Function
