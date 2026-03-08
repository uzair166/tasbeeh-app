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

    func testDefaultPresetIsStandardTasbeeh() {
        XCTAssertEqual(appState.activePresetID, DhikrPreset.standardTasbeeh.id)
    }

    func testDefaultPresetsLoaded() {
        XCTAssertEqual(appState.presets.count, DhikrPreset.allBuiltIn.count)
    }

    func testDefaultCountersAreZero() {
        XCTAssertEqual(appState.lifetimeCount, 0)
        XCTAssertEqual(appState.todayCount, 0)
        XCTAssertEqual(appState.currentStreak, 0)
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
            phases: [DhikrPhase(arabicText: "تست", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        appState.addPreset(custom)
        XCTAssertEqual(appState.presets.count, DhikrPreset.allBuiltIn.count + 1)
        XCTAssertTrue(appState.presets.contains(where: { $0.id == custom.id }))
    }

    func testDeleteCustomPreset() {
        let custom = DhikrPreset(
            id: UUID(),
            name: "Delete Me",
            arabicName: "delete",
            phases: [DhikrPhase(arabicText: "delete", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        appState.addPreset(custom)
        appState.deletePreset(custom)
        XCTAssertEqual(appState.presets.count, DhikrPreset.allBuiltIn.count)
    }

    func testCannotDeleteBuiltInPreset() {
        let before = appState.presets.count
        appState.deletePreset(DhikrPreset.standardTasbeeh)
        XCTAssertEqual(appState.presets.count, before)
    }

    func testDeleteActivePresetResetsToDefault() {
        let custom = DhikrPreset(
            id: UUID(),
            name: "Active Custom",
            arabicName: "custom",
            phases: [DhikrPhase(arabicText: "custom", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        appState.addPreset(custom)
        appState.activePresetID = custom.id
        appState.deletePreset(custom)
        XCTAssertEqual(appState.activePresetID, DhikrPreset.standardTasbeeh.id)
    }

    // MARK: - Active Preset

    func testActivePresetReturnsCorrectPreset() {
        appState.activePresetID = DhikrPreset.duroodShareef.id
        XCTAssertEqual(appState.activePreset.name, "Durood Shareef")
    }

    func testActivePresetFallsBackToDefault() {
        appState.activePresetID = UUID() // non-existent
        XCTAssertEqual(appState.activePreset.id, DhikrPreset.standardTasbeeh.id)
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
}
