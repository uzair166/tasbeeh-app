# App Store Submission Metadata

## App Identity

| Field | Value |
|---|---|
| **App Name** | Tasbeeh: Volume Button Counter |
| **Subtitle** | Dhikr Counter & Zikr Tracker |
| **Bundle ID** | com.alliance.tasbeeh |
| **SKU** | tasbeeh-volume-counter |
| **Primary Category** | Lifestyle |
| **Secondary Category** | Utilities |
| **Age Rating** | 4+ |
| **Price** | Free |
| **Copyright** | 2026 Uzair Ishaq |

## Developer Info

| Field | Value |
|---|---|
| **Developer Name** | Uzair Ishaq |
| **Contact Email** | uzair.i@hotmail.co.uk |
| **Privacy Policy URL** | https://uzair166.github.io/tasbeeh-app/privacy |
| **Support URL** | https://uzair166.github.io/tasbeeh-app/privacy |

## Keywords (100 characters)

```
tasbih,azkar,islamic,muslim,prayer,beads,subhanallah,alhamdulillah,worship,streak,daily,widget,dua
```

97 characters. Does not duplicate words in title (tasbeeh, volume, button, counter) or subtitle (dhikr, zikr, tracker).

## Promotional Text (170 characters)

```
The only tasbeeh counter that uses your volume buttons. Count your dhikr with the screen locked — no tapping, no looking. Just press and remember.
```

148 characters. Can be changed anytime without app review.

## Description (4,000 characters max)

```
The only tasbeeh app that counts with your volume buttons.

Press volume up or volume down — that's it. Count your dhikr with your phone in your pocket, screen locked, without ever looking down. Tasbeeh keeps your audio session alive in the background so every press counts, even with the screen off.

No tapping. No swiping. No beads to drag. Just press and focus on your dhikr.

— QUICK START —

Open the app and start pressing. No setup needed. The default counter is set to SubhanAllah × 33 — tap the Arabic text to switch to any of 12 common dhikr phrases, or tap the count to change your target.

— COMMON DHIKR LIBRARY —

12 pre-loaded phrases with full Arabic text, transliteration, and English meaning:

• SubhanAllah • Alhamdulillah • Allahu Akbar • La ilaha illallah • Astaghfirullah • SubhanAllahi wa bihamdihi • SubhanAllahil Azeem • La hawla wa la quwwata illa billah • HasbunAllahu wa ni'mal wakeel • Allahumma salli ala Muhammad • and more

No Arabic keyboard needed — just pick from the library.

— MULTI-PHASE PRESETS —

The Standard Tasbeeh preset automatically transitions through all four phases:
33 × SubhanAllah → 33 × Alhamdulillah → 33 × Allahu Akbar → 1 × La ilaha illallah

The Arabic text, transliteration, and progress ring update as you move through each phase. Haptic feedback pulses at every phase transition so you know when to switch — without looking.

Create your own presets with multiple phases, each picked from the dhikr library.

— STATS & STREAKS —

• Daily count with automatic day rollover at midnight
• Current streak and best streak tracking
• Best day record with date
• Weekly bar chart showing your last 7 days
• Monthly totals and daily averages
• Days active count
• Calendar heatmap showing your entire history
• Lifetime count across all sessions

— FEATURES —

• Volume button counting — works with screen locked
• 12 common dhikr phrases built in
• 5 built-in multi-phase presets + unlimited custom presets
• Adjustable target count (33, 100, 200, 500, 1000, or custom)
• Haptic feedback with 4 intensity levels (off / light / medium / heavy)
• Optional count sound
• iOS home screen widget (small & medium)
• iCloud sync across all your Apple devices
• Streak tracking with personal records
• Comprehensive stats dashboard
• Light & Dark mode with lilac-blue gradient theme
• Zero ads. Zero accounts. Zero data collection.

— PRIVACY —

Tasbeeh collects no data. Your counts are stored on your device and optionally synced through your own iCloud account. No analytics, no tracking, no accounts, no servers.

— WHY VOLUME BUTTONS? —

Dhikr is an act of remembrance. You shouldn't need to watch a screen. Volume buttons let you count while walking, while sitting in contemplation, while your phone is in your pocket. Press and remember.
```

~2,400 characters.

## What's New (first release)

```
Assalamu Alaikum! Welcome to Tasbeeh — the first dhikr counter that uses your volume buttons.

• Count your dhikr with your phone in your pocket or screen locked
• 12 common dhikr phrases with Arabic text and transliteration
• Multi-phase presets (Standard Tasbeeh: 33+33+33+1)
• Stats dashboard with streak tracking, weekly chart, and calendar heatmap
• iCloud sync across your devices
• iOS widget for your home screen
• Light & Dark mode

JazakAllah Khair for downloading. May your dhikr be accepted.
```

## App Review Notes

```
This app observes volume changes via KVO on AVAudioSession.outputVolume to detect button presses. It does NOT override, disable, or alter the volume buttons — they continue to function normally as volume controls. The app reads the volume level change and resets it to 0.5 to maintain range. This is the same pattern used by approved apps such as Blackbox (by Ryan McLeod). A silent audio engine keeps the audio session alive for background counting.
```

## Privacy Labels

| Question | Answer |
|---|---|
| **Data collected?** | No — select "Data Not Collected" |
| **Reason** | All data stored on-device via UserDefaults. iCloud sync uses NSUbiquitousKeyValueStore which is the user's own iCloud — not data collected by the developer. No analytics, no third-party SDKs, no advertising. |

## Privacy Manifest (PrivacyInfo.xcprivacy)

Required for UserDefaults usage. Declare reason `CA92.1` (accessing info from same app).

## Still Needed

- [ ] Screenshots (6.7" and 6.5" displays minimum)
- [ ] App Preview video (optional but recommended)
- [ ] Privacy manifest file (`PrivacyInfo.xcprivacy`)
- [ ] Test on physical device before submission
- [ ] Set up App Store Connect listing
