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

### Documentation

- Garmin Connect IQ API docs: `https://developer.garmin.com/connect-iq/api-docs/`

### Partial update guidance

- Avoid reading ConnectIQ settings/properties inside `onPartialUpdate()`.
- Cache any settings needed by partial updates during normal `onUpdate()` work instead.

### Device-specific resources

- Use device-specific resource folders for bespoke layouts and assets when screen sizes differ.
- `resources-instinct2s/` is the dedicated override folder for Instinct 2S-specific layouts/backgrounds.
- Garmin auto-detects device-specific folders like `resources-instinct2s`, so do not duplicate them with extra `*.resourcePath` entries in `monkey.jungle` unless there is a specific reason.
- Connect IQ screen sizes currently in use here:
  - `instinct2`: `176x176`
  - `instinct3solar45mm`: `176x176`
  - `instinct2s`: `163x156`
- For layout work, treat the Instinct 2S main screen area as `156x156`.
- The SDK reports Instinct 2S as `163x156` because the inset window in the upper-right extends `7px` farther to the right than the main screen area.
