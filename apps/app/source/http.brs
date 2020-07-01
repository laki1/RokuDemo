'-- Modified from NWM_Utilities.brs in the Roku SDK

Function GetStringFromURL(url, apiToken = "")
	result = ""
	timeout = 10000

	ut = CreateObject("roURLTransfer")
 
 	If (apiToken <> "") Then
		ut.AddHeader("X-API-TOKEN", apiToken)
	End If
 
	ut.SetPort( CreateObject("roMessagePort") )	
	url = url.EncodeUri()
	ut.SetURL(url)
	
	If ut.AsyncGetToString()
    	event = wait(timeout, ut.GetPort())
		If type(event) = "roUrlEvent"	

			statusCode = event.GetResponseCode()		
			If (statusCode >= 200) And (statusCode < 300)							
				result = event.GetString()
			Else
				return {state: "ko", data: "HTTP request problem - statusCode: " + Str(statusCode)}
			End If				
			
		ElseIf event = invalid
			ut.AsyncCancel()      
		Else
			return {state: "ko", data: "roUrlTransfer::AsyncGetToString(): unknown event"}
		Endif
	End If

	return {state: "ok", data: result}
End Function



Function SetDataToURL(url, data, apiToken = "")
	result = ""
	timeout = 10000

	ut = CreateObject("roURLTransfer")
 
 	If (apiToken <> "") Then
		ut.AddHeader("X-API-TOKEN", apiToken)
	End If
	ut.AddHeader("Content-Type", "application/json")	
 
	ut.SetPort( CreateObject("roMessagePort") )	
	url = url.EncodeUri()
	ut.SetURL(url)
	
	dataJSON = FormatJson(data) 
		
	If ut.AsyncPostFromString(dataJSON) Then
		event = wait(timeout, ut.GetPort())
		If type(event) = "roUrlEvent" Then
			
			statusCode = event.GetResponseCode()		
			If (statusCode >= 200) And (statusCode < 300)							
				result = event.GetString()
			Else
				return {state: "ko", data: "HTTP request problem - statusCode: " + Str(statusCode)}
			End If				
			
		ElseIf event = invalid
			ut.AsyncCancel()      
		Else
			return {state: "ko", data: "roUrlTransfer::AsyncPostFromString(): unknown event"}
		Endif		
	End If

	return {state: "ok", data: result}
End Function
