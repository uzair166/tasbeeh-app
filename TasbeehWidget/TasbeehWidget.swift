import SwiftUI
import WidgetKit

struct TasbeehEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let lifetimeCount: Int
    let currentStreak: Int
}

struct TasbeehProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.alliance.tasbeeh")

    func placeholder(in context: Context) -> TasbeehEntry {
        TasbeehEntry(date: Date(), todayCount: 33, lifetimeCount: 1000, currentStreak: 7)
    }

    func getSnapshot(in context: Context, completion: @escaping (TasbeehEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TasbeehEntry>) -> Void) {
        let entry = makeEntry()
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func makeEntry() -> TasbeehEntry {
        let store = defaults ?? .standard
        return TasbeehEntry(
            date: Date(),
            todayCount: store.integer(forKey: "todayCount"),
            lifetimeCount: store.integer(forKey: "lifetimeCount"),
            currentStreak: store.integer(forKey: "currentStreak")
        )
    }
}

struct TasbeehWidget: Widget {
    let kind = "TasbeehWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasbeehProvider()) { entry in
            TasbeehWidgetView(entry: entry)
        }
        .configurationDisplayName("Tasbeeh")
        .description("Track your daily dhikr count.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TasbeehWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    let entry: TasbeehEntry

    private var accentStart: Color { Color(red: 0.753, green: 0.702, blue: 0.941) } // lilac
    private var accentEnd: Color { Color(red: 0.576, green: 0.773, blue: 0.969) }   // blue

    private var bg: Color {
        colorScheme == .dark
            ? Color(red: 0.047, green: 0.047, blue: 0.055)
            : .white
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.1, green: 0.1, blue: 0.12)
    }

    private var secondaryText: Color {
        colorScheme == .dark ? Color.white.opacity(0.55) : Color(red: 0.4, green: 0.4, blue: 0.45)
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget
            default:
                mediumWidget
            }
        }
        .widgetBackground(bg)
    }

    private var smallWidget: some View {
        VStack(spacing: 8) {
            Text("Today")
                .font(.caption)
                .foregroundColor(accentStart.opacity(0.8))

            Text("\(entry.todayCount)")
                .font(.system(size: 48, weight: .thin, design: .rounded))
                .foregroundColor(primaryText)
                .monospacedDigit()

            if entry.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.caption2)
                    Text("\(entry.currentStreak)")
                        .font(.caption2)
                }
                .foregroundColor(accentEnd.opacity(0.7))
            }
        }
    }

    private var mediumWidget: some View {
        HStack {
            VStack(spacing: 8) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(accentStart.opacity(0.8))

                Text("\(entry.todayCount)")
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundColor(primaryText)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(secondaryText.opacity(0.2))

            VStack(spacing: 12) {
                statRow(icon: "infinity", label: "Lifetime", value: "\(entry.lifetimeCount)")
                statRow(icon: "flame", label: "Streak", value: "\(entry.currentStreak)d")
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(accentEnd.opacity(0.7))
                .frame(width: 16)

            Text(label)
                .font(.caption)
                .foregroundColor(secondaryText)

            Spacer()

            Text(value)
                .font(.caption)
                .foregroundColor(primaryText)
                .monospacedDigit()
        }
    }
}

// MARK: - Widget Background Modifier (iOS 17+ containerBackground)

extension View {
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return AnyView(
                self.containerBackground(color, for: .widget)
            )
        } else {
            return AnyView(
                self.padding()
                    .background(color)
            )
        }
    }
}
