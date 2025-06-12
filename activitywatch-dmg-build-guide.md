# ActivityWatch DMG Build Process Guide

## Overview

ActivityWatch uses a multi-step process to build a macOS DMG installer:

1. **Python Packaging**: Uses PyInstaller to bundle Python code into a macOS app
2. **Icon Creation**: Converts PNG logo to macOS ICNS format
3. **App Bundle**: Creates ActivityWatch.app with all modules
4. **DMG Creation**: Uses dmgbuild to create the installer DMG

## Build Process Step-by-Step

### 1. Prerequisites

```bash
# Install Python dependencies
pip install pyinstaller dmgbuild

# Install Rust (for aw-server-rust)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clone with submodules
git clone --recursive https://github.com/ActivityWatch/activitywatch.git
cd activitywatch
```

### 2. Build All Modules

```bash
# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Build all components
make build

# Or build with extras (aw-notify, aw-watcher-input)
AW_EXTRAS=true make build
```

This builds:
- aw-core (core library)
- aw-client (client library)
- aw-server (Python server)
- aw-server-rust (Rust server)
- aw-qt (Qt GUI)
- aw-watcher-afk (AFK tracker)
- aw-watcher-window (window tracker)
- aw-notify (notifications - if AW_EXTRAS=true)
- aw-watcher-input (input tracker - if AW_EXTRAS=true)

### 3. Create macOS Icon

```bash
# Convert PNG logo to ICNS format
make aw-qt/media/logo/logo.icns
```

This uses macOS's `sips` and `iconutil` commands to create all required icon sizes.

### 4. Build App Bundle

```bash
# Create ActivityWatch.app using PyInstaller
make dist/ActivityWatch.app
```

This runs PyInstaller with the `aw.spec` configuration which:
- Bundles all Python modules
- Includes all watchers and the server
- Creates a macOS app bundle structure
- Sets up entitlements for code signing

### 5. Create DMG

```bash
# Build the DMG installer
make dist/ActivityWatch.dmg
```

This uses dmgbuild to:
- Create a DMG with custom background
- Add the app and Applications folder symlink
- Set custom icon positions
- Configure window appearance

## The Key Files

### `aw.spec` (PyInstaller Configuration)
- Defines how to bundle each module
- Sets up Analysis for each component
- Configures code signing with entitlements
- Handles platform-specific settings

### `Makefile`
- Orchestrates the entire build process
- Handles module dependencies
- Creates icons and DMG

### `scripts/package/dmgbuild-settings.py`
- DMG appearance configuration
- Icon positioning
- Window size and layout

## Build Commands Summary

```bash
# Full build from scratch
git clone --recursive https://github.com/ActivityWatch/activitywatch.git
cd activitywatch
python3 -m venv venv
source venv/bin/activate
pip install pyinstaller dmgbuild

# Build everything and create DMG
make build
make dist/ActivityWatch.dmg

# Or in one command (if you have all dependencies)
make dist/ActivityWatch.dmg
```

## Code Signing (for Distribution)

For official releases, the app is code signed:

```bash
# Set your Apple Developer ID
export APPLE_PERSONALID="Developer ID Application: Your Name (XXXXXXXXXX)"

# Build with signing
make dist/ActivityWatch.dmg

# Notarize for Gatekeeper
make dist/notarize
```

## Customization

### Including Additional Modules

Edit the Makefile:
```makefile
# Add to SUBMODULES
SUBMODULES := ... aw-your-module

# Or use AW_EXTRAS
AW_EXTRAS=true make build
```

### Changing DMG Appearance

Edit `scripts/package/dmgbuild-settings.py`:
- Icon positions
- Window size
- Background image
- View settings

### Platform-Specific Builds

The build system automatically detects the platform:
- macOS: Creates .app and .dmg
- Linux: Creates AppImage
- Windows: Creates .exe installer

## Troubleshooting

### Common Issues

1. **Rust not found**
   ```bash
   SKIP_SERVER_RUST=true make build
   ```

2. **Module missing from app**
   - Check if module is in SUBMODULES
   - Verify it has a proper __main__.py

3. **Code signing fails**
   - Ensure APPLE_PERSONALID is set
   - Check developer certificate is valid

4. **DMG creation fails**
   ```bash
   pip install --upgrade dmgbuild
   ```

## The Final Structure

```
ActivityWatch.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   ├── aw-qt (main executable)
│   │   ├── aw-server
│   │   ├── aw-server-rust
│   │   ├── aw-watcher-afk
│   │   ├── aw-watcher-window
│   │   ├── aw-notify (if included)
│   │   └── aw-watcher-input (if included)
│   └── Resources/
│       └── logo.icns
```

The DMG contains:
- ActivityWatch.app
- Symlink to /Applications
- Custom background and layout