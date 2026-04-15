!macro ProcessCheck un GLOBVARRETURN

Function un.SteamVRTest
    StrCpy ${GLOBVARRETURN} "NotFound" 
    Push "vrwebhelper.exe"
    Call un.TestProcess
    Push "vrserver.exe"
    Call un.TestProcess
    Push "vrmonitor.exe"
    Call un.TestProcess
    Push "vrdashboard.exe"
    Call un.TestProcess
    Push "vrcompositor.exe"
    Call un.TestProcess
FunctionEnd

Function un.TestProcess
    Pop $0 
    ${nsProcess::FindProcess} $0 $TestProcessReturn
    ${if} $TestProcessReturn = 0
        StrCpy ${GLOBVARRETURN} "Found"
    ${elseif} $TestProcessReturn != 603
        MessageBox MB_OK "$(DESC_PROCESS_ERROR) $TestProcessReturn"
        StrCpy ${GLOBVARRETURN} "Error"
    ${EndIf}
FunctionEnd

Function un.NextButtonDisable
    GetDlgItem $0 $hwndparent 1
    EnableWindow $0 0
FunctionEnd

Function un.NextButtonEnable
    GetDlgItem $0 $hwndparent 1
    EnableWindow $0 1
FunctionEnd

Function un.UpdateLabelTimer
    ; Test if SlimeVR is Running
    StrCpy $SteamVRResult "NotFound" 
    Push "slimevr.exe"
    Call un.TestProcess
    StrCpy $SlimeVRRunning $SteamVRResult
    ; Test if SteamVR is Running
    Call un.SteamVRTest

    ; Set the Warning label for SteamVR
    ${If} $SteamVRResult == "Found"
        StrCpy $SteamVRLabelTxt $(DESC_STEAMVR_RUNNING)
    ${ElseIf} $SteamVRResult == "NotFound"
        StrCpy $SteamVRLabelTxt ""
    ${EndIf}

    ; Set the Warning label for SlimeVR
    ${If} $SlimeVRRunning == "Found"
        StrCpy $SlimeVRLabelTxt $(DESC_SLIMEVR_RUNNING)
    ${ElseIf} $SlimeVRRunning == "NotFound"
        StrCpy $SlimeVRLabelTxt ""
    ${EndIf}

    ; Logic for Enable Disable the Buttons
    ${If} $SteamVRResult == "Found"
    ${OrIf} $SlimeVRRunning == "Found"
        Call un.NextButtonDisable
    ${ElseIf} $SteamVRResult == "NotFound"
    ${AndIf} $SlimeVRRunning == "NotFound"
        Call un.NextButtonEnable
    ${EndIf}
    ${NSD_SetText} $SteamVRLabelID $SteamVRLabelTxt
    ${NSD_SetText} $SlimeVRLabelID $SlimeVRLabelTxt
FunctionEnd

!macroend
