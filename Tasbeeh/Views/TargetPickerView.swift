import SwiftUI

struct TargetPickerView: View {
    let currentTarget: Int
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var customValue: String = ""
    @State private var showCustom = false

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private let commonCounts = [33, 100, 200, 500, 1000]

    var body: some View {
        let t = theme

        NavigationView {
            VStack(spacing: 20) {
                Text("Set Target Count")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(t.primaryText)
                    .padding(.top, 8)

                // Common count pills
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12) {
                    ForEach(commonCounts, id: \.self) { count in
                        countPill(count, theme: t)
                    }
                }
                .padding(.horizontal, 20)

                Divider()
                    .padding(.horizontal, 20)

                // Custom count
                VStack(spacing: 12) {
                    Text("Custom Count")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(t.secondaryText)

                    HStack(spacing: 12) {
                        TextField("Enter count", text: $customValue)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .padding(12)
                            .background(t.surface)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(t.surfaceBorder, lineWidth: 1)
                            )
                            .frame(maxWidth: 120)

                        Button {
                            if let value = Int(customValue), value > 0, value <= 10000 {
                                onSelect(value)
                                dismiss()
                            }
                        } label: {
                            Text("Set")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(t.accentGradient)
                                .cornerRadius(10)
                        }
                        .disabled({
                            guard let v = Int(customValue) else { return true }
                            return v <= 0 || v > 10000
                        }())
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 16)
            .background(t.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .presentationDetents([.height(320)])
    }

    private func countPill(_ count: Int, theme t: TasbeehTheme) -> some View {
        let isActive = count == currentTarget

        return Button {
            onSelect(count)
            dismiss()
        } label: {
            Text("\(count)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(isActive ? .white : t.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isActive ? AnyShapeStyle(t.accentGradient) : AnyShapeStyle(t.surface))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? Color.clear : t.surfaceBorder, lineWidth: 1)
                )
        }
    }
}
