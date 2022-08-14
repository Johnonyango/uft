CreateResultFile()
Call fundMaster_login()
Call gotoSchemePage()
Call gotoSponsorList()
strSponsorName_01 =  createNewSponsor()
Call gotoSponsorApproval()
Call verifySponsorDetails(strSponsorName_01)
Call removeSponsor()
Call gotoSponsorList()
strSponsorName_02 =  createNewSponsor()
Call gotoSponsorApproval()
Call verifySponsorDetails(strSponsorName_02)
Call approveSponsor()
Call gotoCostCenters()
Call UpdateCostCenter(strSponsorName_02)


















