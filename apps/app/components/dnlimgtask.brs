
Sub init()
	
	m.top.functionName = "dnlImage"	
	
End Sub
                                                                                                        

Sub dnlImage()
	timeout = 0		    
	port = CreateObject("roMessagePort")
    ut = CreateObject("roUrlTransfer")
    ut.SetPort(port)
    ut.SetUrl(m.top.src)
    ut.AddHeader("X-API-TOKEN", m.top.token)
    ut.EnableEncodings (True)    
    If ut.AsyncGetToFile(m.top.dest)
        finished = False
        While Not finished
            msg = Wait(timeout, port)
            If msg = Invalid
                finished = True
                Debug("_getUrlToFile. AsyncGetToFile timed out after " + timeout.ToStr () + " milliseconds")
                ut.AsyncCancel()
            Else
                If Type (msg) = "roUrlEvent"
                    finished = True
                    If msg.GetInt() = 1
                        responseCode = msg.GetResponseCode()
                        If responseCode < 0
                            ' cUrl error
                            Debug("_getUrlToFile. AsyncGetToFile cUrl error: " + responseCode.ToStr () + ". Failure Reason: " + msg.GetFailureReason ())
                        Else If responseCode <> 200
                            ' HTTP error
                            Debug("_getUrlToFile. AsyncGetToFile HTTP error: " + responseCode.ToStr () + ". Failure Reason: " + msg.GetFailureReason ())
                        Else
                            ' Successfully retrieved the Url
                        End If
                    Else
                        Debug("_getUrlToFile. AsyncGetToFile did not complete")
                        ut.AsyncCancel()
                    End If
                End If
            End If
        End While
    Else
        Debug("_getUrlToFile. AsyncGetToFile failed")
    End If		    	
End Sub

