import XCTest
@testable import Tasbeeh

final class DhikrPresetTests: XCTestCase {

    // MARK: - Built-in Presets

    func testAllBuiltInPresetsExist() {
        XCTAssertEqual(DhikrPreset.allBuiltIn.count, 5)
    }

    func testBuiltInPresetsAreMarkedBuiltIn() {
        for preset in DhikrPreset.allBuiltIn {
            XCTAssertTrue(preset.isBuiltIn, "\(preset.name) should be built-in")
        }
    }

    func testBuiltInPresetsHaveUniqueIDs() {
        let ids = DhikrPreset.allBuiltIn.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All preset IDs should be unique")
    }

    func testStandardTasbeehTarget() {
        let preset = DhikrPreset.standardTasbeeh
        XCTAssertEqual(preset.targetCount, 100)
        XCTAssertEqual(preset.phases.count, 4)
        XCTAssertEqual(preset.phaseTargetCount, 100)
    }

    // MARK: - Phase Calculation

    func testCurrentPhaseStandardTasbeeh() {
        let preset = DhikrPreset.standardTasbeeh

        // Count 0-32: SubhanAllah
        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "\u{0633}\u{064F}\u{0628}\u{0652}\u{062D}\u{064E}\u{0627}\u{0646}\u{064E} \u{0627}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")
        XCTAssertEqual(preset.currentPhase(for: 32)?.arabicText, "\u{0633}\u{064F}\u{0628}\u{0652}\u{062D}\u{064E}\u{0627}\u{0646}\u{064E} \u{0627}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")

        // Count 33-65: Alhamdulillah
        XCTAssertEqual(preset.currentPhase(for: 33)?.arabicText, "\u{0627}\u{064E}\u{0644}\u{0652}\u{062D}\u{064E}\u{0645}\u{0652}\u{062F}\u{064F} \u{0644}\u{0650}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")
        XCTAssertEqual(preset.currentPhase(for: 65)?.arabicText, "\u{0627}\u{064E}\u{0644}\u{0652}\u{062D}\u{064E}\u{0645}\u{0652}\u{062F}\u{064F} \u{0644}\u{0650}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")

        // Count 66-98: Allahu Akbar
        XCTAssertEqual(preset.currentPhase(for: 66)?.arabicText, "\u{0627}\u{064E}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{064F} \u{0623}\u{064E}\u{0643}\u{0652}\u{0628}\u{064E}\u{0631}\u{064F}")
        XCTAssertEqual(preset.currentPhase(for: 98)?.arabicText, "\u{0627}\u{064E}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{064F} \u{0623}\u{064E}\u{0643}\u{0652}\u{0628}\u{064E}\u{0631}\u{064F}")

        // Count 99: La ilaha illallah
        XCTAssertEqual(preset.currentPhase(for: 99)?.arabicText, "\u{0644}\u{064E}\u{0627} \u{0625}\u{0650}\u{0644}\u{0670}\u{0647}\u{064E} \u{0625}\u{0650}\u{0644}\u{0651}\u{064E}\u{0627} \u{0627}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{064F}")
    }

    func testSinglePhasePreset() {
        let preset = DhikrPreset.subhanAllah
        XCTAssertEqual(preset.phases.count, 1)
        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "\u{0633}\u{064F}\u{0628}\u{0652}\u{062D}\u{064E}\u{0627}\u{0646}\u{064E} \u{0627}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")
        XCTAssertEqual(preset.currentPhase(for: 32)?.arabicText, "\u{0633}\u{064F}\u{0628}\u{0652}\u{062D}\u{064E}\u{0627}\u{0646}\u{064E} \u{0627}\u{0644}\u{0644}\u{0651}\u{0670}\u{0647}\u{0650}")
    }

    // MARK: - Transliteration

    func testBuiltInPresetsHaveTransliteration() {
        for preset in DhikrPreset.allBuiltIn {
            for phase in preset.phases {
                XCTAssertFalse(phase.transliteration.isEmpty, "\(preset.name) phase should have transliteration")
            }
        }
    }

    func testBuiltInPresetsHaveIconText() {
        for preset in DhikrPreset.allBuiltIn {
            XCTAssertFalse(preset.iconText.isEmpty, "\(preset.name) should have iconText")
        }
    }

    // MARK: - Milestone Indices

    func testMilestoneIndicesStandardTasbeeh() {
        let milestones = DhikrPreset.standardTasbeeh.milestoneIndices()
        XCTAssertEqual(milestones, [33, 66, 99])
    }

    func testMilestoneIndicesSinglePhase() {
        let milestones = DhikrPreset.subhanAllah.milestoneIndices()
        XCTAssertTrue(milestones.isEmpty)
    }

    func testIsPhaseTransition() {
        let preset = DhikrPreset.standardTasbeeh
        XCTAssertTrue(preset.isPhaseTransition(at: 33))
        XCTAssertTrue(preset.isPhaseTransition(at: 66))
        XCTAssertTrue(preset.isPhaseTransition(at: 99))
        XCTAssertFalse(preset.isPhaseTransition(at: 34))
        XCTAssertFalse(preset.isPhaseTransition(at: 0))
        XCTAssertFalse(preset.isPhaseTransition(at: 100))
    }

    // MARK: - Codable

    func testPresetEncodeDecode() throws {
        let original = DhikrPreset.standardTasbeeh
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DhikrPreset.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testPhaseEncodeDecode() throws {
        let original = DhikrPhase(arabicText: "test", transliteration: "test", count: 33)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DhikrPhase.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testPhaseBackwardsCompatDecode() throws {
        // Simulate old data without transliteration field
        let json = #"{"arabicText":"test","count":33}"#
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DhikrPhase.self, from: data)
        XCTAssertEqual(decoded.arabicText, "test")
        XCTAssertEqual(decoded.transliteration, "")
        XCTAssertEqual(decoded.count, 33)
    }

    func testPresetBackwardsCompatDecode() throws {
        // Simulate old data without iconText field
        let preset = DhikrPreset(id: UUID(), name: "Test", arabicName: "تست", phases: [DhikrPhase(arabicText: "تست", count: 10)], targetCount: 10, isBuiltIn: false)
        let data = try JSONEncoder().encode(preset)
        // Decode — iconText should default to ""
        let decoded = try JSONDecoder().decode(DhikrPreset.self, from: data)
        XCTAssertEqual(decoded.name, "Test")
    }

    func testCustomPresetCreation() {
        let preset = DhikrPreset(
            id: UUID(),
            name: "Custom",
            arabicName: "مخصوص",
            phases: [DhikrPhase(arabicText: "مخصوص", transliteration: "Makhsoos", count: 50)],
            targetCount: 50,
            isBuiltIn: false
        )
        XCTAssertFalse(preset.isBuiltIn)
        XCTAssertEqual(preset.targetCount, 50)
        XCTAssertEqual(preset.phases.count, 1)
    }

    // MARK: - Quick Counter

    func testQuickCounterPresetExists() {
        let qc = DhikrPreset.quickCounter
        XCTAssertEqual(qc.id, DhikrPreset.quickCounterID)
        XCTAssertTrue(qc.isQuickCounter)
        XCTAssertTrue(qc.isBuiltIn)
        XCTAssertEqual(qc.targetCount, 33)
    }

    func testQuickCounterIDIsReserved() {
        XCTAssertEqual(DhikrPreset.quickCounterID.uuidString, "00000000-0000-0000-0000-000000000000")
    }

    func testBuiltInPresetsAreNotQuickCounter() {
        for preset in DhikrPreset.allBuiltIn {
            XCTAssertFalse(preset.isQuickCounter, "\(preset.name) should not be a quick counter")
        }
    }

    func testIsQuickCounterDefaultsFalse() {
        let preset = DhikrPreset(
            id: UUID(),
            name: "Test",
            arabicName: "test",
            phases: [DhikrPhase(arabicText: "test", count: 10)],
            targetCount: 10,
            isBuiltIn: false
        )
        XCTAssertFalse(preset.isQuickCounter)
    }

    func testIsQuickCounterEncodeDecode() throws {
        let qc = DhikrPreset.quickCounter
        let data = try JSONEncoder().encode(qc)
        let decoded = try JSONDecoder().decode(DhikrPreset.self, from: data)
        XCTAssertTrue(decoded.isQuickCounter)
        XCTAssertEqual(decoded.id, DhikrPreset.quickCounterID)
    }

    func testIsQuickCounterBackwardsCompatDecode() throws {
        // Old data without isQuickCounter field should default to false
        let json = """
        {"id":"00000000-0000-0000-0000-000000000001","name":"Test","arabicName":"test","phases":[{"arabicText":"test","count":10}],"targetCount":10,"isBuiltIn":true}
        """
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(DhikrPreset.self, from: data)
        XCTAssertFalse(decoded.isQuickCounter)
    }

    // MARK: - DhikrPhrase Library

    func testDhikrPhraseLibraryIsNotEmpty() {
        XCTAssertFalse(DhikrPhrase.library.isEmpty)
    }

    func testDhikrPhraseLibraryHasUniqueIDs() {
        let ids = DhikrPhrase.library.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All phrase IDs should be unique")
    }

    func testDhikrPhraseLibraryCount() {
        XCTAssertEqual(DhikrPhrase.library.count, 12)
    }

    func testDhikrPhrasesHaveRequiredFields() {
        for phrase in DhikrPhrase.library {
            XCTAssertFalse(phrase.arabicText.isEmpty, "\(phrase.id) should have Arabic text")
            XCTAssertFalse(phrase.transliteration.isEmpty, "\(phrase.id) should have transliteration")
            XCTAssertFalse(phrase.meaning.isEmpty, "\(phrase.id) should have meaning")
            XCTAssertGreaterThan(phrase.defaultCount, 0, "\(phrase.id) should have positive default count")
        }
    }

    func testDhikrPhraseDefaultCounts() {
        let subhanAllah = DhikrPhrase.library.first { $0.id == "subhanallah" }!
        XCTAssertEqual(subhanAllah.defaultCount, 33)

        let astaghfirullah = DhikrPhrase.library.first { $0.id == "astaghfirullah" }!
        XCTAssertEqual(astaghfirullah.defaultCount, 100)
    }
}
