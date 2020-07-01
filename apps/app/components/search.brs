
Sub initSearch()

	searchddialog = createObject("roSGNode", "KeyboardDialog")
    searchddialog.title = tr("Search in VOD library")
    searchddialog.optionsDialog = true
    searchddialog.buttons = [tr("Search in all content"), tr("Search only movies"), tr("Search only series"), tr("Close")]
    
    m.top.dialog = searchddialog
    m.top.dialog.text = m.search.text
    m.top.dialog.keyboard.textEditBox.cursorPosition = Len(m.search.text)
    m.top.dialog.keyboard.textEditBox.maxTextLength = 300

    searchddialog.observeFieldScoped("buttonSelected", "onDialogButtonSelected")
    
End Sub
Sub doneSearch()
	
End Sub


Sub onDialogButtonSelected()
	If m.top.dialog.buttonSelected = 0
		'--Search in all content 
        m.search.text = m.top.dialog.text
		m.search.filtermovies = False
		m.search.filterseries = False
		doSearch()
		
    ElseIf m.top.dialog.buttonSelected = 1
    	'--Search only movies
        m.search.text = m.top.dialog.text
        m.search.filtermovies = True
		m.search.filterseries = False
		doSearch()
		        
    ElseIf m.top.dialog.buttonSelected = 2
        '--Search only series
		m.search.text = m.top.dialog.text
		m.search.filtermovies = False
		m.search.filterseries = True
		
		doSearch()
    Else
    	'--Close
		        
	End If	
	m.top.dialog.close = true
End Sub


Sub doSearch()
	
	m.search.active = True
	dataSearch()
	
End Sub





