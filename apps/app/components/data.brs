
Sub dataInit()
	
	m.datamanager = CreateObject("roSGNode", "datamanagerTask")
	
	m.datamanager.observeField("error",    "dataOnError")
	m.datamanager.observeField("response", "dataOnDone")
	
	m.datamanager.setField("baseurl", GetGlobalAA()["api_base_url"])

    m.dnlImageTask = CreateObject("roSGNode", "dnlimgTask")

	'-- database of all valid VOD items
	m.data = []
		
End Sub



Function dataOnError(w)
	
    If m.datamanager.getField("silent") = False Then
	   showError( w.getData() )
    Else
        print "HTTP error: ";w.getData()
    End If       
	 
End Function


Function dataOnDone(w)
	
    request = w.getData()
	data = ParseJson(m.datamanager.responseData) 
    	
	If (request = "getList") Then
		 dataOnDoneGetList( data )
	ElseIf (request = "search") Then
		 dataOnDoneSearch( data )
	ElseIf (request = "getChildernList") Then
		 dataOnDoneGetChildernList( data )
    ElseIf (request = "getDetail") Then
		 dataOnDoneGetDetail( data )         
    ElseIf (request = "sendHearbeat") Then
		 dataOnDoneSendHearbeat( data )
	End If
	
End Function


Sub dataRunRequest(silent)
	If (silent = False) Then
        showLoader()        
    End If
    m.datamanager.setField("silent", silent)    
	m.datamanager.control = "RUN"
End Sub


Sub dataGetList()
	m.datamanager.setField("request", "getList")
	m.datamanager.setField("requestData", {filter: "all"})
	dataRunRequest(False)
End Sub


Sub dataSearch()

    data = {filter: "all", searchstring: m.search.text}
    If m.search.filtermovies = True Then data.filter = "movies"
    If m.search.filterseries = True Then data.filter = "series"

	m.datamanager.setField("request", "search")	
    m.datamanager.setField("requestData", data)    	
	dataRunRequest(False)
End Sub

Sub dataGetChildernList(id, row)
	m.datamanager.setField("request", "getChildernList")
	m.datamanager.setField("requestData", {parent: id, row: row})
	dataRunRequest(False)
End Sub


Sub dataGetDetail(id, ret)
	m.datamanager.setField("request", "getDetail")
	m.datamanager.setField("requestData", {id: id, ret: ret})
	dataRunRequest(False)
End Sub


Sub dataSendHearbeat(id, position)
	m.datamanager.setField("request", "sendHearbeat")
	m.datamanager.setField("requestData", {id: id, position: position})
	dataRunRequest(True)
End Sub



Function dataOnDoneSearch(data)

    token = m.datamanager.token
    
	m.data = [] 
    
	For i=0 To data.Count() - 1
		m.data.push( { id: data[i].id, type: data[i].type, title: data[i].title, year: "n/a", season: data[i].seasonNo, episode: data[i].episodeNo, childern: [], loaded: False } )				
	End For
 
    '--add special DISABLESEARCH item
    m.data.push( { id: "-1", type: "disablesearch", title: tr("Disable search results"), year: "", season: -1, episode: -1, childern: [], loaded: False } )        
        
    hideList()        
    initList()
    showList()
	
End Function


Function dataOnDoneGetList(data)

    token = m.datamanager.token
	
	m.data = []	
    
	For i=0 To data.Count() - 1
		If (data[i].type = "movie") Or (data[i].type = "series") Then        
			m.data.push( { id: data[i].id, type: data[i].type, title: data[i].title, year: "n/a", season: data[i].seasonNo, episode: data[i].episodeNo, childern: [], loaded: False } )
		End If			
	End For
	
	m.dnlImages = []
	prepareDowloadImages(m.data)
	
End Function



Function dataOnDoneGetChildernList(data)

    token = m.datamanager.token
    requestData = m.datamanager.requestData
    
	Debug("dataOnDoneGetChildernList for row " + StrI(requestData.row))

	If (requestData.row = 2) Then                     '--loaded for SECOND row
        item = m.data[m.listsel.first.sel]
        m.listsel.second.line = invalid
    Else If (requestData.row = 3) Then                '--loaded for THIRD row
        item = m.data[m.listsel.first.sel].childern[m.listsel.second.sel]
        m.listsel.third.show = True
        m.listsel.third.line = invalid        
    End If
    
    
 	For i=0 To data.Count() - 1
		item.childern.push( { id: data[i].id, type: data[i].type, title: data[i].title, year: "n/a", season: data[i].seasonNo, episode: data[i].episodeNo, childern: [], loaded: False } )
 	End For
 	
 	item.loaded = True    
 	
 	m.dnlImages = []
 	prepareDowloadImages(item.childern)
	
End Function



Function dataOnDoneGetDetail(data)

    token = m.datamanager.token
    requestData = m.datamanager.requestData
    
	Debug("dataOnDoneGetDetail for id " + requestData.id)

    m.selectedItem = { id: data.id, type: data.type, title: data.title, year: "n/a", children: [], loaded: True }
    
    If requestData.ret = "detail" Then
        showDetail(-1)
    ElseIf requestData.ret = "player"
        m.selectedItem.startposition = invalid
        showVideo()
    End If        
	
End Function


Function dataOnDoneSendHearbeat(data)
    '--data is same as sended data
End Function
