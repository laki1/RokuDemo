
Sub init()

	m.top.enableUI = False
	m.top.enableTrickPlay = False

	m.revert_actions = {
		"Play": "Pause",
		"Pause": "Play"
	}

	progress_height = 7
	m.progress_width = 600
	progress_position = [41, 93]

	m.spinner = createObject("roSGNode", "BusySpinner")
	m.spinner.visible = False
	m.spinner.poster.observeField("loadStatus", "showspinner")
	m.spinner.poster.uri = "pkg:/images/loader.png"
	m.spinner.translation = [340, 160]
	m.top.observeField("loading", "loading")

	ui = createObject("roSGNode", "Rectangle")
	ui.color = "0xFB0046FF"
	ui.translation = [300, 488]
	ui.width = 682
	ui.height = 172

	m.title = createObject("roSGNode", "Label")
	m.title.text = ""
	m.title.color = "0xFFFFFFFF"
	m.title.font.size = 27
	m.title.translation = [38, 16]
	m.title.width = 606 ' 682 - 38 - 38

	ui.appendChild(m.title)

	m.current_time = createObject("roSGNode", "Label")
	m.current_time.text = "00:00"
	m.current_time.translation = [43, 63]
	m.current_time.font.size = 19
	m.current_time.color = "0xFFFFFFFF"

	ui.appendChild(m.current_time)

	m.duration = createObject("roSGNode", "Label")
	m.duration.text = "00:00"
	m.duration.translation = [596, 63]
	m.duration.font.size = 19
	m.duration.color = "0xFFFFFFFF"

	ui.appendChild(m.duration)

	progress = createObject("roSGNode", "Rectangle")
	progress.color = "0xFFFFFFFF"
	progress.translation = progress_position
	progress.width = m.progress_width
	progress.height = progress_height

	m.progress = createObject("roSGNode", "Rectangle")
	m.progress.color = "0x55BEFFFF"
	m.progress.translation = [0, 0]
	m.progress.width = 0
	m.progress.height = progress_height

	progress.appendChild(m.progress)
	ui.appendChild(progress)

    '-- i18n image demo
    localize = createObject("RoLocalization") 	 
	back = createObject("roSGNode","poster")
	back.uri = localize.GetLocalizedAsset("images", "help.png")
	back.translation = [42, 121]
	back.width = 514
	back.height = 32
	ui.appendChild(back)

 	cnt = createObject("roSGNode","ContentNode") 
 	buttons = createObject("roSGNode", "VidButtons")
 	buttons.itemComponentName = "VidButtons"
 	buttons.content = cnt
 	buttons.observeField("mediabuttonpressed", "onKeyEventWrapper")
	ui.appendChild(buttons)
	buttons.jumpToItem = 1
	m.buttons = buttons

	m.top.appendChild(m.spinner)
	m.top.appendChild(ui)

	m.top.observeField("content", "set_ui_content")
	m.top.observeField("time_change", "set_ui_position")
	m.top.observeField("visible", "toggle")

	m.top.aaction = "none"
End Sub


Sub showspinner()

	If (m.spinner.poster.loadStatus = "ready")
		centerx = (1280 - m.spinner.poster.bitmapWidth) / 2
		centery = (720 - m.spinner.poster.bitmapHeight) / 2
		m.spinner.translation = [ centerx, centery ]
	End If
	
End Sub


Sub loading(event)

	If event.getData() = True
		m.spinner.control = "start"
		m.spinner.visible = True
	Else
		m.spinner.control = "stop"
		m.spinner.visible = False
	End If
	
End Sub



Sub toggle(event)
	
	If event.getData() = True
		m.top.control = "play"
		m.buttons.setFocus(True)
	Else
		m.top.control = "stop"
	End If
	
End Sub


Function onKeyEventWrapper(event As Object) As Boolean	
	data = event.getData()
	onKeyEvent(data.key, data.press)	
End Function


Function onKeyEvent(key As String, press As Boolean) As Boolean

	If press = True
		action = ""
		If key = "fastforward"
			action = "Forward"
		Else If key = "rewind"
			action = "Rewind"
		Else If key = "replay"
			m.top.control = "play"
			return true
		Else If key = "play"
			play_pause()
			return True
		End If
		
		If key = "left" Then
			m.top.aaction = "prev"
			return True
		End If
		If key = "right" Then
			m.top.aaction = "next"
			return True
		End If

		If action <> ""
			seekit(action)
			return True
		End If

	End If

	return False

End Function


Sub play_pause()
	state = m.top.state

	If state = "finished" Or state = "stopped" Or state = "error"
		m.top.control = "play"
	Else If state = "playing"
		m.top.control = "pause"
	Else If state = "paused"
		m.top.control = "resume"
	End If

End Sub



Sub seekit(txt As String)

	If txt = "Rewind"
		direction = -1
	Else
		direction = 1
	End If
	m.top.seek = min(max(0, m.top.position + (10 * direction)), m.top.duration)

End Sub



Sub set_ui_content(event As Object)
	
	data = event.getData()
	m.title.text = data.title
	
End Sub



Sub set_ui_position()

	If m.top.state = "buffering" Or m.top.state = "playing"
		m.current_time.text = get_time(m.top.position)
		m.duration.text = get_time(m.top.duration)

		If type(m.top.duration) <> "Invalid" And m.top.duration > 0
			m.progress.width = int(m.top.position / m.top.duration * m.progress_width)
		Else
			m.progress.width = 0
		End If
	End If

End Sub




Function get_time(time As Double) As String
	minutes = int(time / 60)
	seconds = time - (minutes * 60)

	return get_time_string(minutes) + ":" + get_time_string(seconds)
End Function

Function get_time_string(val As Double) As String
	If val > 0
		time = str(int(val)).trim()
		If len(time) = 1
			time = "0" + time
		End If
		return time
	End If
	return "00"
End Function

Function min(num1, num2) As Dynamic
	If num1 > num2
		return num2
	End If
	return num1
End Function

Function max(num1, num2) As Dynamic
	If num1 > num2
		return num1
	End If
	return num2
End Function
