
Sub initList()

	m.selectedItem = invalid    '--vybrana polozka pro zobreazeni detailu popr. prehravani
	
	m.listsel = {
        first:  {sel: -1, show: False, line: invalid, timestamp: -1}, 
        second: {sel: -1, show: False, line: invalid, timestamp: -1}, 
        third:  {sel: -1, show: False, line: invalid, timestamp: -1}, 
        active: -1,                                                      '-- -1 | 1 | 2 | 3
        lastX: -1,
        lastY: -1
    }
    
    m.e.rowList.content = invalid

End Sub


Function generateContentNode(data) As Dynamic

	ret = CreateObject("roSGNode", "ContentNode")	'--line 
	ret.TITLE = ""

	If (data.Count() > 0) Then
		
 		For i=0 To data.Count() - 1
 			item = ret.createChild("ContentNode")
			item.addField("Overlay", "string", false) 			
 			
 			If (data[i].type <> "disablesearch") Then 			
	 			
				item.title = data[i].title + " (" + data[i].year + ")"
				If (m.search.active = True) Then
					item.HDPosterUrl = "pkg:/images/searched.png"
				Else
					item.HDPosterUrl = "tmp:/" + data[i].id + ".jpg"
				End If					
	 				 			
	 			o = ""
	 			If (data[i].type = "series") Then
					o = "series" 
				ElseIf (data[i].type = "season") Then
				    s = StrI(data[i].season, 10) 
					o = "S"
					If (Len(o) = 1) Then o = o + "0"
					o = o + s				
				ElseIf (data[i].type = "episode") Then
				    s = StrI(data[i].season, 10)
					o = "S"
					If (Len(s) = 1) Then o = o + "0"
					o = o + s + "E"
					s = StrI(data[i].episode, 10)
					If (Len(s) = 1) Then o = o + "0"
					o = o + s				
				Else	'-- type=movie
				    o = ""
				End If
				item.Overlay = o
				
			Else
			
		 		item.title = tr("Disable search results")
		 		item.HDPosterUrl = "pkg:/images/disablesearch.png"
				item.Overlay = ""
			
			End If								
			 
 		End For
	 
	End If
			 
	return ret
	
End Function

Sub prepareDowloadImages(data)

	If (data.Count() > 0) Then
				
		token = m.datamanager.getField("token")
		m.dnlImageTask.setField("token", token)
		
		m.dnlImages = []
		
 		For i=0 To data.Count() - 1
 			m.dnlImages.push( {dest: "tmp:/" + data[i].id + ".jpg", src: GetGlobalAA()["api_base_url"] + "/vod/" + data[i].id + "/poster?w=180&h=240"})		    
 		End For
		
		downloadImage()		
	End If
End Sub


Sub downloadImage()	
	
	If (m.dnlImages.Count() > 0) Then		
		m.dnlImageTask.setField("dest", m.dnlImages[0].dest)
		m.dnlImageTask.setField("src", m.dnlImages[0].src)
		m.dnlImageTask.setField("dnlImage", {})
		m.dnlImageTask.control = "RUN"
		m.dnlImageTask.observeField("control", "onDownloadImage")				
	Else
		showList()
	End If

End Sub


Sub onDownloadImage()
	m.dnlImageTask.unobserveField("control")
	
	m.dnlImages.Shift()
	downloadImage()
End Sub




Sub downloadBigImage(id)	

    token = m.datamanager.getField("token")
	m.dnlImageTask.setField("token", token)			
	m.dnlImageTask.setField("dest", "tmp:/big.jpg")
	m.dnlImageTask.setField("src",   GetGlobalAA()["api_base_url"] + "/vod/" + id + "/poster?w=320&h=426")
	m.dnlImageTask.setField("dnlImage", {})
	m.dnlImageTask.control = "RUN"
	m.dnlImageTask.observeField("control", "onDownloadBigImage")     					

End Sub


Sub onDownloadBigImage()
	m.dnlImageTask.unobserveField("control")
	m.afterDownloadBigImage()
End Sub



Sub movePrevNextList(action)
	If (action = "prev") Or (action = "next") Then			
		If m.listsel.active = 1 Then
			a = m.data
			b = m.listsel.first.sel 		
		ElseIf m.listsel.active = 2 Then
			a = m.data[m.listsel.first.sel].childern
			b = m.listsel.second.sel
		ElseIf m.listsel.active = 3 Then
		    a = m.data[m.listsel.first.sel].childern[m.listsel.second.sel].childern
		    b = m.listsel.third.sel
		End If 
		max = a.Count()-1
		
		If (action = "prev") Then	
			If b > 0 Then
				b = b - 1
			Else
				b = max
			End If
		ElseIf (action = "next") Then
			If b < max Then
				b = b + 1
			Else
				b = 0
			End If
		End If
					
		If ( (a[b].type = "movie") Or (a[b].type = "episode") ) Then					    	
    		m.selectedItem = a[b]
    		If m.listsel.active = 1 Then
				m.listsel.first.sel = b				
				m.e.rowList.jumpToRowItem = [ 0, b ] 
			ElseIf m.listsel.active = 2 Then
				m.listsel.second.sel = b
				m.e.rowList.jumpToRowItem = [ 1, b ]
			ElseIf m.listsel.active = 3 Then
		    	m.listsel.third.sel = b
		    	m.e.rowList.jumpToRowItem = [ 2, b ]
			End If
			
			Debug( "movePrevNextList change video " + action )
			doneVideo()        	
    		showVideo()
		End If   		
	End If
End Sub


Sub PlaySelectedItemFromList()
	x = m.e.rowlist.rowItemFocused[0]
    y = m.e.rowlist.rowItemFocused[1]
    
    If (x = 0) Then
        d = m.data[y]
    ElseIf (x = 1) Then
        d = m.data[m.listsel.first.sel].childern[y]        
    ElseIf (x = 2) Then
        d = m.data[m.listsel.first.sel].childern[m.listsel.second.sel].childern[y]
    End If
    
    If ( (d.type = "movie") Or (d.type = "episode") ) Then
    	m.selectedItem = d
    	
    	Debug( "PlaySelectedItemFromList" )
    	showVideo()
    End If
End Sub



