import SwiftUI

struct HistoryView: View {
    @ObservedObject var appState: AppState

    private let gold = Color(red: 0.82, green: 0.70, blue: 0.38)
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
        let range = calendar.range(of: .day, in: .month, for: displayMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = firstWeekday - calendar.firstWeekday
        let paddedOffset = (offset + 7) % 7

        var items: [DayItem] = []

        // Empty cells before first day
        for _ in 0..<paddedOffset {
            items.append(DayItem(day: 0, count: 0, isToday: false))
        }

        let today = AppState.todayString()

        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
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
        ScrollView {
            VStack(spacing: 24) {
                // Stats header
                HStack(spacing: 32) {
                    statBlock(value: "\(appState.currentStreak)", label: "Day Streak")
                    statBlock(value: "\(appState.lifetimeCount.formatted())", label: "Lifetime")
                    statBlock(value: "\(appState.todayCount)", label: "Today")
                }
                .padding(.top, 16)

                // Month navigation
                HStack {
                    Button {
                        displayMonth = calendar.date(byAdding: .month, value: -1, to: displayMonth)!
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(gold)
                    }

                    Spacer()
                    Text(monthTitle)
                        .font(.headline)
                    Spacer()

                    Button {
                        let next = calendar.date(byAdding: .month, value: 1, to: displayMonth)!
                        if next <= Date() {
                            displayMonth = next
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(gold)
                    }
                }
                .padding(.horizontal)

                // Weekday headers
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal)

                // Calendar grid
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, item in
                        if item.day == 0 {
                            Color.clear.frame(height: 40)
                        } else {
                            dayCell(item)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func dayCell(_ item: DayItem) -> some View {
        let intensity = item.count > 0 ? max(0.2, min(1.0, Double(item.count) / Double(maxCount))) : 0.0

        return VStack(spacing: 2) {
            Text("\(item.day)")
                .font(.system(size: 13))
                .foregroundColor(item.isToday ? gold : .primary)
                .fontWeight(item.isToday ? .bold : .regular)
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(item.count > 0 ? gold.opacity(intensity * 0.4) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(item.isToday ? gold.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(gold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct DayItem {
    let day: Int
    let count: Int
    let isToday: Bool
}
