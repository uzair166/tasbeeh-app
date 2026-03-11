import SwiftUI

struct DhikrPickerView: View {
    let currentArabicText: String
    let onSelect: (DhikrPhrase) -> Void
    let onCustom: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showCustomFields = false
    @State private var customArabic = ""
    @State private var customTransliteration = ""

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(DhikrPhrase.library) { phrase in
                        phraseRow(phrase, theme: t)
                    }

                    Divider()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)

                    // Custom option
                    if showCustomFields {
                        customInputSection(theme: t)
                    } else {
                        Button {
                            showCustomFields = true
                        } label: {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(t.accentStart)
                                Text("Custom Dhikr")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(t.primaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(t.tertiaryText)
                            }
                            .padding(14)
                            .background(t.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(t.surfaceBorder, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(t.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Choose Dhikr")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(t.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accentStart)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func phraseRow(_ phrase: DhikrPhrase, theme t: TasbeehTheme) -> some View {
        let isSelected = phrase.arabicText == currentArabicText

        return Button {
            onSelect(phrase)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase.arabicText)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(t.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(phrase.transliteration)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(t.secondaryText)

                    Text(phrase.meaning)
                        .font(.system(size: 11))
                        .foregroundColor(t.tertiaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(t.accentGradient)
                }
            }
            .padding(14)
            .background(t.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? t.accentStart.opacity(t.isDark ? 0.25 : 0.40) : t.surfaceBorder, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .padding(.horizontal, 20)
    }

    private func customInputSection(theme t: TasbeehTheme) -> some View {
        VStack(spacing: 12) {
            TextField("Arabic text", text: $customArabic)
                .font(.system(size: 18))
                .environment(\.layoutDirection, .rightToLeft)
                .padding(12)
                .background(t.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(t.surfaceBorder, lineWidth: 1)
                )

            TextField("Transliteration (optional)", text: $customTransliteration)
                .font(.system(size: 15))
                .padding(12)
                .background(t.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(t.surfaceBorder, lineWidth: 1)
                )

            Button {
                let arabic = customArabic.isEmpty ? customTransliteration : customArabic
                guard !arabic.isEmpty else { return }
                onCustom(arabic, customTransliteration)
                dismiss()
            } label: {
                Text("Use Custom Dhikr")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(t.accentGradient)
                    .cornerRadius(12)
            }
            .disabled(customArabic.isEmpty && customTransliteration.isEmpty)
        }
        .padding(.horizontal, 20)
    }
}
