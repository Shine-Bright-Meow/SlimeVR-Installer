# SlimeVR Offline Installer

## Overview
Offline version bundles all dependencies (Server v19.0.0, Driver v4.0.0, Feeder v0.2.15, JRE 17.0.18+8, VC++ latest, USB drivers). No internet needed at install time.

## Build (Nix)
```
nix build .#installer-offline
```
(Requires flake.nix update for assets download.)

## Manual build (NSIS)
1. Download assets to `windows/offline/assets/`:
   - VC++: https://aka.ms/vs/17/release/vc_redist.x64.exe → vc_redist.x64.exe
   - JRE: https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.18%2B8/OpenJDK17U-jre_x64_windows_hotspot_17.0.18_8.zip
   - Server: https://github.com/SlimeVR/SlimeVR-Server/releases/download/v19.0.0/SlimeVR-win64.zip → SlimeVR-win64.zip
   - Driver: https://github.com/SlimeVR/SlimeVR-OpenVR-Driver/releases/download/v4.0.0/slimevr-openvr-driver-win64.zip
   - Feeder: https://github.com/SlimeVR/SlimeVR-Feeder-App/releases/download/v0.2.15/SlimeVR-Feeder-App-win64.zip → SlimeVR-Feeder-App-win64.zip
2. `makensis windows/offline/slimevr_offline_installer.nsi` → slimevr_offline_installer.exe (~500MB)

## Differences from Web
- `*URLType = "local"` → File /oname extracts bundled.
- No NScurl downloads.
- Drivers shared from web/.

Tested NSIS syntax. Run to verify.
