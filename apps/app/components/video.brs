
Sub initVideo()

	m.e.video.visible = True
	m.e.video.loading = True

	m.e.video.observeField("state", "controlvideoplay")
	m.e.video.observeField("position", "onPositionChange")
	m.e.video.observeField("duration", "onDurationChange")
	m.e.video.observeField("aaction", "onAActionChange")
	
	
	m.e.videoTimer.setField("duration", GetGlobalAA().api_heartbeat_interval_in_sec)
	m.e.videoTimer.observeField("fire", "onFireTimer")
	
	playVideo()

End Sub
Sub doneVideo()
	m.e.video.visible = False
	m.e.video.loading = False
	m.e.video.unobserveField("state")
	m.e.video.unobserveField("position")
	m.e.video.unobserveField("duration")
	m.e.videoTimer.unobserveField("fire")
	m.e.videoTimer.control = "stop"
End Sub


Sub onPositionChange(a)
	
	position = a.getData()
		 
	setReg(m.selectedItem.id, StrI(position))		'--StrI for convert & rounded to whole number  
	'-- only for demo!!!! In production version must be aggregate and writing only in few minutes and on exit action	
	
	m.e.video.time_change = True
	
End Sub
Sub onDurationChange(a)
	m.e.video.time_change = True	
End Sub


Sub onFireTimer(a)
	
	position = m.e.video.position
	
	print "onFireTimer: ";position

	dataSendHearbeat(m.selectedItem.id, Int(position))	
	
End Sub





Sub playVideo()
	
	videoContent = createObject("RoSGNode", "ContentNode")  	
  	
  	If (m.selectedItem.startposition <> invalid) Then
  		videoContent.PlayStart = m.selectedItem.startposition.toInt() 
  	End If
  	
  	drmParams = {
		keySystem: 		  GetGlobalAA().drm_type
		licenseServerURL: GetGlobalAA().drm_licence_url
	}
	videoContent.streamFormat = "dash"
	videoContent.url = GetGlobalAA().drm_stream_mrl
	videoContent.drmParams = drmParams
	  
	videoContent.title = m.selectedItem.title
  	
  	m.e.video.content = videoContent
  	m.e.video.control = "play"
  	
End Sub



Sub controlvideoplay()

 	If m.e.video.state = "error"
    	If m.e.video.errorCode <> -4  '--No streams were provided for playback.player agent play -> it's not error with Adaptive Streaming :-(((
			showError( tr("video player error") )
		End If	
 	End If
 	
	If (m.e.video.state = "finished")
		unsetReg(m.selectedItem.id)		'--on finished -> video was watched complete -> delete last position = next play from start position
    	showLIst()
 	End If
 
 	If m.e.video.state = "buffering"
 		m.e.video.loading = true
 	Else
 		m.e.video.loading = false
 	End If
 	
 	
 	If m.e.video.state = "playing" Then
 		'-- start timer
 		m.e.videoTimer.control = "start"
 	End If
 	If m.e.video.state = "stopped" Or m.e.video.state = "finished" Or m.e.video.state = "error" Or  m.e.video.state = "none" Then
 		'-- stop timer
 		m.e.videoTimer.control = "stop"
 	End If

End Sub



Sub onAActionChange(e)

	action = e.getData()
	m.e.video.setField("aaction", "none")	
	movePrevNextList(action)
		
End Sub