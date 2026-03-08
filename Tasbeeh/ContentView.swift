import SwiftUI

struct ContentView: View {
    @StateObject private var counter = VolumeCounter()
    @ObservedObject var appState: AppState = .shared

    @State private var showSettings = false
    @State private var showPresets = false

    private let gold = Color(red: 0.82, green: 0.70, blue: 0.38)

    private var activePreset: DhikrPreset {
        appState.activePreset
    }

    private var currentPhaseText: String {
        activePreset.currentPhase(for: counter.count)?.arabicText ?? activePreset.arabicName
    }

    private var segmentFraction: CGFloat {
        let target = activePreset.targetCount
        guard target > 0, counter.count > 0 else { return 0 }

        if activePreset.phases.count > 1 {
            // Multi-phase: fill ring per current phase
            var remaining = counter.count
            var currentPhaseSize = activePreset.phases.first?.count ?? target
            for phase in activePreset.phases {
                if remaining <= phase.count {
                    currentPhaseSize = phase.count
                    return CGFloat(remaining) / CGFloat(currentPhaseSize)
                }
                remaining -= phase.count
            }
            return 1.0
        } else {
            // Single phase: fill ring toward target
            return CGFloat(counter.count) / CGFloat(target)
        }
    }

    private var milestones: [Int] {
        activePreset.milestoneIndices()
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.09, blue: 0.14),
                    Color(red: 0.08, green: 0.14, blue: 0.20)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Lifetime count
                    Text("\(appState.lifetimeCount.formatted()) total")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.2))

                    Spacer()

                    // Settings gear
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()

                // Arabic title / preset name
                Button {
                    showPresets = true
                } label: {
                    Text(activePreset.arabicName)
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(gold.opacity(0.8))
                }
                .padding(.bottom, 36)

                // Ring + Counter
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 10)
                        .frame(width: 260, height: 260)

                    Circle()
                        .trim(from: 0, to: segmentFraction)
                        .stroke(
                            AngularGradient(
                                colors: [gold.opacity(0.5), gold],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 260, height: 260)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.15), value: counter.count)

                    VStack(spacing: 6) {
                        Text("\(counter.count)")
                            .font(.system(size: 90, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: counter.count)
                            .monospacedDigit()
                    }
                }

                // Milestone dots
                if !milestones.isEmpty {
                    HStack(spacing: 14) {
                        ForEach(milestones, id: \.self) { milestone in
                            Circle()
                                .fill(counter.count >= milestone ? gold : Color.white.opacity(0.15))
                                .frame(width: 9, height: 9)
                                .animation(.easeOut(duration: 0.2), value: counter.count)
                        }
                    }
                    .padding(.top, 28)
                }

                // Phase label
                Text(currentPhaseText)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(gold.opacity(0.75))
                    .padding(.top, milestones.isEmpty ? 28 : 16)
                    .animation(.easeInOut(duration: 0.3), value: currentPhaseText)

                // Lap counter
                if appState.lapsThisSession > 0 {
                    Text("Round \(appState.lapsThisSession)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(gold.opacity(0.5))
                        .padding(.top, 8)
                        .transition(.opacity)
                }

                // Pocket hint
                Text("Press volume buttons to count")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.top, 10)

                Spacer()

                // Reset button
                Button(action: { counter.manualReset() }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(22)
                }
                .padding(.bottom, 50)
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
        .sheet(isPresented: $showSettings) {
            SettingsView(appState: appState)
        }
        .sheet(isPresented: $showPresets) {
            PresetsView(appState: appState)
        }
    }
}
