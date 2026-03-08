# Tasbeeh App

## Project Overview
iOS prayer counter (tasbeeh) app built with SwiftUI. Counts dhikr using **volume buttons only** (no screen tap counting). Works in background with screen locked via silent audio engine.

## Tech Stack
- **Language**: Swift 5.9
- **UI**: SwiftUI (iOS 16.0+)
- **Build**: XcodeGen (`project.yml` -> `Tasbeeh.xcodeproj`)
- **Persistence**: UserDefaults (shared App Group) + NSUbiquitousKeyValueStore (iCloud)
- **Frameworks**: MediaPlayer, AVFoundation, AudioToolbox, WidgetKit
- **No third-party dependencies**

## Project Structure
```
tasbeeh-app/
  project.yml                 # XcodeGen project definition (source of truth for xcodeproj)
  CLAUDE.md                   # This file — project docs for AI assistants
  SETUP.md                    # Manual Xcode setup instructions
  .gitignore                  # Git ignore rules
  Tasbeeh/                    # Main app target
    TasbeehApp.swift          # App entry point, injects AppState
    ContentView.swift         # Main counter UI (ring, count, milestones, presets)
    VolumeCounter.swift       # Volume button detection via KVO + silent audio engine
    Models/
      DhikrPreset.swift       # Preset model, phases, built-in presets (5 defaults)
      AppState.swift           # Central ObservableObject: settings, counters, persistence, iCloud sync
    Services/
      HapticManager.swift     # Haptic feedback with configurable intensity (off/light/medium/heavy)
      SoundManager.swift      # Click sound for counting (system tock sound 1105)
    Views/
      SettingsView.swift      # Settings sheet (haptics, sound, stats, sync)
      PresetsView.swift       # Dhikr preset picker + custom preset creation
      HistoryView.swift       # Daily streak calendar with heat-map coloring
    Assets.xcassets/          # App icon + asset catalog
    Tasbeeh.entitlements      # App Groups + iCloud/CloudKit entitlements
    Info.plist                # Background audio mode, portrait only
  TasbeehWidget/              # Widget extension target
    TasbeehWidgetBundle.swift # Widget bundle entry point
    TasbeehWidget.swift       # TimelineProvider + small/medium widget views
    TasbeehWidget.entitlements # App Groups entitlement
    Info.plist                # Widget extension config
  TasbeehTests/               # Unit tests (42 tests)
    DhikrPresetTests.swift    # Preset model, phases, milestones, encoding
    AppStateTests.swift       # Persistence, defaults, counting, streak, preset management
    CounterLogicTests.swift   # Phase transitions, target detection, haptic intensity
```

## Build & Run
```bash
# Regenerate Xcode project from project.yml
xcodegen generate

# Build main app
xcodebuild build -scheme Tasbeeh -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Build widget
xcodebuild build -scheme TasbeehWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run tests (42 tests)
xcodebuild test -scheme TasbeehTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

**Volume button detection requires a physical device** -- it does NOT work in the Simulator.

## Architecture Decisions

### Persistence: UserDefaults + JSON (no CoreData)
- All data fits in UserDefaults (~50KB max even after years of use)
- History: JSON-encoded `[String: Int]` dictionary (date string "yyyy-MM-dd" -> count)
- Presets: JSON-encoded `[DhikrPreset]` array
- Chosen over CoreData/SwiftData for zero migration complexity and lightweight footprint

### iCloud Sync: NSUbiquitousKeyValueStore
- 1MB limit is plenty for all app data
- Merge strategy: take the higher value for counts, last-write-wins for settings
- Observes `didChangeExternallyNotification` for remote changes
- No CloudKit dashboard setup needed for basic key-value sync

### App Group: `group.com.alliance.tasbeeh`
- Shared UserDefaults between main app and widget extension
- Widget reads todayCount, lifetimeCount, currentStreak from shared suite
- Main app calls `WidgetCenter.shared.reloadAllTimelines()` on count changes

### Volume Button Detection
- KVO on `AVAudioSession.outputVolume` detects volume changes
- Silent `AVAudioEngine` loop keeps audio session alive in background
- Hidden `MPVolumeView` slider resets system volume to 0.5 when near edges (0.15/0.85)
- `isAwaitingResetKVO` flag prevents counting the reset-triggered KVO callback
- Audio interruption handler restarts engine after phone calls/Siri

### No Tap Counting
The app intentionally only counts via volume buttons. **Do not add tap gestures for counting.**

## Key Patterns

### AppState (Single Source of Truth)
- `AppState.shared` singleton, injected as `@ObservedObject` into views
- All `@Published` properties auto-persist via `didSet` hooks
- `init(defaults:)` accepts custom UserDefaults for testing
- Day rollover logic: saves previous day's count to history, resets todayCount

### DhikrPreset (Preset System)
- 5 built-in presets with fixed UUIDs (survive re-encoding)
- Multi-phase support: Standard Tasbeeh = 33 SubhanAllah + 33 Alhamdulillah + 33 Allahu Akbar + 1 La ilaha illallah
- `currentPhase(for:)` determines which phase text to show at any count
- `milestoneIndices()` returns phase transition points (e.g., [33, 66, 99])
- Custom presets: user-created, single-phase, deletable

### VolumeCounter (Counting Engine)
- Accepts `AppState` dependency (defaults to `.shared`)
- `handleButtonPress()`: increments count, records to AppState, checks milestones/target, triggers haptics
- Prevents screen auto-lock via `isIdleTimerDisabled = true`
- Handles audio session interruptions (phone calls) by restarting engine

### Widget
- `StaticConfiguration` with `TasbeehProvider`
- Supports `.systemSmall` (today count + streak) and `.systemMedium` (+ lifetime)
- Refreshes at midnight for day rollover
- Uses `widgetBackground()` modifier for iOS 17+ `containerBackground` compatibility

## Testing Strategy
- **42 unit tests** across 3 test files
- Tests use isolated `UserDefaults(suiteName: "com.alliance.tasbeeh.tests")` -- no real data pollution
- DhikrPresetTests: preset validation, phase calculation, milestone detection, Codable round-trip
- AppStateTests: defaults, counting, persistence, preset CRUD, date helpers
- CounterLogicTests: phase progression, boundary detection, haptic intensity, custom presets
- Volume button detection is NOT unit-testable (requires physical device + KVO)

## Default Behavior (Zero Config)
The app works immediately on launch with no setup:
- **Default preset**: Standard Tasbeeh (33+33+33+1 = 100)
- **Default haptics**: Medium intensity
- **Default sound**: Off
- **Default iCloud sync**: On
- Settings are tucked behind a subtle gear icon -- power users can customize

## Features
1. **Volume button counting** -- works with screen locked, in pocket
2. **5 built-in dhikr presets** + custom preset creation
3. **Persistent lifetime count** across sessions
4. **Daily count tracking** with automatic day rollover
5. **Streak tracking** (consecutive days of use)
6. **Session lap counter** (rounds completed since app open)
7. **Configurable haptic intensity** (off/light/medium/heavy)
8. **Optional count sound** (system tock)
9. **iOS widget** (small + medium, shows today/lifetime/streak)
10. **iCloud sync** across devices via NSUbiquitousKeyValueStore
11. **History calendar** with heat-map visualization

## Before Submitting to App Store
- [ ] Set `DEVELOPMENT_TEAM` in `project.yml` and regenerate
- [ ] Add 1024x1024 app icon to `Assets.xcassets/AppIcon.appiconset/`
- [ ] Create App Group (`group.com.alliance.tasbeeh`) in Apple Developer portal
- [ ] Create CloudKit container (`iCloud.com.alliance.tasbeeh`) in Apple Developer portal
- [ ] Add privacy manifest (`PrivacyInfo.xcprivacy`) if required
- [ ] Test on physical device: volume counting, background mode, lock screen haptics
- [ ] Test widget on home screen (small + medium sizes)
- [ ] Test iCloud sync between two devices
- [ ] Screenshot automation for App Store listing
- [ ] Write App Store description and metadata
- [ ] Set up App Store Connect listing
