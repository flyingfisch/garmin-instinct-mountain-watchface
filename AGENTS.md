# AGENTS.md

This repo contains a ConnectIQ Garmin watchface built with the Garmin SDK and MonkeyC.

## Building

### Build files

- Jungle file: `monkey.jungle`
- Manifest: `manifest.xml`

### Supported target

- `instinct2`

### Build outputs

- Debug/device build: `build/mountain-watchface.prg`
- Store upload package: `build/mountain-watchface.iq`

### Required local configuration

Local machine-specific paths are stored in an untracked file:

- `AGENTS.local.md`

### Standard build commands

Debug build:

```powershell
& '<MONKEYC_BIN>' -f monkey.jungle -d instinct2 -o build\mountain-watchface.prg -y '<GARMIN_DEVELOPER_KEY>' -w
```
