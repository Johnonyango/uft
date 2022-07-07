
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebEdit("user.username").Set "Johnte" @@ script infofile_;_ZIP::ssf12.xml_;_
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebEdit("user.password").SetSecure "62c58618582a69059a6f204952547ad7f131d31478b6ce46" @@ script infofile_;_ZIP::ssf7.xml_;_
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebButton("button-1224").Click @@ script infofile_;_ZIP::ssf8.xml_;_
wait 3
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebButton("button-1226").Click @@ script infofile_;_ZIP::ssf9.xml_;_
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebElement("Profile").Click @@ script infofile_;_ZIP::ssf10.xml_;_
Browser("FundMaster | Pension Administr").Page("FundMaster | Pension Administr").WebButton("button-1224_2").Click @@ script infofile_;_ZIP::ssf11.xml_;_
Browser("FundMaster | Pension Administr").Close
