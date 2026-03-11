import SwiftUI

struct StatsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var displayMonth: Date = Date()

    private var theme: TasbeehTheme { TasbeehTheme(for: colorScheme) }
    private let calendar = Calendar.current

    var body: some View {
        let t = theme

        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with streak
                    streakHeader(theme: t)

                    VStack(spacing: 20) {
                        // Summary cards
                        summaryCards(theme: t)

                        // Weekly chart
                        weeklyChart(theme: t)

                        // Period stats
                        periodStats(theme: t)

                        // Records
                        recordsSection(theme: t)

                        // Calendar heatmap
                        calendarSection(theme: t)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(t.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Progress")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(t.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accentStart)
                }
            }
        }
    }

    // MARK: - Streak Header

    private func streakHeader(theme t: TasbeehTheme) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                if appState.currentStreak > 0 {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(t.accentGradient)
                }

                Text("\(appState.currentStreak)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(t.primaryText)
            }

            Text(appState.currentStreak == 1 ? "Day Streak" : "Day Streak")
                .font(.system(size: 15))
                .foregroundColor(t.secondaryText)

            if appState.bestStreak > appState.currentStreak {
                Text("Best: \(appState.bestStreak) days")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(t.tertiaryText)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(t.headerGradient)
    }

    // MARK: - Summary Cards

    private func summaryCards(theme t: TasbeehTheme) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                statCard(
                    value: "\(appState.todayCount)",
                    label: "Today",
                    icon: "sun.max.fill",
                    theme: t
                )
                statCard(
                    value: formattedNumber(appState.lifetimeCount),
                    label: "Lifetime",
                    icon: "infinity",
                    theme: t
                )
            }
            HStack(spacing: 10) {
                statCard(
                    value: "\(appState.thisWeekCount)",
                    label: "This Week",
                    icon: "calendar.badge.clock",
                    theme: t
                )
                statCard(
                    value: "\(appState.daysActive)",
                    label: "Days Active",
                    icon: "checkmark.circle.fill",
                    theme: t
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func statCard(value: String, label: String, icon: String, theme t: TasbeehTheme) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(t.accentGradient)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(t.primaryText)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(t.secondaryText)
            }
            Spacer()
        }
        .padding(12)
        .background(t.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(t.surfaceBorder, lineWidth: 1)
        )
    }

    // MARK: - Weekly Chart

    private func weeklyChart(theme t: TasbeehTheme) -> some View {
        let data = appState.last7DaysData()
        let maxVal = max(data.map(\.count).max() ?? 1, 1)
        let dayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEE"
            return f
        }()

        return VStack(alignment: .leading, spacing: 12) {
            Text("LAST 7 DAYS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(t.secondaryText)
                .tracking(0.5)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(t.secondaryText)
                        }

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                AppState.dateString(for: item.date) == AppState.todayString()
                                    ? AnyShapeStyle(t.accentGradient)
                                    : AnyShapeStyle(item.count > 0 ? t.accentStart.opacity(0.4) : t.surface)
                            )
                            .frame(height: max(CGFloat(item.count) / CGFloat(maxVal) * 100, item.count > 0 ? 8 : 4))

                        Text(dayFormatter.string(from: item.date))
                            .font(.system(size: 10))
                            .foregroundColor(
                                AppState.dateString(for: item.date) == AppState.todayString()
                                    ? t.primaryText
                                    : t.tertiaryText
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(t.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(t.surfaceBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Period Stats

    private func periodStats(theme t: TasbeehTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AVERAGES & TOTALS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(t.secondaryText)
                .tracking(0.5)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                periodRow(label: "Daily Average", value: "\(appState.dailyAverage)", theme: t)
                Divider().background(t.surfaceBorder)
                periodRow(label: "This Month", value: formattedNumber(appState.thisMonthCount), theme: t)
                Divider().background(t.surfaceBorder)
                periodRow(label: "This Week", value: "\(appState.thisWeekCount)", theme: t)
            }
            .background(t.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(t.surfaceBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private func periodRow(label: String, value: String, theme t: TasbeehTheme) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(t.primaryText)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(t.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Records

    private func recordsSection(theme t: TasbeehTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERSONAL RECORDS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(t.secondaryText)
                .tracking(0.5)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                recordRow(
                    icon: "flame.fill",
                    label: "Best Streak",
                    value: "\(appState.bestStreak) \(appState.bestStreak == 1 ? "day" : "days")",
                    theme: t
                )
                Divider().background(t.surfaceBorder)
                recordRow(
                    icon: "trophy.fill",
                    label: "Best Day",
                    value: appState.bestDayCount > 0
                        ? "\(formattedNumber(appState.bestDayCount)) counts"
                        : "--",
                    subtitle: formattedBestDayDate(),
                    theme: t
                )
                Divider().background(t.surfaceBorder)
                recordRow(
                    icon: "calendar.badge.checkmark",
                    label: "Total Days Active",
                    value: "\(appState.daysActive)",
                    theme: t
                )
                Divider().background(t.surfaceBorder)
                recordRow(
                    icon: "sum",
                    label: "Lifetime Total",
                    value: formattedNumber(appState.lifetimeCount),
                    theme: t
                )
            }
            .background(t.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(t.surfaceBorder, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    private func recordRow(icon: String, label: String, value: String, subtitle: String? = nil, theme t: TasbeehTheme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(t.accentGradient)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(t.primaryText)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(t.tertiaryText)
                }
            }
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(t.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Calendar Heatmap

    private let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

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

    private func calendarSection(theme t: TasbeehTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CALENDAR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(t.secondaryText)
                .tracking(0.5)
                .padding(.horizontal, 20)

            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Button {
                        displayMonth = calendar.date(byAdding: .month, value: -1, to: displayMonth)!
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(t.accentStart)
                            .frame(width: 28, height: 28)
                    }

                    Spacer()
                    Text(monthTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(t.primaryText)
                    Spacer()

                    Button {
                        let next = calendar.date(byAdding: .month, value: 1, to: displayMonth)!
                        if next <= Date() {
                            displayMonth = next
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(t.accentStart)
                            .frame(width: 28, height: 28)
                    }
                }

                // Weekday headers
                LazyVGrid(columns: calendarColumns, spacing: 4) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(t.tertiaryText)
                            .frame(height: 16)
                    }
                }

                // Calendar grid
                LazyVGrid(columns: calendarColumns, spacing: 4) {
                    ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, item in
                        if item.day == 0 {
                            Color.clear.frame(height: 38)
                        } else {
                            dayCell(item, theme: t)
                        }
                    }
                }

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
            }
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

        return VStack(spacing: 1) {
            Text("\(item.day)")
                .font(.system(size: 12))
                .foregroundColor(item.isToday ? t.accentStart : t.primaryText)
                .fontWeight(item.isToday ? .bold : .regular)

            if item.count > 0 {
                Text("\(item.count)")
                    .font(.system(size: 7, weight: .medium, design: .rounded))
                    .foregroundColor(t.secondaryText)
            }
        }
        .frame(height: 38)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(item.isToday ? t.accentStart.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Helpers

    private func formattedNumber(_ n: Int) -> String {
        if n >= 1000 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
        }
        return "\(n)"
    }

    private func formattedBestDayDate() -> String {
        guard !appState.bestDayDate.isEmpty, let date = AppState.date(from: appState.bestDayDate) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

private struct DayItem {
    let day: Int
    let count: Int
    let isToday: Bool
}
