
Sub init() 

	m.top.id = "rowlistitem"

	m.poster = createObject("roSGNode", "Poster")
	m.poster.width = 180
	m.poster.height = 240
	m.top.appendChild(m.poster)
	
	m.overlay = createObject("roSGNode", "Poster")
	m.overlay.visible = False
	m.overlay.width = 180
	m.overlay.height = 240
	m.overlay.opacity = 0.6
	m.overlay.translation=[0,0]
	m.overlay.uri = "pkg:/images/series.png"
	m.top.appendChild(m.overlay)
	
	m.overlayText = createObject("roSGNode", "Label")
	m.overlayText.visible = False
	m.overlayText.font.size = 32
	m.overlayText.color = "0xFFFFFFFF"
	m.overlayText.opacity = 0.6
	m.overlayText.width = 180	
	m.overlayText.horizAlign = "center"
	m.overlayText.translation = [0, 180]
	m.top.appendChild(m.overlayText)

End Sub

Sub showcontent()
	itemcontent = m.top.itemContent
	m.poster.uri = itemcontent.HDPosterUrl
	
	overlay = itemcontent.Overlay
	 
	If overlay = "series"
		m.overlay.visible = True
		m.overlayText.visible = False 
	ElseIf overlay <> ""
		m.overlay.visible = False
		m.overlayText.text = overlay
		m.overlayText.visible = True		
	Else
		m.overlay.visible = False
		m.overlayText.visible = False
	End If
End Sub
