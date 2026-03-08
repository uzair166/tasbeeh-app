import Foundation
import WidgetKit

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

    // MARK: - Active Preset

    @Published var activePresetID: UUID {
        didSet { save(Key.activePresetID, activePresetID.uuidString) }
    }

    @Published var presets: [DhikrPreset] {
        didSet { savePresets() }
    }

    var activePreset: DhikrPreset {
        presets.first { $0.id == activePresetID } ?? .standardTasbeeh
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
        didSet { save(Key.currentStreak, currentStreak) }
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

        // Load preset
        let presetIDString = store.string(forKey: Key.activePresetID) ?? DhikrPreset.standardTasbeeh.id.uuidString
        self.activePresetID = UUID(uuidString: presetIDString) ?? DhikrPreset.standardTasbeeh.id

        // Load presets
        if let data = store.data(forKey: Key.presets),
           let decoded = try? JSONDecoder().decode([DhikrPreset].self, from: data) {
            self.presets = decoded
        } else {
            self.presets = DhikrPreset.allBuiltIn
        }

        // Load counters
        self.lifetimeCount = store.integer(forKey: Key.lifetimeCount)
        self.todayCount = store.integer(forKey: Key.todayCount)
        self.currentStreak = store.integer(forKey: Key.currentStreak)
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
        history[Self.todayString()] = todayCount
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
        guard !preset.isBuiltIn else { return }
        presets.removeAll { $0.id == preset.id }
        if activePresetID == preset.id {
            activePresetID = DhikrPreset.standardTasbeeh.id
        }
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
    static let activePresetID = "activePresetID"
    static let presets = "presets"
    static let lifetimeCount = "lifetimeCount"
    static let todayCount = "todayCount"
    static let todayDate = "todayDate"
    static let currentStreak = "currentStreak"
    static let lastActiveDate = "lastActiveDate"
    static let history = "history"
}
