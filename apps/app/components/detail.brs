
'--if item is series or season -> display rowlist with childern items, but this is disabled

Sub initDetail(id As Dynamic)
        
    m.e.detailLabel.text = ""    
    
	'----set movie description, but API does not support 
    '--m.e.detailDescription.text = m.selectedItem.description
    
    m.e.detailPoster.uri = ""    
        
    m.detailButtons.buttons = []
    m.detailButtons.active = -1
    m.e.detailBtnPlay.visible = False
	m.e.detailBtnPlayFromPos.visible = False
        
    m.e.detailDescription.setFocus(true)
	
	
	If (m.selectedItem <> invalid) Then 
		generateDetail()		
	Else		
		dataGetDetail(id, "detail")
	End If		 
    
End Sub
Sub doneDetail()
	m.e.detailBtnPlay.unobserveField("buttonSelected")
	m.e.detailBtnPlayFromPos.unobserveField("buttonSelected")
End Sub


Sub generateDetail()
		
    m.e.detailLabel.text = m.selectedItem.title    
    	
    m.afterDownloadBigImage = showDetailAfterDownloadBigImage
    downloadBigImage(m.selectedItem.id)
    
    
    If ( (m.selectedItem.type = "movie") Or (m.selectedItem.type = "episode") ) Then
		m.e.detailBtnPlay.visible = True		
		m.detailButtons.buttons.push( m.e.detailBtnPlay )
		m.e.detailBtnPlay.observeField("buttonSelected", "onPlayAction")
		    	
    	If (getReg(m.selectedItem.id) <> invalid) Then
			m.e.detailBtnPlayFromPos.visible = True
			m.detailButtons.buttons.push( m.e.detailBtnPlayFromPos )
			m.e.detailBtnPlayFromPos.observeField("buttonSelected", "onPlayFromLastPositionAction")
		End If
    	
    	m.detailButtons.active = 0
    	
'     	m.e.detailPoster.width = 320
' 		m.e.detailPoster.height = 426
' 		m.e.detailDescription.height = 426
' 		m.e.detailDescription.width = 800
' 		m.e.detailDescription.translation = [420,180]
' 		m.e.detailSeriesList.visible = false
' 		
' 		m.e.detailDescription.setFocus(true)
' 	Else
' 
' 		m.e.detailPoster.width = 160
' 		m.e.detailPoster.height = 213
' 		m.e.detailDescription.height = 213
' 		m.e.detailDescription.width = 960
' 		m.e.detailDescription.translation = [260,180]
' 		m.e.detailSeriesList.visible = true
' 		
' 		line = generateContentNode(m.selectedItem.childern)		
' 		m.e.detailSeriesList.content = CreateObject("roSGNode", "ContentNode")
' 	 	m.e.detailSeriesList.appendChild(line) 
' 		
' 		m.e.detailSeriesList.setFocus(true)    	
' 		
' 		m.e.detailSeriesList.observeField("itemFocused",    "onDetailItemFocused")
' 		m.e.detailSeriesList.observeField("rowItemFocused", "onDetailItemFocused")
'     	m.e.detailSeriesList.observeField("itemSelected",   "onDetailItemSelected")
	End If    	
        
End Sub


Function onDetailItemFocused(e As Object)

End Function

Function onDetailItemSelected(e As Object)

End Function


Sub showDetailAfterDownloadBigImage()
    
    m.e.detailPoster.uri = "tmp:/big.jpg" 				'-- m.dnlImageTask.getField("src") - show downloaded big poster
    
End Sub


Sub onPlayAction(event)
	Debug ( "onPlayAction" )
	
	m.selectedItem.startposition = invalid
	
	showVideo()		
End Sub


Sub onPlayFromLastPositionAction(event)

	position = getReg(m.selectedItem.id)
	
	Debug ( "onPlayFromLastPositionAction " + position )
	
	m.selectedItem.startposition = position	
	showVideo()
			
End Sub	
