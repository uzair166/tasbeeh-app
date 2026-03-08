import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let gold = Color(red: 0.82, green: 0.70, blue: 0.38)

    var body: some View {
        NavigationView {
            List {
                // MARK: - Feedback
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Haptic Feedback")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Intensity", selection: $appState.hapticIntensity) {
                            ForEach(HapticIntensity.allCases, id: \.self) { intensity in
                                Text(intensity.displayName).tag(intensity)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)

                    Toggle("Count Sound", isOn: $appState.soundEnabled)
                } header: {
                    Text("Feedback")
                }

                // MARK: - Counting
                Section {
                    HStack {
                        Text("Active Preset")
                        Spacer()
                        Text(appState.activePreset.name)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Target Count")
                        Spacer()
                        Text("\(appState.activePreset.targetCount)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Counting")
                }

                // MARK: - Stats
                Section {
                    HStack {
                        Label("Today", systemImage: "calendar")
                        Spacer()
                        Text("\(appState.todayCount)")
                            .foregroundColor(gold)
                    }

                    HStack {
                        Label("Lifetime", systemImage: "infinity")
                        Spacer()
                        Text("\(appState.lifetimeCount.formatted())")
                            .foregroundColor(gold)
                    }

                    HStack {
                        Label("Streak", systemImage: "flame")
                        Spacer()
                        Text("\(appState.currentStreak) day\(appState.currentStreak == 1 ? "" : "s")")
                            .foregroundColor(gold)
                    }

                    NavigationLink {
                        HistoryView(appState: appState)
                    } label: {
                        Label("History", systemImage: "chart.bar")
                    }
                } header: {
                    Text("Stats")
                }

                // MARK: - Sync
                Section {
                    Toggle("iCloud Sync", isOn: $appState.iCloudSyncEnabled)
                } header: {
                    Text("Sync")
                } footer: {
                    Text("Syncs your counts and history across your Apple devices.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
