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
Public randomUserName

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


Function fundMaster_login()
	strFrameworkPath = getFrameworkpath()
	strTestDataPath = strFrameworkPath(0) & "UFT Framework\TestData\CommonTestData.xlsx"
	DataTable.AddSheet "LogIn"
	DataTable.ImportSheet strTestDataPath, "LogIn", "LogIn"
	dtUsername = Trim(DataTable.GetSheet("LogIn").GetParameter("UserName").Value)
	dtPassword= Trim( DataTable.GetSheet("LogIn").GetParameter("Password").Value)
	sUsername = dtUsername
	sPassword = dtPassword
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
		objObject.highlight()
		objObject.click()
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
End Function

Public Function enterProfileNameAndSearch()
	Set edtProfileUserName = Browser("brwFundMaster").Page("pgFundMaster").WebEdit("edtProfileUserName")
	Call objectExistanceCheckAndEnter(edtProfileUserName, "User profile name" ,randomUserName )
	Dim mySendKeys
	set mySendKeys = CreateObject("WScript.shell")
	edtProfileUserName.Highlight
	edtProfileUserName.Click
	wait 2
	'edtProfileUserName.FireEvent
	mySendKeys.SendKeys"{ENTER}"
End Function

Public Function verifyUserDetails()
	Call enterProfileNameAndSearch()
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

Public Function assignSchemeToUser()
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
	Call objectExistanceCheckAndEnter(edtSchemeNameFieldUnderUsersinput, "Scheme Name" ,"Qa Scheme" )
	Call objectExistanceCheckAndClick( btnFilter, "Filter Button")
	Call verifyObjectExist(elmQaScheme, "Qa Scheme" )
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
