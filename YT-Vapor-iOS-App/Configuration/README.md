# Environment Configuration

This directory contains environment-specific configuration files that keep sensitive data out of version control.

## Files

### `AppConfiguration.swift`
The configuration loader that reads settings from `Config.plist` at runtime.

### `Config.plist` (gitignored)
Your **local environment configuration** with actual server URLs and settings.
- ✅ Contains your real backend server URL
- ✅ Contains HTTP exception domains for your server
- ⚠️ **Gitignored** - never committed to version control
- ⚠️ **Must be added to Xcode project** to be bundled with the app

### `Config.plist.template` (committed)
A **safe template** with placeholder values for other developers.
- ✅ Committed to git
- ✅ Contains safe localhost defaults
- ✅ Includes instructions for setup

### `Info.plist` (gitignored)
Your **local Info.plist** with environment-specific App Transport Security settings.
- ⚠️ **Gitignored** - never committed to version control
- ⚠️ **Must be added to Xcode project** as the app's Info.plist

### `Info.plist.template` (committed)
A **safe template** Info.plist for other developers.
- ✅ Committed to git
- ✅ Contains safe localhost defaults

## Setup Instructions

### For First-Time Setup (You've already done this!)

1. ✅ `Config.plist` created with your test server settings
2. ✅ `Info.plist` already exists with your test server domain
3. **Next step:** Add files to Xcode project (see below)

### For Other Developers Cloning This Repo

1. Copy the template files:
   ```bash
   cp Configuration/Config.plist.template Configuration/Config.plist
   cp Info.plist.template Info.plist
   ```

2. Edit `Config.plist` with your backend URL:
   ```xml
   <key>API_BASE_URL</key>
   <string>http://your-server-ip:8080/</string>
   ```

3. Edit `Info.plist` to add your server domain to HTTP exceptions

4. Add `Config.plist` and `Info.plist` to the Xcode project

## Adding Files to Xcode Project

You need to add these files to your Xcode project:

1. Open `YT-Vapor-iOS-App.xcodeproj` in Xcode
2. Right-click on the `YT-Vapor-iOS-App` folder
3. Select **Add Files to "YT-Vapor-iOS-App"...**
4. Navigate to `Configuration/` and select:
   - `AppConfiguration.swift`
   - `Config.plist`
   - `Config.plist.template`
5. Make sure **"Copy items if needed"** is **unchecked** (we want references)
6. Make sure **"Add to targets: YT-Vapor-iOS-App"** is **checked**
7. Click **Add**

8. Also add `Info.plist.template` to the project root (but NOT as the target's Info.plist)

9. Configure `Info.plist` as the target's Info.plist:
   - Select the `YT-Vapor-iOS-App` target
   - Go to **Build Settings**
   - Search for "Info.plist"
   - Set **Info.plist File** to: `YT-Vapor-iOS-App/Info.plist`

## How It Works

1. **At compile time:** Xcode bundles `Config.plist` into the app
2. **At runtime:** `AppConfiguration.shared` loads settings from `Config.plist`
3. **In code:** `APIEndpoint` uses `AppConfiguration.shared.apiBaseURL`
4. **Git safety:** `Config.plist` and `Info.plist` are gitignored - sensitive data never gets committed

## Benefits

✅ **No sensitive data in git** - Your test server IPs stay private
✅ **Easy environment switching** - Just edit `Config.plist` locally
✅ **Team-friendly** - Each developer can use their own backend URL
✅ **Template-based** - New developers copy the template and customize

## Usage Example

```swift
// Old way (hardcoded, committed to git):
let url = "http://13.49.142.169:8080/" // ⚠️ Sensitive!

// New way (loaded from Config.plist, gitignored):
let url = AppConfiguration.shared.apiBaseURL // ✅ Safe!
```

## Troubleshooting

### "Config.plist not found!" crash
- Make sure `Config.plist` exists in the `Configuration/` directory
- Make sure `Config.plist` is added to the Xcode project target
- Make sure "Copy Bundle Resources" includes `Config.plist`

### Changes not reflected in app
- Clean build folder: **Product > Clean Build Folder** (Cmd+Shift+K)
- Delete app from simulator/device and reinstall
