#include-once

#include "CUIAutomation2.au3"
#include <autoitconstants.au3>
#include <winapiconstants.au3>
#include <menuconstants.au3>

;~ Global Const $S_OK                  = 0x00000000
Global Const $S_FALSE               = 0x00000001
;~ Global Const $E_NOTIMPL             = 0x80004001
;~ Global Const $E_NOINTERFACE         = 0x80004002
;~ Global Const $E_FAIL                = 0x80004005
Global Const $DISP_E_MEMBERNOTFOUND = 0x80020003
;~ Global Const $E_OUTOFMEMORY         = 0x8007000E
;~ Global Const $E_INVALIDARG          = 0x80070057

Global Const $VT_EMPTY    = 0
Global Const $VT_I4       = 3
Global Const $VT_DISPATCH = 9

;Global Const $tagVARIANT = "word vt;word r1;word r2;word r3;ptr data; ptr;"
Global $tagVARIANT
If @AutoItX64 Then
	$tagVARIANT = "dword[6];" ; Use this form to be able to build an
Else                               ; array in function AccessibleChildren.
	$tagVARIANT = "dword[4];"
EndIf


Global Const $tIID_IAccessible = CLSIDFromString( $sIID_IAccessible )

Global Const $sIID_IServiceProvider = "{6D5140C1-7436-11CE-8034-00AA006009FA}"
Global Const $tIID_IServiceProvider = CLSIDFromString( $sIID_IServiceProvider )
Global Const $dtagIServiceProvider = "QueryService hresult(struct*;struct*;ptr*);"


; ========= MS Active Accessibility constants =========

; Child ID for the object itself
; (in contrast to simple child elements of the object)
Global Const $CHILDID_SELF = 0

; Navigation constants
Global Const $NAVDIR_MIN        = 0
Global Const $NAVDIR_UP         = 0x1
Global Const $NAVDIR_DOWN       = 0x2
Global Const $NAVDIR_LEFT       = 0x3
Global Const $NAVDIR_RIGHT      = 0x4
Global Const $NAVDIR_NEXT       = 0x5
Global Const $NAVDIR_PREVIOUS   = 0x6
Global Const $NAVDIR_FIRSTCHILD = 0x7
Global Const $NAVDIR_LASTCHILD  = 0x8
Global Const $NAVDIR_MAX        = 0x9

; Selection flags
Global Const $SELFLAG_NONE            = 0
Global Const $SELFLAG_TAKEFOCUS       = 0x1
Global Const $SELFLAG_TAKESELECTION   = 0x2
Global Const $SELFLAG_EXTENDSELECTION = 0x4
Global Const $SELFLAG_ADDSELECTION    = 0x8
Global Const $SELFLAG_REMOVESELECTION = 0x10
Global Const $SELFLAG_VALID           = 0x1f

; Object identifiers
;~ Global Const $OBJID_WINDOW            = 0x00000000
;~ Global Const $OBJID_SYSMENU           = 0xFFFFFFFF
;~ Global Const $OBJID_TITLEBAR          = 0xFFFFFFFE
;~ Global Const $OBJID_MENU              = 0xFFFFFFFD

;~ Global Const $OBJID_CLIENT            = 0xFFFFFFFC
;~ #define     OBJID_CLIENT        ((LONG)0xFFFFFFFC)

Global $OBJID_CLIENT            = 0xFFFFFFFC

Global Const $OBJID_VSCROLL           = 0xFFFFFFFB
Global Const $OBJID_HSCROLL           = 0xFFFFFFFA
;~ Global Const $OBJID_SIZEGRIP          = 0xFFFFFFF9
;~ Global Const $OBJID_CARET             = 0xFFFFFFF8
;~ Global Const $OBJID_CURSOR            = 0xFFFFFFF7
;~ Global Const $OBJID_ALERT             = 0xFFFFFFF6
;~ Global Const $OBJID_SOUND             = 0xFFFFFFF5
Global Const $OBJID_QUERYCLASSNAMEIDX = 0xFFFFFFF4
Global Const $OBJID_NATIVEOM          = 0xFFFFFFF0

; Object roles
Global Const $ROLE_SYSTEM_TITLEBAR           = 0x1
Global Const $ROLE_SYSTEM_MENUBAR            = 0x2
Global Const $ROLE_SYSTEM_SCROLLBAR          = 0x3
Global Const $ROLE_SYSTEM_GRIP               = 0x4
Global Const $ROLE_SYSTEM_SOUND              = 0x5
Global Const $ROLE_SYSTEM_CURSOR             = 0x6
Global Const $ROLE_SYSTEM_CARET              = 0x7
Global Const $ROLE_SYSTEM_ALERT              = 0x8
Global Const $ROLE_SYSTEM_WINDOW             = 0x9
Global Const $ROLE_SYSTEM_CLIENT             = 0xa
Global Const $ROLE_SYSTEM_MENUPOPUP          = 0xb
Global Const $ROLE_SYSTEM_MENUITEM           = 0xc
Global Const $ROLE_SYSTEM_TOOLTIP            = 0xd
Global Const $ROLE_SYSTEM_APPLICATION        = 0xe
Global Const $ROLE_SYSTEM_DOCUMENT           = 0xf
Global Const $ROLE_SYSTEM_PANE               = 0x10
Global Const $ROLE_SYSTEM_CHART              = 0x11
Global Const $ROLE_SYSTEM_DIALOG             = 0x12
Global Const $ROLE_SYSTEM_BORDER             = 0x13
Global Const $ROLE_SYSTEM_GROUPING           = 0x14
Global Const $ROLE_SYSTEM_SEPARATOR          = 0x15
Global Const $ROLE_SYSTEM_TOOLBAR            = 0x16
Global Const $ROLE_SYSTEM_STATUSBAR          = 0x17
Global Const $ROLE_SYSTEM_TABLE              = 0x18
Global Const $ROLE_SYSTEM_COLUMNHEADER       = 0x19
Global Const $ROLE_SYSTEM_ROWHEADER          = 0x1a
Global Const $ROLE_SYSTEM_COLUMN             = 0x1b
Global Const $ROLE_SYSTEM_ROW                = 0x1c
Global Const $ROLE_SYSTEM_CELL               = 0x1d
Global Const $ROLE_SYSTEM_LINK               = 0x1e
Global Const $ROLE_SYSTEM_HELPBALLOON        = 0x1f
Global Const $ROLE_SYSTEM_CHARACTER          = 0x20
Global Const $ROLE_SYSTEM_LIST               = 0x21
Global Const $ROLE_SYSTEM_LISTITEM           = 0x22
Global Const $ROLE_SYSTEM_OUTLINE            = 0x23
Global Const $ROLE_SYSTEM_OUTLINEITEM        = 0x24
Global Const $ROLE_SYSTEM_PAGETAB            = 0x25
Global Const $ROLE_SYSTEM_PROPERTYPAGE       = 0x26
Global Const $ROLE_SYSTEM_INDICATOR          = 0x27
Global Const $ROLE_SYSTEM_GRAPHIC            = 0x28
Global Const $ROLE_SYSTEM_STATICTEXT         = 0x29
Global Const $ROLE_SYSTEM_TEXT               = 0x2a
Global Const $ROLE_SYSTEM_PUSHBUTTON         = 0x2b
Global Const $ROLE_SYSTEM_CHECKBUTTON        = 0x2c
Global Const $ROLE_SYSTEM_RADIOBUTTON        = 0x2d
Global Const $ROLE_SYSTEM_COMBOBOX           = 0x2e
Global Const $ROLE_SYSTEM_DROPLIST           = 0x2f
Global Const $ROLE_SYSTEM_PROGRESSBAR        = 0x30
Global Const $ROLE_SYSTEM_DIAL               = 0x31
Global Const $ROLE_SYSTEM_HOTKEYFIELD        = 0x32
Global Const $ROLE_SYSTEM_SLIDER             = 0x33
Global Const $ROLE_SYSTEM_SPINBUTTON         = 0x34
Global Const $ROLE_SYSTEM_DIAGRAM            = 0x35
Global Const $ROLE_SYSTEM_ANIMATION          = 0x36
Global Const $ROLE_SYSTEM_EQUATION           = 0x37
Global Const $ROLE_SYSTEM_BUTTONDROPDOWN     = 0x38
Global Const $ROLE_SYSTEM_BUTTONMENU         = 0x39
Global Const $ROLE_SYSTEM_BUTTONDROPDOWNGRID = 0x3a
Global Const $ROLE_SYSTEM_WHITESPACE         = 0x3b
Global Const $ROLE_SYSTEM_PAGETABLIST        = 0x3c
Global Const $ROLE_SYSTEM_CLOCK              = 0x3d
Global Const $ROLE_SYSTEM_SPLITBUTTON        = 0x3e
Global Const $ROLE_SYSTEM_IPADDRESS          = 0x3f
Global Const $ROLE_SYSTEM_OUTLINEBUTTON      = 0x40

; Object state constants
Global Const $STATE_SYSTEM_NORMAL          = 0
Global Const $STATE_SYSTEM_UNAVAILABLE     = 0x1
Global Const $STATE_SYSTEM_SELECTED        = 0x2
Global Const $STATE_SYSTEM_FOCUSED         = 0x4
Global Const $STATE_SYSTEM_PRESSED         = 0x8
Global Const $STATE_SYSTEM_CHECKED         = 0x10
Global Const $STATE_SYSTEM_MIXED           = 0x20
Global Const $STATE_SYSTEM_INDETERMINATE   = $STATE_SYSTEM_MIXED
Global Const $STATE_SYSTEM_READONLY        = 0x40
Global Const $STATE_SYSTEM_HOTTRACKED      = 0x80
Global Const $STATE_SYSTEM_DEFAULT         = 0x100
Global Const $STATE_SYSTEM_EXPANDED        = 0x200
Global Const $STATE_SYSTEM_COLLAPSED       = 0x400
Global Const $STATE_SYSTEM_BUSY            = 0x800
Global Const $STATE_SYSTEM_FLOATING        = 0x1000
Global Const $STATE_SYSTEM_MARQUEED        = 0x2000
Global Const $STATE_SYSTEM_ANIMATED        = 0x4000
Global Const $STATE_SYSTEM_INVISIBLE       = 0x8000
Global Const $STATE_SYSTEM_OFFSCREEN       = 0x10000
Global Const $STATE_SYSTEM_SIZEABLE        = 0x20000
Global Const $STATE_SYSTEM_MOVEABLE        = 0x40000
Global Const $STATE_SYSTEM_SELFVOICING     = 0x80000
Global Const $STATE_SYSTEM_FOCUSABLE       = 0x100000
Global Const $STATE_SYSTEM_SELECTABLE      = 0x200000
Global Const $STATE_SYSTEM_LINKED          = 0x400000
Global Const $STATE_SYSTEM_TRAVERSED       = 0x800000
Global Const $STATE_SYSTEM_MULTISELECTABLE = 0x1000000
Global Const $STATE_SYSTEM_EXTSELECTABLE   = 0x2000000
Global Const $STATE_SYSTEM_ALERT_LOW       = 0x4000000
Global Const $STATE_SYSTEM_ALERT_MEDIUM    = 0x8000000
Global Const $STATE_SYSTEM_ALERT_HIGH      = 0x10000000
Global Const $STATE_SYSTEM_PROTECTED       = 0x20000000
Global Const $STATE_SYSTEM_HASPOPUP        = 0x40000000
Global Const $STATE_SYSTEM_VALID           = 0x7fffffff

; Event constants
;#include "APIConstants.au3"   ; AutoIt 3.3.8.0+
#include <APISysConstants.au3> ; AutoIt 3.3.10.0+

#cs
Global Const $EVENT_MIN = 0x00000001
Global Const $EVENT_SYSTEM_SOUND = 0x00000001
Global Const $EVENT_SYSTEM_ALERT = 0x00000002
Global Const $EVENT_SYSTEM_FOREGROUND = 0x00000003
Global Const $EVENT_SYSTEM_MENUSTART = 0x00000004
Global Const $EVENT_SYSTEM_MENUEND = 0x00000005
Global Const $EVENT_SYSTEM_MENUPOPUPSTART = 0x00000006
Global Const $EVENT_SYSTEM_MENUPOPUPEND = 0x00000007
Global Const $EVENT_SYSTEM_CAPTURESTART = 0x00000008
Global Const $EVENT_SYSTEM_CAPTUREEND = 0x00000009
Global Const $EVENT_SYSTEM_MOVESIZESTART = 0x0000000A
Global Const $EVENT_SYSTEM_MOVESIZEEND = 0x0000000B
Global Const $EVENT_SYSTEM_CONTEXTHELPSTART = 0x0000000C
Global Const $EVENT_SYSTEM_CONTEXTHELPEND = 0x0000000D
Global Const $EVENT_SYSTEM_DRAGDROPSTART = 0x0000000E
Global Const $EVENT_SYSTEM_DRAGDROPEND = 0x0000000F
Global Const $EVENT_SYSTEM_DIALOGSTART = 0x00000010
Global Const $EVENT_SYSTEM_DIALOGEND = 0x00000011
Global Const $EVENT_SYSTEM_SCROLLINGSTART = 0x00000012
Global Const $EVENT_SYSTEM_SCROLLINGEND = 0x00000013
Global Const $EVENT_SYSTEM_SWITCHSTART = 0x00000014
Global Const $EVENT_SYSTEM_SWITCHEND = 0x00000015
Global Const $EVENT_SYSTEM_MINIMIZESTART = 0x00000016
Global Const $EVENT_SYSTEM_MINIMIZEEND = 0x00000017
Global Const $EVENT_SYSTEM_DESKTOPSWITCH = 0x00000020
Global Const $EVENT_OBJECT_CREATE = 0x00008000
Global Const $EVENT_OBJECT_DESTROY = 0x00008001
Global Const $EVENT_OBJECT_SHOW = 0x00008002
Global Const $EVENT_OBJECT_HIDE = 0x00008003
Global Const $EVENT_OBJECT_REORDER = 0x00008004
Global Const $EVENT_OBJECT_FOCUS = 0x00008005
Global Const $EVENT_OBJECT_SELECTION = 0x00008006
Global Const $EVENT_OBJECT_SELECTIONADD = 0x00008007
Global Const $EVENT_OBJECT_SELECTIONREMOVE = 0x00008008
Global Const $EVENT_OBJECT_SELECTIONWITHIN = 0x00008009
Global Const $EVENT_OBJECT_STATECHANGE = 0x0000800A
Global Const $EVENT_OBJECT_LOCATIONCHANGE = 0x0000800B
Global Const $EVENT_OBJECT_NAMECHANGE = 0x0000800C
Global Const $EVENT_OBJECT_DESCRIPTIONCHANGE = 0x0000800D
Global Const $EVENT_OBJECT_VALUECHANGE = 0x0000800E
Global Const $EVENT_OBJECT_PARENTCHANGE = 0x0000800F
Global Const $EVENT_OBJECT_HELPCHANGE = 0x00008010
Global Const $EVENT_OBJECT_DEFACTIONCHANGE = 0x00008011
Global Const $EVENT_OBJECT_ACCELERATORCHANGE = 0x00008012
Global Const $EVENT_OBJECT_INVOKED = 0x00008013
Global Const $EVENT_OBJECT_TEXTSELECTIONCHANGED = 0x00008014
Global Const $EVENT_OBJECT_CONTENTSCROLLED = 0x00008015
Global Const $EVENT_MAX = 0x7FFFFFFF

Global Const $WINEVENT_INCONTEXT = 0x04
Global Const $WINEVENT_OUTOFCONTEXT = 0x00
Global Const $WINEVENT_SKIPOWNPROCESS = 0x02
Global Const $WINEVENT_SKIPOWNTHREAD = 0x01
#ce

; =====================================================


Global Const $hdllOleacc = DllOpen( "oleacc.dll" )

OnAutoItExitRegister( "ExitMSAccessibility" )

Func ExitMSAccessibility()
	DllClose( $hdllOleacc )
EndFunc


Func AccessibleChildren( $paccContainer, $iChildStart, $iChildren, ByRef $tVarChildren, ByRef $iObtained )
	Local $sVarArray = ""
	For $i = 1 To $iChildren
		$sVarArray &= $tagVARIANT
	Next
	$tVarChildren = DllStructCreate( $sVarArray )
	Local $aRet = DllCall( "oleacc.dll", "int", "AccessibleChildren", "ptr", $paccContainer, "int", $iChildStart, "int", $iChildren, "struct*", $tVarChildren, "int*", 0 )
	If @error Then Return SetError(1, 0, $S_FALSE)
	If $aRet[0] Then Return SetError(2, 0, $aRet[0])
	$iObtained = $aRet[5]
	Return $S_OK
EndFunc

Func AccessibleObjectFromEvent( $hWnd, $iObjectID, $iChildID, ByRef $pAccessible, ByRef $tVarChild )
	Local $tVARIANT = DllStructCreate( $tagVARIANT )
	Local $aRet = DllCall( $hdllOleacc, "int", "AccessibleObjectFromEvent", "hwnd", $hWnd, "dword", $iObjectID, "dword", $iChildID, "ptr*", 0, "struct*", $tVARIANT )
	If @error Then Return SetError(1, 0, $S_FALSE)
	If $aRet[0] Then Return SetError(2, 0, $aRet[0])
	$pAccessible = $aRet[4]
	$tVarChild = $aRet[5]
	Return $S_OK
EndFunc

Func AccessibleObjectFromPoint( $x, $y, ByRef $pAccessible, ByRef $tVarChild )
	Local $tPOINT = DllStructCreate( "long;long" )
	DllStructSetData( $tPOINT, 1, $x )
	DllStructSetData( $tPOINT, 2, $y )
	Local $tPOINT64 = DllStructCreate( "int64", DllStructGetPtr( $tPOINT ) )
	Local $tVARIANT = DllStructCreate( $tagVARIANT )
	Local $aRet = DllCall( $hdllOleacc, "int", "AccessibleObjectFromPoint", "int64", DllStructGetData( $tPOINT64, 1 ), "ptr*", 0, "struct*", $tVARIANT )
	If @error Then Return SetError(1, 0, $S_FALSE)
	If $aRet[0] Then Return SetError(2, 0, $aRet[0])
	$pAccessible = $aRet[2]
	$tVarChild = $aRet[3]
	Return $S_OK
EndFunc

;~ Func _IEControlGetObjFromHWND($hWin)
#cs
Func _AccessibleObjectFromWindow( $hWnd, $iObjectID, $tRIID, ByRef $pObject )
    Local $aCall = DllCall("user32.dll", "dword", "RegisterWindowMessageW", "wstr", "WM_GETOBJECT")

    If @error Or Not $aCall[0] Then
        Return SetError(1, 0, "")
    EndIf

    Local Const $WM_GETOBJECT = $aCall[0]

;~     $aCall = DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "dword", $WM_GETOBJECT, "wparam", 0, "lparam", $iObjectID0)

    Local $lResult = $aCall[0]

;~ Global Const $sIID_IAccessible="{618736E0-3C3D-11CF-810C-00AA00389B71}"
Local $tUUID = _WinAPI_GUIDFromString("{618736E0-3C3D-11CF-810C-00AA00389B71}")
;~     Local $tUUID = _WinAPI_GUIDFromString("{626FC520-A41E-11CF-A731-00A0C9082637}") ; IID_IHTMLDocument

    DllCall("ole32.dll", "int", "CoInitializeEx", "ptr", 0, "dword", 2) ;COINIT_APARTMENTTHREADED

    $aCall = DllCall("oleacc.dll", "dword", "ObjectFromLresult", _
            "lresult", $lResult, _
            "ptr", DllStructGetPtr($tUUID), _
            "wparam", 0, _
            "idispatch*", 0)


    If IsObj($aCall[4]) Then
		return $aCall[4]
	Else
        Return SetError(1, 0, 0)
    EndIf

EndFunc   ;==>_AccessibleObjectFromWindow
#ce

Func AccessibleObjectFromWindow( $hWnd, $iObjectID, $tRIID, ByRef $pObject )
;~ 		Local $aRet = DllCall( $hdllOleacc, "int", "AccessibleObjectFromWindow", "hwnd", $hWnd, "dword", $iObjectID, "struct*", $tRIID, "int*", 0 )
		Local $aRet = DllCall( $hdllOleacc, "int", "AccessibleObjectFromWindow", "hwnd", $hWnd, "dword", $iObjectID, "struct*", $tRIID, "ptr*", 0 )
	If @error Then
		msgbox(0,"Error",$aRet)
		Return SetError(1, 0, $S_FALSE)
	EndIf

	If $aRet[0] Then Return SetError(2, 0, $aRet[0])
	$pObject = $aRet[4]
	Return $S_OK
EndFunc

Func WindowFromAccessibleObject( $pAccessible, ByRef $hWnd )
	Local $aRet = DllCall( $hdllOleacc, "int", "WindowFromAccessibleObject", "ptr", $pAccessible, "hwnd*", 0 )
	If @error Then Return SetError(1, 0, $S_FALSE)
	If $aRet[0] Then Return SetError(2, 0, $aRet[0])
	$hWnd = $aRet[2]
	Return $S_OK
EndFunc

Func GetRoleText( $iRole, $sRole, $iRoleMax )
	Local $aRet = DllCall( $hdllOleacc, "uint", "GetRoleTextW", "dword", $iRole, "ptr", $sRole, "uint", $iRoleMax )
	If @error Then Return SetError(1, 0, 0)
	If Not $aRet[0] Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc

Func GetStateText( $iStateBit, $sStateBit, $iStateBitMax )
	Local $aRet = DllCall( $hdllOleacc, "uint", "GetStateTextW", "dword", $iStateBit, "ptr", $sStateBit, "uint", $iStateBitMax )
	If @error Then Return SetError(1, 0, 0)
	If Not $aRet[0] Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc

; Copied form WinAPISys.au3
; Authors: KaFu, Yashied, Jpm
Func SetWinEventHook($iEventMin, $iEventMax, $pEventProc, $iProcessID = 0, $iThreadID = 0, $iFlags = 0)
	Local $Ret = DllCall('user32.dll', 'handle', 'SetWinEventHook', 'uint', $iEventMin, 'uint', $iEventMax, 'ptr', 0, _
		'ptr', $pEventProc, 'dword', $iProcessID, 'dword', $iThreadID, 'uint', $iFlags)
	If @error Then Return SetError(@error, @extended, 0)
	Return $Ret[0]
EndFunc

; Copied form WinAPISys.au3
; Authors: KaFu, Yashied, Jpm
Func UnhookWinEvent($hEventHook)
	Local $Ret = DllCall('user32.dll', 'bool', 'UnhookWinEvent', 'handle', $hEventHook)
	If @error Then Return SetError(@error, @extended, False)
	Return $Ret[0]
EndFunc

; Copied form WinAPICom.au3
; Authors: Yashied, Jpm
Func CoTaskMemFree($pMemory)
	DllCall('ole32.dll', 'none', 'CoTaskMemFree', 'ptr', $pMemory)
	If @error Then Return SetError(@error, @extended, 0)
	Return 1
EndFunc

; Copied and slightly modified from AutoItObject.au3 by the AutoItObject-Team
Func CLSIDFromString( $sIID )
	Local $tCLSID = DllStructCreate( "dword;word;word;byte[8]" )
	Local $aRet = DllCall( "ole32.dll", "long", "CLSIDFromString", "wstr", $sIID, "struct*", $tCLSID )
	If @error Then Return SetError(1, @error, 0)
	If $aRet[0] <> 0 Then Return SetError(2, $aRet[0], 0)
	Return $tCLSID
EndFunc


Func PrintElementInfo( $oElement, $iChild, $sIndent )
	Local $sName, $iRole, $sRole, $iRoleLen
	Local $iState, $sState, $iStateLen
	Local $sValue, $x, $y, $w, $h
	If $iChild <> $CHILDID_SELF Then _
		ConsoleWrite( $sIndent & "$iChildElem = " & $iChild & @CRLF )
	$oElement.get_accName( $iChild, $sName )
	ConsoleWrite( $sIndent & "$sName  = " & $sName & @CRLF )
	If $oElement.get_accRole( $iChild, $iRole ) = $S_OK Then
		ConsoleWrite( $sIndent & "$iRole  = 0x" & Hex( $iRole ) & @CRLF )
		$iRoleLen = GetRoleText( $iRole, 0, 0 ) + 1
		$sRole = DllStructCreate( "wchar[" & $iRoleLen & "]" )
		GetRoleText( $iRole, DllStructGetPtr( $sRole ), $iRoleLen )
		ConsoleWrite( $sIndent & "$sRole  = " & DllStructGetData( $sRole, 1 ) & @CRLF )
	EndIf
	If $oElement.get_accState( $iChild, $iState ) = $S_OK Then
		ConsoleWrite( $sIndent & "$iState = 0x" & Hex( $iState ) & @CRLF )
		$iStateLen = GetStateText( $iState, 0, 0 ) + 1
		$sState = DllStructCreate( "wchar[" & $iStateLen & "]" )
		GetStateText( $iState, DllStructGetPtr( $sState ), $iStateLen )
		ConsoleWrite( $sIndent & "$sState = " & DllStructGetData( $sState, 1 ) & @CRLF )
	EndIf
	If $oElement.get_accValue( $iChild, $sValue ) = $S_OK Then _
		ConsoleWrite( $sIndent & "$sValue = " & $sValue & @CRLF )
	IF $oElement.accLocation( $x, $y, $w, $h, $iChild ) = $S_OK Then _
		ConsoleWrite( $sIndent & "$x, $y, $w, $h = " & $x & ", " & $y & ", " & $w & ", " & $h & @CRLF )
	ConsoleWrite( @CRLF )
EndFunc
