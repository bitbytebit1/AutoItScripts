Global $sSound = "Sound"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ COMMAND LINE ~~~~~~~~~~~~~~~~~~~~~~~~~~~
If $CmdLine[0] > 0 And @Compiled Then
	$bAlreadyOpen = _openSoundDevices()
	ControlListView($sSound, "", "SysListView321", "Select", _findNextDevice())
	ControlClick($sSound, "", "Button2") ; Set Default
	If Not $bAlreadyOpen Then WinClose($sSound)
	Exit
EndIf
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ END COMMAND LINE ~~~~~~~~~~~~~~~~~~~~~~~~~~~

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ INITIALISATION ~~~~~~~~~~~~~~~~~~~~~~~~~~~
AutoItSetOption('TrayAutoPause', 0)
AutoItSetOption('TrayMenuMode', 1 + 2)
AutoItSetOption('TrayOnEventMode', 1)

#include <GUIConstantsEx.au3>
#include <HotKeyInput.au3>
#include <HotKey_21b.au3>

$iHotkey = IniRead('settings.ini', 'settings', 'hotkey', '1073')
_HotKey_Assign($iHotkey, '_switchAudioDevice')
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ END INITIALISATION ~~~~~~~~~~~~~~~~~~~~~~~~~~~

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ GUI ~~~~~~~~~~~~~~~~~~~~~~~~~~~
Global $Form, $HKI1, $HButton

$Form = GUICreate('Settings', 300, 120)
GUISetBkColor(0x1d1d1d)

GUISetFont(8.5, 400, 0, 'Tahoma', $Form)

$HKI1 = _GUICtrlHKI_Create($iHotkey, 56, 5, 230, 20)

; Lock CTRL-ALT-DEL for Hotkey Input control, but not for Windows
_KeyLock(0x062E)

GUICtrlCreateLabel('Hotkey:', 10, 8, 44, 14)
GUICtrlSetColor(-1, 0xffffff)
;~ GUICtrlCreateLabel('Click on Input box and hold a combination of keys.', 10, 10, 280, 28)
$hButton = GUICtrlCreateButton('Save', 110, 84, 80, 23)
GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
;~ GUISetState(@SW_HIDE)
GUISetState(@SW_SHOW)
$hCheckbox = GUICtrlCreateCheckbox('Auto start with windows', 10, 38, 199, 14)
If FileExists(@StartupDir & "\AudioChanger.lnk") Then
	GUICtrlSetState(-1, True)
EndIf
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($hCheckbox), "wstr", 0, "wstr", 0)
GUICtrlSetColor(-1, 0xffffff)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ END GUI ~~~~~~~~~~~~~~~~~~~~~~~~~~~


; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ TRAY ~~~~~~~~~~~~~~~~~~~~~~~~~~~
TrayCreateItem('Settings')
TrayItemSetOnEvent(-1, "_showGUI")
TrayCreateItem('')
TrayCreateItem('Exit')
TrayItemSetOnEvent(-1, "_exit")
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~ END TRAY ~~~~~~~~~~~~~~~~~~~~~~~~~~~

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE)
		Case $hCheckbox
			If FileExists(@StartupDir & "\AudioChanger.lnk") Then
				FileDelete(@StartupDir & "\AudioChanger.lnk")
			Else
				FileCreateShortcut(@ScriptFullPath, @StartupDir & "\AudioChanger.lnk")
			EndIf
		Case $hButton
			_HotKey_Release() ; unset previous hotkey
			$iHotkey = _GUICtrlHKI_GetHotKey($HKI1)
			$bIni = IniWrite('settings.ini', 'settings', 'hotkey', $iHotkey)
			If Not $bIni Then MsgBox(0, 'Error', "Unable to save your settings, maybe you don't have permission to write to this folder?")
			_HotKey_Assign($iHotkey, '_switchAudioDevice')
	EndSwitch
WEnd

Func _openSoundDevices()
	Local $bAlreadyOpen = WinExists($sSound)
	ShellExecute("mmsys.cpl")
	WinWait($sSound)
	Return $bAlreadyOpen
EndFunc   ;==>_openSoundDevices

Func _switchAudioDevice()
	Local $bAlreadyOpen = _openSoundDevices()
	ControlListView($sSound, "", "SysListView321", "Select", _findNextDevice())
	ControlClick($sSound, "", "Button2") ; Set Default
	If Not $bAlreadyOpen Then WinClose($sSound)
EndFunc   ;==>_switchAudioDevice

Func _findNextDevice()
	Local $iRet = 0, $iCurrentDevice = -1
	$iNumberOfDevices = ControlListView($sSound, "", "SysListView321", "GetItemCount") - 1
	; loop through all devices until we find the currently enabled device
	Do
		$iCurrentDevice += 1
		ControlListView($sSound, "", "SysListView321", "Select", $iCurrentDevice)
		$bDeviceEnabled = ControlCommand($sSound, "", "Button2", 'IsEnabled')
	Until $bDeviceEnabled = False Or $iNumberOfDevices == $iCurrentDevice
	$iCurrentDevice += 1
	If $iCurrentDevice > $iNumberOfDevices Then
		$iCurrentDevice = 0
	EndIf
	Return $iCurrentDevice
EndFunc   ;==>_findNextDevice

Func _showGUI()
	GUISetState(@SW_SHOW)
EndFunc   ;==>_showGUI

Func _exit()
	Exit
EndFunc   ;==>_exit

