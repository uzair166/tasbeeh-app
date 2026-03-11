import SwiftUI

struct HistoryView: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    @State private var displayMonth: Date = Date()

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayMonth)
    }

    private var daysInMonth: [DayItem] {
        guard let range = calendar.range(of: .day, in: .month, for: displayMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = firstWeekday - calendar.firstWeekday
        let paddedOffset = (offset + 7) % 7

        var items: [DayItem] = []
        for _ in 0..<paddedOffset {
            items.append(DayItem(day: 0, count: 0, isToday: false))
        }

        let today = AppState.todayString()
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) else { continue }
            let dateString = AppState.dateString(for: date)
            let count = appState.history[dateString] ?? (dateString == today ? appState.todayCount : 0)
            let isToday = dateString == today
            items.append(DayItem(day: day, count: count, isToday: isToday))
        }
        return items
    }

    private var maxCount: Int {
        max(appState.history.values.max() ?? 1, 1)
    }

    var body: some View {
        let t = theme

        ScrollView {
            VStack(spacing: 0) {
                // Gradient header
                VStack(spacing: 6) {
                    Text("\(appState.currentStreak)")
                        .font(.system(size: 60, weight: .semibold, design: .rounded))
                        .foregroundColor(t.primaryText)
                    Text("Day Streak")
                        .font(.system(size: 15))
                        .foregroundColor(t.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(t.headerGradient)

                VStack(spacing: 20) {
                    // Stats row
                    HStack(spacing: 12) {
                        statCard(value: "\(appState.todayCount)", label: "Today", theme: t)
                        statCard(value: "\(appState.lifetimeCount.formatted())", label: "Lifetime", theme: t)
                    }
                    .padding(.horizontal, 20)

                    // Month navigation
                    HStack {
                        Button {
                            if let prev = calendar.date(byAdding: .month, value: -1, to: displayMonth) {
                                displayMonth = prev
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(t.accentStart)
                        }
                        .accessibilityLabel("Previous month")

                        Spacer()
                        Text(monthTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(t.primaryText)
                        Spacer()

                        Button {
                            if let next = calendar.date(byAdding: .month, value: 1, to: displayMonth), next <= Date() {
                                displayMonth = next
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(t.accentStart)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Weekday headers
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption2)
                                .foregroundColor(t.tertiaryText)
                                .frame(height: 20)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Calendar grid
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, item in
                            if item.day == 0 {
                                Color.clear.frame(height: 40)
                            } else {
                                dayCell(item, theme: t)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Legend
                    HStack(spacing: 6) {
                        Text("Less")
                            .font(.system(size: 10))
                            .foregroundColor(t.tertiaryText)
                        ForEach([t.heatmap1, t.heatmap2, t.heatmap3, t.heatmap4], id: \.description) { color in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(color)
                                .frame(width: 14, height: 14)
                        }
                        Text("More")
                            .font(.system(size: 10))
                            .foregroundColor(t.tertiaryText)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .background(t.background.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func dayCell(_ item: DayItem, theme t: TasbeehTheme) -> some View {
        let tier: Int = {
            guard item.count > 0 else { return 0 }
            let ratio = Double(item.count) / Double(maxCount)
            if ratio <= 0.25 { return 1 }
            if ratio <= 0.50 { return 2 }
            if ratio <= 0.75 { return 3 }
            return 4
        }()

        let bgColor: Color = {
            switch tier {
            case 1: return t.heatmap1
            case 2: return t.heatmap2
            case 3: return t.heatmap3
            case 4: return t.heatmap4
            default: return Color.clear
            }
        }()

        return VStack(spacing: 2) {
            Text("\(item.day)")
                .font(.system(size: 13))
                .foregroundColor(item.isToday ? t.accentStart : t.primaryText)
                .fontWeight(item.isToday ? .bold : .regular)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(item.isToday ? t.primaryText.opacity(0.9) : Color.clear, lineWidth: 1.5)
        )
    }

    private func statCard(value: String, label: String, theme t: TasbeehTheme) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(t.primaryText)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(t.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(t.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(t.surfaceBorder, lineWidth: 1)
        )
    }
}

private struct DayItem {
    let day: Int
    let count: Int
    let isToday: Bool
}
