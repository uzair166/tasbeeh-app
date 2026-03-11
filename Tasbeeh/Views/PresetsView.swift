import SwiftUI

struct PresetsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showAddPreset = false

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private var savedPresets: [DhikrPreset] {
        appState.presets.filter { !$0.isQuickCounter }
    }

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Gradient header
                    VStack(spacing: 8) {
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(t.primaryText)
                            }
                            Spacer()
                            Button { showAddPreset = true } label: {
                                Text("+ Add")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(t.primaryText)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(t.surface.opacity(0.8))
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)

                        Text("Dhikr Presets")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(t.primaryText)
                        Text("Choose your dhikr for counting")
                            .font(.system(size: 14))
                            .foregroundColor(t.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(t.headerGradient)

                    // Preset list
                    VStack(spacing: 10) {
                        // Quick counter row at top
                        quickCounterRow(theme: t)

                        ForEach(savedPresets) { preset in
                            presetRow(preset, theme: t)
                        }
                    }
                    .padding(20)
                }
            }
            .background(t.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPreset) {
                AddPresetView(appState: appState)
            }
        }
    }

    private func quickCounterRow(theme t: TasbeehTheme) -> some View {
        let isActive = appState.activePresetID == DhikrPreset.quickCounterID

        return Button {
            appState.activePresetID = DhikrPreset.quickCounterID
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18))
                    .foregroundColor(t.accentStart)
                    .frame(width: 38, height: 38)
                    .background(t.accentGradient.opacity(t.isDark ? 0.15 : 0.20))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Counter")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(t.primaryText)

                    Text("Simple counter with any dhikr")
                        .font(.system(size: 12))
                        .foregroundColor(t.secondaryText)
                }

                Spacer()

                if isActive {
                    Text("Active")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(t.accentStart)
                }
            }
            .padding(12)
            .background(t.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? t.accentStart.opacity(t.isDark ? 0.25 : 0.40) : t.surfaceBorder, lineWidth: isActive ? 1.5 : 1)
            )
        }
    }

    private func presetRow(_ preset: DhikrPreset, theme t: TasbeehTheme) -> some View {
        let isActive = preset.id == appState.activePresetID

        return Button {
            appState.activePresetID = preset.id
            dismiss()
        } label: {
            HStack(spacing: 12) {
                // Icon container
                Text(preset.iconText.isEmpty ? String(preset.arabicName.prefix(2)) : preset.iconText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(t.sourceBadgeText)
                    .frame(width: 38, height: 38)
                    .background(t.accentGradient.opacity(t.isDark ? 0.15 : 0.20))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(t.primaryText)

                    HStack(spacing: 6) {
                        Text(preset.arabicName)
                            .font(.system(size: 12))
                            .foregroundColor(t.secondaryText)
                            .lineLimit(1)

                        if preset.phases.count > 1 {
                            Text("\(preset.phases.count) phases")
                                .font(.system(size: 11))
                                .foregroundColor(t.tertiaryText)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(preset.targetCount)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(t.secondaryText)

                    if isActive {
                        Text("Active")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(t.accentStart)
                    }
                }
            }
            .padding(12)
            .background(t.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? t.accentStart.opacity(t.isDark ? 0.25 : 0.40) : t.surfaceBorder, lineWidth: isActive ? 1.5 : 1)
            )
        }
        .contextMenu {
            if !preset.isBuiltIn {
                Button(role: .destructive) {
                    appState.deletePreset(preset)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Add Preset

struct AddPresetView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name = ""
    @State private var phases: [(arabicText: String, transliteration: String, count: Int)] = []
    @State private var showDhikrPicker = false
    @State private var editingPhaseIndex: Int? = nil

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private var totalTarget: Int {
        phases.reduce(0) { $0 + $1.count }
    }

    private var canSave: Bool {
        !phases.isEmpty && totalTarget > 0
    }

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Name field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NAME (OPTIONAL)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(t.secondaryText)
                            .tracking(0.5)

                        TextField("Auto-generated from dhikr", text: $name)
                            .font(.system(size: 15))
                            .padding(12)
                            .background(t.surface)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(t.surfaceBorder, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)

                    // Phases
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PHASES")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(t.secondaryText)
                            .tracking(0.5)
                            .padding(.horizontal, 20)

                        ForEach(phases.indices, id: \.self) { index in
                            phaseRow(index: index, theme: t)
                        }

                        // Add phase button
                        Button {
                            editingPhaseIndex = nil
                            showDhikrPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(t.accentGradient)
                                Text(phases.isEmpty ? "Choose Dhikr" : "Add Phase")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(t.primaryText)
                                Spacer()
                            }
                            .padding(14)
                            .background(t.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(t.surfaceBorder, style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                        }
                        .padding(.horizontal, 20)
                    }

                    // Total
                    if !phases.isEmpty {
                        HStack {
                            Text("Total Count")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(t.secondaryText)
                            Spacer()
                            Text("\(totalTarget)")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(t.primaryText)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(t.background.ignoresSafeArea())
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(t.accentStart)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { savePreset() }
                        .foregroundColor(t.accentStart)
                        .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showDhikrPicker) {
                DhikrPickerView(
                    currentArabicText: "",
                    onSelect: { phrase in
                        addPhase(arabicText: phrase.arabicText, transliteration: phrase.transliteration, count: phrase.defaultCount)
                    },
                    onCustom: { arabic, translit in
                        addPhase(arabicText: arabic, transliteration: translit, count: 33)
                    }
                )
            }
        }
    }

    private func phaseRow(index: Int, theme t: TasbeehTheme) -> some View {
        let phase = phases[index]

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.arabicText)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(t.primaryText)
                    .lineLimit(1)

                if !phase.transliteration.isEmpty {
                    Text(phase.transliteration)
                        .font(.system(size: 12))
                        .foregroundColor(t.secondaryText)
                }
            }

            Spacer()

            // Count stepper
            HStack(spacing: 8) {
                Button {
                    if phases[index].count > 1 {
                        phases[index].count -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(t.secondaryText)
                }

                Text("\(phase.count)")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(t.primaryText)
                    .frame(minWidth: 30)

                Button {
                    if phases[index].count < 10000 {
                        phases[index].count += 1
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(t.secondaryText)
                }
            }

            // Delete phase
            Button {
                phases.remove(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(t.tertiaryText)
            }
        }
        .padding(12)
        .background(t.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(t.surfaceBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private func addPhase(arabicText: String, transliteration: String, count: Int) {
        phases.append((arabicText: arabicText, transliteration: transliteration, count: count))
    }

    private func savePreset() {
        let dhikrPhases = phases.map { DhikrPhase(arabicText: $0.arabicText, transliteration: $0.transliteration, count: $0.count) }
        let autoName = name.isEmpty ? (phases.first?.transliteration.isEmpty == false ? phases.first!.transliteration : "Custom") : name
        let arabicName = phases.first?.arabicText ?? "Custom"

        let preset = DhikrPreset(
            id: UUID(),
            name: autoName,
            arabicName: arabicName,
            phases: dhikrPhases,
            targetCount: totalTarget,
            isBuiltIn: false
        )
        appState.addPreset(preset)
        appState.activePresetID = preset.id
        dismiss()
    }
}
