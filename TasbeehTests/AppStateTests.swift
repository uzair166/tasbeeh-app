import XCTest
@testable import Tasbeeh

final class AppStateTests: XCTestCase {

    private var appState: AppState!
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: "com.alliance.tasbeeh.tests")!
        // Clear all keys
        testDefaults.removePersistentDomain(forName: "com.alliance.tasbeeh.tests")
        appState = AppState(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: "com.alliance.tasbeeh.tests")
        super.tearDown()
    }

    // MARK: - Defaults

    func testDefaultHapticIntensity() {
        XCTAssertEqual(appState.hapticIntensity, .medium)
    }

    func testDefaultSoundDisabled() {
        XCTAssertFalse(appState.soundEnabled)
    }

    func testDefaultiCloudEnabled() {
        XCTAssertTrue(appState.iCloudSyncEnabled)
    }

    func testDefaultPresetIsQuickCounter() {
        XCTAssertEqual(appState.activePresetID, DhikrPreset.quickCounterID)
    }

    func testDefaultPresetsLoaded() {
        // Quick counter + all built-in presets
        XCTAssertEqual(appState.presets.count, DhikrPreset.allBuiltIn.count + 1)
    }

    func testQuickCounterIsFirstPreset() {
        XCTAssertTrue(appState.presets.first?.isQuickCounter == true)
    }

    func testDefaultCountersAreZero() {
        XCTAssertEqual(appState.lifetimeCount, 0)
        XCTAssertEqual(appState.todayCount, 0)
        XCTAssertEqual(appState.currentStreak, 0)
        XCTAssertEqual(appState.bestStreak, 0)
        XCTAssertEqual(appState.bestDayCount, 0)
        XCTAssertEqual(appState.bestDayDate, "")
        XCTAssertEqual(appState.lapsThisSession, 0)
    }

    // MARK: - Counting

    func testRecordCountIncrementsToday() {
        appState.recordCount()
        XCTAssertEqual(appState.todayCount, 1)
    }

    func testRecordCountIncrementsLifetime() {
        appState.recordCount()
        appState.recordCount()
        XCTAssertEqual(appState.lifetimeCount, 2)
    }

    func testRecordCountUpdatesHistory() {
        appState.recordCount()
        let today = AppState.todayString()
        XCTAssertEqual(appState.history[today], 1)
    }

    func testCompleteLap() {
        appState.completeLap()
        XCTAssertEqual(appState.lapsThisSession, 1)
        appState.completeLap()
        XCTAssertEqual(appState.lapsThisSession, 2)
    }

    // MARK: - Settings Persistence

    func testHapticIntensityPersists() {
        appState.hapticIntensity = .heavy
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.hapticIntensity, .heavy)
    }

    func testSoundEnabledPersists() {
        appState.soundEnabled = true
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertTrue(reloaded.soundEnabled)
    }

    func testDefaultAppearanceModeIsSystem() {
        XCTAssertEqual(appState.appearanceMode, .system)
    }

    func testAppearanceModePersists() {
        appState.appearanceMode = .dark
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.appearanceMode, .dark)
    }

    func testActivePresetPersists() {
        appState.activePresetID = DhikrPreset.subhanAllah.id
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.activePresetID, DhikrPreset.subhanAllah.id)
    }

    func testLifetimeCountPersists() {
        appState.recordCount()
        appState.recordCount()
        appState.recordCount()
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.lifetimeCount, 3)
    }

    // MARK: - Preset Management

    func testAddCustomPreset() {
        let custom = DhikrPreset(
            id: UUID(),
            name: "Test",
            arabicName: "تست",
            phases: [DhikrPhase(arabicText: "تست", transliteration: "Test", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        let beforeCount = appState.presets.count
        appState.addPreset(custom)
        XCTAssertEqual(appState.presets.count, beforeCount + 1)
        XCTAssertTrue(appState.presets.contains(where: { $0.id == custom.id }))
    }

    func testDeleteCustomPreset() {
        let custom = DhikrPreset(
            id: UUID(),
            name: "Delete Me",
            arabicName: "delete",
            phases: [DhikrPhase(arabicText: "delete", transliteration: "Delete", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        let beforeCount = appState.presets.count
        appState.addPreset(custom)
        appState.deletePreset(custom)
        XCTAssertEqual(appState.presets.count, beforeCount)
    }

    func testCannotDeleteBuiltInPreset() {
        let before = appState.presets.count
        appState.deletePreset(DhikrPreset.standardTasbeeh)
        XCTAssertEqual(appState.presets.count, before)
    }

    func testCannotDeleteQuickCounter() {
        let before = appState.presets.count
        appState.deletePreset(appState.presets.first(where: { $0.isQuickCounter })!)
        XCTAssertEqual(appState.presets.count, before)
    }

    func testDeleteActivePresetResetsToQuickCounter() {
        let custom = DhikrPreset(
            id: UUID(),
            name: "Active Custom",
            arabicName: "custom",
            phases: [DhikrPhase(arabicText: "custom", transliteration: "Custom", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        appState.addPreset(custom)
        appState.activePresetID = custom.id
        appState.deletePreset(custom)
        XCTAssertEqual(appState.activePresetID, DhikrPreset.quickCounterID)
    }

    func testUpdateQuickCounter() {
        appState.updateQuickCounter(arabicText: "test", transliteration: "Test", targetCount: 50)
        let qc = appState.presets.first(where: { $0.id == DhikrPreset.quickCounterID })!
        XCTAssertEqual(qc.arabicName, "test")
        XCTAssertEqual(qc.targetCount, 50)
        XCTAssertEqual(qc.phases.first?.transliteration, "Test")
    }

    func testQuickCounterMigration() {
        // Simulate old data without quick counter
        let oldPresets = DhikrPreset.allBuiltIn
        let data = try! JSONEncoder().encode(oldPresets)
        testDefaults.set(data, forKey: "presets")
        testDefaults.set(DhikrPreset.standardTasbeeh.id.uuidString, forKey: "activePresetID")

        let reloaded = AppState(defaults: testDefaults)
        // Quick counter should be inserted
        XCTAssertTrue(reloaded.presets.contains(where: { $0.id == DhikrPreset.quickCounterID }))
        XCTAssertEqual(reloaded.presets.count, DhikrPreset.allBuiltIn.count + 1)
        // Active preset should remain Standard Tasbeeh (existing user)
        XCTAssertEqual(reloaded.activePresetID, DhikrPreset.standardTasbeeh.id)
    }

    // MARK: - Active Preset

    func testActivePresetReturnsCorrectPreset() {
        appState.activePresetID = DhikrPreset.duroodShareef.id
        XCTAssertEqual(appState.activePreset.name, "Durood Shareef")
    }

    func testActivePresetFallsBackToQuickCounter() {
        appState.activePresetID = UUID() // non-existent
        XCTAssertEqual(appState.activePreset.id, DhikrPreset.quickCounterID)
    }

    // MARK: - Date Helpers

    func testTodayStringFormat() {
        let today = AppState.todayString()
        // Should be yyyy-MM-dd format
        let parts = today.split(separator: "-")
        XCTAssertEqual(parts.count, 3)
        XCTAssertEqual(parts[0].count, 4) // year
        XCTAssertEqual(parts[1].count, 2) // month
        XCTAssertEqual(parts[2].count, 2) // day
    }

    func testDateRoundTrip() {
        let date = Date()
        let string = AppState.dateString(for: date)
        let parsed = AppState.date(from: string)
        XCTAssertNotNil(parsed)
    }

    // MARK: - Best Streak

    func testBestStreakDefaultsToZero() {
        XCTAssertEqual(appState.bestStreak, 0)
    }

    func testBestStreakUpdatesWithCurrentStreak() {
        appState.currentStreak = 5
        XCTAssertEqual(appState.bestStreak, 5)
    }

    func testBestStreakDoesNotDecrease() {
        appState.currentStreak = 10
        XCTAssertEqual(appState.bestStreak, 10)
        appState.currentStreak = 3
        XCTAssertEqual(appState.bestStreak, 10)
    }

    func testBestStreakPersists() {
        appState.currentStreak = 7
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.bestStreak, 7)
    }

    func testBestStreakUpdatesOnHigherStreak() {
        appState.currentStreak = 5
        XCTAssertEqual(appState.bestStreak, 5)
        appState.currentStreak = 12
        XCTAssertEqual(appState.bestStreak, 12)
    }

    // MARK: - Best Day

    func testBestDayTrackedOnRecordCount() {
        appState.recordCount()
        XCTAssertEqual(appState.bestDayCount, 1)
        XCTAssertEqual(appState.bestDayDate, AppState.todayString())
    }

    func testBestDayUpdatesWithHigherCount() {
        for _ in 0..<5 {
            appState.recordCount()
        }
        XCTAssertEqual(appState.bestDayCount, 5)
    }

    func testBestDayDoesNotDecrease() {
        appState.bestDayCount = 100
        appState.bestDayDate = "2025-01-01"
        appState.recordCount()
        // todayCount is 1, which is less than 100
        XCTAssertEqual(appState.bestDayCount, 100)
        XCTAssertEqual(appState.bestDayDate, "2025-01-01")
    }

    func testBestDayPersists() {
        for _ in 0..<3 {
            appState.recordCount()
        }
        let reloaded = AppState(defaults: testDefaults)
        XCTAssertEqual(reloaded.bestDayCount, 3)
        XCTAssertEqual(reloaded.bestDayDate, AppState.todayString())
    }

    // MARK: - Computed Stats

    func testDaysActiveWithNoHistory() {
        XCTAssertEqual(appState.daysActive, 0)
    }

    func testDaysActiveWithHistory() {
        appState.history["2025-01-01"] = 10
        appState.history["2025-01-02"] = 5
        appState.history["2025-01-03"] = 0
        XCTAssertEqual(appState.daysActive, 2)
    }

    func testDailyAverageWithNoHistory() {
        XCTAssertEqual(appState.dailyAverage, 0)
    }

    func testDailyAverageWithHistory() {
        appState.history["2025-01-01"] = 10
        appState.history["2025-01-02"] = 20
        // 30 total / 2 active days = 15
        XCTAssertEqual(appState.dailyAverage, 15)
    }

    func testDailyAverageIgnoresZeroDays() {
        appState.history["2025-01-01"] = 10
        appState.history["2025-01-02"] = 0
        appState.history["2025-01-03"] = 20
        // 30 total / 2 active days = 15 (zero day not counted)
        XCTAssertEqual(appState.dailyAverage, 15)
    }

    func testThisMonthCount() {
        let today = AppState.todayString()
        let prefix = String(today.prefix(7)) // "yyyy-MM"
        appState.history["\(prefix)-01"] = 10
        appState.history["\(prefix)-15"] = 20
        appState.history["2020-01-01"] = 999 // old month, should not count
        XCTAssertEqual(appState.thisMonthCount, 30)
    }

    func testLast7DaysDataHasSevenEntries() {
        let data = appState.last7DaysData()
        XCTAssertEqual(data.count, 7)
    }

    func testLast7DaysDataIncludesToday() {
        appState.recordCount()
        let data = appState.last7DaysData()
        let todayEntry = data.last!
        XCTAssertEqual(AppState.dateString(for: todayEntry.date), AppState.todayString())
        XCTAssertEqual(todayEntry.count, 1)
    }

    func testLast7DaysDataReadsHistory() {
        let cal = Calendar.current
        let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))!
        appState.history[AppState.dateString(for: yesterday)] = 42
        let data = appState.last7DaysData()
        let yesterdayEntry = data[data.count - 2]
        XCTAssertEqual(yesterdayEntry.count, 42)
    }

    func testLast30DaysDataHas30Entries() {
        let data = appState.last30DaysData()
        XCTAssertEqual(data.count, 30)
    }

    func testThisWeekCountIncludesToday() {
        appState.recordCount()
        XCTAssertGreaterThanOrEqual(appState.thisWeekCount, 1)
    }
}
