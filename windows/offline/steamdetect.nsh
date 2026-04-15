!insertmacro ProcessCheck "vrserver.exe" "SteamVRResult"
!insertmacro ProcessCheck "SlimeVR.exe" "SlimeVRRunning"

!macro ProcessCheck process unproc result
  ${If} "${process}" == ""
    StrCpy ${result} "No ProcessCheck"
  ${Else}
    nsProcess::FindProcess /EXACT "${process}" $0
    Pop $TestProcessReturn
    ${If} $TestProcessReturn == 0
      StrCpy ${result} "${process} is running"
    ${Else}
      StrCpy ${result} "${process} not running"
    ${EndIf}
  ${EndIf}
!macroend
