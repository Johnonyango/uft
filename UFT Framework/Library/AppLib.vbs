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
Public randomUserName, randomSchemeName

Public Function testCleanUp()
	'systemutil.CloseProcessByName("FIREFOX.EXE")
	systemutil.CloseProcessByName("IEXPLORE.EXE")
	systemutil.CloseProcessByName("CHROME.EXE")
	'systemutil.CloseProcessByName("EXCEL.EXE")
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}" & "!\\.\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * From Win32_Process")
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("EXCEL.EXE") OR LCase(objProcess.Name) = LCase("EXCEL.EXE *32") Then
			objProcess.Terminate()
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
	End If
End Function

Public Function verifyObjectExist(objObject , strMsg)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(3) Then
		objObject.highlight()
		LogResult micpass , " Verify  " & strMsg ,  " Verified  " & strMsg & "  exist Successfully"
	Else
		LogResult micFail ,  " Verify  " & strMsg , " Verified  " & strMsg & "   not exist"
	End If
End Function

Public Function verifyObjectNotExist(objObject , strMsg)
	Browser("brwFundMaster").Page("pgFundMaster").Sync
	If objObject.Exist(3) Then
		objObject.highlight()
		LogResult micFail ,  " Verify  " & strMsg , " Verified  " & strMsg & "    exist"	
	Else
		LogResult micpass , " Verify  " & strMsg ,  " Verified  " & strMsg & " Not  exist "
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

Public Function gotoContributeNewBatchPage()
	set objContributeNewBatch = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welNew Batch")
       set objEleMemberRegister = Browser("brwFundMaster").Page("pgFundMaster").WebElement("welMemberRegister")
       Call objectExistanceCheckAndClick(objEleMemberRegister,"Member Register")
       Call objectExistanceCheckAndClick(objContributeNewBatch,"Contribute -> New Batch")
End Function

Public Function uploadMemberExcelFile()
	strMemberExcelFilePath = "C:\Users\Administrator\Documents\MemberUpload.xlsx"
	call browserAndUpload(strMemberExcelFilePath)
	Set chkBox01 =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set btnSaveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	Set elmSuccessMsg = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessMsg")
	wait 10
	Call objectExistanceCheckAndClick(chkBox01, "Check box")
	Call objectExistanceCheckAndClick(btnSaveBatch, "Save")
	Call objectExistanceCheckAndClick(elmSuccessMsg, "Success Message")
End Function

Public Function uploadAddBatchScheduleExcelFile()
	strTempleFilePath = "C:\Users\Administrator\Documents\CONTRIBUTION TEMPLATE.xls"
	Set tblContribution = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tblContribution")
	Set chkBox01 =Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox01")
	Set elmApplyThisSheet = Browser("brwFundMaster").Page("pgFundMaster").WebElement("sheetExcel-btnInnerEl")
	Set tblContributionData = Browser("brwFundMaster").Page("pgFundMaster").WebTable("batchcontributionuploadgridvie")
	Set chkBox02 = Browser("brwFundMaster").Page("pgFundMaster").WebElement("chkBox02")
	Set btnSaveBatch = Browser("brwFundMaster").Page("pgFundMaster").WebButton("saveBatch")
	Set elmSuccessMsg = Browser("brwFundMaster").Page("pgFundMaster").WebElement("elmSuccessMsg")
	Call browserAndUpload(strTempleFilePath)
	Call verifyObjectExist(tblContribution," Contribution uploaded table")
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
      ' Call objectExistanceCheckAndClick(objBtnBrowse,"Browse File")
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
	strCostCenter = "CBK TEST SCHEME SPONSOR COST CENTRE"
	strSponsorName  = "CBK TEST SCHEME SPONSOR"
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
	Call objectExistanceCheckAndClick(elmDatePicker,"Date Picker")
	Call objectExistanceCheckAndClick(elmTodayDate,"Today's date")
	Call objectExistanceCheckAndEnter(edtSponsorName,"Sponsor name",strSponsorName )
	Call objectExistanceCheckAndEnter(edtCostCenter,"Cost Center",strCostCenter )
	Call objectExistanceCheckAndEnter(edtMonth,"Month","May" )
	Call objectExistanceCheckAndEnter(edtYear,"Year","2023" )
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
	Set tblStatusDELETE = Browser("brwFundMaster").Page("pgFundMaster").WebElement("tblStatusDELETE")
	Call objectExistanceCheckAndEnter(edtModule, "Module" , "Administrative")
	Call objectExistanceCheckAndEnter(edtCrudeTypetf, "CrudeType" , "Delete")
	Call objectExistanceCheckAndClick(btnFilter,"Filter button")
	Call verifyObjectExist(tblAuditTable,"AuditTable")
	Call verifyObjectExist(tblStatusDELETE,"DELETE Status")
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
	Call objectExistanceCheckAndEnter(edtbaseCurre, "scheme base currency" , "EURO")
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
	Call objectExistanceCheckAndEnter(eleschemePin, "scheme Pin" ,"12345678901")
	Call objectExistanceCheckAndEnter(eleSchemeMod, "Scheme Mode" ,"Single")
	Call objectExistanceCheckAndEnter(eleSchemecontribut, "Scheme contribute" ,"Monthly")

	Call objectExistanceCheckAndEnter(elesponsrCon, "sponsor Contribute" ,"Yes")
	Call objectExistanceCheckAndEnter(eleSchemeremittanc, "Scheme remittanc" ,"In Arrears")
	Call objectExistanceCheckAndEnter(eleSchemebaseCurre, "SchemebaseCurre" ,"Kenyan shilling")
	Call objectExistanceCheckAndEnter(eleSchemebaseTaxRe, "SchemebaseTaxRe" ,"Kenya")
	Call objectExistanceCheckAndEnter(eleSchemeoffshoreC, "Scheme off shoreC" ,"Kenyan shilling")
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
