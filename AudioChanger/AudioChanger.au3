Global $bSpeakers, $sSound = "Sound", $iCurrentDevice = -1

 ; IF RUN WITH COMMAND LINE PARAMETER ENABLE NEXT DEVICE THEN EXIT
If $CmdLine[0] > 0 AND @Compiled Then
	$bAlreadyOpen = _openSoundDevices()
	$iNext = _findNextDevice()
	ControlListView($sSound, "", "SysListView321", "Select", $iCurrentDevice)
	If Not $bAlreadyOpen Then WinClose($sSound)
	Exit
Else
; OTHERWISE WAIT FOR HOTKEY alt+1
	HotKeySet("!1", "_hotkeyTriggered") 
	While Sleep(0x7ffffff)
	WEnd
EndIf

Func _hotkeyTriggered()
  Local $bAlreadyOpen = _openSoundDevices()
  _switchAudioDevice()
	If Not $bAlreadyOpen Then WinClose($sSound)
EndFunc

Func _switchAudioDevice()
	$iNumberOfDevices = ControlListView($sSound, "", "SysListView321", "GetItemCount")
	If $iCurrentDevice < $iNumberOfDevices Then
		$iCurrentDevice += 1
	Else
		$iCurrentDevice = 0
	EndIf

	; Select audio device
	ControlListView($sSound, "", "SysListView321", "Select", $iCurrentDevice)
	; Check if "Set default" button is enabled or disabled, if disabled then this is the current device
	$bDeviceEnabled = ControlCommand($sSound, "", "Button2", 'IsEnabled')
	; Device not enabled, skip to next
	If Not $bDeviceEnabled Then
		_switchAudioDevice()
		Return
	EndIf

	ControlClick($sSound, "", "Button2") ; Set Default
EndFunc   ;==>_switchAudioDevice

Func _openSoundDevices()
	Local $bAlreadyOpen = WinExists($sSound)
  ShellExecute("mmsys.cpl")
  WinWait($sSound)
  ConsoleWrite($bAlreadyOpen & @crlf)
	Return $bAlreadyOpen
EndFunc   ;==>_openSoundDevices


Func _findNextDevice()
	Local $iRet = 0, $iCurrentDevice = -1
	$iNumberOfDevices = ControlListView($sSound, "", "SysListView321", "GetItemCount") - 1
  ; loop through all devices
	Do
		$iCurrentDevice += 1
		ControlListView($sSound, "", "SysListView321", "Select", $iCurrentDevice)
		$bDeviceEnabled = ControlCommand($sSound, "", "Button2", 'IsEnabled')
	Until $bDeviceEnabled = False Or $iNumberOfDevices == $iCurrentDevice
	If $iNumberOfDevices == $iCurrentDevice Then
		Return 0
	Else
		Return $iCurrentDevice
	EndIf
EndFunc   ;==>_findNextDevice

