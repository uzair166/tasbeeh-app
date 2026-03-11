import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    @State private var showPresets = false
    @State private var showStats = false

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    settingsGroup(title: "DISPLAY", theme: t) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appearance")
                                .font(.system(size: 14))
                                .foregroundColor(t.secondaryText)

                            Picker("Appearance", selection: $appState.appearanceMode) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    Text(mode.displayName).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // MARK: - Feedback
                    settingsGroup(title: "FEEDBACK", theme: t) {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Haptic Feedback")
                                    .font(.system(size: 14))
                                    .foregroundColor(t.secondaryText)

                                Picker("Intensity", selection: $appState.hapticIntensity) {
                                    ForEach(HapticIntensity.allCases, id: \.self) { intensity in
                                        Text(intensity.displayName).tag(intensity)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            Divider()
                                .background(t.surfaceBorder)

                            Toggle(isOn: $appState.soundEnabled) {
                                Text("Count Sound")
                                    .font(.system(size: 15))
                                    .foregroundColor(t.primaryText)
                            }
                            .tint(t.accentStart)
                        }
                    }

                    // MARK: - Sync
                    settingsGroup(title: "SYNC", theme: t) {
                        VStack(spacing: 4) {
                            Toggle(isOn: $appState.iCloudSyncEnabled) {
                                Text("iCloud Sync")
                                    .font(.system(size: 15))
                                    .foregroundColor(t.primaryText)
                            }
                            .tint(t.accentStart)

                            Text("Syncs your counts and history across your Apple devices.")
                                .font(.system(size: 12))
                                .foregroundColor(t.tertiaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                    }

                    // MARK: - More
                    settingsGroup(title: "MORE", theme: t) {
                        VStack(spacing: 0) {
                            Button { showPresets = true } label: {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 14))
                                        .foregroundColor(t.accentStart)
                                        .frame(width: 24)
                                    Text("Dhikr Presets")
                                        .font(.system(size: 15))
                                        .foregroundColor(t.primaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(t.tertiaryText)
                                }
                                .padding(.vertical, 4)
                            }

                            Divider()
                                .background(t.surfaceBorder)
                                .padding(.vertical, 8)

                            Button { showStats = true } label: {
                                HStack {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(t.accentStart)
                                        .frame(width: 24)
                                    Text("Stats & History")
                                        .font(.system(size: 15))
                                        .foregroundColor(t.primaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(t.tertiaryText)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(t.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(t.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accentStart)
                }
            }
            .sheet(isPresented: $showPresets) {
                PresetsView(appState: appState)
            }
            .sheet(isPresented: $showStats) {
                StatsView(appState: appState)
            }
        }
    }

    private func settingsGroup<Content: View>(title: String, theme t: TasbeehTheme, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(t.secondaryText)
                .tracking(0.5)
                .padding(.horizontal, 20)

            content()
                .padding(16)
                .background(t.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(t.surfaceBorder, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        }
    }
}
