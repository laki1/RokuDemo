
Function onKeyEvent(key As String, press As Boolean) As Boolean

	If press = true
		
        If key = "fastforward" Or key = "rewind"
			m.top.mediabuttonpressed = {
				key: key,
				press: press
			}
			return True
		End If

	End If

	return False

End Function
