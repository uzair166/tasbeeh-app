import Foundation
import WidgetKit

enum AppearanceMode: String, CaseIterable, Codable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

final class AppState: ObservableObject {
    static let shared = AppState()
    static let suiteName = "group.com.alliance.tasbeeh"

    private let defaults: UserDefaults
    private let ubiquitous = NSUbiquitousKeyValueStore.default

    // MARK: - Settings

    @Published var hapticIntensity: HapticIntensity {
        didSet { save(Key.hapticIntensity, hapticIntensity.rawValue) }
    }

    @Published var soundEnabled: Bool {
        didSet { save(Key.soundEnabled, soundEnabled) }
    }

    @Published var iCloudSyncEnabled: Bool {
        didSet { save(Key.iCloudSyncEnabled, iCloudSyncEnabled) }
    }

    @Published var appearanceMode: AppearanceMode {
        didSet { save(Key.appearanceMode, appearanceMode.rawValue) }
    }

    // MARK: - Active Preset

    @Published var activePresetID: UUID {
        didSet { save(Key.activePresetID, activePresetID.uuidString) }
    }

    @Published var presets: [DhikrPreset] {
        didSet { savePresets() }
    }

    var activePreset: DhikrPreset {
        presets.first { $0.id == activePresetID } ?? .quickCounter
    }

    // MARK: - Counters

    @Published var lifetimeCount: Int {
        didSet {
            save(Key.lifetimeCount, lifetimeCount)
            reloadWidget()
        }
    }

    @Published var todayCount: Int {
        didSet {
            save(Key.todayCount, todayCount)
            reloadWidget()
        }
    }

    @Published var currentStreak: Int {
        didSet {
            save(Key.currentStreak, currentStreak)
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        }
    }

    @Published var bestStreak: Int {
        didSet { save(Key.bestStreak, bestStreak) }
    }

    @Published var bestDayCount: Int {
        didSet { save(Key.bestDayCount, bestDayCount) }
    }

    @Published var bestDayDate: String {
        didSet { save(Key.bestDayDate, bestDayDate) }
    }

    @Published var lapsThisSession: Int = 0

    // MARK: - History

    @Published var history: [String: Int] {
        didSet { saveHistory() }
    }

    // MARK: - Private State

    private var todayDate: String {
        didSet { defaults.set(todayDate, forKey: Key.todayDate) }
    }

    private var lastActiveDate: String {
        didSet { defaults.set(lastActiveDate, forKey: Key.lastActiveDate) }
    }

    // MARK: - Init

    init(defaults: UserDefaults? = nil) {
        let store = defaults ?? UserDefaults(suiteName: AppState.suiteName) ?? .standard
        self.defaults = store

        // Load settings
        let rawIntensity = store.string(forKey: Key.hapticIntensity) ?? HapticIntensity.medium.rawValue
        self.hapticIntensity = HapticIntensity(rawValue: rawIntensity) ?? .medium
        self.soundEnabled = store.bool(forKey: Key.soundEnabled)
        self.iCloudSyncEnabled = store.object(forKey: Key.iCloudSyncEnabled) == nil ? true : store.bool(forKey: Key.iCloudSyncEnabled)
        let rawAppearance = store.string(forKey: Key.appearanceMode) ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: rawAppearance) ?? .system

        // Load preset
        let presetIDString = store.string(forKey: Key.activePresetID) ?? DhikrPreset.quickCounterID.uuidString
        self.activePresetID = UUID(uuidString: presetIDString) ?? DhikrPreset.quickCounterID

        // Load presets
        if let data = store.data(forKey: Key.presets),
           let decoded = try? JSONDecoder().decode([DhikrPreset].self, from: data) {
            // Migration: ensure quick counter exists
            if !decoded.contains(where: { $0.id == DhikrPreset.quickCounterID }) {
                self.presets = [DhikrPreset.quickCounter] + decoded
            } else {
                self.presets = decoded
            }
        } else {
            self.presets = [DhikrPreset.quickCounter] + DhikrPreset.allBuiltIn
        }

        // Load counters
        self.lifetimeCount = store.integer(forKey: Key.lifetimeCount)
        self.todayCount = store.integer(forKey: Key.todayCount)
        self.currentStreak = store.integer(forKey: Key.currentStreak)
        self.bestStreak = store.integer(forKey: Key.bestStreak)
        self.bestDayCount = store.integer(forKey: Key.bestDayCount)
        self.bestDayDate = store.string(forKey: Key.bestDayDate) ?? ""
        self.todayDate = store.string(forKey: Key.todayDate) ?? ""
        self.lastActiveDate = store.string(forKey: Key.lastActiveDate) ?? ""

        // Load history
        if let data = store.data(forKey: Key.history),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.history = decoded
        } else {
            self.history = [:]
        }

        // Check day rollover
        checkDayRollover()

        // Setup iCloud observer
        setupiCloudObserver()
    }

    // MARK: - Day Management

    func checkDayRollover() {
        let today = Self.todayString()
        if todayDate != today {
            // Save yesterday's count to history before resetting
            if !todayDate.isEmpty && todayCount > 0 {
                history[todayDate] = todayCount
            }
            todayDate = today
            todayCount = 0
        }
    }

    func recordCount() {
        checkDayRollover()
        todayCount += 1
        lifetimeCount += 1
        updateStreak()
        // Update today in history
        let today = Self.todayString()
        history[today] = todayCount
        // Track best day
        if todayCount > bestDayCount {
            bestDayCount = todayCount
            bestDayDate = today
        }
    }

    func completeLap() {
        lapsThisSession += 1
    }

    func resetSession() {
        // Session counters only — persisted counts remain
    }

    // MARK: - Streak Logic

    private func updateStreak() {
        let today = Self.todayString()
        if lastActiveDate == today { return }

        let yesterday = Self.dateString(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        if lastActiveDate == yesterday {
            currentStreak += 1
        } else if lastActiveDate != today {
            currentStreak = 1
        }
        lastActiveDate = today
    }

    // MARK: - Preset Management

    func addPreset(_ preset: DhikrPreset) {
        presets.append(preset)
    }

    func deletePreset(_ preset: DhikrPreset) {
        guard !preset.isBuiltIn && !preset.isQuickCounter else { return }
        presets.removeAll { $0.id == preset.id }
        if activePresetID == preset.id {
            activePresetID = DhikrPreset.quickCounterID
        }
    }

    func updateQuickCounter(arabicText: String, transliteration: String, targetCount: Int) {
        guard let index = presets.firstIndex(where: { $0.id == DhikrPreset.quickCounterID }) else { return }
        presets[index].arabicName = arabicText
        presets[index].phases = [DhikrPhase(arabicText: arabicText, transliteration: transliteration, count: targetCount)]
        presets[index].targetCount = targetCount
    }

    func updatePreset(_ preset: DhikrPreset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index] = preset
    }

    // MARK: - iCloud Sync

    private func setupiCloudObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ubiquitousStoreChanged),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitous
        )
        ubiquitous.synchronize()
    }

    @objc private func ubiquitousStoreChanged(_ notification: Notification) {
        guard iCloudSyncEnabled else { return }
        DispatchQueue.main.async { [weak self] in
            self?.mergeFromiCloud()
        }
    }

    private func mergeFromiCloud() {
        let remoteLifetime = Int(ubiquitous.longLong(forKey: Key.lifetimeCount))
        if remoteLifetime > lifetimeCount {
            lifetimeCount = remoteLifetime
        }

        let remoteStreak = Int(ubiquitous.longLong(forKey: Key.currentStreak))
        if remoteStreak > currentStreak {
            currentStreak = remoteStreak
        }

        let remoteBestStreak = Int(ubiquitous.longLong(forKey: Key.bestStreak))
        if remoteBestStreak > bestStreak {
            bestStreak = remoteBestStreak
        }

        let remoteBestDay = Int(ubiquitous.longLong(forKey: Key.bestDayCount))
        if remoteBestDay > bestDayCount {
            bestDayCount = remoteBestDay
            if let remoteBestDayDate = ubiquitous.string(forKey: Key.bestDayDate) {
                bestDayDate = remoteBestDayDate
            }
        }

        if let data = ubiquitous.data(forKey: Key.history),
           let remote = try? JSONDecoder().decode([String: Int].self, from: data) {
            for (date, count) in remote {
                if count > (history[date] ?? 0) {
                    history[date] = count
                }
            }
        }
    }

    // MARK: - Persistence Helpers

    private func save(_ key: String, _ value: Any) {
        defaults.set(value, forKey: key)
        guard iCloudSyncEnabled else { return }
        ubiquitous.set(value, forKey: key)
    }

    private func savePresets() {
        if let data = try? JSONEncoder().encode(presets) {
            defaults.set(data, forKey: Key.presets)
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Key.history)
            if iCloudSyncEnabled {
                ubiquitous.set(data, forKey: Key.history)
            }
        }
    }

    private func reloadWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Computed Stats

    var daysActive: Int {
        history.values.filter { $0 > 0 }.count
    }

    var dailyAverage: Int {
        guard daysActive > 0 else { return 0 }
        let total = history.values.reduce(0, +)
        return total / daysActive
    }

    var thisWeekCount: Int {
        let cal = Calendar.current
        let today = Date()
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return 0 }
        var total = 0
        for i in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: i, to: weekStart) else { continue }
            let key = Self.dateString(for: day)
            total += history[key] ?? 0
        }
        return total
    }

    var thisMonthCount: Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.year, .month], from: Date())
        let prefix = String(format: "%04d-%02d", components.year!, components.month!)
        return history.filter { $0.key.hasPrefix(prefix) }.values.reduce(0, +)
    }

    func last7DaysData() -> [(date: Date, count: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let key = Self.dateString(for: day)
            let count = key == Self.todayString() ? todayCount : (history[key] ?? 0)
            return (date: day, count: count)
        }
    }

    func last30DaysData() -> [(date: Date, count: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<30).reversed().compactMap { offset in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let key = Self.dateString(for: day)
            let count = key == Self.todayString() ? todayCount : (history[key] ?? 0)
            return (date: day, count: count)
        }
    }

    // MARK: - Date Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    static func todayString() -> String {
        dateFormatter.string(from: Date())
    }

    static func dateString(for date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}

// MARK: - UserDefaults Keys

fileprivate enum Key {
    static let hapticIntensity = "hapticIntensity"
    static let soundEnabled = "soundEnabled"
    static let iCloudSyncEnabled = "iCloudSyncEnabled"
    static let appearanceMode = "appearanceMode"
    static let activePresetID = "activePresetID"
    static let presets = "presets"
    static let lifetimeCount = "lifetimeCount"
    static let todayCount = "todayCount"
    static let todayDate = "todayDate"
    static let currentStreak = "currentStreak"
    static let bestStreak = "bestStreak"
    static let bestDayCount = "bestDayCount"
    static let bestDayDate = "bestDayDate"
    static let lastActiveDate = "lastActiveDate"
    static let history = "history"
}
