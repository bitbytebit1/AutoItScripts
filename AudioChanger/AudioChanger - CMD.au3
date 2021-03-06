Global $bSpeakers, $sSound = "Sound", $iCurrentDevice = -1

$bAlreadyOpen = _openSoundDevices()
ControlListView($sSound, "", "SysListView321", "Select", _findNextDevice())
ControlClick($sSound, "", "Button2") ; Set Default
If Not $bAlreadyOpen Then WinClose($sSound)
Exit

Func _openSoundDevices()
	Local $bAlreadyOpen = WinExists($sSound)
  ShellExecute("mmsys.cpl")
  WinWait($sSound)
	Return $bAlreadyOpen
EndFunc   ;==>_openSoundDevices


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

