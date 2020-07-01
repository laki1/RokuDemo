
Sub init()
	
	m.top.functionName = "requestData"
	m.top.token = ""
	
End Sub
                                                                                                        

Function getApiToken()
	ret = true		
	url = m.top.baseurl + "/"
	
	Debug( "DM: getApiToken " + url)
		
	response = GetStringFromURL(url)	
	If (response.state = "ok") Then	
		json = ParseJson(response.data)
		m.top.token = json["apiToken"]
	
		Debug("DM: getApiToken - set token: " + m.top.token)
	Else
		m.top.error = response.data
		ret = False
	End If	
	
	return ret	
		    	
End Function


Sub requestData()	
	
	If m.top.token = "" Then
		isOk = getApiToken()
		If (isOk = False) Then
			return
		End If
	End If
		
	If (m.top.request = "getList") Then
		 getList()
	ElseIf (m.top.request = "search") Then
		 search()
	ElseIf (m.top.request = "getChildernList") Then
		 getChildernList()	 		 
	ElseIf (m.top.request = "getDetail") Then
		 getDetail()
	ElseIf (m.top.request = "sendHearbeat") Then		 
		 sendHearbeat()
	End If
	
		    	
End Sub



Sub getList()
		
	data = m.top.requestData["filter"]		
		
	Debug( "DM: getList /" + data + "/")
		
	url = m.top.baseurl + "/vod" 
	If (data = "movies") Then
		url = url + "?filter=movie"
	ElseIf (data = "series") Then
		url = url + "?filter=series" 
	End If
	'-- other => search all

	response = GetStringFromURL(url, m.top.token)
	If (response.state = "ok") Then
				
		m.top.responseData = response.data
		m.top.response = m.top.request		
	Else
		m.top.error = response.data
	End If
		    	
End Sub



Sub search()
		
	dataFilter = m.top.requestData["filter"]
	dataString = m.top.requestData["searchstring"]		
		
	Debug( "DM: search /" + dataString + ", " + dataFilter + "/")
		
	url = m.top.baseurl + "/vod/search?s=" + dataString 
	If (dataFilter = "movies") Then
		url = url + "&filter=movie"
	ElseIf (dataFilter = "series") Then
		url = url + "&filter=series" 
	End If
	'-- other => search all	
	 
	response = GetStringFromURL(url, m.top.token)	
	If (response.state = "ok") Then
	
		m.top.responseData = response.data			
		m.top.response = m.top.request		
	Else
		m.top.error = response.data
	End If
		    	
End Sub



Sub getChildernList()
	'-- token has bene loaded before	
	data = m.top.requestData["parent"]
		
	Debug( "DM: getChildernList /" + data + "/")
		
	url = m.top.baseurl + "/vod/" + data + "/children" 
	 
	response = GetStringFromURL(url, m.top.token)
	If (response.state = "ok") Then	
		m.top.responseData = response.data					
		m.top.response = m.top.request				
	Else
		m.top.error = response.data
	End If
		    	
End Sub


Sub getDetail()

	'-- token has been loaded before	
	data = m.top.requestData["id"]
		
	Debug( "DM: getDetail /" + data + "/")
		
	url = m.top.baseurl + "/vod/" + data + "?full=true" 
	 
	response = GetStringFromURL(url, m.top.token)
	If (response.state = "ok") Then
		m.top.responseData = response.data			
		m.top.response = m.top.request
	Else
		m.top.error = response.data
	End If
		    	
End Sub



Sub sendHearbeat()

	Debug( "DM: sendHearbeat /" + StrI(m.top.requestData["position"]) + "/")
		
	url = m.top.baseurl + "/vod/heartbeat" 
	 
	data = {id: m.top.requestData["id"], progress: m.top.requestData["position"]}
	 
	response = SetDataToURL(url, data, m.top.token)
	If (response.state = "ok") Then
		m.top.responseData = response.data			
		m.top.response = m.top.request
	Else
		m.top.error = response.data
	End If
		    	
End Sub
