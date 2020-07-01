
'--this is a modified my old code, that comes out from ROKU examples

Sub init()
	m.top.backgroundColor = "0xFB0046FF"
	m.top.backgroundUri = ""

	m.scene = m.top.getScene()
	m.dialog = invalid
	
	m.mode = "loading"						'--actual mode (state of application) -> simple router :-)
	
	'--save local elements
	m.e = {}	
	m.e.rowlist = m.top.findNode("contentList")	
	m.e.main = m.top.FindNode("main")		
	m.e.list = m.top.FindNode("list")	
	m.e.detail = m.top.FindNode("detail")
    m.e.detailLabel = m.top.findNode("detailLabel")
    m.e.detailButtons = m.top.FindNode("detailButtons")
    m.e.detailDescription = m.top.FindNode("detailDescription")
    m.e.detailPoster = m.top.findNode("detailPoster")
    m.e.detailBtnPlay = m.top.findNode("detailBtnPlay")
    m.e.detailBtnPlayFromPos = m.top.findNode("detailBtnPlayFromPos")
	m.e.detailSeriesList = m.top.findNode("detailSeriesList") 	
	m.e.loader = m.top.FindNode("loader")	
	m.e.spinner = m.top.FindNode("spinner")	
	m.e.error = m.top.FindNode("error")
	m.e.errorText = m.top.FindNode("errorText")
    m.e.video = m.top.FindNode("video")
    m.e.videoTimer = m.top.FindNode("videoTimer")
    
    '--i18n
    m.top.FindNode("topLabel").text = tr("appName")
    m.top.FindNode("loaderText").text = tr("loading")
    

	'-- saved VOD database from API
	m.data = CreateObject("roAssociativeArray")	      
    
    m.detailButtons = {active: -1, buttons: []}     '--buttons array in detail page
    
    initList()

	'--default attributes for search filtering
	m.search = {active: False, text: "", filtermovies: False, filterseries: False}	
	
	'-- check hw platform
	valid = checkSystemAndInitGlobals()
    
    If (valid <> True)
    	showError( tr("invalid_device") )
	End If
    
    device = CreateObject("roDeviceInfo")
	Debug( device.GetCurrentLocale() ) 

	'-- init UI
	m.e.main.setFocus(true)
	showLoader()	
	
	dataInit()
	m.init = True
	If type(m.global.deeplink) <> "Invalid" Then
		If m.global.deeplink.type = "movie" Then						
			m.init = False
			Debug ("Deeplink movie " + m.global.deeplink.id)

			dataGetDetail(m.global.deeplink.id, "player")
			
		ElseIf m.global.deeplink.type = "series" Then
			m.init = False
			Debug ("Deeplink series " + m.global.deeplink.id)
		
			dataGetDetail(m.global.deeplink.id, "detail")
		End If
	End If				
	
	If m.init = True Then 
		dataGetList()
	End If		
End Sub                                                                



Function onItemSelected(e As Object)
    x = m.e.rowlist.rowItemFocused[0]
    y = m.e.rowlist.rowItemFocused[1]
    
    If (x = 0) Then
        d = m.data[y]
    ElseIf (x = 1) Then
        d = m.data[m.listsel.first.sel].childern[y]        
    ElseIf (x = 2) Then
        d = m.data[m.listsel.first.sel].childern[m.listsel.second.sel].childern[y]
    End If
    
    
	If (d.type = "disablesearch") Then
		m.data = CreateObject("roAssociativeArray")
		m.search.active = False
		
		m.e.rowList.content = invalid
	
		dataInit()
		m.listsel.active = -1
		dataGetList()    
    Else    
    	m.selectedItem = d
    	showDetail(-1)
	End If    	
	       
End Function




Function onItemFocused()
    x = m.e.rowlist.rowItemFocused[0]
    y = m.e.rowlist.rowItemFocused[1]     
	  
    
    If ( (x <> invalid) And (y <> invalid) ) And ( (m.listsel.lastX <> x) Or (m.listsel.lastY <> y) ) And (m.data.Count() > 0) Then
        m.listsel.active = x + 1		
		 
		If (m.listsel.active = 1) Then            '--FIRST line
            item = m.data[y]        
            
        	m.listsel.first.sel = y
			
			If (m.search.active = False) And ( (item.type <> "movie") And (item.type <> "episode") And (item.type <> "disablesearch") ) Then        '--select SERIES or SEASON -> they have additional data
			
				If (item.loaded = False) Then			
					Debug( "load additional data for " + item.type + " " + item.id )
					dataGetChildernList(item.id, 2)
                    m.listsel.second.show = True
                Else
                    m.listsel.second.show = True
                    showList()                    					
				End If                                
            
            Else
                m.listsel.second.show = False
                showList()			 
			End If
            
            m.listsel.third.show = False
            
            tr = m.e.rowlist.translation
            tr[1] = 300
            m.e.rowlist.translation = tr
			
		ElseIf (m.listsel.active = 2) Then
		    m.listsel.second.sel = y        
            
            item = m.data[m.listsel.first.sel].childern[y]
        
            tr = m.e.rowlist.translation
            tr[1] = 120
            m.e.rowlist.translation = tr
            
            If (item.type = "season") Then
			
                tr = m.e.rowlist.translation
                tr[1] = -20
                m.e.rowlist.translation = tr
            
				If (item.loaded = False) Then			
					Debug( "load additional data for " + item.type + " " + item.id )
										
					m.listsel.third.show = False
					showList() 	'###'
					
					dataGetChildernList(item.id, 3)
                Else
                    m.listsel.third.show = False
					showList()	'--remove old trhird line			
					
					m.listsel.third.show = True
					showList()	'-- add new third line
				End If                                
            
            Else
                m.listsel.third.show = False
                showList()			 
			End If
            
		Else
			m.listsel.third.sel = y
                    
            tr = m.e.rowlist.translation
            tr[1] = -220
            m.e.rowlist.translation = tr
            
		End If 
 		
  		m.e.rowlist.content.getChild(x).TITLE = m.e.rowlist.content.getChild(x).getChild(y).title

        m.listsel.lastX = x
        m.listsel.lastY = y
	End If 		

End Function	





Sub showError(message As String)
	hideLoader()
	hideList()
	hideDetail()
    hideVideo()
	
	m.e.error.visible = true	
	m.e.errorText.text = message
	
	m.mode = "error"
End Sub
Sub hideError()
    m.e.error.visible = false
End Sub



Sub showLoader()
    hideError()
	hideList()
	hideDetail()
    hideVideo()
	
	m.e.loader.visible = true	

	m.e.spinner.poster.uri = "pkg:/images/loader.png"
	m.e.spinner.control = "start"		
	
	m.mode = "loading"
End Sub
Sub hideLoader()
	m.e.spinner.control = "stop"
    m.e.loader.visible = false
End Sub



Sub showList()

	If m.init = False Then
		m.init = True
		dataGetList()
		return
	End If

    hideError()
	hideLoader()
	hideDetail()
    hideVideo()
	
    '-- cleaup after detail scene: DeleteFile("tmp:/big.jpg")
    
	m.e.list.visible = true
	
	m.mode = "list"		
	
    If (m.listsel.active = -1) Then
        '--prepare FIRST line
        m.listsel.active = 1
        m.listsel.first.show = True
        
        line = generateContentNode(m.data)
        m.listsel.first.line = line
        
	 	m.e.rowList.content = CreateObject("roSGNode", "ContentNode")
	 	m.e.rowlist.content.appendChild(line)	         
    End If       
    
    
	If (type(m.e.rowList.content) <> "roInvalid")
        '--other call of showList function 
        
        If (m.listsel.active = 1) Then
            m.listsel.first.show = True
            
            If (m.listsel.second.show)
                If (m.listsel.second.line <> invalid)
 			        line = m.listsel.second.line
                Else            
 			        line = generateContentNode(m.data[m.listsel.first.sel].childern)                    
                    m.listsel.second.line = line
     	 	    End If
                m.e.rowlist.content.appendChild(line)
            Else                
                If (m.listsel.third.line <> invalid) Then
                    m.e.rowlist.content.removeChild(m.listsel.third.line)
                    m.listsel.third.line = invalid
                End If
                If (m.listsel.second.line <> invalid) Then
                    m.e.rowlist.content.removeChild(m.listsel.second.line)
                    m.listsel.second.line = invalid
                End If                                                                          
            End If                                       
            
        ElseIf (m.listsel.active = 2) Then
            m.listsel.second.show = True
            
            If (m.listsel.third.show)
                If (m.listsel.third.line <> invalid)
 			        line = m.listsel.third.line
                Else            
 			        line = generateContentNode(m.data[m.listsel.first.sel].childern[m.listsel.second.sel].childern)
                    m.listsel.third.line = line
     	 	    End If
                m.e.rowlist.content.appendChild(line)            
                
            Else                
                If (m.listsel.third.line <> invalid) Then
                    m.e.rowlist.content.removeChild(m.listsel.third.line)
                    m.listsel.third.line = invalid
                End If                                                                          
            End If    
        
        Else If (m.listsel.active = 3) Then
            m.listsel.third.show = True                               
        End If        		
	Else	 
        '--insert FIRST line -> first call of showList function 
	 	m.e.rowList.content = CreateObject("roSGNode", "ContentNode")
	 	m.e.rowlist.content.appendChild(m.listsel.first.line)	 				 	
	End If	 	

    m.e.rowlist.observeField("itemFocused",    "onItemFocused")
	m.e.rowlist.observeField("rowItemFocused", "onItemFocused")
    m.e.rowlist.observeField("itemSelected",   "onItemSelected")

	m.e.rowlist.setFocus(true)
End Sub
Sub hideList()
    m.e.list.visible = false
    
	m.e.rowlist.unobserveField("itemFocused")
	m.e.rowlist.unobserveField("rowItemFocused")
    m.e.rowlist.unobserveField("itemSelected")
End Sub



Sub showDetail(id As Dynamic)
    hideError()
	hideLoader()
	hideList()
    hideVideo()
	
	m.e.detail.visible = true	
	
	m.mode = "detail"
    
    initDetail(id) 
    
End Sub
Sub hideDetail()
    m.e.detail.visible = false
    doneDetail()
End Sub



Sub showVideo()
    hideError()
	hideLoader()
	hideList()
    hideDetail()
	
	m.e.video.visible = true	
	
	m.mode = "video"
    
    initVideo() 
    
End Sub
Sub hideVideo()
    doneVideo()
End Sub



Function onKeyEvent(key As String, press As Boolean) As Boolean
	handled = false

	If (m.mode = "error") Or (m.mode = "loading")	'--in error/loading mode stop application 
		return false
	End If
    
    '--rewind / fastforward / replay / options / play / home
    
 	If press Then
        If (m.mode = "detail") Then

            If (key = "down") And ( m.e.detailDescription.hasFocus() ) Then
                If (m.detailButtons.buttons.Count() > 0) Then
                    m.detailButtons.buttons[0].setFocus(true)
                End If  
 			    handled = true
     		End If 
            
            If (key = "up") And ( m.e.detailButtons.isInFocusChain() ) Then
                m.e.detailDescription.setFocus(true)  
 			    handled = true
     		End If
            
            If (key = "right") And (m.e.detailButtons.isInFocusChain() ) Then
                If (m.detailButtons.active >= 0) And (m.detailButtons.buttons.Count() > 1) And (m.detailButtons.active < m.detailButtons.buttons.Count()-1) Then
                    m.detailButtons.active = m.detailButtons.active + 1
                    m.detailButtons.buttons[m.detailButtons.active].setFocus(true)
                End If                    
 			    handled = true
     		End If
            
            If (key = "left") And (m.e.detailButtons.isInFocusChain() ) Then
                If (m.detailButtons.active > 0) Then
                    m.detailButtons.active = m.detailButtons.active - 1
                    m.detailButtons.buttons[m.detailButtons.active].setFocus(true)
                End If                  
 			    handled = true
     		End If
        End If


        If (key = "back") Then
            
            If (m.mode = "detail") Then
                showList()                                  
 			    handled = true                               
            End If
            
            If (m.mode = "video") Then
                showList()                                  
 			    handled = true                               
            End If
                           
 		End If
        
        If (key = "play") Then
            If (m.mode = "list") Then
                PlaySelectedItemFromList()                                  
 			    handled = true
            End If               
 		End If        
    
        If (key = "replay") Then
            If (m.mode = "detail") Then
				showList()                                                  
 			    handled = true
            End If               
 		End If
        
        If (key = "options") Then
 			initSearch() 
			handled = true
        End If
                
    End If

    return handled
End Function



