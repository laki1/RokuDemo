'*******************************************************************************
' Utilities
'*******************************************************************************

Sub Debug(message As Dynamic)

#if DEBUG 
	print message
#end if    	

End Sub


Function checkSystemAndInitGlobals() As Boolean
    device = CreateObject("roDeviceInfo")
	         
    ' Get device software version and check if OS >= 9 (8.1+ for DRM Widevine, 9.0 for RSG & Profiller, 7.5 escape etc.)
    version = device.GetVersion()
    major = Mid(version, 3, 1).toInt()
    minor = Mid(version, 5, 2).toInt()
    If (major < 9) Then return False                       
                       
    ' Get config values
    manifest = ReadAsciiFile("pkg:/config")
    lines = manifest.Tokenize(chr(10))
    For Each line In lines
        entry = CreateObject("roRegex", " = ", "i").split(line)        
        
		indx = entry[0].Trim()        
                                                                                
        If ( (Len(indx) > 0) And (Left(indx, 1) <> "#") ) 
        	val = entry[1].Trim()	
			GetGlobalAA().AddReplace(indx, val)
        End If
		        
    End For

    ' Check DRM support
    drmInfo = device.GetDrmInfoEx()
    drmPlugin = drmInfo[ GetGlobalAA()["drm_type"] ]
    If (drmPlugin = invalid) Then return False

	Debug (GetGlobalAA())
	Debug( "active locale: " + device.GetCurrentLocale() )

	return True         
End Function


'--return Now UNIX timestamp
Function getNowTimestamp() As Integer

    dt = CreateObject("roDateTime")
	return dt.AsSeconds()
	         
End Function

