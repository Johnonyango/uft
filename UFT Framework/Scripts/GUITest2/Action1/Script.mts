
Call updateExcel("C:\temp.xls",3,"New dynamic value")

Function updateExcel(filePath,columnIndex,dynamicValue)
	set objExcel = CreateObject("Excel.Application")
	objExcel.Application.DisplayAlerts = False
	set objWorkbook=objExcel.workbooks.Open(filePath)
	objExcel.cells(2,columnIndex).value = dynamicValue
	objWorkbook.Save
	objWorkbook.Close
End Function



