# AGENTS.md

This repo contains a ConnectIQ Garmin watchface built with the Garmin SDK and MonkeyC.

## Building

### Build files

- Jungle file: `monkey.jungle`
- Manifest: `manifest.xml`

### Supported target

- `instinct2`

### Build outputs

- Debug/device build: `bin/garmininstinctmountainwatchface.prg`
- Store upload package: `bin/garmininstinctmountainwatchface.iq`

### Required local configuration

Local machine-specific paths are stored in an untracked file:

- `AGENTS.local.md`

### Standard build commands

Debug build:

```powershell
& '<MONKEYC_BIN>' -f monkey.jungle -d instinct2 -o bin\garmininstinctmountainwatchface.prg -y '<GARMIN_DEVELOPER_KEY>' -w
```

### Partial update guidance

- Avoid reading ConnectIQ settings/properties inside `onPartialUpdate()`.
- Cache any settings needed by partial updates during normal `onUpdate()` work instead.
