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
      DhikrPhrase.swift       # Common dhikr library (~12 phrases with Arabic, transliteration, meaning)
      DhikrPreset.swift       # Preset model, phases, built-in presets (5 defaults) + quick counter
      AppState.swift           # Central ObservableObject: settings, counters, stats, persistence, iCloud sync
    Services/
      HapticManager.swift     # Haptic feedback with configurable intensity (off/light/medium/heavy)
      SoundManager.swift      # Click sound for counting (system tock sound 1105)
    Theme.swift               # Color system: TasbeehTheme(for: colorScheme), all design tokens
    Views/
      SettingsView.swift      # Settings sheet (haptics, sound, appearance, sync)
      PresetsView.swift       # Dhikr preset picker + library-based preset creation
      DhikrPickerView.swift   # Half-sheet phrase picker from common dhikr library
      TargetPickerView.swift  # Quick count selector (33, 100, 200, 500, 1000, custom)
      StatsView.swift         # Comprehensive stats dashboard (streak, records, weekly chart, calendar)
      HistoryView.swift       # Legacy calendar heatmap (now integrated into StatsView)
      BenefitsView.swift      # Benefits of Dhikr — Quran verses + Hadith with source links
    Assets.xcassets/          # App icon + asset catalog
    Tasbeeh.entitlements      # App Groups + iCloud/CloudKit entitlements
    Info.plist                # Background audio mode, portrait only
  TasbeehWidget/              # Widget extension target
    TasbeehWidgetBundle.swift # Widget bundle entry point
    TasbeehWidget.swift       # TimelineProvider + small/medium widget views
    TasbeehWidget.entitlements # App Groups entitlement
    Info.plist                # Widget extension config
  designs/
    DESIGN.md                 # Design 13 spec (lilac-blue theme, ring, flat surfaces)
  logos/                      # App icon source + pre-rendered sizes
  TasbeehTests/               # Unit tests (83 tests)
    DhikrPresetTests.swift    # Preset model, phases, milestones, encoding, quick counter, DhikrPhrase library
    AppStateTests.swift       # Persistence, defaults, counting, streak, best streak/day, computed stats, preset management
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

# Run tests (83 tests)
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
- Tracks `bestStreak`, `bestDayCount`, `bestDayDate` (persisted, auto-updated)
- Computed stats: `daysActive`, `dailyAverage`, `thisWeekCount`, `thisMonthCount`, `last7DaysData()`, `last30DaysData()`
- Quick counter management: `updateQuickCounter(arabicText:transliteration:targetCount:)`

### Quick Counter (Default Experience)
- Simple counter backed by a special `DhikrPreset` with `isQuickCounter: true` and fixed UUID `00000000...0000`
- Default on fresh install: SubhanAllah, 33 count
- Tap Arabic text → `DhikrPickerView` (choose from 12 common dhikr phrases or type custom)
- Tap "of N" → `TargetPickerView` (quick count selector with common values)
- No preset name displayed — just dhikr phrase + count

### DhikrPhrase (Common Dhikr Library)
- 12 common dhikr phrases shipped as static data (`DhikrPhrase.library`)
- Each phrase: `arabicText`, `transliteration`, `meaning`, `defaultCount`
- Used by both quick counter (DhikrPickerView) and preset creation (AddPresetView)
- "Custom" option at bottom for users who want to type their own

### DhikrPreset (Preset System)
- 5 built-in presets with fixed UUIDs (survive re-encoding) + 1 quick counter preset
- Multi-phase support: Standard Tasbeeh = 33 SubhanAllah + 33 Alhamdulillah + 33 Allahu Akbar + 1 La ilaha illallah
- `currentPhase(for:)` determines which phase text to show at any count
- `milestoneIndices()` returns phase transition points (e.g., [33, 66, 99])
- `isQuickCounter: Bool` — backwards-compatible Codable field (defaults to `false`)
- Custom presets: user-created via library picker, single or multi-phase, deletable

### VolumeCounter (Counting Engine)
- Accepts `AppState` dependency (defaults to `.shared`)
- `handleButtonPress()`: increments count, records to AppState, checks milestones/target, triggers haptics
- On target reached: resets count synchronously (no async delay — avoids stacked resets eating fast presses)
- Prevents screen auto-lock via `isIdleTimerDisabled = true`
- Handles audio session interruptions (phone calls) by restarting engine

### Widget
- `StaticConfiguration` with `TasbeehProvider`
- Supports `.systemSmall` (today count + streak) and `.systemMedium` (+ lifetime)
- Refreshes at midnight for day rollover
- Uses `widgetBackground()` modifier for iOS 17+ `containerBackground` compatibility

### Theme System (Design 13)
- `TasbeehTheme(for: colorScheme)` — all color tokens computed from `ColorScheme`
- Dual mode: Light (#ffffff bg) + Dark (#0c0c0e bg)
- Accent gradient: Lilac `#c0b3f0` to Blue `#93c5f7`
- Flat surface containers with subtle borders (no system grouped list)
- Progress ring: 260px, 5px gradient stroke, 12px glow layer, indicator dot at arc end
- Design spec: `designs/DESIGN.md`

## Testing Strategy
- **83 unit tests** across 3 test files
- Tests use isolated `UserDefaults(suiteName: "com.alliance.tasbeeh.tests")` -- no real data pollution
- DhikrPresetTests: preset validation, phase calculation, milestone detection, Codable round-trip, quick counter, DhikrPhrase library validation
- AppStateTests: defaults, counting, persistence, preset CRUD, quick counter CRUD, migration, best streak/day tracking, computed stats (daysActive, dailyAverage, thisWeekCount, thisMonthCount, last7/30DaysData), date helpers
- CounterLogicTests: phase progression, boundary detection, haptic intensity, custom presets
- Volume button detection is NOT unit-testable (requires physical device + KVO)

## Default Behavior (Zero Config)
The app works immediately on launch with no setup:
- **Default mode**: Quick Counter (SubhanAllah, 33 count) — simple, no preset name
- **Default haptics**: Medium intensity
- **Default sound**: Off
- **Default iCloud sync**: On
- Tap Arabic text to switch dhikr, tap "of 33" to change target
- Settings/presets tucked behind subtle icons — power users can customize

## Features
1. **Volume button counting** — works with screen locked, in pocket
2. **Quick Counter** — simple default mode with dhikr phrase picker (12 common phrases) and adjustable target
3. **Common dhikr library** — 12 pre-built phrases with Arabic, transliteration, meaning (no Arabic typing needed)
4. **5 built-in dhikr presets** + library-based custom preset creation with multi-phase support
5. **Persistent lifetime count** across sessions
6. **Daily count tracking** with automatic day rollover
7. **Streak tracking** — current streak + best streak (persisted)
8. **Comprehensive stats dashboard** — today/lifetime/week/month counts, daily average, days active, best day record, weekly bar chart, calendar heatmap
9. **Session lap counter** (rounds completed since app open)
10. **Configurable haptic intensity** (off/light/medium/heavy)
11. **Optional count sound** (system tock)
12. **iOS widget** (small + medium, shows today/lifetime/streak)
13. **iCloud sync** across devices via NSUbiquitousKeyValueStore (includes best streak/day)
14. **Calendar heatmap** with day-level count details
15. **Benefits of Dhikr** — Quran verses + Hadith with Arabic text, translations, and source links
16. **Dual theme** — Light + Dark mode following system appearance (Design 13)
17. **Appearance mode** — System/Light/Dark override in settings

## App Logo
- **Design**: Gradient ring arc (~90% complete) with lilac (#c0b3f0) to sky blue (#93c5f7) gradient on pure black background, with a subtle glow
- **Source file**: `logos/01-gradient-ring.png` (1024x1024, AI-generated via Imagen 4)
- **Asset catalog**: `Tasbeeh/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (1024x1024, RGB, no alpha)
- **All sizes**: `logos/appstore/` contains pre-rendered sizes (1024, 180, 167, 152, 120, 87, 80, 76, 60, 58, 40, 29, 20)
- **Style**: Matches Design 13's visual language — minimal, abstract, lilac-to-blue palette, dark background

## Before Submitting to App Store
- [x] Set `DEVELOPMENT_TEAM` in `project.yml` and regenerate
- [x] Add 1024x1024 app icon to `Assets.xcassets/AppIcon.appiconset/`
- [ ] Create App Group (`group.com.alliance.tasbeeh`) in Apple Developer portal
- [ ] Create CloudKit container (`iCloud.com.alliance.tasbeeh`) in Apple Developer portal
- [ ] Add privacy manifest (`PrivacyInfo.xcprivacy`) if required
- [ ] Test on physical device: volume counting, background mode, lock screen haptics
- [ ] Test widget on home screen (small + medium sizes)
- [ ] Test iCloud sync between two devices
- [ ] Screenshot automation for App Store listing
- [ ] Write App Store description and metadata
- [ ] Set up App Store Connect listing
