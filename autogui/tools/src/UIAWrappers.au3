#AutoIt3Wrapper_Au3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
;~ #au3check -q -d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w- 7
#Region includes
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <constants.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include <ScreenCapture.au3>
#include "CUIAutomation2.au3"
#EndRegion
;~ https://sites.google.com/site/jozsefbekes/Home/windows-programming/dotnet-registering-an-object-to-the-running-object-table-from-a-non-com-project
;~ TODO gethistogram of an area
;~ 	local $rectangle = _UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId)
;~ 	local $name=_UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId)
;~ 	local $t = StringSplit($rectangle, ";")
;~ 	_UIA_DrawRect($t[1]+16, $t[3] + $t[1], $t[2], $t[4] + $t[2])
;~ 	_ScreenCapture_Capture($name, $t[1], $t[2], $t[3] + $t[1], $t[4] + $t[2])
;~ ; Find a pure green pixel
;~ Local $aCoord = PixelSearch($t[1]+16, $t[2], $t[3] + $t[1], $t[4] + $t[2], 0x006400)
;~ UIAutomator for iPhone and UI Automation/Instrumentation for Android
;~ Walk thru the tree with a treewalker
;~ Three other predefined conditions can be used alone or in combination with other conditions: ContentViewCondition, ControlViewCondition, and RawViewCondition.
;~ RawViewCondition, used by itself, is equivalent to TrueCondition, because it does not filter elements by their IsControlElement or IsContentElement properties.

;~ Version x.xx
;~ - New: Internal functions
;~ - Added:
;~ - Changed:
;~ - Fixed:

; #INDEX# =======================================================================================================================
; Title .........: UI automation helper functions
; AutoIt Version : 3.3.8.1 thru 3.3.14.2
; Language ......: English (language independent)
; Description ...: Brings UI automation to AutoIt.
; Author(s) .....: junkew
; Copyright .....: Copyright (C) 2013,2014.2015,2016,2017,2018 All rights reserved.
; License .......: GPL or BSD which either of the two fits to your purpose
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;
; ===============================================================================================================================
#Region Header
#cs
	Title:		UI automation helper functions
	Filename:  	UIAWrappers.au3
	Description: A collection of functions for creating, attaching to, reading from and manipulating Windows, Browsers and JavaApplications
	Author:   	Elwin Wildschut (junkew)
	Modified:
	Version:  	T0.6.6.
	Last Update: 11/04/2018
	Requirements: AutoIt3 3.3.8 or higher

	Update History:
	===================================================
	T0.6.6 11/04/2018

	Enhancements
	- Enhanced logic on fallback / dynamic search, still not perfect, to slow
	- Retested with latest Chrome, FF, Edge and IE11 and some extensions to show how to get text from the webpage
	- Some small bugfixes
	- Some comments as given in forum incorporated

	T0.6.5 08/09/2017

	Enhancements
	- Enhanced logic on fallback / dynamic search

	T0.6.4 05/09/2016

	Enhancements
	- Enhanced logic on fallback / dynamic search

	T0.6.3 10/07/2016

	Enhancements
	- Major cleanup and strict compile options
	- All examples validated on W10
	- UDF style followed

	TODO
	- Clean out the large switch in smaller functions
	- Done: Enhance logic on fallback if object is not found (search childs, search (grand)parent before failing with object not found)
	- Include the logic on JavaObjects in a better way out of JABSimpleSpy
#ce
#EndRegion Header

#Region UIA Variables
; #UIAWrappers_CONSTANTS# ===================================================================================================================
;~ Some core default variables frequently to use in wrappers/helpers/global objects and pointers
; ===============================================================================================================================
;~ Global $objUIAutomation          ;Deprecated
;~ Global $oDesktop, $pDesktop      ;Deprecated
;~ Global $oTW, $pTW                ;Deprecated globals Used frequently for treewalking
;~ Global $oUIElement, $pUIElement  ;Used frequently to get an element

Global $UIA_oUIAutomation ;The main library core CUI automation reference
Global $UIA_oDesktop, $UIA_pDesktop ;Desktop will be frequently the starting point

Global $UIA_oUIElement, $UIA_pUIElement ;Used frequently to get an element

Global $UIA_oTW, $UIA_pTW ;Generic treewalker which is allways available
Global $UIA_oTRUECondition ;TRUE condition easy to be available for treewalking

;~ Global $UIA_Vars ;Hold global UIA data in a dictionary object    ;Not working properly with returning objects / vartypes
;~ TODO Global $UIA_VarsMap[] ;Hold global UIA data in a map object
Global $UIA_Vars[0][2] ;Name value pair for non beta / versions not supporting map

Global $UIA_DefaultWaitTime = 250 ;Frequently it makes sense to have a small waiting time to have windows rebuild, could be set to 0 if good synch is happening

Global Const $__gaUIAAU3VersionInfo[6] = ["T", 0, 6, 6, "20181104", "T0.6-6"]

Global Const $_UIA_MAXDEPTH = 25 ; The hierarchy used is 25 deep if more stuff just will crash

; ===================================================================================================================

; #CONSTANTS# ===================================================================================================================
Local Const $UIA_tryMax = 3 ;Retry
Local Const $UIA_CFGFileName = "UIA.CFG" ;The default configuration file

;~ Loglevels that can be used in scripting following log4j defined standard
Local Const $UIA_Log_Wrapper = 5, $UIA_Log_trace = 10, $UIA_Log_debug = 20, $UIA_Log_info = 30, $UIA_Log_warn = 40, $UIA_Log_error = 50, $UIA_Log_fatal = 60
Local Const $UIA_Log_Pass = 70, $UIA_Log_Fail = 80

Local Const $__UIA_debugCacheOn = 1
Local Const $__UIA_debugCacheOff = 2

Local Const $__UIA_SpecialProperty = -1

Local $__gl_XMLCache
Local $__l_UIA_CacheState = False ;Initial state no caching of log

Global Enum _; Error Status Types
		$_UIASTATUS_Success = 0, _
		$_UIASTATUS_GeneralError, _
		$_UIASTATUS_InvalidValue, _
		$_UIASTATUS_NoMatch, _
		$_UIASTATUS_NoUIAutomationFound, _
		$_UIASTATUS_NoTreewalkerFound, _
		$_UIASTATUS_NoDesktopFound

; ===================================================================================================================
#EndRegion UIA Variables

#Region UIA Core
_UIA_Init()

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_Init
; Description ...: Initializes the basic stuff for the UI Automation library of MS
; Syntax.........: _UIA_Init()
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_Init()
	Local $UIA_pTRUECondition

;~ The main object with acces to the windows automation api 3.0
	$UIA_oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation)
	If _UIA_IsElement($UIA_oUIAutomation) = 0 Then
;~ 		msgbox(1,"UI automation failed", "UI Automation failed",10)
		Return SetError($_UIASTATUS_NoUIAutomationFound, 0, 0)
	EndIf

;~ Try to get the desktop as a generic reference/global for all samples
	$UIA_oUIAutomation.GetRootElement($UIA_pDesktop)
	$UIA_oDesktop = ObjCreateInterface($UIA_pDesktop, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
	If IsObj($UIA_oDesktop) = 0 Then
;~ 		MsgBox(1, "UI automation desktop failed", "Fatal: UI Automation desktop failed")
		Return SetError($_UIASTATUS_NoDesktopFound, 0, 0)
	EndIf

;~ 	_UIA_LOG("At least it seems I have the desktop as a frequently used starting point" 	& "[" &_UIA_getPropertyValue($UIA_oDesktop, $UIA_NamePropertyId) & "][" &_UIA_getPropertyValue($UIA_oDesktop, $UIA_ClassNamePropertyId) & "]" & @CRLF, , $UIA_Log_Wrapper)

;~ Have a treewalker available to easily walk around the element trees
	$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
	$UIA_oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
	If _UIA_IsElement($UIA_oTW) = 0 Then
;~ 		MsgBox(1, "UI automation treewalker failed", "UI Automation failed to setup treewalker", 10)
		Return SetError($_UIASTATUS_NoTreewalkerFound, 0, 0)
	EndIf

;~ 	Create a true condition for easy reference in treewalkers
	$UIA_oUIAutomation.CreateTrueCondition($UIA_pTRUECondition)
	$UIA_oTRUECondition = ObjCreateInterface($UIA_pTRUECondition, $sIID_IUIAutomationCondition, $dtagIUIAutomationCondition)
	Return SetError($_UIASTATUS_Success, $_UIASTATUS_Success, True)
EndFunc   ;==>_UIA_Init

;~ Propertynames to match to numeric values, all names will be lowercased in actual usage case insensitive
;~ 23 july 2014 added all propertyids
#Region UIA Core variables
const $constColName=0
const $constColType=1

Local $UIA_propertiesSupportedArray[123][2] = [ _
		["indexrelative", $__UIA_SpecialProperty], _                                      			; Special propertyname
		["index", $__UIA_SpecialProperty], _                                       					; Special propertyname
		["instance", $__UIA_SpecialProperty], _                                       				; Special propertyname
		["title", $UIA_NamePropertyId], _                                       ; Alternate propertyname
		["text", $UIA_NamePropertyId], _                                        ; Alternate propertyname
		["regexptitle", $UIA_NamePropertyId], _                                 ; Alternate propertyname
		["class", $UIA_ClassNamePropertyId], _									; Alternate propertyname
		["regexpclass", $UIA_ClassNamePropertyId], _							; Alternate propertyname
		["iaccessiblevalue", $UIA_LegacyIAccessibleValuePropertyId], _			; Alternate propertyname
		["iaccessiblechildId", $UIA_LegacyIAccessibleChildIdPropertyId], _		; Alternate propertyname
		["id", $UIA_AutomationIdPropertyId], _                                  ; Alternate propertyname
		["handle", $UIA_NativeWindowHandlePropertyId], _ 						; Alternate propertyname
		["RuntimeId", $UIA_RuntimeIdPropertyId], _
		["BoundingRectangle", $UIA_BoundingRectanglePropertyId], _
		["ProcessId", $UIA_ProcessIdPropertyId], _
		["ControlType", $UIA_ControlTypePropertyId], _
		["LocalizedControlType", $UIA_LocalizedControlTypePropertyId], _
		["Name", $UIA_NamePropertyId], _
		["AcceleratorKey", $UIA_AcceleratorKeyPropertyId], _
		["AccessKey", $UIA_AccessKeyPropertyId], _
		["HasKeyboardFocus", $UIA_HasKeyboardFocusPropertyId], _
		["IsKeyboardFocusable", $UIA_IsKeyboardFocusablePropertyId], _
		["IsEnabled", $UIA_IsEnabledPropertyId], _
		["AutomationId", $UIA_AutomationIdPropertyId], _
		["ClassName", $UIA_ClassNamePropertyId], _
		["HelpText", $UIA_HelpTextPropertyId], _
		["ClickablePoint", $UIA_ClickablePointPropertyId], _
		["Culture", $UIA_CulturePropertyId], _
		["IsControlElement", $UIA_IsControlElementPropertyId], _
		["IsContentElement", $UIA_IsContentElementPropertyId], _
		["LabeledBy", $UIA_LabeledByPropertyId], _
		["IsPassword", $UIA_IsPasswordPropertyId], _
		["NativeWindowHandle", $UIA_NativeWindowHandlePropertyId], _
		["ItemType", $UIA_ItemTypePropertyId], _
		["IsOffscreen", $UIA_IsOffscreenPropertyId], _
		["Orientation", $UIA_OrientationPropertyId], _
		["FrameworkId", $UIA_FrameworkIdPropertyId], _
		["IsRequiredForForm", $UIA_IsRequiredForFormPropertyId], _
		["ItemStatus", $UIA_ItemStatusPropertyId], _
		["IsDockPatternAvailable", $UIA_IsDockPatternAvailablePropertyId], _
		["IsExpandCollapsePatternAvailable", $UIA_IsExpandCollapsePatternAvailablePropertyId], _
		["IsGridItemPatternAvailable", $UIA_IsGridItemPatternAvailablePropertyId], _
		["IsGridPatternAvailable", $UIA_IsGridPatternAvailablePropertyId], _
		["IsInvokePatternAvailable", $UIA_IsInvokePatternAvailablePropertyId], _
		["IsMultipleViewPatternAvailable", $UIA_IsMultipleViewPatternAvailablePropertyId], _
		["IsRangeValuePatternAvailable", $UIA_IsRangeValuePatternAvailablePropertyId], _
		["IsScrollPatternAvailable", $UIA_IsScrollPatternAvailablePropertyId], _
		["IsScrollItemPatternAvailable", $UIA_IsScrollItemPatternAvailablePropertyId], _
		["IsSelectionItemPatternAvailable", $UIA_IsSelectionItemPatternAvailablePropertyId], _
		["IsSelectionPatternAvailable", $UIA_IsSelectionPatternAvailablePropertyId], _
		["IsTablePatternAvailable", $UIA_IsTablePatternAvailablePropertyId], _
		["IsTableItemPatternAvailable", $UIA_IsTableItemPatternAvailablePropertyId], _
		["IsTextPatternAvailable", $UIA_IsTextPatternAvailablePropertyId], _
		["IsTogglePatternAvailable", $UIA_IsTogglePatternAvailablePropertyId], _
		["IsTransformPatternAvailable", $UIA_IsTransformPatternAvailablePropertyId], _
		["IsValuePatternAvailable", $UIA_IsValuePatternAvailablePropertyId], _
		["IsWindowPatternAvailable", $UIA_IsWindowPatternAvailablePropertyId], _
		["ValueValue", $UIA_ValueValuePropertyId], _
		["ValueIsReadOnly", $UIA_ValueIsReadOnlyPropertyId], _
		["RangeValueValue", $UIA_RangeValueValuePropertyId], _
		["RangeValueIsReadOnly", $UIA_RangeValueIsReadOnlyPropertyId], _
		["RangeValueMinimum", $UIA_RangeValueMinimumPropertyId], _
		["RangeValueMaximum", $UIA_RangeValueMaximumPropertyId], _
		["RangeValueLargeChange", $UIA_RangeValueLargeChangePropertyId], _
		["RangeValueSmallChange", $UIA_RangeValueSmallChangePropertyId], _
		["ScrollHorizontalScrollPercent", $UIA_ScrollHorizontalScrollPercentPropertyId], _
		["ScrollHorizontalViewSize", $UIA_ScrollHorizontalViewSizePropertyId], _
		["ScrollVerticalScrollPercent", $UIA_ScrollVerticalScrollPercentPropertyId], _
		["ScrollVerticalViewSize", $UIA_ScrollVerticalViewSizePropertyId], _
		["ScrollHorizontallyScrollable", $UIA_ScrollHorizontallyScrollablePropertyId], _
		["ScrollVerticallyScrollable", $UIA_ScrollVerticallyScrollablePropertyId], _
		["SelectionSelection", $UIA_SelectionSelectionPropertyId], _
		["SelectionCanSelectMultiple", $UIA_SelectionCanSelectMultiplePropertyId], _
		["SelectionIsSelectionRequired", $UIA_SelectionIsSelectionRequiredPropertyId], _
		["GridRowCount", $UIA_GridRowCountPropertyId], _
		["GridColumnCount", $UIA_GridColumnCountPropertyId], _
		["GridItemRow", $UIA_GridItemRowPropertyId], _
		["GridItemColumn", $UIA_GridItemColumnPropertyId], _
		["GridItemRowSpan", $UIA_GridItemRowSpanPropertyId], _
		["GridItemColumnSpan", $UIA_GridItemColumnSpanPropertyId], _
		["GridItemContainingGrid", $UIA_GridItemContainingGridPropertyId], _
		["DockDockPosition", $UIA_DockDockPositionPropertyId], _
		["ExpandCollapseExpandCollapseState", $UIA_ExpandCollapseExpandCollapseStatePropertyId], _
		["MultipleViewCurrentView", $UIA_MultipleViewCurrentViewPropertyId], _
		["MultipleViewSupportedViews", $UIA_MultipleViewSupportedViewsPropertyId], _
		["WindowCanMaximize", $UIA_WindowCanMaximizePropertyId], _
		["WindowCanMinimize", $UIA_WindowCanMinimizePropertyId], _
		["WindowWindowVisualState", $UIA_WindowWindowVisualStatePropertyId], _
		["WindowWindowInteractionState", $UIA_WindowWindowInteractionStatePropertyId], _
		["WindowIsModal", $UIA_WindowIsModalPropertyId], _
		["WindowIsTopmost", $UIA_WindowIsTopmostPropertyId], _
		["SelectionItemIsSelected", $UIA_SelectionItemIsSelectedPropertyId], _
		["SelectionItemSelectionContainer", $UIA_SelectionItemSelectionContainerPropertyId], _
		["TableRowHeaders", $UIA_TableRowHeadersPropertyId], _
		["TableColumnHeaders", $UIA_TableColumnHeadersPropertyId], _
		["TableRowOrColumnMajor", $UIA_TableRowOrColumnMajorPropertyId], _
		["TableItemRowHeaderItems", $UIA_TableItemRowHeaderItemsPropertyId], _
		["TableItemColumnHeaderItems", $UIA_TableItemColumnHeaderItemsPropertyId], _
		["ToggleToggleState", $UIA_ToggleToggleStatePropertyId], _
		["TransformCanMove", $UIA_TransformCanMovePropertyId], _
		["TransformCanResize", $UIA_TransformCanResizePropertyId], _
		["TransformCanRotate", $UIA_TransformCanRotatePropertyId], _
		["IsLegacyIAccessiblePatternAvailable", $UIA_IsLegacyIAccessiblePatternAvailablePropertyId], _
		["LegacyIAccessibleChildId", $UIA_LegacyIAccessibleChildIdPropertyId], _
		["LegacyIAccessibleName", $UIA_LegacyIAccessibleNamePropertyId], _
		["LegacyIAccessibleValue", $UIA_LegacyIAccessibleValuePropertyId], _
		["LegacyIAccessibleDescription", $UIA_LegacyIAccessibleDescriptionPropertyId], _
		["LegacyIAccessibleRole", $UIA_LegacyIAccessibleRolePropertyId], _
		["LegacyIAccessibleState", $UIA_LegacyIAccessibleStatePropertyId], _
		["LegacyIAccessibleHelp", $UIA_LegacyIAccessibleHelpPropertyId], _
		["LegacyIAccessibleKeyboardShortcut", $UIA_LegacyIAccessibleKeyboardShortcutPropertyId], _
		["LegacyIAccessibleSelection", $UIA_LegacyIAccessibleSelectionPropertyId], _
		["LegacyIAccessibleDefaultAction", $UIA_LegacyIAccessibleDefaultActionPropertyId], _
		["AriaRole", $UIA_AriaRolePropertyId], _
		["AriaProperties", $UIA_AriaPropertiesPropertyId], _
		["IsDataValidForForm", $UIA_IsDataValidForFormPropertyId], _
		["ControllerFor", $UIA_ControllerForPropertyId], _
		["DescribedBy", $UIA_DescribedByPropertyId], _
		["FlowsTo", $UIA_FlowsToPropertyId], _
		["ProviderDescription", $UIA_ProviderDescriptionPropertyId], _
		["IsItemContainerPatternAvailable", $UIA_IsItemContainerPatternAvailablePropertyId], _
		["IsVirtualizedItemPatternAvailable", $UIA_IsVirtualizedItemPatternAvailablePropertyId], _
		["IsSynchronizedInputPatternAvailable", $UIA_IsSynchronizedInputPatternAvailablePropertyId] _
		]

Local $UIA_ControlArray[41][3] = [ _
		["UIA_AppBarControlTypeId", 50040, "Identifies the AppBar control type. Supported starting with Windows 8.1."], _
		["UIA_ButtonControlTypeId", 50000, "Identifies the Button control type."], _
		["UIA_CalendarControlTypeId", 50001, "Identifies the Calendar control type."], _
		["UIA_CheckBoxControlTypeId", 50002, "Identifies the CheckBox control type."], _
		["UIA_ComboBoxControlTypeId", 50003, "Identifies the ComboBox control type."], _
		["UIA_CustomControlTypeId", 50025, "Identifies the Custom control type. For more information, see Custom Properties, Events, and Control Patterns."], _
		["UIA_DataGridControlTypeId", 50028, "Identifies the DataGrid control type."], _
		["UIA_DataItemControlTypeId", 50029, "Identifies the DataItem control type."], _
		["UIA_DocumentControlTypeId", 50030, "Identifies the Document control type."], _
		["UIA_EditControlTypeId", 50004, "Identifies the Edit control type."], _
		["UIA_GroupControlTypeId", 50026, "Identifies the Group control type."], _
		["UIA_HeaderControlTypeId", 50034, "Identifies the Header control type."], _
		["UIA_HeaderItemControlTypeId", 50035, "Identifies the HeaderItem control type."], _
		["UIA_HyperlinkControlTypeId", 50005, "Identifies the Hyperlink control type."], _
		["UIA_ImageControlTypeId", 50006, "Identifies the Image control type."], _
		["UIA_ListControlTypeId", 50008, "Identifies the List control type."], _
		["UIA_ListItemControlTypeId", 50007, "Identifies the ListItem control type."], _
		["UIA_MenuBarControlTypeId", 50010, "Identifies the MenuBar control type."], _
		["UIA_MenuControlTypeId", 50009, "Identifies the Menu control type."], _
		["UIA_MenuItemControlTypeId", 50011, "Identifies the MenuItem control type."], _
		["UIA_PaneControlTypeId", 50033, "Identifies the Pane control type."], _
		["UIA_ProgressBarControlTypeId", 50012, "Identifies the ProgressBar control type."], _
		["UIA_RadioButtonControlTypeId", 50013, "Identifies the RadioButton control type."], _
		["UIA_ScrollBarControlTypeId", 50014, "Identifies the ScrollBar control type."], _
		["UIA_SemanticZoomControlTypeId", 50039, "Identifies the SemanticZoom control type. Supported starting with Windows 8."], _
		["UIA_SeparatorControlTypeId", 50038, "Identifies the Separator control type."], _
		["UIA_SliderControlTypeId", 50015, "Identifies the Slider control type."], _
		["UIA_SpinnerControlTypeId", 50016, "Identifies the Spinner control type."], _
		["UIA_SplitButtonControlTypeId", 50031, "Identifies the SplitButton control type."], _
		["UIA_StatusBarControlTypeId", 50017, "Identifies the StatusBar control type."], _
		["UIA_TabControlTypeId", 50018, "Identifies the Tab control type."], _
		["UIA_TabItemControlTypeId", 50019, "Identifies the TabItem control type."], _
		["UIA_TableControlTypeId", 50036, "Identifies the Table control type."], _
		["UIA_TextControlTypeId", 50020, "Identifies the Text control type."], _
		["UIA_ThumbControlTypeId", 50027, "Identifies the Thumb control type."], _
		["UIA_TitleBarControlTypeId", 50037, "Identifies the TitleBar control type."], _
		["UIA_ToolBarControlTypeId", 50021, "Identifies the ToolBar control type."], _
		["UIA_ToolTipControlTypeId", 50022, "Identifies the ToolTip control type."], _
		["UIA_TreeControlTypeId", 50023, "Identifies the Tree control type."], _
		["UIA_TreeItemControlTypeId", 50024, "Identifies the TreeItem control type."], _
		["UIA_WindowControlTypeId", 50032, "Identifies the Window control type."] _
		]

Local $patternArray[21][3] = [ _
		[$UIA_ValuePatternId, $sIID_IUIAutomationValuePattern, $dtagIUIAutomationValuePattern], _
		[$UIA_InvokePatternId, $sIID_IUIAutomationInvokePattern, $dtagIUIAutomationInvokePattern], _
		[$UIA_SelectionPatternId, $sIID_IUIAutomationSelectionPattern, $dtagIUIAutomationSelectionPattern], _
		[$UIA_LegacyIAccessiblePatternId, $sIID_IUIAutomationLegacyIAccessiblePattern, $dtagIUIAutomationLegacyIAccessiblePattern], _
		[$UIA_SelectionItemPatternId, $sIID_IUIAutomationSelectionItemPattern, $dtagIUIAutomationSelectionItemPattern], _
		[$UIA_RangeValuePatternId, $sIID_IUIAutomationRangeValuePattern, $dtagIUIAutomationRangeValuePattern], _
		[$UIA_ScrollPatternId, $sIID_IUIAutomationScrollPattern, $dtagIUIAutomationScrollPattern], _
		[$UIA_GridPatternId, $sIID_IUIAutomationGridPattern, $dtagIUIAutomationGridPattern], _
		[$UIA_GridItemPatternId, $sIID_IUIAutomationGridItemPattern, $dtagIUIAutomationGridItemPattern], _
		[$UIA_MultipleViewPatternId, $sIID_IUIAutomationMultipleViewPattern, $dtagIUIAutomationMultipleViewPattern], _
		[$UIA_WindowPatternId, $sIID_IUIAutomationWindowPattern, $dtagIUIAutomationWindowPattern], _
		[$UIA_DockPatternId, $sIID_IUIAutomationDockPattern, $dtagIUIAutomationDockPattern], _
		[$UIA_TablePatternId, $sIID_IUIAutomationTablePattern, $dtagIUIAutomationTablePattern], _
		[$UIA_TextPatternId, $sIID_IUIAutomationTextPattern, $dtagIUIAutomationTextPattern], _
		[$UIA_TogglePatternId, $sIID_IUIAutomationTogglePattern, $dtagIUIAutomationTogglePattern], _
		[$UIA_TransformPatternId, $sIID_IUIAutomationTransformPattern, $dtagIUIAutomationTransformPattern], _
		[$UIA_ScrollItemPatternId, $sIID_IUIAutomationScrollItemPattern, $dtagIUIAutomationScrollItemPattern], _
		[$UIA_ItemContainerPatternId, $sIID_IUIAutomationItemContainerPattern, $dtagIUIAutomationItemContainerPattern], _
		[$UIA_VirtualizedItemPatternId, $sIID_IUIAutomationVirtualizedItemPattern, $dtagIUIAutomationVirtualizedItemPattern], _
		[$UIA_SynchronizedInputPatternId, $sIID_IUIAutomationSynchronizedInputPattern, $dtagIUIAutomationSynchronizedInputPattern], _
		[$UIA_ExpandCollapsePatternId, $sIID_IUIAutomationExpandCollapsePattern, $dtagIUIAutomationExpandCollapsePattern] _
		]
#endregion

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlName
; Description ...: Transforms the number of a control to a readable name
; Syntax.........: _UIA_getControlName($controlID)
; Parameters ....: $controlID
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=$_UIASTATUS_GeneralError     - No control with that id
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UIA_getControlName($controlID)
	Local $i

	For $i = 0 To UBound($UIA_ControlArray) - 1
		If ($UIA_ControlArray[$i][1] = $controlID) Then
			Return $UIA_ControlArray[$i][0]
		EndIf
	Next
	Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "No control with that id")

EndFunc   ;==>_UIA_getControlName

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getControlId
; Description ...: Transforms the name of a controltype to an id
; Syntax.........: _UIA_getControlId($controlName)
; Parameters ....: $controlName
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=$_UIASTATUS_GeneralError     - UI automation failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _UIA_getControlID($controlName)
	Local $tName, $i
;~ 	If its already a number then just return that same number
	if isnumber($controlName) Then
		return $controlName
	EndIf

	$tName = StringUpper($controlName)
;~ Use lengthy names to map with array like "UIA_" & "Button" & "ControlTypeId"
	If StringLeft($tName, 4) <> "UIA_" Then
		$tName = "UIA_" & $tName
	EndIf
;~ 	For those who add control add the end fix it to full length
	If StringRight($tName, 7) = "CONTROL" Then
		$tName = $tName & "CONTROLTYPEID"
	EndIf
	If StringRight($tName, 13) <> "CONTROLTYPEID" Then
		$tName = $tName & "CONTROLTYPEID"
	EndIf

	For $i = 0 To UBound($UIA_ControlArray) - 1
		If (StringUpper($UIA_ControlArray[$i][0]) = $tName) Then
			Return $UIA_ControlArray[$i][1]
		EndIf
	Next

	Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "No control with that name " & $tname)
EndFunc   ;==>_UIA_getControlID

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _UIA_getPropertyIndex
; Description ...: Internal use just to find the location of the property name in the property array##
; Syntax.........:
; Parameters ....:
; Return values .:
; Author ........:
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _UIA_getPropertyIndex($propName)
	Local $i

;~ Special properties
;~ 	if stringinstr("indexrelative;index;instance", $propName) Then
;~ 		return seterror(0,0,-1)
;~ 	EndIf

	For $i = 0 To UBound($UIA_propertiesSupportedArray, 1) - 1
		If StringLower($UIA_propertiesSupportedArray[$i][$constColName]) = StringLower($propName) Then
			Return $i
		EndIf
	Next

	_UIA_LOG("[FATAL] : property you use is having invalid name:=" & $propName & @CRLF, $UIA_Log_Wrapper)
	Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "[FATAL] : property you use is having invalid name:=" & $propName & @CRLF)

EndFunc   ;==>_UIA_getPropertyIndex

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getPropertyValue($obj, $id)
; Description ...: Just return a single property or if its an array string them together
; Syntax.........: _UIA_getPropertyValue
; Parameters ....: $obj2 - An UI Element object
;				   $id - A reference to the property id
; Return values .: Success      - Returns value of the property
;                  Failure		- Returns tmpString and sets @error on errors:
;                  @error=$_UIASTATUS_GeneralError     - UI automation failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_getPropertyValue($UIA_oUIElement, $id)
	Local $tmpValue, $tmpStr, $iProperty

	If Not _UIA_IsElement($UIA_oUIElement) Then
		Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "** NO PROPERTYVALUE DUE TO NONEXISTING OBJECT **")
	EndIf

	$UIA_oUIElement.GetCurrentPropertyValue($id, $tmpValue)
	$tmpStr = "" & $tmpValue
	If IsArray($tmpValue) Then
		$tmpStr = ""
		For $iProperty = 0 To UBound($tmpValue) - 1
			$tmpStr = $tmpStr & StringStripWS($tmpValue[$iProperty], $STR_STRIPLEADING + $STR_STRIPTRAILING)
			If $iProperty <> UBound($tmpValue) - 1 Then
				$tmpStr = $tmpStr & ";"
			EndIf
		Next
		Return $tmpStr
	EndIf
	Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, $tmpStr)
EndFunc   ;==>_UIA_getPropertyValue

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getAllPropertyValues($UIA_oUIElement)
; Description ...: Just return all properties as a string
;                  Just get all available properties for desktop/should work on all IUIAutomationElements depending on ControlTypePropertyID they work yes/no
;				   Just make it a very long string name:= value pairs
; Syntax.........: _UIA_getPropertyValues
; Parameters ....: $UIA_oUIElement - An UI Element object
;				   $id - A reference to the property id
; Return values .: Success      - Returns string
;                  Failure		- Returns 0 and sets @error on errors:
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_getAllPropertyValues($UIA_oUIElement)
	Local $tmpStr, $tmpValue, $tSeparator, $i
	$tmpStr = ""
	$tSeparator = @CRLF ; To make sure its not a value you normally will get back for values

	For $i = 0 To UBound($UIA_propertiesSupportedArray) - 1
;~ 		Exclude the special ones
		If $UIA_propertiesSupportedArray[$i][$constColType] <> $__UIA_SpecialProperty Then
			$tmpValue = _UIA_getPropertyValue($UIA_oUIElement, $UIA_propertiesSupportedArray[$i][1])
			If $tmpValue <> "" Then
				$tmpStr = $tmpStr & "UIA_" & $UIA_propertiesSupportedArray[$i][$constColName] & ":= <" & $tmpValue & ">" & $tSeparator
			EndIf
		EndIf
	Next
	Return $tmpStr
EndFunc   ;==>_UIA_getAllPropertyValues

Func _UIA_getPattern($UIA_oUIElement, $patternID)
	Local $pPattern, $oPattern
	Local $sIID_Pattern
	Local $sdTagPattern
	Local $i

	If Not _UIA_IsElement($UIA_oUIElement) Then
		_UIA_LOG("Critical: UIA ERROR invalid element passed to getPattern function" & @CRLF, $UIA_Log_Wrapper)
		Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "UIA CRITICAL INVALID ELEMENT" & @CRLF)
		Exit
	EndIf

	For $i = 0 To UBound($patternArray) - 1
		If $patternArray[$i][0] = $patternID Then
;~ 			consolewrite("Pattern identified " & @crlf)
			$sIID_Pattern = $patternArray[$i][1]
			$sdTagPattern = $patternArray[$i][2]
			ExitLoop
		EndIf
	Next
;~ 	consolewrite($patternid & $sIID_Pattern & $sdTagPattern & @CRLF)

	$UIA_oUIElement.getCurrentPattern($patternID, $pPattern)
	$oPattern = ObjCreateInterface($pPattern, $sIID_Pattern, $sdTagPattern)
	If _UIA_IsElement($oPattern) Then
;~ 		consolewrite("UIA found the pattern" & @CRLF)
		Return $oPattern
	Else
		_UIA_LOG("UIA WARNING ** NOT ** found the pattern" & @CRLF, $UIA_Log_Wrapper)
		Return SetError($_UIASTATUS_GeneralError, $_UIASTATUS_GeneralError, "UIA WARNING ** NOT ** found the pattern" & @CRLF)
	EndIf
EndFunc   ;==>_UIA_getPattern

#EndRegion UIA Core

#Region UIA Testing Framework

Local Const $cRTI_Prefix = "RTI."

Global $__g_hFileLog ; Logfile reference

_UIA_TFW_Init()

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_TFW_Init
; Description ...: Initializes the basic stuff for the test framework based on the UIA core functions
; Syntax.........: _UIA_TFW_Init()
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - Framework failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_TFW_Init()

	OnAutoItExitRegister("_UIA_TFW_Close")

;~ 	Dictionary object to store a lot of handy global data, // Not working stable replaced with array and in future with maps
;~ 	$UIA_Vars = ObjCreate("Scripting.Dictionary")

;~ Removed, rewritten with map array of beta
;~ 	$UIA_Vars = ObjCreate("System.Collections.ArrayList")
;~ 	$UIA_Vars.comparemode = 2 ; Text comparison case insensitive

;~ Check if We can find configuration from file(s)
	_UIA_LoadConfiguration()

;~ Log each time to a new logyyyymmddhhmmssms.XML file in log folder
	Local $logFileName = @ScriptDir & "\LOG\" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & @SEC & @MSEC & ".XML"
	_UIA_setVar("logFileName", $logFileName)
	_UIA_LogFile($logFileName, True)

	_UIA_setVar("DESKTOP", $UIA_oDesktop)
	_UIA_setVar("RTI.MAINWINDOW", $UIA_oDesktop)
;~ 	$UIA_Vars.add("DESKTOP", $UIA_oDesktop)

	_UIA_VersionInfo()

	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_TFW_Init

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_TFW_Close
; Description ...: Closes the stuff of the test framework
; Syntax.........: _UIA_TFW_Close()
; Parameters ....: none
; Return values .: none
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_TFW_Close()
	_UIA_LogFileClose()
	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_TFW_Close

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_LoadConfiguration
; Description ...: Load all settings from a CFG file
; Syntax.........: _UIA_LoadConfiguration()
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_LoadConfiguration()

	_UIA_setVar("RTI.ACTIONCOUNT", 0)

;~ 	Some settings to use as a default
	_UIA_setVar("Global.Debug", True)
	_UIA_setVar("Global.Debug.File", True)
	_UIA_setVar("Global.Highlight", True)

;~ 	Check if we can find a configuration file and load it from that file
	If FileExists($UIA_CFGFileName) Then
		_UIA_loadCFGFile($UIA_CFGFileName)
	EndIf
;~ 		_UIA_LOG("Script name " & stringinstr(@scriptname),  $UIA_Log_Wrapper)

	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_LoadConfiguration

Func _UIA_loadCFGFile($strFname)
;~ 	Local $var
	Local $sections, $values, $strKey, $strVal, $i, $j

	$sections = IniReadSectionNames($strFname)

	If @error <> 0 Then
		_UIA_LOG("Error occurred on reading " & $strFname & @CRLF, $UIA_Log_Wrapper)
	Else
;~ 		Load all settings into the dictionary
		For $i = 1 To $sections[0]
			$values = IniReadSection($strFname, $sections[$i])
			If @error <> 0 Then
				_UIA_LOG("Error occurred on reading " & $strFname & @CRLF, $UIA_Log_Wrapper)
			Else
;~ 		Load all settings into the dictionary
				For $j = 1 To $values[0][0]
					$strKey = $sections[$i] & "." & $values[$j][0]
					$strVal = $values[$j][1]

					If StringLower($strVal) = "true" Then $strVal = True
					If StringLower($strVal) = "false" Then $strVal = False
					If StringLower($strVal) = "on" Then $strVal = True
					If StringLower($strVal) = "off" Then $strVal = False

					If StringLower($strVal) = "minimized" Then $strVal = @SW_MINIMIZE
					If StringLower($strVal) = "maximized" Then $strVal = @SW_MAXIMIZE
					If StringLower($strVal) = "normal" Then $strVal = @SW_RESTORE

					$strVal = StringReplace($strVal, "%windowsdir%", @WindowsDir)
					$strVal = StringReplace($strVal, "%programfilesdir%", @ProgramFilesDir)

;~ 					_UIA_LOG("Key: [" & $strKey & "] Value: [" &  $strVal & "]" & @CRLF, $UIA_Log_Wrapper)
;~ 					consolewrite("Key: [" & $strKey & "] Value: [" &  $strVal & "]" & @CRLF)

					_UIA_setVar($strKey, $strVal)
				Next
			EndIf
		Next
	EndIf
	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_loadCFGFile

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_getVar($varName)
; Description ...: Just returns a value as set before
; Syntax.........: _UIA_getVar("Global.UIADebug")
; Parameters ....: $varName  - A name for a variable
; Return values .: Success      - Returns the value of the variable
;                  Failure		- Returns "*** ERROR ***" and sets error to 1
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
;~ Just get a value in a dictionary object
Func _UIA_getVar($varName)
	Local $iIndex
	$iIndex = _ArraySearch($UIA_Vars, $varName)
	If $iIndex <> -1 Then
		Local $retValue = $UIA_Vars[$iIndex][1]
		Return SetError($_UIASTATUS_Success, 0, $retValue)
	Else
		Return SetError($_UIASTATUS_InvalidValue, 1, "*** WARNING: not in repository *** reference:=" & $varName)
	EndIf

;~ Rewritten with maps - only works with beta
;~ 	if MapExists($UIA_VarsMap, $varname) Then
;~ 		local $retValue= $UIA_VarsMap[$varName]
;~ 		return $retValue
;~ 	Else
;~ 		SetError(1) ;~ Not defined in repository
;~ 		Return "*** WARNING: not in repository *** reference:=" & $varName
;~ 	EndIf

;~ Old code, not working stable
;~ 	If $UIA_Vars.exists($varName) Then
;~ 		Local $retmpValue = $UIA_Vars($varName)
;~ 		Return $retmpValue
;~ 	Else
;~ 		SetError(1) ;~ Not defined in repository
;~ 		Return "*** WARNING: not in repository *** reference:=" & $varName
;~ 	EndIf
EndFunc   ;==>_UIA_getVar

Func _UIA_LogVarsArray()
	Local $i, $vKey, $vValue, $vType
;~ 	consolewrite("Ubound 0:=" & ubound($UIA_Vars,0))
;~ 	consolewrite("Ubound 1:=" & ubound($UIA_Vars,1))
;~ 	consolewrite("Ubound 2:=" & ubound($UIA_Vars,2))
;~ _arrayDisplay($uia_vars)

	For $i = 0 To UBound($UIA_Vars, 1) - 1
		$vKey = $UIA_Vars[$i][0]
		$vValue = $UIA_Vars[$i][1]
		$vType = VarGetType($vValue)
;~ 		consolewrite("Key: [" & $vKey & _ ; The key.
;~                 "] Value: [" & $vValue & _ ; Use the array value of MapKeys() to display the value of the key.
;~                 "] Variable Type: " & $vType & @CRLF) ; Display the variable type of the key i.e. integer or string.
		_UIA_LOG("Key: [" & $vKey & _ ; The key.
				"] Value: [" & $vValue & _ ; Use the array value of MapKeys() to display the value of the key.
				"] Variable Type: " & $vType & @CRLF) ; Display the variable type of the key i.e. integer or string.
	Next

;~ 	TODO for maps in beta
;~     Local $aMapKeys = MapKeys(Map)
;~ 	_UIA_LOG("# of elements : " & UBound($aMapKeys) - 1 & @CRLF, $UIA_Log_Wrapper)
;~ 	;For $i = 0 To UBound($aMapKeys) - 1
;~ 	for $vKey in $aMapKeys
;~ 		_UIA_LOG("Key: [" & $vKey & _ ; The key.
;~                 "] Value: [" & $UIA_VarsMap[$vKey] & _ ; Use the array value of MapKeys() to display the value of the key.
;~                 "] Variable Type: " & VarGetType($aMapKeys[$vKey]) & @CRLF) ; Display the variable type of the key i.e. integer or string.
;~ 	Next
;~ _UIA_LOG("Key: [" & $vKey & _ ; The key.
;~                 "] Value: [" & $UIA_VarsMap[$vKey] & _ ; Use the array value of MapKeys() to display the value of the key.
;~                 "] Variable Type: " & VarGetType($aMapKeys[$vKey]) & @CRLF) ; Display the variable type of the key i.e. integer or string.

EndFunc   ;==>_UIA_LogVarsArray

;~ ** TODO: Not needed??? **
;~ Func _UIA_getVars2Array($prefix = "")
;TODO prevent compile error on $ prefix
;~ 	local $T
;~ 	$T=$prefix

;~ 	Local $keys, $it, $i
;~ 	_UIA_LOG($UIA_Vars.count - 1 & @CRLF, $UIA_Log_Wrapper)
;~ 	$keys = $UIA_Vars.keys
;~ 	$it = $UIA_Vars.items
;~ 	For $i = 0 To $UIA_Vars.count - 1
;~ 		Local $oRef = $it[$i]
;~ 		_UIA_LOG("[" & $keys[$i] & "]:=[" & $oRef & "] " & _UIA_IsElement($oRef) & @CRLF, $UIA_Log_Wrapper)
;~ 	Next
; Retrieve the keys contained in the map. A zero-based one-dimensional array is returned.

;~ EndFunc   ;==>_UIA_getVars2Array

; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_setVar($varName, $varValue)
; Description ...: Just sets a variable to a certain value
; Syntax.........: _UIA_setVar("Global.UIADebug",True)
; Parameters ....: $varName  - A name for a variable
;				   $varValue - A value to assign to the variable
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
;~ Just set a value in a dictionary object
;  see http://www.autoitscript.com/forum/topic/163278-defect-or-by-design-dictionary-object-assignment-in-autoit/
Func _UIA_setVar($varName, $varValue)
;~ Rewritten with array as datadictionary is not working properly and maps do not exist in non beta version
	Local $iIndex
	$iIndex = _ArraySearch($UIA_Vars, $varName)
	If $iIndex <> -1 Then
		$UIA_Vars[$iIndex][1] = $varValue
	Else
		Local $aFill[1][2] = [[$varName, $varValue]]
		_ArrayAdd($UIA_Vars, $aFill)
	EndIf
	Return SetError($_UIASTATUS_Success, 0, 1)
;~ 		Broken since AutoIT version 3.10??
;~ 		$UIA_Vars($varName) = $varValue
;~ 	If $UIA_Vars.exists($varName) Then
;~ 		$UIA_Vars.remove($varName)
;~ 		$UIA_Vars.add($varName, $varValue)
;~ 	Else
;~ 		$UIA_Vars.add($varName, $varValue)
;~ 	EndIf

;~ TODO MAPS Rewritten with maps - only works with beta
;~ 	if MapExists($UIA_VarsMap, $varname) Then
;~ 		mapremove($UIA_VarsMap,$varName)
;~ 		$UIA_VarsMap[$varName]=$varvalue
;~ 	Else
;~ 		mapappend($UIA_VarsMap,$varName)
;~ 		$UIA_VarsMap[$varName]=$varvalue
;~ 	EndIf

EndFunc   ;==>_UIA_setVar

Func _UIA_setVarsFromArray(ByRef $_array, $prefix = "")
	Local $iRow
	If Not IsArray($_array) Then Return 0
	For $iRow = 0 To UBound($_array, 1) - 1
		_UIA_setVar($prefix & $_array[$iRow][0], $_array[$iRow][1])
	Next
	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_setVarsFromArray

Func _UIA_launchScript(ByRef $_scriptArray)
	Local $iLine
	If Not IsArray($_scriptArray) Then
		Return SetError(1, 0, 0)
	EndIf

	For $iLine = 0 To UBound($_scriptArray, 1) - 1
		If ($_scriptArray[$iLine][0] <> "") Then
			_UIA_action($_scriptArray[$iLine][0], $_scriptArray[$iLine][1], $_scriptArray[$iLine][2], $_scriptArray[$iLine][3], $_scriptArray[$iLine][4], $_scriptArray[$iLine][5])
		EndIf
	Next
	Return SetError($_UIASTATUS_Success, 0, 1)
EndFunc   ;==>_UIA_launchScript
; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_normalizeExpression($sPropList)
; Description ...: Just puts the expression in an splitted array
; Syntax.........:
;	$tArr=_UIA_normalizeExpression("Title=Adresbalk;controltype=UIA_PaneControlTypeId;class=Address Band Root;indexrelative=1")
; Parameters ....: $sPropList is an expression of properties key value pairs to be splitted
; Return values .: Success      - Returns an array with
;					- propertyName
;					- Value
;					- Matched=true when object
;					- special=true when special property
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
; Author ........:
; Modified.......:
; Remarks .......: None
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _UIA_normalizeExpression($sPropList)
	Local $asAllProperties ;~ All properties of the expression to match in a splitted form
	Local $iPropertyCount ;~ Number of properties given in the expression
	Local $asProperties2Match[1][4] ;~ All properties of the expression to match in a normalized form

	Local $i ;~ Just a looping integer
	Local $aKV ;~ Array key/value pair
	Local $iMatch ;~ Temp value to see if there is a match on that property
	Local $propName, $propValue
	Local $bSkipSpecialProperty ;~ Skips the specific special properties

	Local $UIA_oUIElement
	Local $UIA_pUIElement

	Local $index

;~ 	Split it first into multiple sections representing each property
	$asAllProperties = StringSplit($sPropList, ";", 1)

;~ Redefine the array to have all properties that are used to identify
	$iPropertyCount = $asAllProperties[0] + 1
	ReDim $asProperties2Match[$iPropertyCount][4]

	If ($iPropertyCount - 1) >= 1 Then
		_UIA_LOG("_UIA_normalizeExpression " & $sPropList & ";" & "elements 1-" & ($iPropertyCount - 1) & "in properties array" & @CRLF, $UIA_Log_Wrapper)
	Else
		_UIA_LOG("_UIA_normalizeExpression " & $sPropList & ";" & " property definition is incorrect" & @CRLF, $UIA_Log_Wrapper)
	EndIf

	For $i = 1 To $iPropertyCount - 1
		_UIA_LOG("  _UIA_getObjectByFindAll property " & $i & " " & $asAllProperties[$i] & @CRLF, $UIA_Log_Wrapper)
		$aKV = StringSplit($asAllProperties[$i], ":=", 1)
		$iMatch = 0
		$bSkipSpecialProperty = False
;~ Handle syntax without a property to have default name property:  Ok as Name:=Ok or if referring to [ACTIVE] then find element
		If $aKV[0] = 1 Then
			$aKV[1] = StringStripWS($aKV[1], 3)

			$propName = $UIA_NamePropertyId
			$propValue = $asAllProperties[$i]

			Switch $aKV[1]
				Case "active", "[active]"
					$UIA_oUIAutomation.GetFocusedElement($UIA_pUIElement)
					$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)

					$propName = "object"
					$propValue = $UIA_oUIElement
					$iMatch = 1
					$bSkipSpecialProperty = True
				Case "last", "[last]"
					$UIA_oUIElement = _UIA_getVar("RTI.LASTELEMENT")
					If Not _UIA_IsElement($UIA_oUIElement) Then
						$UIA_oUIElement = $UIA_oDesktop
					EndIf

					$propName = "object"
					$propValue = $UIA_oUIElement
					$iMatch = 1
					$bSkipSpecialProperty = True
				Case Else
					$propName = $UIA_NamePropertyId
					$propValue = $asAllProperties[$i]
					$iMatch = 0
					$bSkipSpecialProperty = False
			EndSwitch

			$asProperties2Match[$i][0] = $propName
			$asProperties2Match[$i][1] = $propValue
			$asProperties2Match[$i][2] = $iMatch
			$asProperties2Match[$i][3] = $bSkipSpecialProperty

		Else
;~ 			Just clean the properties as given in the pattern to find comparable to descriptive description
			$aKV[1] = StringStripWS($aKV[1], 3)
			$aKV[2] = StringStripWS($aKV[2], 3)
			$propName = $aKV[1]
			$propValue = $aKV[2]
			$iMatch = 0
			$bSkipSpecialProperty = False

			$index = _UIA_getPropertyIndex($propName)

			If $index >= 0 Then

;~ If its a special property
				If $UIA_propertiesSupportedArray[$index][$constColType] = $__UIA_SpecialProperty Then
					$bSkipSpecialProperty = True
					$asProperties2Match[$i][0] = $propName
				Else
;~ 			Some properties expect a number (otherwise system will break)
					Switch $UIA_propertiesSupportedArray[$index][$constcoltype]
						Case $UIA_ControlTypePropertyId
;~ Be aware on definitions like controltype=50003 or controltype=Edit
							if number($propValue)=0 Then
								$propValue = _UIA_getControlID($propValue)
							EndIf
;~ 							Weird enough sometimes string number stays string when not explicitly made a number
							$propvalue=number($propvalue)
;~ 							consolewrite("Sure its a number" & $propvalue & isnumber($propvalue)  & @CRLF)
					EndSwitch
;~ _UIA_LOG("value after" & $propValue)

					_UIA_LOG(" name:[" & $propName & "] value:[" & $propValue & "] having index " & $index & @CRLF, $UIA_Log_Wrapper)

;~ Add it to the normalized array
;~ 				consolewrite("index:" & $index & @CRLF)
					$asProperties2Match[$i][0] = $UIA_propertiesSupportedArray[$index][$constColType] ;~ store the propertyID (numeric value)
				EndIf
			Else
;~ 				this should never be reached in normal circumstances
				$asProperties2Match[$i][0] = $propName
;~ 				$bSkipSpecialProperty=true ; **** Otherwise _UIA_getObjectByFindAll will try to match by property value, which is not desired.
			EndIf

			$asProperties2Match[$i][1] = $propValue
			$asProperties2Match[$i][2] = $iMatch
			$asProperties2Match[$i][3] = $bSkipSpecialProperty
		EndIf
	Next

	$asProperties2Match[0][0] = $iPropertyCount
	Return $asProperties2Match

EndFunc   ;==>_UIA_normalizeExpression

;~ Find it by using a findall array of the UIA framework
Func _UIA_getObjectByFindAll($UIA_oUIElement, $str, $treeScope = $treescope_children, $p1 = 0)
;~ 	Local $pCondition, $pTrueCondition
	Local $pElements, $iLength
	Local $iPropertyMatch = 0

;~ 	Local $tResult
	Local $propertyID
;~ 	Local $tPos
	Local $relPos = 0
	Local $relIndex = 0
	Local $iMatch = 0
	Local $tmpStr
	Local $UIA_oDesktopHandle ;~ Handle to get the parent of the element available
	Local $parentHandle
	Local $properties2Match[1][4] ;~ All properties of the expression to match in a normalized form

;~ 	Local $allProperties, $propertyCount, $propName, $propValue, $bAdd, $index
	Local $i, $arrSize, $j
	Local $objParent, $propertyActualValue, $propertyVal, $oAutomationElementArray, $matchCount
	Local $bSkipSpecialProperty = False

	Local $tXMLLogString ; For logging purposes

	Local $itUIA_oUIElement ;- For iterating over the elements of the array
	Local $UIA_oUIElementFound ;- For element actually matching
	Local $propName

;~ First normalize the string expression of properties to an array
;~ 	consolewrite("Normalizing:" & $Str)

	$properties2Match = _UIA_normalizeExpression($str)
	$arrSize = UBound($properties2Match, 1) - 1

;~ 		_ArrayDisplay($properties2Match)

;~ If there was a reference of 1 property directly to an object
	If $properties2Match[1][0] = "object" Then
		$UIA_oUIElementFound = $properties2Match[1][1]
		$iMatch = 1
	EndIf

	;- If not an object given directly then
	If $iMatch = 0 Then
;~ Get the exceptional properties with special meaning
		For $i = 1 To $arrSize
			$propName = $properties2Match[$i][0]
			$bSkipSpecialProperty = $properties2Match[$i][3]
			If $bSkipSpecialProperty = True Then

;~ The properties with a specific meaning
				If $propName = "indexrelative" Then
;~ 					$relPos = $propValue
					$relPos = $properties2Match[$i][1]
					consolewrite("Relative position is : "& $relPos &@CRLF)
				EndIf

				If ($propName = "index") Or ($propName = "instance") Then
;~ 					$relIndex = $propValue
					$relIndex = $properties2Match[$i][1]
				EndIf
			EndIf
		Next

;~ Now get the tree of runtime objects and try to find a match
		If _UIA_IsElement($UIA_oUIElement) Then
			_UIA_LOG("*** Try to get a list of elements *** treescopetype:=" & $treeScope & @CRLF, $UIA_Log_Wrapper)
			$UIA_oUIElement.FindAll($treeScope, $UIA_oTRUECondition, $pElements)
			$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)
;~ 			//TODO: For some silly reason we have to wait otherwise element is not ready
;~ 			sleep(200)
		EndIf

		$matchCount = 0

;~ 	If there are ** NO ** childs found then there is nothing to search
		If _UIA_IsElement($oAutomationElementArray) Then
;~ All elements to inspect are in this array assign the lenght of the array to variable
			$oAutomationElementArray.Length($iLength)
		Else
			_UIA_LOG("***** FATAL:???? _UIA_getObjectByFindAll no childarray found for object with following details *****" & @CRLF, $UIA_Log_Wrapper)
			_UIA_LOG(_UIA_getAllPropertyValues($UIA_oUIElement) & @CRLF, $UIA_Log_Wrapper)
			$iLength = 0
		EndIf

		_UIA_LOG("_UIA_getObjectByFindAll walk thru the tree with n elements where n equals " &  $iLength )
;~         _UIA_LOG(_UIA_getAllPropertyValues($UIA_oUIElement) & @CRLF, $UIA_Log_Wrapper)

;~ Start the actual tree searching
;~ Walk thru all objects, walk thru all properties, match them all, if matched continue for special properties

		$tXMLLogString = "<propertymatching>"
		For $i = 0 To $iLength - 1; it's zero based
			$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
			$itUIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
			$iMatch = 0 ;~ initially object never matches

			$tmpStr = _UIA_getBasePropertyInfo($itUIA_oUIElement)
;~ 			_UIA_LOG(" Element: " & $i & " " & $tmpStr & @CRLF, $UIA_Log_Wrapper)

;~		Walk thru all properties in the properties2Match normalized array to match
;~		Normally not a big array just 1 - 5 elements frequently just 1 as it are the properties user gives to search on
			$iPropertyMatch = 0
			For $j = 1 To $arrSize
				$bSkipSpecialProperty = $properties2Match[$j][3]
				If $bSkipSpecialProperty = False Then
					$propertyID = $properties2Match[$j][0]
					$propertyVal = $properties2Match[$j][1]
					$propertyActualValue = ""
;~ 			_UIA_LOG("   1    j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $iMatch & @CRLF, $UIA_Log_Wrapper)
;~ $tXMLLogString=$tXMLLogString & _UIA_EncodeHTMLString("   1    j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $iMatch)

;~ 			Some properties expect a number (otherwise system will break)
;~ TODO: Replace button with the actual id

					Switch $propertyID
						Case $UIA_ControlTypePropertyId
							$propertyVal = Number($propertyVal)
					EndSwitch

					$propertyActualValue = _UIA_getPropertyValue($itUIA_oUIElement, $propertyID)

;~ 			TODO: Tricky logic on numbers and strings
;~ 			if $propertyVal=0 Then
;~ 				if $propertyVal=$propertyActualValue Then
;~ 					$iMatch=1
;~ 				Else
;~ 					$iMatch=0
;~ 					_UIA_LOG("j:" & $j & "[" & $propertyID & "][" & $propertyVal & "][" & $propertyActualValue & "]" & $iMatch & @CRLF, $UIA_Log_Wrapper)
;~ 					ExitLoop
;~ 				EndIf
;~ 			Else

;~ 			if $propertyVal=0
					$iPropertyMatch = StringRegExp($propertyActualValue, $propertyVal, $STR_REGEXPMATCH)
;~ 					$iMatch = StringRegExp($propertyActualValue, $propertyVal, $STR_REGEXPMATCH )

;~ 			Filter so not to much logging happens
;~ 				If $propertyActualValue <> "" Then
;~ 					$tXMLLogString = $tXMLLogString & _UIA_EncodeHTMLString("        j:" & $j & " propID:[" & $propertyID & "] expValue:[" & $propertyVal & "]actualValue:[" & $propertyActualValue & "]" & $iPropertyMatch & @CRLF)
;~ 					_UIA_LOG("        j:" & $j & " propID:[" & $propertyID & "] expValue:[" & $propertyVal & "]actualValue:[" & $propertyActualValue & "]" & $iMatch & @CRLF, $UIA_Log_Wrapper)
;~ 				EndIf

;~ 				Very tricky logic to circument the issue when propertyVal=0 but actualValue is something else
;~ 				Actually there should be a way to see if we are using a regex match or an exact string/number match
;~ 				Below is to repair this check j:1 propID:[30003] expValue:[0]actualValue:[50003]1 which gives incorrectly true
;~ 				if $iMatch=1 Then
;~ 					if ($propertyVal=0) and ($propertyActualValue<>"") Then
;~ 						$iMatch=0
;~ 						_UIA_LOG("        j:" & $j & " propID:[" & $propertyID & "] expValue:[" & $propertyVal & "]actualValue:[" & $propertyActualValue & "]" & $iMatch & " *** reset to no match *** " & @CRLF, $UIA_Log_Wrapper)
;~ 					EndIf
;~ 				EndIf

					If $iPropertyMatch = 0 Then
;~ 				Special situation could be that its non matching on regex but exact match is there
						If $propertyVal <> $propertyActualValue Then
;~ 						$tXMLLogString = $tXMLLogString & "</propertymatching>"
;~ 						_UIA_LOG($tXMLLogString, $UIA_Log_Wrapper)
							ExitLoop
;~ 						Else
;~ 							$iPropertyMatch = 1
						EndIf
					EndIf
				EndIf
			Next

;~ Check if found / basically $iPropertyMatch never became 0 but still we want to continue due to relative position or index
			If $iPropertyMatch = 1 Then
				$iMatch = 1
;~ 				Just go a few elements further in the array and make that element the found one
				If $relPos <> 0 Then
					_UIA_LOG("Relative position used", $UIA_Log_Wrapper)
;~ 					local $idebugSome
;~ 					for $iDebugSome=$i-5 to $i+5
;~ 						$oAutomationElementArray.GetElement($iDebugSome, $UIA_pUIElement)
;~ 						$UIA_oUIElementFound = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
;~ 						consolewrite("Debuggin relpos: " & $iDebugSome & _UIA_getAllPropertyValues($UIA_oUIElementFound))
;~ 					Next

;~ 					Set the references of the found object
                    $oAutomationElementArray.GetElement($i + $relPos, $UIA_pUIElement)
					$UIA_oUIElementFound = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
					$itUIA_oUIElement=$UIA_oUIElementFound
;~ 					consolewrite(_UIA_getAllPropertyValues($UIA_oUIElementFound))

					$iMatch = 1
				EndIf
;~ 				Just reset found status and continue in the loop till the right one is found
				If $relIndex <> 0 Then
					$matchCount = $matchCount + 1
					If $matchCount <> $relIndex Then
						$iMatch = 0
						_UIA_LOG(" Found and skipped due to index position: <" & $relIndex & " " & $matchCount & " " & $tmpStr & @CRLF, $UIA_Log_Wrapper)
					Else
						$iMatch = 1
					EndIf
				EndIf

				If $iMatch = 1 Then
					_UIA_LOG("Found match with element: " & $i & " the Name is: <" & $tmpStr & @CRLF, $UIA_Log_Wrapper)
					$UIA_oUIElementFound = $itUIA_oUIElement
;~ 						_UIA_Highlight($UIA_oUIElement)
					ExitLoop
				EndIf
			EndIf
		Next
		$tXMLLogString = $tXMLLogString & "</propertymatching>"
		_UIA_LOG($tXMLLogString, $UIA_Log_Wrapper)

	EndIf

;~ So if we found an element do some additional handling
	If $iMatch = 1 Then
;~ Have the parent also available in the RTI
;~ $UIA_oTW, $UIA_pTW
		$UIA_oTW.getparentelement($UIA_oUIElementFound, $parentHandle)
		$objParent = ObjCreateInterface($parentHandle, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		If _UIA_IsElement($objParent) = 0 Then
			_UIA_LOG("No parent " & @CRLF, $UIA_Log_Wrapper)
		Else
			_UIA_LOG("Storing parent for found object in RTI as RTI.PARENT " & _UIA_getPropertyValue($objParent, $UIA_NamePropertyId) & @CRLF, $UIA_Log_Wrapper)
			_UIA_setVar("RTI.PARENT", $objParent)
		EndIf

;~ 		Add element to runtime information object reference
		If IsString($p1) Then
			_UIA_LOG("Storing in RTI as RTI." & $p1 & @CRLF, $UIA_Log_Wrapper)
			_UIA_setVar("RTI." & StringUpper($p1), $UIA_oUIElementFound)
		EndIf

		If (_UIA_getVar("Global.Highlight") = True) Then
;~ 			consolewrite("its h value " & isstring(_UIA_getVar("Global.Highlight")) & isbool(_UIA_getVar("Global.Highlight"))  & (_UIA_getVar("Global.Highlight") =true ) & (_UIA_getVar("Global.Highlight") ="False" ) & @CRLF)
			_UIA_Highlight($UIA_oUIElementFound)
		EndIf

		Return $UIA_oUIElementFound
	Else
		Return ""
	EndIf

EndFunc   ;==>_UIA_getObjectByFindAll

Func _UIA_getTaskBar()
	Return _UIA_getFirstObjectOfElement($UIA_oDesktop, "classname:=Shell_TrayWnd", $TreeScope_Children)
EndFunc   ;==>_UIA_getTaskBar

;~ Determince the object based on the description or directly based on the object reference or based on the context of previous actions
Func _UIA_getObject($obj_or_string,$Parent=$UIA_oDesktop)
	Local $oElement
	Local $tPhysical
	Local $strStartElement, $oStart, $pos, $tmpStr
;~ 	Local $xx     ;~ most likely remove in far future
	Local $oParentHandle, $oParentBefore, $i
	Local $parentCount
	$parentCount = $parentCount + 1 ;~ TODO to prevent compileerror for not so obvious reason
;~ 	local $oFocusElement

;~ If we are giving a description then try to make an object first by looking from repository
;~ Otherwise assume an advanced description we should search under one of the previously referenced elements at runtime
;~ or in a newly created popup

;~ It could be that reference given is already an object
	If _UIA_IsElement($obj_or_string) Then
		$oElement = $obj_or_string
	Else
;~ Check if its maybe already in the repository with an RTI object reference
		$oElement = _UIA_getVar($cRTI_Prefix & $obj_or_string)

;~ If not found in repository try again without prefix (normally then a physical description and not an object)
		If @error <> 0 Then
			$oElement = _UIA_getVar($obj_or_string)
			$tPhysical = $oElement
		EndIf

;~ If still not found in repository assume its a physical description which we have to transform later on to an object
		If @error <> 0  Then
			_UIA_LOG("Finding object (bypassing repository) with physical description " & $tPhysical & ":" & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
			$tPhysical = $obj_or_string
		EndIf
	EndIf

;~ So it could be by the lookup its already an element previously referenced
	If _UIA_IsElement($oElement) Then
;~ 		$oElement = $obj_or_string
		_UIA_LOG("Quickly referenced object " & $tPhysical & ":" & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
	Else

;~ 		TODO: If its a physical description the searching should start at one of the last active elements or parent of that last active element
;~ 		else
;~ 			We found a reference try to make it an object
;~ 		_UIA_LOG("Finding object with physical description " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

;~ TODO For the moment the context has to be set in mainscript
;~ Future tought on this to find it more based on the context of the previous actions (more complicated algorithm)
;~ Actually logic should become
;~ If there is no LAST then use desktop else use LAST, if not found use parent of LAST, if not found use grandparent of LAST etc.

;~ if its a repository reference with .mainwindow at end in name then find it under the desktop
		If StringRight($obj_or_string, StringLen(".mainwindow")) = ".mainwindow" Then
			$strStartElement = "Desktop"
			$oStart = $Parent
			_UIA_LOG("Fallback finding 1 object under " & $strStartElement & @TAB & $tPhysical & @CRLF, $UIA_Log_Wrapper)
;~ 			_UIA_LOG("Fallback find under 1 " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

			$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_children, $obj_or_string)

;~ 			And store quick references to mainwindow
			_UIA_setVar("RTI.MAINWINDOW", $oElement)
			_UIA_setVar($cRTI_Prefix & StringUpper($obj_or_string), $oElement)

			_UIA_setVar("RTI.SEARCHCONTEXT", $oElement)
		Else


			$oStart = _UIA_getVar("RTI.SEARCHCONTEXT")
			$strStartElement = "RTI.SEARCHCONTEXT"

			If Not _UIA_IsElement($oStart) Then
;~ 				$pos=stringinstr($obj_or_string,".",0,-1)
;~ TODO: Not sure if both backwards dot and forward dot to investigate
				$pos = StringInStr($obj_or_string, ".")

				_UIA_LOG("_UIA_action: No RTI.SEARCHCONTEXT used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
				If $pos > 0 Then
					$tmpStr = $cRTI_Prefix & StringLeft(StringUpper($obj_or_string), $pos - 1) & ".MAINWINDOW"
				Else
					$tmpStr = "RTI.MAINWINDOW"
				EndIf
				_UIA_LOG("_UIA_action: try for " & $tmpStr & @CRLF, $UIA_Log_Wrapper)


				$oStart = _UIA_getVar($tmpStr)
				$strStartElement = $tmpStr

				If Not _UIA_IsElement($oStart) Then
					_UIA_LOG("_UIA_action: No RTI.MAINWINDOW used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)

;~ TODO: Dump RTI vars only for debugging purpose
					_UIA_LogVarsArray()

					$oStart = _UIA_getVar("RTI.PARENT")
					$strStartElement = "RTI.PARENT"
;~ 					$oStart=$UIA_oParent     ;~TODO: Somehow not retrievable from the DD $UIA_Vars object
					If Not _UIA_IsElement($oStart) Then
						_UIA_LOG("_UIA_action: No RTI.PARENT used for " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
						$strStartElement = "Desktop"
						$oStart = $Parent
					EndIf
				EndIf

;~ 				$oStart=_UIA_getVar("RTI.MAINWINDOW")
;~ 				$strStartElement="RTI.MAINWINDOW"

			EndIf

			_UIA_LOG("_UIA_action: Finding object " & $obj_or_string & " object a:=" & _UIA_IsElement($obj_or_string) & " under " & $strStartElement & " object b:=" & _UIA_IsElement($oStart) & @CRLF, $UIA_Log_Wrapper)
			_UIA_LOG("  looking for " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

;~ 			Check if its a popup dialog which we are going to handle
;~ 			$UIA_oUIAutomation.GetFocusedElement($UIA_pUIElement)
;~ consolewrite("focused Element is passed, trying to convert to object ")
;~ 			$oFocusElement = objcreateinterface($UIA_pUIElement,$sIID_IUIAutomationElement, $dtagIUIAutomationElement)
;~ 			$strStartElement = "Focused element"

;~ 			_UIA_LOG("*** focused object *** " & @CRLF, $UIA_Log_Wrapper)
;~ 			$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_children)
;~ 			_UIA_LOG(_UIA_getBasePropertyInfo($oFocusElement) & @crlf, $UIA_Log_Wrapper)
;~ 			consolewrite("_UIA_action: Finding object " & $obj_or_string & " object a:=" & _UIA_IsElement($obj_or_string) & " under " & $strStartElement & " object b:=" & _UIA_IsElement($oStart) & @CRLF)
;~ 			consolewrite("  looking for " & $tPhysical & @CRLF)


;~ 			Do not directly search all children and grandchildren but take 2 step approach as frequently only looking in the direct childs
			$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_children)

			If Not _UIA_IsElement($oElement) Then

				consolewrite("  deep find in subtree 1 " & $obj_or_string & ";" & $strStartElement & @CRLF)
				consolewrite("  deep find in subtree 2 " & $tPhysical & ";" & $strStartElement & @CRLF)
				consolewrite("    RTI.MAINWINDOW is an object" & isobj(_UIA_getVar("RTI.MAINWINDOW")) & @CRLF)

				_UIA_LOG("  deep find in subtree " & $tPhysical & @CRLF, $UIA_Log_Wrapper)
;~ 				return
				$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree)
			EndIf

;~ 			And in worst case search backward highest parents and refind in subtree

			If Not _UIA_IsElement($oElement) Then
				_UIA_LOG("  walking back to mainwindow and deep find in subtree " & $tPhysical & @CRLF, $UIA_Log_Wrapper)

;~ Walk thru the tree with a treewalker
				$UIA_oUIAutomation.RawViewWalker($UIA_pTW)
				$UIA_oTW = ObjCreateInterface($UIA_pTW, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
				If Not _UIA_IsElement($UIA_oTW) Then
					_UIA_LOG("UI automation treewalker failed. UI Automation failed failed " & @CRLF, $UIA_Log_Wrapper)
				EndIf
;~ 	at least 1 assumed (assuming we are not spying the desktop)
				$i = 0
				$UIA_oTW.getparentelement($oStart, $oParentHandle)
				$oParentHandle = ObjCreateInterface($oParentHandle, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
				If _UIA_IsElement($oParentHandle) = 0 Then
					_UIA_LOG("No parent: UI Automation failed could be you spy the desktop", $UIA_Log_Wrapper)
				Else
					While ($i <= $_UIA_MAXDEPTH) And (_UIA_IsElement($oParentHandle) = True)
						_UIA_LOG(_UIA_getPropertyValue($oParentHandle, $UIA_NamePropertyId) & " parent" & $i, $UIA_Log_Wrapper)
						$i = $i + 1
						$oParentBefore = $oParentHandle
						$UIA_oTW.getparentelement($oParentHandle, $oParentHandle)
						$oParentHandle = ObjCreateInterface($oParentHandle, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
					WEnd
					$parentCount = $i - 1
					$oStart = $oParentBefore
				EndIf

				$oElement = _UIA_getObjectByFindAll($oStart, $tPhysical, $treescope_subtree)
			EndIf

;~ We have not found an object, so for debugging its easier to have then whole tree dumped in logfiles
;~ unless it was a check for (non)existence
			If Not _UIA_IsElement($oElement) Then
				If _UIA_getVar("Global.Debug") = True Then
					_UIA_DumpThemAll($oStart, $treescope_subtree)
				EndIf
			Else
;~ 				We set the context to the last found element
;~ 				_UIA_setVar("RTI.SEARCHCONTEXT", $oElement)
			EndIf
		EndIf
	EndIf

	Return $oElement

EndFunc   ;==>_UIA_getObject

;this function does the core of the work for doing actions. if calls search functions to find the desired element
Func _UIA_action($obj_or_string, $strAction, $p1 = 0, $p2 = 0, $Parent=$UIA_oDesktop,$None=0) ; may need to place $deep at the end
	Local $obj2ActOn ;~ Object that is found and where we want to act on
	Local $tPattern ;~ Reference to hold the pattern of UIA thats needed to execute an action
	Local $x, $y ;~ Used for x and y of mouse clicking
	Local $controlType
	Local $oElement
	Local $parentHandle
	Local $oTW
	Local $hwnd
	Local $retValue = True ;~ Default returnvalue unless overwritten below with other value
	Local $tRect ;~ Holds reference to 4 values of a rectangle (in an array so no RECT struct)

	_UIA_LOG($__UIA_debugCacheOn)

	;if you have more than one selector then we need to do a more thorough search for the element rather than the faster search
	if StringInStr($obj_or_string,";")<>0 Then
		;$oElement = _UIA_getObject($obj_or_string,$Parent)
		$oElement = _UIA_getObjectByFindAll($Parent,$obj_or_string,$treescope_subtree)
	Else
    	$oElement = _UIA_getFirstObjectOfElement($Parent,$obj_or_string,$treescope_subtree)
	EndIf
	

	If _UIA_IsElement($oElement) Then
		$obj2ActOn = $oElement
		_UIA_setVar("RTI.LASTELEMENT", $oElement)
		$controlType = _UIA_getPropertyValue($obj2ActOn, $UIA_ControlTypePropertyId)
	Else
		Exit(1)
;~ 		exclude the intentional actions that are done for nonexistent objects
		;If Not StringInStr("exist,exists", $strAction) Then
		;	_UIA_LOG("Not an object failing action " & $strAction & " on " & $obj_or_string & @CRLF, $UIA_Log_Wrapper)
		;	SetError(1)
		;	Return False
		;EndIf
	EndIf

	_UIA_setVar("RTI.ACTIONCOUNT", _UIA_getVar("RTI.ACTIONCOUNT") + 1)

	_UIA_LOG($__UIA_debugCacheOff)

;~ Execute the given action
	Switch $strAction
;~ 		All mouse click actions
		Case "leftclick", "left", "click", _
				"leftdoubleclick", "leftdouble", "doubleclick", _
				"rightclick", "right", _
				"rightdoubleclick", "rightdouble", _
				"middleclick", "middle", _
				"middledoubleclick", "middledouble", _
				"mousemove", "movemouse"

			Local $clickAction = "left" ;~ Default action is the left mouse button
			Local $clickCount = 1 ;~ Default action is the single click

			If StringInStr($strAction, "right") Then $clickAction = "right"
			If StringInStr($strAction, "middle") Then $clickAction = "middle"
			If StringInStr($strAction, "double") Then $clickCount = 2

			;if clickable object is invokable we get big speed performance by using its invoke method
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_InvokePatternId)
			if _UIA_getPropertyValue($obj2ActOn, $UIA_IsInvokePatternAvailablePropertyId)='True' and $clickAction='left' then 
				$tPattern.invoke()
			Else
			;else manually click by getting the clickable point and moving the mouse and clicking the mouse
				Local $t
				$t = StringSplit(_UIA_getPropertyValue($obj2ActOn, $UIA_BoundingRectanglePropertyId), ";")
	;~ 			If no parameter detect the middle
				if $p1=0 then
					$x = Int($t[1] + ($t[3] / 2))
					$y = Int($t[2] + $t[4] / 2)
				Else
	;~ 				calculate location relative in the element found
					$x=Int($t[1] +$p1)
					$y=Int($t[2] +$p2)
				endif

	;~ 			Mouse should move to keep it as userlike as possible
				MouseMove($x, $y, 0)

				If Not StringInStr($strAction, "move") Then
					MouseClick($clickAction, $x, $y, $clickCount, 0)
				EndIf
				Sleep($UIA_DefaultWaitTime)
			EndIf

		Case "setValue", "settextValue"
			If ($controlType = $UIA_WindowControlTypeId) Then
				$hwnd = 0
				$obj2ActOn.CurrentNativeWindowHandle($hwnd)
;~ 				ConsoleWrite($hwnd)
				WinSetTitle(HWnd($hwnd), "", $p1)
			Else
				$obj2ActOn.setfocus()
				Sleep($UIA_DefaultWaitTime)
;~ 				Let take IAccessible pattern precedence over value pattern
				$tPattern = _UIA_getPattern($obj2ActOn, $UIA_LegacyIAccessiblePatternId)
				If _UIA_IsElement($tPattern) Then
					$tPattern.setValue($p1)
				Else
					$tPattern = _UIA_getPattern($obj2ActOn, $UIA_ValuePatternId)
					If _UIA_IsElement($tPattern) Then
						$tPattern.setValue($p1)
					EndIf
				EndIf
			EndIf

		Case "setValue using keys"
			$obj2ActOn.setfocus()
			Send("^a")
			Send($p1)
			Sleep($UIA_DefaultWaitTime)
		Case "setValue using clipboard"
			ClipPut($p1)
			$obj2ActOn.setfocus()
			Send("^v")
;~ 			Send($p1)
			Sleep($UIA_DefaultWaitTime)

		Case "getValue"
			$obj2ActOn.setfocus()
			Send("^a")
			sleep(50)
			Send("^c")
			$retValue = ClipGet()

		Case "sendkeys", "enterstring", "type", "typetext"
			$obj2ActOn.setfocus()
			Send($p1)
		Case "invoke"
			$obj2ActOn.setfocus()
			Sleep($UIA_DefaultWaitTime)
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_InvokePatternId)
			if isobj($tPattern) then
				$tPattern.invoke()
			Else
				consolewrite("FATAL: your object does not support invoke, try click instead")
			EndIf

		Case "focus", "setfocus", "activate", "switchto"
			_UIA_setVar("RTI.SEARCHCONTEXT", $obj2ActOn)
			$obj2ActOn.setfocus()
			Sleep($UIA_DefaultWaitTime)

		Case "close"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.close()
		Case "move", "setposition"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_TransformPatternId)
			$tPattern.move($p1, $p2)
		Case "resize"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Normal)
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_TransformPatternId)
			$tPattern.resize($p1, $p2)
		Case "minimize"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Minimized)
		Case "maximize"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Maximized)
		Case "normal"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.SetWindowVisualState($WindowVisualState_Normal)
		Case "close"
			$tPattern = _UIA_getPattern($obj2ActOn, $UIA_WindowPatternId)
			$tPattern.close()
		Case "searchcontext", "context"
			_UIA_setVar("RTI.SEARCHCONTEXT", $obj2ActOn)
		Case "highlight"
			_UIA_Highlight($obj2ActOn)
		Case "getobject", "object"
			Return $obj2ActOn
		Case "attach"
			Return $obj2ActOn
		Case "capture", "screenshot", "takescreenshot"
			$tRect = StringSplit(_UIA_getPropertyValue($obj2ActOn, $UIA_BoundingRectanglePropertyId), ";")
			ConsoleWrite($p1 & ";" & $tRect[1] & ";" & ($tRect[3] + $tRect[1]) & ";" & $tRect[2] & ";" & ($tRect[4] + $tRect[2]))
			_ScreenCapture_Capture($p1, $tRect[1], $tRect[2], $tRect[3] + $tRect[1], $tRect[4] + $tRect[2])
		Case "dump", "dumpthemall"
			_UIA_DumpThemAll($obj2ActOn, $treescope_subtree)
		Case "propertyvalue", "property"
			Local $i = _UIA_getPropertyIndex($p1)
			If Not @error <> 0 Then
				$retValue = _UIA_getPropertyValue($obj2ActOn, $UIA_propertiesSupportedArray[$i][1])
			Else
				$retValue = _UIA_getPropertyValue($obj2ActOn, $p1)
			EndIf

		Case Else

	EndSwitch

	Return $retValue

EndFunc   ;==>_UIA_action

;~ Just dumps all information under a certain object
Func _UIA_DumpThemAll($oElementStart, $treeScope)
;~  Get result with findall function alternative could be the treewalker
;~ 	Local $pCondition, $pTrueCondition, $oCondition
	Local $oAutomationElementArray
	Local $pElements, $iLength, $i
	Local $dumpStr
	Local $tmpStr

	If not _UIA_IsElement($oElementStart) Then
		exit
	EndIf

	$dumpStr = "<treedump>"
	$dumpStr = $dumpStr & "<treeheader>***** Dumping tree *****</treeheader>"
;~ 	_UIA_LOG("<treedump>"	& @CRLF)
;~ 	_UIA_LOG("***** Dumping tree *****" & @CRLF)

;~     $UIA_oUIAutomation.CreateTrueCondition($pTrueCondition)
;~     $oCondition=ObjCreateInterface($pTrueCondition, $sIID_IUIAutomationCondition,$dtagIUIAutomationCondition)

	$oElementStart.FindAll($treeScope, $UIA_oTRUECondition, $pElements)

	$oAutomationElementArray = ObjCreateInterface($pElements, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)

;~ 	If there are no childs found then there is nothing to search
	If _UIA_IsElement($oAutomationElementArray) Then
;~ All elements to inspect are in this array
		$oAutomationElementArray.Length($iLength)
	Else
		$dumpStr = $dumpStr & "<fatal>***** FATAL:???? _UIA_DumpThemAll no childarray found ***** </fatal>"
;~ 		_UIA_LOG("***** FATAL:???? _UIA_DumpThemAll no childarray found *****" & @CRLF, $UIA_Log_Wrapper)
		$iLength = 0
	EndIf

	For $i = 0 To $iLength - 1; it's zero based
		$oAutomationElementArray.GetElement($i, $UIA_pUIElement)
		$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		$tmpStr = "Title is: <" & _UIA_getPropertyValue($UIA_oUIElement, $UIA_NamePropertyId) & ">" & @TAB _
				 & "Class   := <" & _UIA_getPropertyValue($UIA_oUIElement, $UIA_ClassNamePropertyId) & ">" & @TAB _
				 & "controltype:= " _
				 & "<" & _UIA_getControlName(_UIA_getPropertyValue($UIA_oUIElement, $UIA_ControlTypePropertyId)) & ">" & @TAB _
				 & ",<" & _UIA_getPropertyValue($UIA_oUIElement, $UIA_ControlTypePropertyId) & ">" & @TAB _
				 & ", (" & Hex(_UIA_getPropertyValue($UIA_oUIElement, $UIA_ControlTypePropertyId)) & ")" & @TAB _
				 & ", acceleratorkey:= <" & _UIA_getPropertyValue($UIA_oUIElement, $UIA_AcceleratorKeyPropertyId) & ">" & @TAB _
				 & ", automationid:= <" & _UIA_getPropertyValue($UIA_oUIElement, $UIA_AutomationIdPropertyId) & ">" & @TAB
		$tmpStr = _UIA_EncodeHTMLString($tmpStr)

		$dumpStr = $dumpStr & "<elementinfo>" & $tmpStr & "</elementinfo>"

;~ 		_UIA_LOG($tmpStr)

	Next
	$dumpStr = $dumpStr & "</treedump>"

	_UIA_LOG($dumpStr)


EndFunc   ;==>_UIA_DumpThemAll

Func _UIA_StartSUT($SUT_VAR)
	Local $fullName = _UIA_getVar($SUT_VAR & ".Fullname")
	Local $processName = _UIA_getVar($SUT_VAR & ".processname")
	Local $app2Start = $fullName & " " & _UIA_getVar($SUT_VAR & ".Parameters")
	Local $workingDir = _UIA_getVar($SUT_VAR & ".Workingdir")
	Local $windowState = _UIA_getVar($SUT_VAR & ".Windowstate")

	Local $PID ; Holds the process id's
	Local $oSUT

	If FileExists($fullName) Then
;~ 		Only start new instance when not found
		$PID = ProcessExists($processName)
		If $PID = 0 Then
			_UIA_LOG("Starting with RUN: " & $app2Start & " from " & $workingDir, $UIA_Log_Wrapper)
			$PID = Run($app2Start, $workingDir, $windowState)
;~ 			$PID  = ProcessWait($processName, 60)
;~ 			sleep(500) ;~ Just to give the system some time to show everything
		EndIf

;~ Wait for the window to be there
		$oSUT = _UIA_getObjectByFindAll($UIA_oDesktop, "processid:=" & $PID, $TreeScope_Children)
		If Not _UIA_IsElement($oSUT) Then
			_UIA_LOG("No window found in SUT : " & $app2Start & " from " & $workingDir & @CRLF, $UIA_Log_Wrapper)
		Else
;~ Add it to the Runtime Type Information
			_UIA_setVar($cRTI_Prefix & $SUT_VAR & ".PID", $PID)
			_UIA_setVar($cRTI_Prefix & $SUT_VAR & ".HWND", Hex(_UIA_getPropertyValue($oSUT, $UIA_NativeWindowHandlePropertyId)))
;~ 			_UIA_DumpThemAll($oSUT,$treescope_subtree)
		EndIf
	Else
		_UIA_LOG("No clue where to find the system under test (SUT) on your system, please start manually:" & @CRLF, $UIA_Log_Wrapper)
		_UIA_LOG($app2Start & @CRLF, $UIA_Log_Wrapper)
	EndIf
EndFunc   ;==>_UIA_StartSUT

Func _UIA_Highlight($oElement)
	Local $t
	$t = StringSplit(_UIA_getPropertyValue($oElement, $UIA_BoundingRectanglePropertyId), ";")
	_UIA_DrawRect($t[1], $t[3] + $t[1], $t[2], $t[4] + $t[2])
EndFunc   ;==>_UIA_Highlight

Func _UIA_NiceString($str)
	Local $tmpStr = $str
	$tmpStr = StringReplace($tmpStr, " ", "")
	$tmpStr = StringReplace($tmpStr, "\", "")
	Return $tmpStr
EndFunc   ;==>_UIA_NiceString

Func _UIA_EncodeHTMLString($str)
	Local $tmpStr = $str
	$tmpStr = StringReplace($tmpStr, "&", "&amp;")
	$tmpStr = StringReplace($tmpStr, ">", "&gt;")
	$tmpStr = StringReplace($tmpStr, "<", "&lt;")
	$tmpStr = StringReplace($tmpStr, """", "&quot;")
	$tmpStr = StringReplace($tmpStr, "'", "&apos;")

;~ 	quick dirty fix

	$tmpStr = StringReplace($tmpStr, "&amp;gt;", "&gt;")
	$tmpStr = StringReplace($tmpStr, "&amp;lt;", "&lt;")
	$tmpStr = StringReplace($tmpStr, "&amp;quot;", "&quot;")
	$tmpStr = StringReplace($tmpStr, "&amp;apos;", "&apos;")

;~ 	$tmpStr = StringReplace($tmpStr, @CRLF, "&#10;&#13;")
;~ 	$tmpStr = StringReplace($tmpStr, @CRLF, "<![CDATA["& @CRLF & "]]>")
;~ 	$tmpStr = StringReplace($tmpStr, @CRLF, "<br>")

	Return $tmpStr

EndFunc   ;==>_UIA_EncodeHTMLString

Func _UIA_LogFile($strName = "log.xml", $reset = False)
	If _UIA_getVar("global.debug.file") = True Then

		If $reset = True Then
			$__g_hFileLog = FileOpen($strName, $FO_CREATEPATH + $FO_OVERWRITE + $FO_UTF8)

			FileWrite($__g_hFileLog, "<?xml version=""1.0"" encoding=""UTF-8""?>")
			FileWrite($__g_hFileLog, "<log space=""preserve"">")

;~ 		filewrite($__g_hFileLog,"<!DOCTYPE html><html><body>")
;~ 		filewrite($__g_hFileLog,"<h1>UIA logging</h1>")
		Else
			$__g_hFileLog = FileOpen($strName, $FO_APPEND + $FO_UTF8)
		EndIf
	EndIf
EndFunc   ;==>_UIA_LogFile
Func _UIA_LogFileClose()
	If _UIA_getVar("global.debug.file") = True Then
;~ 	filewrite($__g_hFileLog,"</body></html>")
		FileWrite($__g_hFileLog, "</log>" & @CRLF)
		FileClose($__g_hFileLog)
	EndIf
EndFunc   ;==>_UIA_LogFileClose

Func _UIA_LOG($sLogString, $logLevel = 0)
	Local $sLogStrOut, $bFlushCache = False

	If Not ((_UIA_getVar("global.debug.file") = True) Or (_UIA_getVar("global.debug") = True)) Then Return SetError($_UIASTATUS_Success, $_UIASTATUS_Success, "")

;~ Check if we are caching data from multiple logging steps
	If $sLogString = $__UIA_debugCacheOn Then
		$sLogString = ""
		$__l_UIA_CacheState = True
		$bFlushCache = True
	EndIf

	If $sLogString = $__UIA_debugCacheOff Then
		$__l_UIA_CacheState = False
		$sLogString = $__gl_XMLCache
	EndIf

;~  Assume if it starts with a tag that calling function has taken care of html encoding
	If StringLeft($sLogString, 1) <> "<" Then
;~ 		consolewrite(stringleft($slogString,20))
		$sLogString = _UIA_EncodeHTMLString($sLogString)
	EndIf

;~ Check if we are caching data from multiple logging steps
	If $__l_UIA_CacheState = True And $bFlushCache = False Then
		$__gl_XMLCache = $__gl_XMLCache & $sLogString
	EndIf

	If ($__l_UIA_CacheState = False) Or ($bFlushCache = True) Then

;~ Strip excessive CRLF
		If StringRight($sLogString, 2) = @CRLF Then
			$sLogString = StringLeft($sLogString, StringLen($sLogString) - 2)
		EndIf

		$sLogStrOut = "<logline level=""" & $logLevel & """"
		$sLogStrOut = $sLogStrOut & " timestamp=""" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & @SEC & @MSEC & """>"
		$sLogStrOut = $sLogStrOut & " " & $sLogString & "</logline>" & @CRLF

		If _UIA_getVar("global.debug.file") = True Then
			FileWrite($__g_hFileLog, $sLogStrOut)
		Else
			If _UIA_getVar("global.debug") = True Then
				ConsoleWrite($sLogStrOut)
			EndIf
		EndIf

		$__gl_XMLCache = ""
	EndIf

	Return $_UIASTATUS_Success
EndFunc   ;==>_UIA_LOG

Func _UIA_getBasePropertyInfo($oUIElement)
	Local $title = _UIA_getPropertyValue($oUIElement, $UIA_NamePropertyId)
	Local $class = _UIA_getPropertyValue($oUIElement, $uia_classnamepropertyid)
	Local $controltypeName = _UIA_getControlName(_UIA_getPropertyValue($oUIElement, $UIA_ControlTypePropertyId))
	Local $controltypeId = _UIA_getPropertyValue($oUIElement, $UIA_ControlTypePropertyId)
	Local $nativeWindow = _UIA_getPropertyValue($oUIElement, $UIA_NativeWindowHandlePropertyId)
	Local $controlRect = _UIA_getPropertyValue($oUIElement, $UIA_BoundingRectanglePropertyId)
	Local $acceleratorkey = _UIA_getPropertyValue($oUIElement, $UIA_AcceleratorKeyPropertyId)
	Local $automationid = _UIA_getPropertyValue($oUIElement, $UIA_AutomationIdPropertyId)

	Return "Title is: <" & $title & ">" & @TAB _
			 & "Class   := <" & $class & ">" & @TAB _
			 & "controltype:= " & "<" & $controltypeName & ">" & @TAB _
			 & ",<" & $controltypeId & ">" & @TAB _
			 & ", (" & Hex($controltypeId) & ")" & @TAB _
			 & "rect := < " & $controlRect & ">" & @TAB _
			 & "hwnd := < " & $nativeWindow & ">" & @TAB _
			 & "acceleratorkey := < " & $acceleratorkey & ">" & @TAB _
			 & "automationid := <" & $automationid & ">" & @CRLF

EndFunc   ;==>_UIA_getBasePropertyInfo

#EndRegion UIA Testing Framework

#Region UIA Internal USE

; Draw rectangle on screen.
Func _UIA_DrawRect($tLeft, $tRight, $tTop, $tBottom, $color = 0xFF, $PenWidth = 4)
	Local $hDC, $hPen, $obj_orig, $x1, $x2, $y1, $y2
	$x1 = $tLeft
	$x2 = $tRight
	$y1 = $tTop
	$y2 = $tBottom
	$hDC = _WinAPI_GetWindowDC(0) ; DC of entire screen (desktop)
	$hPen = _WinAPI_CreatePen($PS_SOLID, $PenWidth, $color)
	$obj_orig = _WinAPI_SelectObject($hDC, $hPen)

	_WinAPI_DrawLine($hDC, $x1, $y1, $x2, $y1) ; horizontal to right
	_WinAPI_DrawLine($hDC, $x2, $y1, $x2, $y2) ; vertical down on right
	_WinAPI_DrawLine($hDC, $x2, $y2, $x1, $y2) ; horizontal to left right
	_WinAPI_DrawLine($hDC, $x1, $y2, $x1, $y1) ; vertical up on left

	; clear resources
	_WinAPI_SelectObject($hDC, $obj_orig)
	_WinAPI_DeleteObject($hPen)
	_WinAPI_ReleaseDC(0, $hDC)
EndFunc   ;==>_UIA_DrawRect

;~ Small helper function to get an object out of a treeSearch based on the name / title
;~ Not possible to match on multiple properties then findall should be used
;~ Deprecate in future??? Most sophisticated stuff is in _UIA_getObjectByFindAll
;~ Should stay as its more speedy on search with 1 property
Func _UIA_getFirstObjectOfElement($obj, $str, $treeScope)
	Local $tResult, $tmpValue, $iTry
	Local $hResult
	Local $pCondition, $oCondition
	Local $propertyID
	Local $i

;~ Check if first element passed is an object
	If IsObj($obj) = 0 Then
		Return SetError($_UIASTATUS_InvalidValue, 0, 0)
	EndIf

;~ 	Split a description into multiple subdescription/properties
	$tResult = StringSplit($str, ":=", 1)

;~ If there is only 1 value without a property assume the default property name to use for identification
	If $tResult[0] = 1 Then
		$propertyID = $UIA_NamePropertyId
		$tmpValue = $str
	Else
;~ 		Find the property as a name and transform to numeric propertyid
		For $i = 0 To UBound($UIA_propertiesSupportedArray) - 1
			If $UIA_propertiesSupportedArray[$i][0] = StringLower($tResult[1]) Then
;~ In general this works fine, line below just for debugging
;~ 	_UIA_LOG("Property identified: " & $UIA_propertiesSupportedArray[$i][0] & " " & $UIA_propertiesSupportedArray[$i][1] & @CRLF, $UIA_Log_Wrapper)
				$propertyID = $UIA_propertiesSupportedArray[$i][1]

;~ 				Some properties expect a number (otherwise system will break)
				Switch $UIA_propertiesSupportedArray[$i][1]
					Case $UIA_ControlTypePropertyId
						$tmpValue = Number($tResult[2])
					Case Else
						$tmpValue = $tResult[2]
				EndSwitch
			EndIf
		Next
	EndIf

	_UIA_LOG("Matching " & $tResult[1] & " transformed to propertynumber: " & $propertyID & ":" & " for having value " & $tmpValue & @CRLF, $UIA_Log_Wrapper)

;~ Tricky when numeric values to pass
	$UIA_oUIAutomation.createPropertyCondition($propertyID, $tmpValue, $pCondition)

	$oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationPropertyCondition, $dtagIUIAutomationPropertyCondition)

	$iTry = 1
	$UIA_oUIElement = ""
	While Not _UIA_IsElement($UIA_oUIElement) And $iTry <= $UIA_tryMax
		$hResult = $obj.Findfirst($treeScope, $oCondition, $UIA_pUIElement)
		If $hResult = 0 Then
			$UIA_oUIElement = ObjCreateInterface($UIA_pUIElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
		EndIf
		If Not _UIA_IsElement($UIA_oUIElement) Then
			Sleep(100)
			$iTry = $iTry + 1
		EndIf
	WEnd

	If _UIA_IsElement($UIA_oUIElement) Then
		_UIA_LOG("UIA found the element" & @CRLF, $UIA_Log_Wrapper)
		If _UIA_getVar("Global.Highlight") = True Then
			_UIA_Highlight($UIA_oUIElement)
		EndIf

		Return $UIA_oUIElement
	Else
		_UIA_LOG("UIA failing ** NOT ** found the element" & @CRLF, $UIA_Log_Wrapper)
		If _UIA_getVar("Global.Debug") = True Then
			_UIA_DumpThemAll($obj, $treeScope)
		EndIf

		Return ""
	EndIf

EndFunc   ;==>_UIA_getFirstObjectOfElement

Func _UIA_IsElement($control)
	Return IsObj($control)
EndFunc   ;==>_UIA_IsElement

#EndRegion UIA Internal USE


;~ ***** Experimental catching the events that are flowing around *****
;~ ;===============================================================================
;~ #interface "IUnknown"
;~ Global Const $sIID_IUnknown = "{00000000-0000-0000-C000-000000000046}"
;~ ; Definition
;~ Global $dtagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
;~ 		"AddRef dword();" & _
;~ 		"Release dword();"
;~ ; List
;~ Global $ltagIUnknown = "QueryInterface;" & _
;~ 		"AddRef;" & _
;~ 		"Release;"
;~ ;===============================================================================
;~ ;===============================================================================
;~ #interface "IDispatch"
;~ Global Const $sIID_IDispatch = "{00020400-0000-0000-C000-000000000046}"
;~ ; Definition
;~ Global $dtagIDispatch = $dtagIUnknown & _
;~ 		"GetTypeInfoCount hresult(dword*);" & _
;~ 		"GetTypeInfo hresult(dword;dword;ptr*);" & _
;~ 		"GetIDsOfNames hresult(ptr;ptr;dword;dword;ptr);" & _
;~ 		"Invoke hresult(dword;ptr;dword;word;ptr;ptr;ptr;ptr);"
;~ ; List
;~ Global $ltagIDispatch = $ltagIUnknown & _
;~ 		"GetTypeInfoCount;" & _
;~ 		"GetTypeInfo;" & _
;~ 		"GetIDsOfNames;" & _
;~ 		"Invoke;"
;~ ;===============================================================================
;~ ; #FUNCTION# ====================================================================================================================
;~ ; Name...........: UIA_ObjectFromTag($obj, $id)
;~ ; Description ...: Get an object from a DTAG
;~ ; Syntax.........:
;~ ; Parameters ....:
;~ ;
;~ ; Return values .: Success      - Returns 1
;~ ;                  Failure		- Returns 0 and sets @error on errors:
;~ ;                  |@error=1     - UI automation failed
;~ ;                  |@error=2     - UI automation desktop failed
;~ ; Author ........: TRANCEXX
;~ ; Modified.......:
;~ ; Remarks .......: None
;~ ; Related .......:
;~ ; Link ..........:
;~ ; Example .......: Yes
;~ ; ===============================================================================================================================
;~ http://www.autoitscript.com/forum/topic/153859-objevent-possible-with-addfocuschangedeventhandler/
;~ Func UIA_ObjectFromTag($sFunctionPrefix, $tagInterface, ByRef $tInterface)
;~     Local Const $tagIUnknown = "QueryInterface hresult(ptr;ptr*);" & _
;~             "AddRef dword();" & _
;~             "Release dword();"
;~     ; Adding IUnknown methods
;~     $tagInterface = $tagIUnknown & $tagInterface
;~     Local Const $PTR_SIZE = DllStructGetSize(DllStructCreate("ptr"))
;~     ; Below line really simple even though it looks super complex. It's just written weird to fit one line, not to steal your eyes
;~     Local $aMethods = StringSplit(StringReplace(StringReplace(StringReplace(StringReplace(StringTrimRight(StringReplace(StringRegExpReplace($tagInterface, "\h*(\w+)\h*(\w+\*?)\h*(\((.*?)\))\h*(;|;*\z)", "$1\|$2;$4" & @LF), ";" & @LF, @LF), 1), "object", "idispatch"), "variant*", "ptr"), "hresult", "long"), "bstr", "ptr"), @LF, 3)
;~     Local $iUbound = UBound($aMethods)
;~     Local $sMethod, $aSplit, $sNamePart, $aTagPart, $sTagPart, $sRet, $sParams
;~     ; Allocation. Read http://msdn.microsoft.com/en-us/library/ms810466.aspx to see why like this (object + methods):
;~     $tInterface = DllStructCreate("ptr[" & $iUbound + 1 & "]")
;~     If @error Then Return SetError(1, 0, 0)
;~     For $i = 0 To $iUbound - 1
;~         $aSplit = StringSplit($aMethods[$i], "|", 2)
;~         If UBound($aSplit) <> 2 Then ReDim $aSplit[2]
;~         $sNamePart = $aSplit[0]
;~         $sTagPart = $aSplit[1]
;~         $sMethod = $sFunctionPrefix & $sNamePart
;~         $aTagPart = StringSplit($sTagPart, ";", 2)
;~         $sRet = $aTagPart[0]
;~         $sParams = StringReplace($sTagPart, $sRet, "", 1)
;~         $sParams = "ptr" & $sParams
;~         DllStructSetData($tInterface, 1, DllCallbackGetPtr(DllCallbackRegister($sMethod, $sRet, $sParams)), $i + 2) ; Freeing is left to AutoIt.
;~     Next
;~     DllStructSetData($tInterface, 1, DllStructGetPtr($tInterface) + $PTR_SIZE) ; Interface method pointers are actually pointer size away
;~     Return ObjCreateInterface(DllStructGetPtr($tInterface), "", $tagInterface, False) ; and first pointer is object pointer that's wrapped
;~ EndFunc

;~ TODO: javascript: var e = document.createElement("input");e.setAttribute("value","Hello world");document.body.appendChild(e);void(0);
;~ xjavascript:(function(){document.body.appendChild(document.createElement('script')).src='file://test.js';})(); "path/to/your/jsfile"
;~ javascript:(function(){document.body.appendChild(document.createElement('script')).src='file://c:\test.js';})();
;~  javascript: var e = document.createElement("input");e.setAttribute("value",document.body.innerHTML);document.body.appendChild(e);e.setFocus();void(0);
;~ window.location.hash = 'category-name'; // address bar would become http://example.com/#category-name


;~ TODO take over from IE.AU3 UDF as an example
; #FUNCTION# ====================================================================================================================
; Name...........: _UIA_Introduction
; Description ...: Shows cross browser on how to show html page
; Syntax.........: _UIA_Introduction("basic")
; Parameters ....: none
; Return values .: Success      - Returns 1
;                  Failure		- Returns 0 and sets @error on errors:
;                  |@error=1     - UI automation failed
;                  |@error=2     - UI automation desktop failed
; Author ........:
; Modified.......:
; Remarks .......: based on IE.AU3 logic
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================; ===============================================================================================================================
Func _UIA_Introduction($sModule = "basic")
	Local $sHtml = ""
	Switch $sModule
		Case "basic"
			$sHtml &= '<!DOCTYPE html>' & @CR
			$sHtml &= '<html>' & @CR
			$sHtml &= '<head>' & @CR
			$sHtml &= '<meta content="text/html; charset=UTF-8" http-equiv="content-type">' & @CR
			$sHtml &= '<title>_UIA_Introduction ("basic")</title>' & @CR
			$sHtml &= '<style>body {font-family: Arial}' & @CR
			$sHtml &= 'td {padding:6px}</style>' & @CR
			$sHtml &= '</head>' & @CR
			$sHtml &= '<body>' & @CR
			$sHtml &= '<table border=1 id="table1" style="width:600px;border-spacing:6px;">' & @CR
			$sHtml &= '<tr>' & @CR
			$sHtml &= '<td>' & @CR
			$sHtml &= '<h1>Welcome to UIWrappers.au3</h1>' & @CR
			$sHtml &= 'UIAWrappers.au3 is a UDF (User Defined Function) library for the ' & @CR
			$sHtml &= '<a href="http://www.autoitscript.com">AutoIt</a> scripting language.' & @CR
			$sHtml &= '<br>  ' & @CR
			$sHtml &= 'It allows you to either create or attach to an browser and do ' & @CR
			$sHtml &= 'just about anything you could do with it interactively with the mouse and ' & @CR
			$sHtml &= 'keyboard, but do it through script.' & @CR
			$sHtml &= '<br>' & @CR
			$sHtml &= 'You can navigate to pages, click links, fill and submit forms etc. You can ' & @CR
			$sHtml &= 'also do things you cannot do interactively like change or rewrite page ' & @CR
			$sHtml &= 'content and JavaScripts, read, parse and save page content. ' & @CR
			$sHtml &= 'Browser "events are a little harder to catch although it can be done with favlets and javascript".<br>' & @CR
			$sHtml &= 'The module uses the IUIAutomation interface in AutoIt to interact with the elements and browsers ' & @CR
			$sHtml &= 'and partly allows access to the DOM (Document Object Model) supported by the browser.' & @CR
			$sHtml &= '<br>' & @CR
			$sHtml &= 'Here are some links for more information and helpful tools:<br>' & @CR
			$sHtml &= 'Reference Material: ' & @CR
			$sHtml &= '<ul>' & @CR
			$sHtml &= '<li><a href="http://msdn1.microsoft.com/">MSDN (Microsoft Developer Network)</a></li>' & @CR
			$sHtml &= '<li><a href="http://msdn2.microsoft.com/en-us/library/aa752084.aspx" target="_blank">InternetExplorer Object</a></li>' & @CR
			$sHtml &= '<li><a href="http://msdn2.microsoft.com/en-us/library/ms531073.aspx" target="_blank">Document Object</a></li>' & @CR
			$sHtml &= '<li><a href="http://msdn2.microsoft.com/en-us/ie/aa740473.aspx" target="_blank">Overviews and Tutorials</a></li>' & @CR
			$sHtml &= '<li><a href="http://msdn2.microsoft.com/en-us/library/ms533029.aspx" target="_blank">DHTML Objects</a></li>' & @CR
			$sHtml &= '<li><a href="http://msdn2.microsoft.com/en-us/library/ms533051.aspx" target="_blank">DHTML Events</a></li>' & @CR
			$sHtml &= '</ul><br>' & @CR
			$sHtml &= 'Helpful Tools: ' & @CR
			$sHtml &= '<ul>' & @CR
			$sHtml &= '<li><a href="http://www.autoitscript.com/forum/index.php?showtopic=19368" target="_blank">AutoIt IE Builder</a> (build IE scripts interactively)</li>' & @CR
			$sHtml &= '<li><a href="http://www.debugbar.com/" target="_blank">DebugBar</a> (DOM inspector, HTTP inspector, HTML validator and more - free for personal use) Recommended</li>' & @CR
			$sHtml &= '<li><a href="http://www.microsoft.com/downloads/details.aspx?FamilyID=e59c3964-672d-4511-bb3e-2d5e1db91038&amp;displaylang=en" target="_blank">IE Developer Toolbar</a> (comprehensive DOM analysis tool)</li>' & @CR
			$sHtml &= '<li><a href="http://slayeroffice.com/tools/modi/v2.0/modi_help.html" target="_blank">MODIV2</a> (view the DOM of a web page by mousing around)</li>' & @CR
			$sHtml &= '<li><a href="http://validator.w3.org/" target="_blank">HTML Validator</a> (verify HTML follows format rules)</li>' & @CR
			$sHtml &= '<li><a href="http://www.fiddlertool.com/fiddler/" target="_blank">Fiddler</a> (examine HTTP traffic)</li>' & @CR
			$sHtml &= '</ul>' & @CR
			$sHtml &= '</td>' & @CR
			$sHtml &= '</tr>' & @CR
			$sHtml &= '</table>' & @CR
			$sHtml &= '</body>' & @CR
			$sHtml &= '</html>'
		Case Else
			_UIA_LOG("Error UIA_Introduction UIASTATUS_InvalidValue")
			Return SetError($_UIASTATUS_InvalidValue, 1, 0)
	EndSwitch
	_UIADocWriteHTML($sHtml)
	Return SetError($_UIASTATUS_Success, 0, 0)
EndFunc   ;==>_UIA_Introduction

Func _UIADocWriteHTML($sHtml)
	Local $hFileHTML = FileOpen("UIA_INTRO.HTML", $FO_CREATEPATH + $FO_OVERWRITE + $FO_UTF8)
	FileWrite($hFileHTML, $sHtml)
	FileClose($hFileHTML)
EndFunc   ;==>_UIADocWriteHTML

Func _UIA_VersionInfo()
	_UIA_LOG(_UIA_getVersionInfoString(), $UIA_Log_Wrapper)
	Return SetError($_UIASTATUS_Success, 0, $__gaUIAAU3VersionInfo)
EndFunc   ;==>_UIA_VersionInfo

Func _UIA_getVersionInfoString()
	Return "<information> Information " & "_UIA_VersionInfo" & _
			" version: " & $__gaUIAAU3VersionInfo[0] & $__gaUIAAU3VersionInfo[1] & "." & $__gaUIAAU3VersionInfo[2] & "-" & $__gaUIAAU3VersionInfo[3] & ";" & _
			" Release date: " & $__gaUIAAU3VersionInfo[4] & ";" & _
			" OS Version: " & @OSVersion & _
			"</information>" & @CRLF
EndFunc   ;==>_UIA_getVersionInfoString
