'*******************************************************************************
' Utilities - registry
'*******************************************************************************

Function getReg(key)
    ret = invalid
	
	reg = CreateObject("roRegistrySection", "24iDemo")
    If reg.exists(key) then
        ret = reg.read(key)
    End If
	
	return ret    
End Function

Function setReg(key, value)    	
    reg = CreateObject("roRegistrySection", "24iDemo")
    reg.write(key, value)
    reg.flush()
End Function

Function unsetReg(key)
    reg = CreateObject("roRegistrySection", "24iDemo")
    reg.delete(key)
    reg.flush()
End Function

