# SlimeVR Offline Installer

This is an offline version of the SlimeVR installer. All components are bundled, no internet required during installation.

## Assets Required

Download these files to `windows/offline/assets/`:

1. **VC++ Redist** (latest): https://aka.ms/vc14/vc_redist.x64.exe → `vc_redist.x64.exe`
2. **Java JRE 17.0.17+10**: https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.17%2B10/OpenJDK17U-jre_x64_windows_hotspot_17.0.17_10.zip → `OpenJDK17U-jre_x64_windows_hotspot_17.0.17_10.zip`
3. **SlimeVR Server** (latest): https://github.com/SlimeVR/SlimeVR-Server/releases/latest/download/SlimeVR-win64.zip → `SlimeVR-Server-latest.zip`
4. **OpenVR Driver** (latest): https://github.com/SlimeVR/SlimeVR-OpenVR-Driver/releases/latest/download/slimevr-openvr-driver-win64.zip → `slimevr-openvr-driver-win64.zip`
5. **Feeder App** (latest): https://github.com/SlimeVR/SlimeVR-Feeder-App/releases/latest/download/SlimeVR-Feeder-App-win64.zip → `SlimeVR-Feeder-App-latest.zip`

## Build

Update flake.nix to support offline:

```
nix build .#installer-offline
```

Installer ~500MB.

## Test

Run the exe, ensure offline network disabled, verify installs without errors.
