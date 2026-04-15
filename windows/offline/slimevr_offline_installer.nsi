!AddPluginDir /x86-unicode     "plugins\NScurl\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\NScurl\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\NScurl\amd64-unicode"
!AddPluginDir /x86-unicode     "plugins\AccessControl\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\AccessControl\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\AccessControl\amd64-unicode"
!AddPluginDir /x86-unicode     "plugins\Nsisunz\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\Nsisunz\x86-ansi"
!AddPluginDir /x86-unicode     "plugins\NsProcess\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\NsProcess\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\NsProcess\amd64-unicode"

!include x64.nsh 		; For RunningX64 check
!include LogicLib.nsh	; For conditional operators
!include nsDialogs.nsh  ; For custom pages
!include FileFunc.nsh   ; For GetTime function
!include nsProcess.nsh ; For Check on SteamVR
!include TextFunc.nsh   ; For ConfigRead
!include MUI2.nsh
!include steamdetect.nsh
!include dlmacro.nsh

!define CSIDL_COMMON_DOCUMENTS 0x002E ; Define CSIDL_COMMON_DOCUMENTS if not already defined

!define SF_USELECTED  0
!define MUI_ICON "run.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "../web/logo.bmp"
!define MUI_HEADERIMAGE_BITMAP_STRETCH "NoStretchNoCrop"
!define MUI_HEADERIMAGE_RIGHT
!define SLIMETEMP "$TEMP\SlimeVRInstaller"

# Define all download URLs and versions here for easy editing - OFFLINE BUNDLE (matching web latest)
!define MVCVersion ""
!define MVCURLType "local"
!define MVCDLURL "assets\\vc_redist.x64.exe"
!define MVCDLFileZip "vc_redist.x64.exe"

!define JREVersion "17.0.17+10"
!define JREURLType "local"
!define JREDLURL "assets\\OpenJDK17U-jre_x64_windows_hotspot_17.0.17_10.zip"
!define JREDLFileZip "OpenJDK17U-jre_x64_windows_hotspot_17.0.17_10.zip"

!define SVRServerVersion "latest"
!define SVRServerURLType "local"
!define SVRServerDLURL "assets\\SlimeVR-Server-latest.zip"
!define SVRServerDLFileZip "SlimeVR-Server-latest.zip"

!define SVRDriverVersion "latest"
!define SVRDriverURLType "local"
!define SVRDriverDLURL "assets\\slimevr-openvr-driver-win64.zip"
!define SVRDriverDLFileZip "slimevr-openvr-driver-win64.zip"

!define SVRFeederVersion "latest"
!define SVRFeederURLType "local"
!define SVRFeederDLURL "assets\\SlimeVR-Feeder-App-win64.zip"
!define SVRFeederDLFileZip "SlimeVR-Feeder-App-latest.zip"

Var JREneedInstall
Var /GLOBAL PUBLIC
Var /GLOBAL SteamVRResult
Var /GLOBAL SteamVRLabelID
Var /GLOBAL SteamVRLabelTxt
Var /GLOBAL TestProcessReturn
Var /GLOBAL SlimeVRRunning
Var /GLOBAL SlimeVRLabelID
Var /GLOBAL SlimeVRLabelTxt

# Define name of installer
Name "SlimeVR Offline Installer"

SpaceTexts none # Don't show required disk space since we don't know for sure
SetOverwrite on
SetCompressor lzma

OutFile "slimevr_offline_installer.exe"

# Define installation directory
InstallDir "$PROGRAMFILES\SlimeVR Server"

ShowInstDetails show
ShowUninstDetails show

BrandingText "SlimeVR Offline Installer 1.0.0"

RequestExecutionLevel admin

Var REPAIR
Var UPDATE
Var SELECTED_INSTALLER_ACTION

Var CREATE_DESKTOP_SHORTCUT
Var CREATE_STARTMENU_SHORTCUTS
Var OPEN_DOCUMENTATION
Var OPEN_SLIMEVR

Var STEAMDIR

Function .onInit
    InitPluginsDir
    ${If} ${RunningX64}
        ReadRegStr $0 HKLM SOFTWARE\WOW6432Node\Valve\Steam InstallPath
    ${Else}
        ReadRegStr $0 HKLM SOFTWARE\Valve\Steam InstallPath
    ${EndIf}
    StrCpy $STEAMDIR $0

    StrCpy $0 ""
    System::Call 'shell32::SHGetFolderPathW(i 0, i ${CSIDL_COMMON_DOCUMENTS}, i 0, i 0, t .r0)'
    ${GetParent} $0 $0
    StrCpy $PUBLIC $0

FunctionEnd

!insertmacro ProcessCheck "un." "SteamVRResult"
!insertmacro ProcessCheck "" "SteamVRResult"

Function un.onInit
    ${If} ${RunningX64}
        ReadRegStr $0 HKLM SOFTWARE\WOW6432Node\Valve\Steam InstallPath
    ${Else}
        ReadRegStr $0 HKLM SOFTWARE\Valve\Steam InstallPath
    ${EndIf}
    StrCpy $STEAMDIR $0
FunctionEnd

Function cleanTemp
    RMDir /r "${SLIMETEMP}"
FunctionEnd

Function .onInstFailed
    ${If} $SELECTED_INSTALLER_ACTION == ""
        RMDir /r $INSTDIR
    ${Endif}
FunctionEnd

Function .onGUIEnd
    Call cleanTemp
FunctionEnd

Page Custom startPage startPageLeave

!define MUI_PAGE_CUSTOMFUNCTION_PRE componentsPre
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_PAGE_CUSTOMFUNCTION_PRE installerActionPre
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_PAGE_CUSTOMFUNCTION_PRE cleanTemp
!insertmacro MUI_PAGE_INSTFILES

Page Custom endPage endPageLeave

!insertmacro MUI_SET MUI_UNCONFIRMPAGE ""
UninstPage custom un.startPageConfirm un.endPageunConfirm
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

LangString START_PAGE_TITLE ${LANG_ENGLISH} "Welcome"
LangString START_PAGE_SUBTITLE ${LANG_ENGLISH} "Welcome to SlimeVR Setup!"

Function startPage
    Call UpdateLabelTimer
    !insertmacro MUI_HEADER_TEXT $(START_PAGE_TITLE) $(START_PAGE_SUBTITLE)
    nsDialogs::Create 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ReadRegStr $0 HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR InstallLocation
    ${If} $0 != ""
        StrCpy $INSTDIR $0

        ${NSD_CreateLabel} 0 0 100% 20u 'An existing installation was detected in "$0". Choose an option and click Next to proceed.'
        ${NSD_CreateRadioButton} 0 40u 100% 10u "Update"
        Pop $UPDATE
        ${NSD_CreateRadioButton} 0 55u 100% 10u "Repair"
        Pop $REPAIR

        ${If} $SELECTED_INSTALLER_ACTION == "update"
            SendMessage $UPDATE ${BM_SETCHECK} 1 0
        ${ElseIf} $SELECTED_INSTALLER_ACTION == "repair"
            SendMessage $REPAIR ${BM_SETCHECK} 1 0
        ${Else}
            SendMessage $UPDATE ${BM_SETCHECK} 1 0
        ${EndIf}
    ${Else}
        ${NSD_CreateLabel} 0 0 100% 50u "Click Next to proceed with installation."
        Pop $0
    ${EndIf}

    ${NSD_CreateLabel} 0 90u 100% 10u '$SteamVRLabelTxt'
    Pop $SteamVRLabelID
    ${NSD_CreateLabel} 0 100u 100% 10u '$SlimeVRLabelTxt'
    Pop $SlimeVRLabelID
    GetFunctionAddress $0 UpdateLabelTimer
    nsDialogs::CreateTimer $0 2000

    nsDialogs::Show

FunctionEnd

Function startPageLeave
    GetFunctionAddress $0 UpdateLabelTimer
    nsDialogs::KillTimer $0
    ${NSD_GetState} $UPDATE $0
    ${NSD_GetState} $REPAIR $1

    ${If} $0 = 1
        StrCpy $SELECTED_INSTALLER_ACTION "update"
    ${ElseIf} $1 = 1
        StrCpy $SELECTED_INSTALLER_ACTION "repair"
    ${EndIf}

FunctionEnd

Function endPage

    nsDialogs::Create 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 12u "The installation is finished!"
    Pop $0

    ${NSD_CreateCheckbox} 0 25u 100% 10u "Open SlimeVR Quick setup guide"
    Pop $OPEN_DOCUMENTATION
    ${If} $SELECTED_INSTALLER_ACTION == ""
        ${NSD_Check} $OPEN_DOCUMENTATION
    ${EndIf}

    ${NSD_CreateCheckbox} 0 40u 100% 10u "Create Desktop shortcut"
    Pop $CREATE_DESKTOP_SHORTCUT
    ${NSD_Check} $CREATE_DESKTOP_SHORTCUT
    
    ${NSD_CreateCheckbox} 0 55u 100% 10u "Create Start Menu shortcuts"
    Pop $CREATE_STARTMENU_SHORTCUTS
    ${NSD_Check} $CREATE_STARTMENU_SHORTCUTS

    ${NSD_CreateCheckbox} 0 70u 100% 10u "Open SlimeVR Server"
    Pop $OPEN_SLIMEVR
    ${NSD_Check} $OPEN_SLIMEVR

    nsDialogs::Show

FunctionEnd


Function endPageLeave

    SetOutPath $INSTDIR

    ${NSD_GetState} $CREATE_STARTMENU_SHORTCUTS $0
    ${NSD_GetState} $CREATE_DESKTOP_SHORTCUT $1
    ${NSD_GetState} $OPEN_DOCUMENTATION $2
    ${NSD_GetState} $OPEN_SLIMEVR $3

    ${If} $0 = 1
        CreateDirectory "$SMPROGRAMS\SlimeVR Server"
        CreateShortcut "$SMPROGRAMS\SlimeVR Server\Uninstall SlimeVR Server.lnk" "$INSTDIR\uninstall.exe"
        CreateShortcut "$SMPROGRAMS\SlimeVR Server\SlimeVR Server.lnk" "$INSTDIR\SlimeVR.exe" ""
    ${Else}
        Delete "$SMPROGRAMS\Uninstall SlimeVR Server.lnk"
        Delete "$SMPROGRAMS\SlimeVR Server.lnk"
        RMdir /r "$SMPROGRAMS\SlimeVR Server"
    ${Endif}

    ${If} $1 = 1
        CreateShortcut "$DESKTOP\SlimeVR Server.lnk" "$INSTDIR\SlimeVR.exe" ""
    ${Else}
        Delete "$DESKTOP\SlimeVR Server.lnk"
    ${EndIf}
    
    ${If} $2 = 1
        ExecShell "open" "https://docs.slimevr.dev/quick-setup.html#connecting-and-preparing-your-trackers"
    ${EndIf}

    ${If} $3 = 1
        Exec '"$WINDIR\explorer.exe" "$INSTDIR\SlimeVR.exe"'
    ${EndIf}

FunctionEnd

Function installerActionPre
    ${If} $SELECTED_INSTALLER_ACTION != ""
        Abort
    ${EndIf}
FunctionEnd

Function JREdetect
    IfFileExists "$INSTDIR\jre\release" 0 SEC_JRE_JAVAVERSIONELSE
        ${ConfigRead} "$INSTDIR\jre\release" "JAVA_RUNTIME_VERSION=" $R0
        ${If} $R0 == "$\"${JREVersion}$\""
            StrCpy $JREneedInstall "False"
        ${Else}
            StrCpy $JREneedInstall "True"
        ${EndIf}
        Goto SEC_JRE_JAVAVERSIONDONE
    SEC_JRE_JAVAVERSIONELSE:
        StrCpy $JREneedInstall "True"
    SEC_JRE_JAVAVERSIONDONE:
FunctionEnd

!insertmacro GetTime

Function DumpLog
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6

  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 exit
  FileOpen $5 $5 "w"
  StrCmp $5 "" exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd

Function un.startPageConfirm
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
      Abort
    ${EndIf}
    
    !insertmacro MUI_HEADER_TEXT $(MUI_UNTEXT_CONFIRM_TITLE) $(MUI_UNTEXT_CONFIRM_SUBTITLE)

    ${NSD_CreateLabel} 0 0 450 30 "$(^UninstallingText)"

    ${NSD_CreateLabel} 0 68 98 20 "$(^UninstallingSubText)"

    ${NSD_CreateText} 98 65 350 20 "$INSTDIR"
    Pop $0
    SendMessage $0 ${EM_SETREADONLY} 1 0

    ${NSD_CreateLabel} 0 90u 100% 10u '$SteamVRLabelTxt'
    Pop $SteamVRLabelID
    ${NSD_CreateLabel} 0 100u 100% 10u '$SlimeVRLabelTxt'
    Pop $SlimeVRLabelID

    Call un.UpdateLabelTimer
    GetFunctionAddress $0 un.UpdateLabelTimer
    nsDialogs::CreateTimer /NOUNLOAD $0 2000

    nsDialogs::Show
FunctionEnd

Function un.endPageunConfirm
    GetFunctionAddress $0 un.UpdateLabelTimer
    nsDialogs::KillTimer $0
FunctionEnd

Section "SlimeVR Server" SEC_SERVER
    SectionIn RO

    SetOutPath $INSTDIR

    !insertmacro dlFile "${SVRServerURLType}" "SlimeVR Server" "${SVRServerVersion}" "${SVRServerDLURL}" "${SVRServerDLFileZip}"

    CreateDirectory "${SLIMETEMP}\SlimeVR"
    !insertmacro unzipFile "SlimeVR Server" "${SVRServerVersion}" "${SLIMETEMP}\${SVRServerDLFileZip}" "${SLIMETEMP}\SlimeVR"

    DetailPrint "Copying SlimeVR Server to installation folder..."
    CopyFiles /SILENT "${SLIMETEMP}\SlimeVR\*" $INSTDIR

    ${If} $SELECTED_INSTALLER_ACTION == "update"
        IfFileExists "$LOCALAPPDATA\dev.slimevr.SlimeVR" 0 SEC_TAURI_DIRNOTFOUND
            RMDir /r "$LOCALAPPDATA\dev.slimevr.SlimeVR"
        SEC_TAURI_DIRNOTFOUND:
        
        IfFileExists "$APPDATA\dev.slimevr.SlimeVR\electron" 0 SEC_ELECTON_DIRNOTFOUND
            RMDir /r "$APPDATA\dev.slimevr.SlimeVR\electron"
        SEC_ELECTON_DIRNOTFOUND:
    ${EndIf}
    
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "Java JRE" SEC_JRE
    SectionIn RO

    !insertmacro dlFile "${JREURLType}" "Java JRE" "${JREVersion}" "${JREDLURL}" "${JREDLFileZip}"
    !insertmacro unzipFile "Java JRE" "${JREVersion}" "${SLIMETEMP}\${JREDLFileZip}" "${SLIMETEMP}\OpenJDK"

    IfFileExists "$INSTDIR\jre" 0 SEC_JRE_DIRNOTFOUND
        DetailPrint "Removing old Java JRE..."
        RMdir /r "$INSTDIR\jre"
        CreateDirectory "$INSTDIR\jre"
    SEC_JRE_DIRNOTFOUND:
    FindFirst $0 $1 "${SLIMETEMP}\OpenJDK\jdk-17.*-jre"
    loop:
        StrCmp $1 "" done
        CopyFiles /SILENT "${SLIMETEMP}\OpenJDK\$1\*" "$INSTDIR\jre"
        FindNext $0 $1
        Goto loop
    done:
    FindClose $0
SectionEnd

Section "SteamVR Driver" SEC_VRDRIVER
    SetOutPath $INSTDIR

    !insertmacro dlFile "${SVRDriverURLType}" "SteamVR Driver" "${SVRDriverVersion}" "${SVRDriverDLURL}" "${SVRDriverDLFileZip}"
    !insertmacro unzipFile "SteamVR Driver" "${SVRDriverVersion}" "${SLIMETEMP}\${SVRDriverDLFileZip}" "${SLIMETEMP}\slimevr-openvr-driver-win64"

    File "steamvr.ps1"
    File "steamcleanexternaldrivers.ps1"

    DetailPrint "Removing old external drivers in SteamVR Config..."

    ${DisableX64FSRedirection}
    CreateShortcut "$INSTDIR\steamcleanexternaldrivers.lnk" "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" '-ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\steamcleanexternaldrivers.ps1"' "$INSTDIR\steamcleanexternaldrivers.ps1" 0
    Exec "explorer.exe $INSTDIR\steamcleanexternaldrivers.lnk"
    Sleep 5000
    ${EnableX64FSRedirection}
    IfFileExists "$PUBLIC\Documents\SlimeVRUninstall_log.txt" 0 no_log
        FileOpen $1 "$PUBLIC\Documents\SlimeVRUninstall_log.txt" r
        FileRead $1 $2
        DetailPrint "$2"
        FileClose $1
        Delete "$PUBLIC\Documents\SlimeVRUninstall_log.txt"
    no_log:
    Delete "$INSTDIR\steamcleanexternaldrivers.lnk"
    Delete "$INSTDIR\steamcleanexternaldrivers.ps1"

    DetailPrint "Copying SteamVR Driver to SteamVR..."
    ${DisableX64FSRedirection}
    nsExec::ExecToLog '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "$INSTDIR\steamvr.ps1" -SteamPath "$STEAMDIR" -DriverPath "${SLIMETEMP}\slimevr-openvr-driver-win64\slimevr"' $0
    ${EnableX64FSRedirection}
    Pop $0
    ${If} $0 != 0
        nsDialogs::SelectFolderDialog "Specify a path to your SteamVR folder" "$STEAMDIR\steamapps\common\SteamVR"
        Pop $0
        ${If} $0 == "error"
            Abort "Failed to copy SlimeVR Driver."
        ${Endif}
        CopyFiles /SILENT "${SLIMETEMP}\slimevr-openvr-driver-win64\slimevr" "$0\drivers\slimevr"
    ${EndIf}
SectionEnd

Section "SlimeVR Feeder App" SEC_FEEDER_APP
    SetOutPath $INSTDIR

    !insertmacro dlFile "${SVRFeederURLType}" "SlimeVR Feeder App" "${SVRFeederVersion}" "${SVRFeederDLURL}" "${SVRFeederDLFileZip}"
    !insertmacro unzipFile "SlimeVR Feeder App" "${SVRFeederVersion}" "${SLIMETEMP}\${SVRFeederDLFileZip}" "${SLIMETEMP}"

    DetailPrint "Copying SlimeVR Feeder App..."
    CopyFiles /SILENT "${SLIMETEMP}\SlimeVR-Feeder-App-win64\*" "$INSTDIR\Feeder-App"

    DetailPrint "Installing SlimeVR Feeder App driver..."
    nsExec::ExecToLog '"$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" --install'
SectionEnd

Section "Microsoft Visual C++ Redistributable" SEC_MSVCPP
    SetOutPath $INSTDIR

    !insertmacro dlFile "${MVCURLType}" "Microsoft Visual C++ Redistributable" "${MVCVersion}" "${MVCDLURL}" "${MVCDLFileZip}"

    DetailPrint "Installing Microsoft Visual C++ Redistributable..."
    nsExec::ExecToLog '"${SLIMETEMP}\vc_redist.x64.exe" /install /passive /norestart' $0
    Pop $0
    ${If} $0 == 0
        DetailPrint "Microsoft Visual C++ Redistributable installed successfully."
    ${ElseIf} $0 == 3010
        DetailPrint "Microsoft Visual C++ Redistributable installed successfully, but a reboot is required."
        SetRebootFlag true
    ${ElseIf} $0 == 1602
        Abort "User canceled the Microsoft Visual C++ Redistributable installation."
    ${ElseIf} $0 == 1603
        Abort "Fatal error during Microsoft Visual C++ Redistributable installation."
    ${ElseIf} $0 == 1618
        Abort "Installation aborted: Another installation is in progress."
    ${ElseIf} $0 == 1638
        DetailPrint "Microsoft Visual C++ Redistributable is already installed or a newer version is present."
    ${ElseIf} $0 == 1641
        DetailPrint "Microsoft Visual C++ Redistributable installed successfully, and a system restart is happening."
    ${ElseIf} $0 == 5100
        Abort "Installation failed: Unsupported operating system."
    ${Else}
        Abort "Microsoft Visual C++ Redistributable installation failed with unknown error code: $0"
    ${EndIf}
SectionEnd

SectionGroup /e "USB drivers" SEC_USBDRIVERS

    Section "CP210x driver" SEC_CP210X
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CP201x"
        DetailPrint "Installing CP210x driver..."
        File /r "../web/CP201x\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CP201x\silabser.inf"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "Success!"
        ${ElseIf} $0 == 259
            DetailPrint "No devices match the supplied driver or the target device is already using a better or newer driver than the driver specified for installation."
        ${ElseIf} $0 == 3010
            DetailPrint "The requested operation completed successfully and a system reboot is required."
        ${Else}
            Abort "Failed to install CP210x driver. Error code: $0."
        ${Endif}
    SectionEnd

    Section "CH340 driver" SEC_CH340
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CH341SER"
        DetailPrint "Installing CH340 driver..."
        File /r "../web/CH341SER\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CH341SER\CH341SER.INF"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "Success!"
        ${ElseIf} $0 == 259
            DetailPrint "No devices match the supplied driver or the target device is already using a better or newer driver than the driver specified for installation."
        ${ElseIf} $0 == 3010
            DetailPrint "The requested operation completed successfully and a system reboot is required."
        ${Else}
            Abort "Failed to install CH340 driver. Error code: $0."
        ${Endif}
    SectionEnd

    Section /o "CH9102x driver" SEC_CH9102X
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CH343SER"
        DetailPrint "Installing CH910x driver..."
        File /r "../web/CH343SER\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CH343SER\CH343SER.INF"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "Success!"
        ${ElseIf} $0 == 259
            DetailPrint "No devices match the supplied driver or the target device is already using a better or newer driver than the driver specified for installation."
        ${ElseIf} $0 == 3010
            DetailPrint "The requested operation completed successfully and a system reboot is required."
        ${Else}
            Abort "Failed to install CH910x driver. Error code: $0."
        ${Endif}
    SectionEnd

SectionGroupEnd

Section "-" SEC_FIREWALL
    ${If} $SELECTED_INSTALLER_ACTION == "repair"
        ${OrIf} $SELECTED_INSTALLER_ACTION == "update"
        DetailPrint "Removing SlimeVR Server from firewall exceptions...."
        nsExec::ExecToLog '"$INSTDIR\firewall_uninstall.bat"'
    ${Endif}

    DetailPrint "Adding SlimeVR Server to firewall exceptions...."
    nsExec::ExecToLog '"$INSTDIR\firewall.bat"'
SectionEnd

Section "-" SEC_REGISTERAPP
    DetailPrint "Registering installation..."
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "DisplayName" "SlimeVR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "DisplayIcon" "$INSTDIR\SlimeVR.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "HelpLink" "https://docs.slimevr.dev/"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "URLInfoAbout" "https://slimevr.dev/"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "URLUpdateInfo" "https://github.com/SlimeVR/SlimeVR-Installer/releases"
SectionEnd

Section
    AccessControl::GrantOnFile $INSTDIR "(BU)" "FullAccess"
    Pop $0

    ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "InstallDate" "$2$1$0"

    StrCpy $0 "$INSTDIR\install.log"
    Push $0
    Call DumpLog
SectionEnd

Function componentsPre
    Call JREdetect
    ${If} $SELECTED_INSTALLER_ACTION == "update"
        SectionSetFlags ${SEC_FIREWALL} ${SF_SELECTED}
        SectionSetFlags ${SEC_REGISTERAPP} 0
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}
        SectionSetFlags ${SEC_USBDRIVERS} ${SF_SECGRP}
        SectionSetFlags ${SEC_SERVER} ${SF_SELECTED}
    ${EndIf}
    ${If} $STEAMDIR == ""
        MessageBox MB_OK $(DESC_STEAM_NOTFOUND)
        SectionSetFlags ${SEC_VRDRIVER} ${SF_USELECTED}|${SF_RO}
        SectionSetFlags ${SEC_FEEDER_APP} ${SF_USELECTED}|${SF_RO}
        SectionSetFlags ${SEC_MSVCPP} ${SF_USELECTED}|${SF_RO}
    ${Else}
        SectionSetFlags ${SEC_VRDRIVER} ${SF_SELECTED}
        SectionSetFlags ${SEC_FEEDER_APP} ${SF_SELECTED}
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}|${SF_RO}
    ${EndIf}

    ${If} $JREneedInstall == "True"
        SectionSetFlags ${SEC_JRE} ${SF_SELECTED}|${SF_RO}
    ${ElseIf} $SELECTED_INSTALLER_ACTION == "repair"
        SectionSetFlags ${SEC_JRE} ${SF_SELECTED}
    ${Else}        
        SectionSetFlags ${SEC_JRE} ${SF_USELECTED}
    ${EndIf}

FunctionEnd

Function .onSelChange
    SectionGetFlags ${SEC_VRDRIVER} $0
    IntOp $0 $0 & ${SF_SELECTED}
    SectionGetFlags ${SEC_FEEDER_APP} $1
    IntOp $1 $1 & ${SF_SELECTED}
    IntOp $0 $0 | $1
    ${If} $0 == ${SF_SELECTED}
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}|${SF_RO}
    ${Else}
        SectionSetFlags ${SEC_MSVCPP} ${SF_USELECTED}|${SF_RO}
    ${EndIf}
FunctionEnd

Section "-un.SlimeVR Server" un.SEC_SERVER
    RMdir /r "$SMPROGRAMS\SlimeVR Server"
    Delete "$SMPROGRAMS\Uninstall SlimeVR Server.lnk"
    Delete "$SMPROGRAMS\SlimeVR Server.lnk"
    Delete "$DESKTOP\SlimeVR Server.lnk"
    RMDir /r "$LOCALAPPDATA\dev.slimevr.SlimeVR"
    RMDir /r "$APPDATA\dev.slimevr.SlimeVR\electron"
    ClearErrors
    RMDir /r $INSTDIR

    IfErrors fail success
    fail:
        Abort "Failed to remove SlimeVR Server files. Make sure SlimeVR Server is closed."
    success:
SectionEnd

Section "-un.SteamVR Driver" un.SEC_VRDRIVER
    ${DisableX64FSRedirection}
    nsExec::ExecToLog '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "$INSTDIR\steamvr.ps1" -SteamPath "$STEAMDIR" -DriverPath "slimevr" -Uninstall' $0
    ${EnableX64FSRedirection}
    Pop $0
    ${If} $0 != 0
        DetailPrint "Failed to remove SteamVR Driver."
    ${EndIf}
    Delete "$INSTDIR\steamvr.ps1"
SectionEnd

Section "-un.SlimeVR Feeder App" un.SEC_FEEDER_APP
    IfFileExists "$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" found not_found
    found:
        DetailPrint "Unregistering SlimeVR Feeder App driver..."
        nsExec::ExecToLog '"$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" --uninstall'
        DetailPrint "Removing SlimeVR Feeder App..."
        RMdir /r "$INSTDIR\Feeder-App"
    not_found:
SectionEnd

Section "-un." un.SEC_FIREWALL
    DetailPrint "Removing SlimeVR Server from firewall exceptions...."
    nsExec::Exec '"$INSTDIR\firewall_uninstall.bat"'
    Pop $0
    Delete "$INSTDIR\firewall*.bat"
SectionEnd

Section "-un." un.SEC_POST_UNINSTALL
    DetailPrint "Unregistering installation..."
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR"
    Delete "$INSTDIR\uninstall.exe"
    RMDir $INSTDIR
    DetailPrint "Done."
SectionEnd

LangString DESC_SEC_SERVER ${LANG_ENGLISH} "Installs SlimeVR Server v19.0.0 (bundled)."
LangString DESC_SEC_JRE ${LANG_ENGLISH} "Copies bundled Java JRE 17.0.18+8. Required for SlimeVR Server."
LangString DESC_SEC_VRDRIVER ${LANG_ENGLISH} "Installs bundled SteamVR Driver v4.0.0 for SlimeVR."
LangString DESC_SEC_USBDRIVERS ${LANG_ENGLISH} "USB drivers for various boards."
LangString DESC_SEC_FEEDER_APP ${LANG_ENGLISH} "Installs bundled SlimeVR Feeder App v0.2.15."
LangString DESC_SEC_MSVCPP ${LANG_ENGLISH} "Installs bundled Microsoft Visual C++ Redistributable."
LangString DESC_SEC_CP210X ${LANG_ENGLISH} "CP210X USB driver (NodeMCU v2, Wemos D1 Mini)."
LangString DESC_SEC_CH340 ${LANG_ENGLISH} "CH340 USB driver (NodeMCU v3, SlimeVR, Wemos D1 Mini)."
LangString DESC_SEC_CH9102x ${LANG_ENGLISH} "CH9102x USB driver (NodeMCU v2.1)."
LangString DESC_STEAM_NOTFOUND ${LANG_ENGLISH} "No Steam installation detected. Steam and SteamVR required for SteamVR Driver."
LangString DESC_STEAMVR_RUNNING ${LANG_ENGLISH} "SteamVR is running! Please close SteamVR."
LangString DESC_SLIMEVR_RUNNING ${LANG_ENGLISH} "SlimeVR is running! Please close SlimeVR."
LangString DESC_PROCESS_ERROR ${LANG_ENGLISH} "Error looking for $0"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SERVER} $(DESC_SEC_SERVER)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_JRE} $(DESC_SEC_JRE)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_VRDRIVER} $(DESC_SEC_VRDRIVER)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_FEEDER_APP} $(DESC_SEC_FEEDER_APP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MSVCPP} $(DESC_SEC_MSVCPP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_USBDRIVERS} $(DESC_SEC_USBDRIVERS)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CP210X} $(DESC_SEC_CP210X)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CH340} $(DESC_SEC_CH340)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CH9102x} $(DESC_SEC_CH9102x)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
