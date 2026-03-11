import SwiftUI

struct ContentView: View {
    @StateObject private var counter = VolumeCounter()
    @ObservedObject var appState: AppState = .shared
    @Environment(\.colorScheme) private var colorScheme

    @State private var showSettings = false
    @State private var showBenefits = false
    @State private var showPresets = false
    @State private var showDhikrPicker = false
    @State private var showTargetPicker = false
    @State private var showStats = false

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private var activePreset: DhikrPreset {
        appState.activePreset
    }

    private var currentPhase: DhikrPhase? {
        activePreset.currentPhase(for: counter.count)
    }

    private var currentPhaseArabic: String {
        currentPhase?.arabicText ?? activePreset.arabicName
    }

    private var currentTransliteration: String {
        currentPhase?.transliteration ?? activePreset.name
    }

    private var ringProgress: CGFloat {
        let target = activePreset.targetCount
        guard target > 0, counter.count > 0 else { return 0 }
        return min(CGFloat(counter.count) / CGFloat(target), 1.0)
    }

    private var phaseCount: Int {
        activePreset.phases.count
    }

    private var currentPhaseIndex: Int {
        guard phaseCount > 1 else { return 0 }
        var remaining = counter.count % max(activePreset.targetCount, 1)
        for (i, phase) in activePreset.phases.enumerated() {
            if remaining < phase.count { return i }
            remaining -= phase.count
        }
        return phaseCount - 1
    }

    // Ring sizing
    private let ringSize: CGFloat = 260
    private let ringStroke: CGFloat = 5
    private let glowStroke: CGFloat = 12

    var body: some View {
        let t = theme

        ZStack {
            // Background
            t.background.ignoresSafeArea()

            // Top gradient overlay
            VStack {
                t.headerGradient
                    .frame(height: 440)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: info left, stats + gear right
                HStack(spacing: 10) {
                    Button { showBenefits = true } label: {
                        Image(systemName: "info")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(t.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(t.surface)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Benefits of Dhikr")

                    Spacer()

                    Button { showStats = true } label: {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(t.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(t.surface)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Stats and History")

                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(t.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(t.surface)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Settings")
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()

                // Arabic text
                Button {
                    if activePreset.isQuickCounter {
                        showDhikrPicker = true
                    } else {
                        showPresets = true
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(currentPhaseArabic)
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(t.primaryText.opacity(0.85))

                        Text(currentTransliteration)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(t.tertiaryText)
                    }
                }
                .padding(.bottom, 32)

                // Progress ring
                ZStack {
                    // Track
                    Circle()
                        .stroke(t.ringTrack, lineWidth: ringStroke)
                        .frame(width: ringSize, height: ringSize)

                    // Glow layer (blurred)
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            t.ringGradient,
                            style: StrokeStyle(lineWidth: glowStroke, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .blur(radius: 6)
                        .opacity(0.5)
                        .animation(.easeOut(duration: 0.15), value: counter.count)

                    // Main arc
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            t.ringGradient,
                            style: StrokeStyle(lineWidth: ringStroke, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.15), value: counter.count)

                    // Indicator dot at arc end
                    if ringProgress > 0 {
                        Circle()
                            .fill(t.ringGradient)
                            .frame(width: 12, height: 12)
                            .shadow(color: t.ringGlow, radius: 8)
                            .offset(y: -ringSize / 2)
                            // Dot must use the same start point + direction as the trimmed arc.
                            .rotationEffect(.degrees(360 * Double(ringProgress)))
                            .animation(.easeOut(duration: 0.15), value: counter.count)
                    }

                    // Count inside ring
                    VStack(spacing: 2) {
                        Text("\(counter.count)")
                            .font(.system(size: 84, weight: .semibold, design: .rounded))
                            .foregroundColor(t.primaryText)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: counter.count)
                            .monospacedDigit()

                        if activePreset.isQuickCounter {
                            Button { showTargetPicker = true } label: {
                                Text("of \(activePreset.targetCount)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(t.tertiaryText)
                                    .underline(color: t.tertiaryText.opacity(0.5))
                            }
                        } else {
                            Text("of \(activePreset.targetCount)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(t.tertiaryText)
                        }
                    }
                }

                // Phase dots
                if phaseCount > 1 {
                    HStack(spacing: 10) {
                        ForEach(0..<phaseCount, id: \.self) { i in
                            Circle()
                                .fill(i <= currentPhaseIndex ? t.dotActive : t.dotInactive)
                                .frame(width: 6, height: 6)
                                .animation(.easeOut(duration: 0.2), value: counter.count)
                        }
                    }
                    .padding(.top, 24)
                }

                // Lap counter
                if appState.lapsThisSession > 0 {
                    Text("Round \(appState.lapsThisSession)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(t.secondaryText)
                        .padding(.top, 10)
                        .transition(.opacity)
                }

                // Hint
                Text("Press volume buttons to count")
                    .font(.system(size: 13))
                    .foregroundColor(t.tertiaryText)
                    .padding(.top, phaseCount > 1 ? 16 : 24)

                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let window = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first
                counter.setupVolumeView(in: window)
            }
        }
        .sheet(isPresented: $showStats) {
            StatsView(appState: appState)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(appState: appState)
        }
        .sheet(isPresented: $showBenefits) {
            BenefitsView()
        }
        .sheet(isPresented: $showPresets) {
            PresetsView(appState: appState)
        }
        .sheet(isPresented: $showDhikrPicker) {
            DhikrPickerView(
                currentArabicText: activePreset.arabicName,
                onSelect: { phrase in
                    appState.updateQuickCounter(
                        arabicText: phrase.arabicText,
                        transliteration: phrase.transliteration,
                        targetCount: phrase.defaultCount
                    )
                    counter.count = 0
                },
                onCustom: { arabic, translit in
                    let currentTarget = appState.activePreset.targetCount
                    appState.updateQuickCounter(
                        arabicText: arabic,
                        transliteration: translit,
                        targetCount: currentTarget
                    )
                    counter.count = 0
                }
            )
        }
        .sheet(isPresented: $showTargetPicker) {
            TargetPickerView(
                currentTarget: activePreset.targetCount,
                onSelect: { newTarget in
                    let preset = appState.activePreset
                    appState.updateQuickCounter(
                        arabicText: preset.arabicName,
                        transliteration: preset.phases.first?.transliteration ?? "",
                        targetCount: newTarget
                    )
                    counter.count = 0
                }
            )
        }
    }
}
