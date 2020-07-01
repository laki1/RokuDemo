'*******************************************************************************
' DemoApplication for ROKU device 3500x
'  - only one resolution - hd - can use fix dimensions
'
'  - using only utils codes from ROKU github / ROKU community
'
'  - if i can use any framework -> maestro is the best choice (i'm tested alfa 
'    version and gave feedback to author)
'  - in this demo is no need to keep history etc.
'
'  - file pkg:/config contains application configuration
'
'  - main controller is located in MainScene. It's a spaghetti code with fixed 
'    user interactions. But without any framework and for this alone simple demo 
'    application its acceptablly (for me :-! )
'
'  - i18n i used ROKU Localisation susbystem - demo is in /pkg/locale (text 
'    and images in EN-US and DE-DE)  
'
'  - if i can use foreign code, i linked any http request manager with cancel
'    function, such as https://github.com/mrkjffrsn/RokuFramework
'    For this simple demo it's enough non-blocking (without tasks) http requests
'    based on Roku SDK NWN code GetStringFromURL
'
'  - deeplink support is from ROKU example code
'  
'  - i tried demostrate how i work with Roku SG instead of using clean and 
'    maintable code techniques
'
'  - differences from task:
'     - PLAYREADY stream is in actual fact WIDEVINE stream (directly WIDEVINE 
'       demo stream)
'     - year of movie/series is set to default value (n/a) in datamanager - 
'       API does not implemented
'     - images from API must be downloaded to the local filesystem at the first
'       (token via http header to image source is a bad thing, this should 
'       be registred in the documentation)
'     - heartbeat - it's not exactly specified: 
'         + Send tick every interval after start play stream (to keep session on streamer)? If player is paused?
'         + Send only actual position of stream? On each interval tick or on reach interval?
'         + it's obviously test to use Timer component, i choose first choice
'     - creating data structure on-fly with API service childern, unnecessary data is removed in datamanager
'     - posters on search is not implemented:
'          even with a postponed progressive download of images and limited to only 20 elements, 
'          ROKU rowlist(grid) with local files from tmp:/ (but not from pkg:/!) have same problem 
'          and crash any lists with a little more elements. 
'          it probably does not release graphical memory...
'     - Left/Right to next/prev content isn't implemented in detail, but in player (my oversight...)
'*******************************************************************************

Sub Main(args)
	showScreen(args)     
End Sub

Sub showScreen(args)
	screen = CreateObject("roSGScreen")
	m.port = CreateObject("roMessagePort")
	screen.setMessagePort(m.port)
	scene = screen.CreateScene("MainScene")
	
	m.global = screen.getGlobalNode()
    print "args= "; formatjson(args)
    deeplink = getDeepLinks(args)
    print "deeplink= "; deeplink
    m.global.addField("deeplink", "assocarray", false)
    m.global.deeplink = deeplink
	
	screen.show()
	scene.setFocus(true)
    
	While(true)
		msg = wait(0, m.port)                                                                                        
		msgType = type(msg)

		If msgType = "roSGScreenEvent"
			If msg.isScreenClosed() Then return
		End If
	End While                                            
End Sub


Function getDeepLinks(args) as Object
    deeplink = Invalid

    If args.contentid <> Invalid And args.mediaType <> Invalid
        deeplink = {
            id: args.contentId
            type: args.mediaType
        }
    End If

    return deeplink
End Function