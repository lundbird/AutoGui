#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#AutoIt3Wrapper_Outfile=simplespy.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#RequireAdmin

#include <GuiEdit.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>

#include <APISysConstants.au3>
#include <GUIMenu.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>

#include "UIAWrappers.au3"
#include "MSAccessibility.au3"
#include "ISimpleDOM.au3"

#include <File.au3>
#include <WinAPIFiles.au3>
AutoItSetOption("MustDeclareVars", 1)

const $cUIA_MAXDEPTH=50  ; The array used is 50 deep if more simplespy just will crash
const $dQuote=""""
const $AutoSpy=0 ;2000 ; SPY about every 2000 milliseconds automatically, 0 is turn of use only ctrl+w

global $oldUIElement ; To keep track of latest referenced element
global $frmSimpleSpy, $edtCtrlInfo , $lblCapture, $lblEscape, $lblRecord, $edtCtrlRecord, $msg
global $i              ; Just a simple counter to measure time expired in main loop
global $UIA_CodeArray  ; Code array to generate code from

global $scriptWrite=false; ;sets writing a robot script of actions

global $LastWindow=null ;contains the last active windows

global $recorderText


;~ Some references for reading
;~ [url=http://support.microsoft.com/kb/138518/nl]http://support.microsoft.com/kb/138518/nl[/url]  tagpoint structures attention point
;~ [url=http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/]http://www.autoitscript.com/forum/topic/128406-interface-autoitobject-iuiautomation/[/url]
;~ [url=http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx]http://msdn.microsoft.com/en-us/library/windows/desktop/ff625914(v=vs.85).aspx[/url]

HotKeySet("{ESC}", "Close") ; Set ESC as a hotkey to exit the script.
HotKeySet("^w", "GetElementInfo") ; Set Hotkey Ctrl+W to get some basic information in the GUI
HotKeySet("^r", "WriteScriptOn") ;toggle the writing of a robot script
HotKeySet("^e","WriteScriptOff") ;toggle off the writing of a robot script

FileDelete(@scriptdir & "\robotScript.txt") ; deletes the last used robot script


Local $hEventProc = DllCallbackRegister('_EventProc', 'none', 'ptr;dword;hwnd;long;long;dword;dword')
;~ Global $g_tRECT, $g_iIndex, $g_hMenu = 0

OnAutoItExitRegister('OnAutoItExit')

Local $hEventHook = _WinAPI_SetWinEventHook($EVENT_SYSTEM_ALERT, $EVENT_SYSTEM_ALERT, DllCallbackGetPtr($hEventProc))

#Region ### START Koda GUI section ### Form=
$frmSimpleSpy = GUICreate("Simple UIA Spy", 801, 601, 181, 4)
$edtCtrlInfo = GUICtrlCreateEdit("", 18, 18, 512, 580)
GUICtrlSetData(-1, "")
$lblCapture = GUICtrlCreateLabel("Ctrl+W to capture information", 544, 10, 528, 17)
$recorderText  = GUICtrlCreateLabel("Ctrl+R to Record and Ctrl+E to End", 544, 30, 528, 17)
$lblEscape = GUICtrlCreateLabel("Escape to exit", 544, 53, 528, 17)
$edtCtrlRecord = GUICtrlCreateEdit("", 544, 72, 233, 520)
;GUICtrlSetData(-1, "//TO DO edtCtrlRecord")
;~ $lblRecord = GUICtrlCreateLabel("Ctrl + R to record code", 544, 32, 527, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;~ _UIA_Init()

;~ loadCodeTemplates() ; //TODO: To use templates per class/controltype

; Run the GUI until the dialog is closed
While true
	$msg = GUIGetMsg()
	sleep(100)
	;~ if _ispressed(01) Then
	;~ getelementinfo()
	;~ endif

	;Just to show anyway the information about every n ms so ctrl+w is not interfering / removing window as unwanted side effects
	$i=$i+100
	if ($autoSpy<>0) and ($i>= $autoSpy) then
		$i=0
		getelementinfo()
	EndIf

	If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd

Func WriteScriptOn()
	$scriptWrite=True
    GUICtrlSetData(-1, "Recording ON")
    FileDelete(@scriptdir & "\recordedActions.robot")
	FileDelete(@scriptdir & "\recordedActions.py")
EndFunc

Func WriteScriptOff()
    GUICtrlSetData(-1, "Recording OFF")
	$scriptWrite=false;

    Local Const $sFilePath = @scriptdir & "\recordedActions.robot"
    _FileWriteToLine($sFilePath,1,"***Settings***" & @CRLF & "Library  autogui  " & @CRLF & @CRLF & "***Test cases***" & @CRLF & "Case 1",false)

	Local Const $pFilePath = @scriptdir & "\recordedActions.py"
	_FileWriteToLine($pFilePath,1,"from autogui import *")
EndFunc

Func GetElementInfo()
;~ 	Local $hWnd, $oldElement, $oExpandCollapse\
	Local $oldElement
	#forceref $oldElement
	Local $i, $parentCount, $xMouse, $yMouse, $oUIElement, $oTW, $objParent,  $text1, $t
	;~ Local $tStruct = DllStructCreate("INT64,INT64")
	Local $tStruct = DllStructCreate($tagPOINT) ; Create a structure that defines the point to be checked.
	local $oParentHandle[$cUIA_MAXDEPTH] ; Max number of (grand)parents

;~	Some variables to put generated sourcecode in
	local $codeFlex1=""

	local $codeMain1_1=""
	local $codeMain1_2=""

	$oldElement=""
	$xMouse=MouseGetPos(0)
	$yMouse=MouseGetPos(1)
	DllStructSetData($tStruct, "x", $xMouse)
	DllStructSetData($tStruct, "y", $yMouse)
;~ consolewrite(DllStructGetData($tStruct,"x") & DllStructGetData($tStruct,"y"))
;~ consolewrite("Mouse position is retrieved " & @crlf)

;~ Check for an UIA Element
	$UIA_oUIAutomation.ElementFromPoint($tStruct,$UIA_pUIElement )
	;~ consolewrite("Element from point is passed, trying to convert to object ")
	$oUIElement = objcreateinterface($UIA_pUIElement,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)

;~ _UIA_DumpThemAll($oUIElement, $treescope_subtree)
;~ $oExpandCollapse=_UIA_getpattern($oUIElement,$UIA_ExpandCollapsePatternID)
;~ $oExpandCollapse.expand()
;~ $oExpandCollapse.collapse()


;~ Walk thru the tree with a treewalker
;~ Three other predefined conditions can be used alone or in combination with other conditions: ContentViewCondition, ControlViewCondition, and RawViewCondition.
;~ RawViewCondition, used by itself, is equivalent to TrueCondition, because it does not filter elements by their IsControlElement or IsContentElement properties.
$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
;~ 	$UIA_oUIAutomation.ContentViewWalker($UIA_pTW)
;~ 	$UIA_oUIAutomation.ControlViewWalker($UIA_pTW)

	$oTW=ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
    If IsObj($oTW) = 0 Then
        msgbox(1,"UI automation treewalker failed", "UI Automation failed failed",10)
    EndIf

#REGION Check if there is an better element closely related
;~  Just walk thru all childs to find a better element if UI Hierarchy is having overlapping windows
;~ 	at least 1 assumed (assuming we are not spying the desktop)
;~	Chrome is terrible regarding overlapping windows

	$i=0
	local $oChildHandle
	local $pChildHandle

	local $oTMPParentHandle
	local $pTMPParentHandle
	$oTW.getparentelement($oUIElement,$pTMPParentHandle)
	$oTMPParentHandle=objcreateinterface($pTMPparentHandle,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)

	$oTW.GetFirstChildElement($oTMPParenthandle,$pChildHandle)
	$oChildHandle=objcreateinterface($pChildHandle,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If IsObj($oChildHandle) = 0 Then
		msgbox(1,"No childs", "No childs below this element",10)
	Else

		while (IsObj($oChildHandle)=1)
			consolewrite("title:=" & _UIA_getPropertyValue($oChildHandle,$UIA_NamePropertyId) & @CRLF)
			$t=stringsplit(_UIA_getPropertyValue($oChildHandle, $UIA_BoundingRectanglePropertyId),";")
			;x,y,width,heigth
			if (($xMouse >= $t[1]) and ($xMouse <= ($t[1]+$t[3]))) and (($yMouse >= $t[2]) and ($yMouse <=($t[2]+$t[4]))) then
				$oUIElement=$oChildHandle
;~ 				_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])
				consolewrite("title:=" & _UIA_getPropertyValue($oChildHandle,$UIA_NamePropertyId) & ";classname:=" & _UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid) & _UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId) & @CRLF)
;~ 				sleep(1000)
;~ 				exitloop
			EndIf
			$oTW.GetNextSiblingElement($oChildHandle,$pChildHandle)
			$oChildHandle=objcreateinterface($pChildHandle,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		wend
	endif
#EndRegion

#REGION Get all parents
;~ 	at least 1 assumed (assuming we are not spying the desktop)
	$i=0
	$oTW.getparentelement($oUIElement,$oParentHandle[$i])
	$oParentHandle[$i]=objcreateinterface($oparentHandle[$i],$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If IsObj($oParentHandle[$i]) = 0 Then
		msgbox(1,"No parent", "UI Automation failed could be you spy the desktop",10)
	Else
;~	Just put all parents in an array
		while ($i <=$cUIA_MAXDEPTH-1) and (IsObj($oParentHandle[$i])=true)
			$i=$i+1
			$oTW.getparentelement($oparentHandle[$i-1],$oparentHandle[$i])
			$oParentHandle[$i]=objcreateinterface($oparentHandle[$i],$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		wend
		$parentCount=$i-1
	EndIf
#EndRegion

;~ Just make sure we do not inspect twice same element
	if isobj($oldUIElement) Then
		if $oldUIElement=$oUIElement then
			return
		endif
	endif
	$oldElement=$oUIElement

	_WinAPI_RedrawWindow(_WinAPI_GetDesktopWindow(), 0, 0, $RDW_INVALIDATE + $RDW_ALLCHILDREN) ; Clears Red outline graphics.

;~	Just some information in the edit box that we have a mouseposition (not neccesarily an element found)
	GUICtrlSetData($edtCtrlInfo, "Mouse position is retrieved " & $xMouse & "-" & $yMouse & @CRLF)

;~ Check for an IAccessible element
;~ https://www.autoitscript.com/forum/topic/153520-iuiautomation-ms-framework-automate-chrome-ff-ie/?do=findComment&comment=1156373
;~ post #153
	local $pObject, $tVarChild, $vt
	If AccessibleObjectFromPoint( $xMouse, $yMouse, $pObject, $tVarChild ) = $S_OK Then
;~ 		msgbox(0,"accessible object", "accessible object")
		Local $oIA_Object, $hWnd, $sName = ""
				$oIA_Object = ObjCreateInterface( $pObject, $sIID_IAccessible, $dtagIAccessible )
				$oIA_Object.get_accName( $CHILDID_SELF, $sName )
				GUICtrlSetData($edtCtrlInfo, "There is also an IAccessible interface for " & $sName &  @CRLF)
				GUICtrlSetData($edtCtrlInfo, "    https://www.autoitscript.com/forum/topic/153520-iuiautomation-ms-framework-automate-chrome-ff-ie/?do=findComment&comment=1156373 " &  @CRLF)


		$vt = BitAND( DllStructGetData( $tVarChild, 1, 1 ), 0xFFFF )
		If $vt = $VT_I4 Then

			If WindowFromAccessibleObject( $pObject, $hWnd ) = $S_OK Then
				AccessibleObjectFromWindow( $hWnd, $OBJID_CLIENT, $tIID_IAccessible, $pObject )
				$oIA_Object = ObjCreateInterface( $pObject, $sIID_IAccessible, $dtagIAccessible )
				$oIA_Object.get_accName( $CHILDID_SELF, $sName )
				GUICtrlSetData($edtCtrlInfo, "There is also an IAccessible interface for " & $sName &  @CRLF)
				GUICtrlSetData($edtCtrlInfo, "    https://www.autoitscript.com/forum/topic/153520-iuiautomation-ms-framework-automate-chrome-ff-ie/?do=findComment&comment=1156373 " &  @CRLF)
			EndIf
		EndIf
	EndIf

;~	And now just retrieve some basic information about the object spied on
If IsObj($oUIElement) Then
	local $title=_UIA_getPropertyValue($oUIElement,$UIA_NamePropertyId)
	local $class=_UIA_getPropertyValue($oUIElement,$uia_classnamepropertyid)
	local $controltypeName=_UIA_getControlName(_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId))
	local $controltypeId=_UIA_getPropertyValue($oUIElement,$UIA_ControlTypePropertyId)
	local $controlIDString=$title
	local $DefaultExpression=$dQuote & "Title:=" & $Title & ";" & "controltype:=" & $ControlTypeName & ";" & "class:=" & $Class & $dQuote
	local $nativeWindow=_UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)
	local $controlRect=_UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId)

	local $pos=stringinstr($controlIDString,"-")
	if $pos > 0 Then
		$controlIDString=stringleft($controlIDString,$pos)
	EndIf
	$controlIDString=_UIA_NiceString($controlIDString)

;~  ConsoleWrite("At least we have an element "  & "[" & _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId) & "][" & _UIA_getPropertyValue($oUIElement, $UIA_ClassNamePropertyId) & "]" & @CRLF)
	GUICtrlSetData($edtCtrlInfo, "At least we have an element "  & "title: [" & $title & "] class: [" & $class & "]" & @CRLF & @CRLF ,1)

;~	Construct the basic information we are interested in
	$text1="Title is: <" &  $title &  ">" & @TAB _
			& "Class   := <" & $class &  ">" & @TAB _
			& "controltype:= " 	& "<" &  $controltypeName &  ">" & @TAB  _
			& ",<" &  $controltypeId &  ">" & @TAB & ", (" &  hex($controltypeId )&  ")" & @TAB & $controlRect  & @CRLF

if $nativeWindow <> 0 Then
;~ Maintainable syntax
		$codeMain1_1=$codeMain1_1 & "_UIA_setVar(""" & $controlIDString & ".mainwindow"",""title:=" & $title &";classname:=" & $class & """)" & @CRLF
		$codeMain1_2=$codeMain1_2 & "_UIA_action(""" & $controlIDString & ".mainwindow"",""setfocus"")" & @CRLF
;~ Straight forward syntax

;~ Flexible syntax
		$codeFlex1=$codeFlex1 & "_UIA_setVar(""" & $controlIDString & ".mainwindow"",""title:=" & $title &";classname:=" & $class & """)" & @CRLF
		$codeFlex1=$codeFlex1 & "_UIA_action(""" & $controlIDString & ".mainwindow"",""setfocus"")" & @CRLF

Else
;~ Maintainable syntax
;~ 		$codeMain1_1=$codeMain1_1 & ";~ First find the object in the parent before you can do something" & @CRLF
 		$codeMain1_1=$codeMain1_1 & ";~ $oUIElement=_UIA_getObjectByFindAll(""" & $controlIDString & ".mainwindow"", ""title:=" & $title &";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
 		$codeMain1_1=$codeMain1_1 & "_UIA_setVar(" & $dQuote & "oUIElement" & $dQuote & "," & $defaultExpression & ") ;ControlType:=" & $controltypeName  & ";classname:=" & $class & """)" & @CRLF
;~ 		$codeMain1_2=$codeMain1_2 & ";~_UIA_action($oUIElement" & $dQuote & ","  & $dQuote & "highlight" &  $dQuote & ")" & @CRLF
;~ 		$codeMain1_2=$codeMain1_2 & ";~_UIA_action($oUIElement," & $dQuote & "click" & $dQuote & ")" & @CRLF
		$codeMain1_2=$codeMain1_2 & "_UIA_action(" & $dQuote & "oUIElement" & $dQuote & "," & $dQuote & "highlight" & $dQuote & ")" & @CRLF
		$codeMain1_2=$codeMain1_2 & ";~_UIA_action(" & $dQuote & "oUIElement" & $dQuote & "," & $dQuote & "click" & $dQuote & ")" & @CRLF

;~ Flexible syntax
		$codeFlex1=$codeFlex1 & ";~ First find the object in the parent before you can do something" & @CRLF
		$codeFlex1=$codeFlex1 & ";~$oUIElement=_UIA_getObjectByFindAll(""" & $controlIDString & ".mainwindow"", ""title:=" & $title &";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
		$codeFlex1=$codeFlex1 & "Local $oUIElement=_UIA_getObjectByFindAll($oP0, ""title:=" & $title &";ControlType:=" & $controltypeName & """, $treescope_subtree)" & @CRLF
		$codeFlex1=$codeFlex1 & ";~_UIA_action($oUIElement,""highlight"")" & @CRLF
		$codeFlex1=$codeFlex1 & "_UIA_action($oUIElement,""click"")" & @CRLF
EndIf

    $text1=$text1 & "*** Parent Information top down ***" & @CRLF
    local $pText1=""
	local $pCodeFlex1="", $pCodeMain1_1="", $pcodeMain1_2=""

;~ parentcount-1 As thats the $UIA_oDesktop'
;~ $oParentHandle[0] is direct parent of the element we are spying
    for $i=$parentcount-1 to 0 step -1
			$objParent=$oParentHandle[$i]
			local $ptitle=_UIA_getPropertyValue($objParent,$UIA_NamePropertyId)
			local $pclass=_UIA_getPropertyValue($objParent,$uia_classnamepropertyid)
			local $pcontroltypeName=_UIA_getControlName(_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId))
			local $pControltypeId=_UIA_getPropertyValue($objParent,$UIA_ControlTypePropertyId)
            local $pDefaultExpression=$dQuote & "Title:=" & $pTitle & ";" & "controltype:=" & $pControlTypeName & ";" & "class:=" & $pClass & $dQuote
			local $pNativeWindow=_UIA_getPropertyValue($objParent, $UIA_NativeWindowHandlePropertyId)
			local $pcontrolRect=_UIA_getPropertyValue($objParent, $UIA_BoundingRectanglePropertyId)
			local $pVisible=_UIA_getPropertyValue($objParent, $UIA_IsOffscreenPropertyId)

			$pText1=$pText1 & $I & ": Title is: <" &  $ptitle &  ">" & @TAB _
					& "Class   := <" & $pclass &  ">" & @TAB _
					& "controltype:= " & "<" &  $pcontroltypeName &  ">" & @TAB  _
					& ",<" &  $PcontroltypeId &  ">" & @TAB & ", (" &  hex($PcontroltypeId) &  ")" & @TAB &  $pcontrolRect  & @CRLF
			$ptext1=$ptext1  & $pdefaultExpression &   $dQuote & @TAB & @CRLF

;~ Maintainable syntax
			if $pVisible="true" then
				$pcodeMain1_1=$pCodeMain1_1 & "#cs This element is not visible" & @CRLF
				$pcodeMain1_2=$pCodeMain1_2 & "#cs This element is not visible" & @CRLF
			EndIf

			$pcodeMain1_1=$pCodeMain1_1 & "_UIA_setVar(" & $dQuote & "oP" & $parentcount-$i & $dQuote & "," &   $pdefaultExpression & ")" & @TAB & ";" & $ptitle  & @CRLF
			$pCodeMain1_2=$pCodeMain1_2 & ";~_UIA_Action(" & $dQuote & "oP" & $parentcount-$i & $dQuote &  ",""highlight"")"  & @CRLF
			$pCodeMain1_2=$pCodeMain1_2 & "_UIA_Action(" & $dQuote & "oP" & $parentcount-$i & $dQuote &  ",""setfocus"")"  & @CRLF

			if $pVisible="true" then
				$pcodeMain1_1=$pCodeMain1_1 & "#ce" & @CRLF
				$pcodeMain1_2=$pCodeMain1_2 & "#ce" & @CRLF
			EndIf

;~ Flexible syntax
			if $i=$parentcount-1 Then
				$pCodeFlex1=$pCodeFlex1 & "Local $oP" &$i & "=_UIA_getObjectByFindAll($UIA_oDesktop, " & $pdefaultExpression & ", $treescope_children)" & @TAB & @CRLF
			Else
				if $i<=$parentcount-2 then
					$pCodeFlex1=$pCodeFlex1 & "Local $oP" &$i & "=_UIA_getObjectByFindAll($oP" & $i+1 & ", " & $pdefaultExpression & ", $treescope_children)" & @TAB & @CRLF
				endif

			endif
			if ($pnativeWindow <> 0) and ($i<>$ParentCount) Then
				$pCodeFlex1=$pCodeFlex1 & "_UIA_Action($oP" & $i & ",""setfocus"")"  & @CRLF
			endif
	Next

    $text1=$text1 & $ptext1 & @CRLF & @CRLF

;output Maintainable code section
;~ Maintainable syntax

	$text1=$text1 & ";~ *** Standard code maintainable ***" & @CRLF
	$text1=$text1 & "#include ""UIAWrappers.au3""" & @CRLF
	$text1=$text1 & "AutoItSetOption(""MustDeclareVars"", 1)" & @CRLF & @CRLF
	$text1=$text1 & $pcodeMain1_1 & @CRLF
	$text1=$text1 & $codeMain1_1 & @CRLF
	$text1=$text1 & ";~ Actions split away from logical/technical definition above can come from configfiles " & @CRLF & @CRLF

	$text1=$text1 & $pcodeMain1_2 & @CRLF
	$text1=$text1 & $codeMain1_2 & @CRLF & @CRLF

;output flexible code section
	$text1=$text1 & ";~ *** Standard code Flexible***" & @CRLF
	$text1=$text1 & "#include ""UIAWrappers.au3""" & @CRLF
	$text1=$text1 & "AutoItSetOption(""MustDeclareVars"", 1)" & @CRLF & @CRLF

	$text1=$text1 & $pCodeFlex1
	$text1=$text1 & $codeFlex1 & @CRLF & @CRLF

	$text1=$text1 & "*** Detailed properties of the highlighted element ***"
	$text1= $text1 & @CRLF & _UIA_getAllPropertyValues($oUIElement)



	GUICtrlSetData($edtCtrlInfo, "Having the following values for all properties: " & @crlf & $text1 & @CRLF, 1)

	_GUICtrlEdit_LineScroll($edtCtrlInfo, 0, 0 - _GUICtrlEdit_GetLineCount($edtCtrlInfo))

;~      x, y, w, h
	$t=stringsplit(_UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId),";")
	_UIA_DrawRect($t[1],$t[3]+$t[1],$t[2],$t[4]+$t[2])


	if $scriptWrite=true Then
		WriteRobotScript($oUIElement,$oParentHandle[$parentCount-1])
	EndIf

EndIf

EndFunc   ;==>GetElementInfo

Func WriteRobotScript($obj,$objParent)
	Local Const $sFilePath = @scriptdir & "\recordedActions.robot"
	Local Const $pFilePath = @scriptdir & "\recordedActions.py"

    Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
    If $hFileOpen = -1 Then
        consolewrite( "recordedActions.robot not available An error occurred when reading the file." & @CRLF)
        Return False
    EndIf	

	Local $pFileOpen = FileOpen($pFilePath,$FO_APPEND)
	if $pFileOpen = -1 Then	
		consolewrite("recordedActions.py not available" & @CRLF)
		Return False
	EndIf

	Local $id = _UIA_getPropertyValue($obj,$UIA_AutomationIdPropertyId)
	Local $title = _UIA_getPropertyValue($obj,$UIA_NamePropertyId)
	local $accessibleValue = _UIA_getPropertyValue($obj,$UIA_LegacyIAccessibleValuePropertyId)
	local $class = _UIA_getPropertyValue($obj,$UIA_ClassNamePropertyId)
    local $ptitle=_UIA_getPropertyValue($objParent,$UIA_NamePropertyId)

    if $LastWindow<>$ptitle Then
		FileWrite($hFileOpen,@TAB & "setWindow  "  & $ptitle & @CRLF)
		FileWrite($pFileOpen,"setWindow(" & '"' & $ptitle & '"' & ")" & @CRLF)
		$LastWindow=$ptitle
	EndIf

	;writes to both robot and python files
	if $id <>'' Then
		FileWrite($hFileOpen,@TAB & "click  " & "id:=" & $id  & @CRLF)
		FileWrite($pFileOpen, "click(" & '"' & "id:=" & $id & '"' & ")" & @CRLF)
	Elseif $title<>'' Then
		FileWrite($hFileOpen,@TAB & "click  " & $title  & @CRLF)
		FileWrite($pFileOpen,"click(" & '"' & $title  & '"' & ")" & @CRLF)
	Elseif $accessibleValue<>'' Then
		FileWrite($hFileOpen,@TAB & "click  " & "value:=" & $accessibleValue & @CRLF)
		FileWrite($pFileOpen,"click("& '"' & "value:=" & $accessibleValue & '"' & ")" & @CRLF)
	Else
		FileWrite($hFileOpen,@TAB & "click  " & "class:=" & $class & @CRLF)
		FileWrite($pFileOpen,"click(" & '"' & "class:=" & $class & '"' &")" & @CRLF)
	EndIf

	FileClose($hFileOpen)
	FileClose($pFileOpen)
EndFunc


Func Close()
Exit
EndFunc   ;==>Close

Func OnAutoItExit()
    _WinAPI_UnhookWinEvent($hEventHook)
    DllCallbackFree($hEventProc)
EndFunc   ;==>OnAutoItExit

;~ Chrome accessibility looks for screenreaders when starting or opening new tab so reply that we are a screen spy
;~ https://www.chromium.org/developers/design-documents/accessibility
;~ Windows: Chrome calls NotifyWinEvent with EVENT_SYSTEM_ALERT and the custom object id of 1.
;~ If it subsequently receives a WM_GETOBJECT call for that custom object id, it assumes that assistive technology is running.
Func _EventProc($hEventHook, $iEvent, $hWnd, $iObjectID, $iChildID, $iThreadID, $iEventTime)
    #forceref $hEventHook, $iObjectID, $iChildID, $iThreadID, $iEventTime
	local $result=0
	#forceref $result
    Switch $iEvent
        Case $EVENT_SYSTEM_ALERT
            if $iObjectID=1 then
                $result = _SendMessage($hWnd, $WM_GETOBJECT, 0, 1)
;~                 consolewrite("Chrome gave a call so we replied " & $iObjectID)
            EndIf
    EndSwitch
EndFunc   ;==>_EventProc



#CS
func genCode()
	local $i, $tLine
    $i=0
	while $i<>ubound($UIA_CodeArray)-1
		$i=$i+1

;~ 		["name",$UIA_NamePropertyId], _
;~ Global Const $UIA_RuntimeIdPropertyId=30000
		$tLine=$UIA_CodeArray[$i]
	WEnd


    ; Display the first line of the file.
;~     MsgBox($MB_SYSTEMMODAL, "", "First line of the file:" & @CRLF & $aArray[1])

EndFunc

func loadCodeTemplates()
    Local Const $sFilePath = @scriptdir & "\codeTemplates.txt"

    Local $hFileOpen = FileOpen($sFilePath, $FO_READ)
    If $hFileOpen = -1 Then
        consolewrite( "//TODO codetemplates.txt not available An error occurred when reading the file. & @CRLF")
        Return False
    EndIf

;~ 	Read the whole file straight into an array
	$UIA_CodeArray = FileReadToArray($hFileOpen)

    FileClose($hFileOpen)
EndFunc
#CE




;~ While 1
;~     Sleep(1000)
;~ WEnd

