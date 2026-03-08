# Tasbeeh App — Xcode Setup

## Files
- `Tasbeeh/TasbeehApp.swift`
- `Tasbeeh/ContentView.swift`
- `Tasbeeh/VolumeCounter.swift`
- `Tasbeeh/HapticManager.swift`
- `Tasbeeh/Info.plist`

## Steps

### 1. Create Xcode project
- Open Xcode → File → New → Project
- Choose **iOS → App**
- Product Name: `Tasbeeh`
- Interface: **SwiftUI**, Language: **Swift**
- Save anywhere (you'll replace the files)

### 2. Replace generated files
Delete the generated `ContentView.swift` and `TasbeehApp.swift`, then drag all 5 files from `~/tasbeeh-app/Tasbeeh/` into the Xcode project navigator.
- When adding, check **"Copy items if needed"** and **"Add to target: Tasbeeh"**

### 3. Set custom Info.plist
- Click the project root in the navigator → select the **Tasbeeh** target → **Build Settings**
- Search for `Info.plist File` → set value to `Tasbeeh/Info.plist`
- OR: In **Signing & Capabilities** tab, under **Background Modes**, enable **Audio, AirPlay, and Picture in Picture**

### 4. Add MediaPlayer framework
- Target → **Build Phases** → **Link Binary With Libraries** → `+` → search `MediaPlayer` → Add

### 5. Set deployment target
- Target → **General** → Minimum Deployments: **iOS 16.0**

### 6. Build & Run on a real device
Volume button detection does NOT work in the Simulator. You need a physical iPhone.

## How it works
- Volume buttons are detected via KVO on `AVAudioSession.outputVolume`
- A silent AVAudioEngine loop keeps the session alive in the background (pocket use)
- Volume is immediately reset to 0.5 via a hidden `MPVolumeView` slider so you never run out of range
- **At 33**: single vibration (works with screen locked)
- **At 100**: double vibration + auto-reset to 0 (works with screen locked)
- **Counting** works whether screen is on or off
