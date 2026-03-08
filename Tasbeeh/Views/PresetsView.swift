import SwiftUI

struct PresetsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showAddPreset = false

    private let gold = Color(red: 0.82, green: 0.70, blue: 0.38)

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(appState.presets.filter(\.isBuiltIn)) { preset in
                        presetRow(preset)
                    }
                } header: {
                    Text("Built-in")
                }

                let custom = appState.presets.filter { !$0.isBuiltIn }
                if !custom.isEmpty {
                    Section {
                        ForEach(custom) { preset in
                            presetRow(preset)
                        }
                        .onDelete { indexSet in
                            let customPresets = appState.presets.filter { !$0.isBuiltIn }
                            for index in indexSet {
                                appState.deletePreset(customPresets[index])
                            }
                        }
                    } header: {
                        Text("Custom")
                    }
                }
            }
            .navigationTitle("Dhikr Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPreset = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPreset) {
                AddPresetView(appState: appState)
            }
        }
    }

    private func presetRow(_ preset: DhikrPreset) -> some View {
        Button {
            appState.activePresetID = preset.id
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .foregroundColor(.primary)
                    Text(preset.arabicName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("\(preset.targetCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if preset.id == appState.activePresetID {
                    Image(systemName: "checkmark")
                        .foregroundColor(gold)
                }
            }
        }
    }
}

// MARK: - Add Preset

struct AddPresetView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var arabicName = ""
    @State private var targetCount = 33

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name (e.g. SubhanAllah)", text: $name)
                    TextField("Arabic Text", text: $arabicName)
                        .environment(\.layoutDirection, .rightToLeft)
                } header: {
                    Text("Dhikr")
                }

                Section {
                    Stepper("Target: \(targetCount)", value: $targetCount, in: 1...10000)
                } header: {
                    Text("Count")
                }
            }
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let preset = DhikrPreset(
                            id: UUID(),
                            name: name.isEmpty ? "Custom" : name,
                            arabicName: arabicName.isEmpty ? name : arabicName,
                            phases: [DhikrPhase(arabicText: arabicName.isEmpty ? name : arabicName, count: targetCount)],
                            targetCount: targetCount,
                            isBuiltIn: false
                        )
                        appState.addPreset(preset)
                        appState.activePresetID = preset.id
                        dismiss()
                    }
                    .disabled(name.isEmpty && arabicName.isEmpty)
                }
            }
        }
    }
}
