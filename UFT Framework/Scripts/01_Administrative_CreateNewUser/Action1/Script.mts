CreateResultFile()
Call fundMaster_login()
Call gotoAdministrativeExistingUser()
strUserName =  registerNewUser()
Call verifyUserDetails(strUserName)
Call assignSchemeToUser("Qa Scheme")
Call gotoUserDetails()
Call assignAddAllowedMemberClasses()
Call lockUserAndVerify()
Call unlockUserAndVerify()






