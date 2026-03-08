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
        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "سُبْحَانَ اللّٰهِ")
        XCTAssertEqual(preset.currentPhase(for: 32)?.arabicText, "سُبْحَانَ اللّٰهِ")

        // Count 33-65: Alhamdulillah
        XCTAssertEqual(preset.currentPhase(for: 33)?.arabicText, "اَلْحَمْدُ لِلّٰهِ")
        XCTAssertEqual(preset.currentPhase(for: 65)?.arabicText, "اَلْحَمْدُ لِلّٰهِ")

        // Count 66-98: Allahu Akbar
        XCTAssertEqual(preset.currentPhase(for: 66)?.arabicText, "اَللّٰهُ أَكْبَرُ")
        XCTAssertEqual(preset.currentPhase(for: 98)?.arabicText, "اَللّٰهُ أَكْبَرُ")

        // Count 99: La ilaha illallah
        XCTAssertEqual(preset.currentPhase(for: 99)?.arabicText, "لَا إِلٰهَ إِلَّا اللّٰهُ")
    }

    func testSinglePhasePreset() {
        let preset = DhikrPreset.subhanAllah
        XCTAssertEqual(preset.phases.count, 1)
        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "سُبْحَانَ اللّٰهِ")
        XCTAssertEqual(preset.currentPhase(for: 32)?.arabicText, "سُبْحَانَ اللّٰهِ")
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
        let original = DhikrPhase(arabicText: "test", count: 33)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DhikrPhase.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testCustomPresetCreation() {
        let preset = DhikrPreset(
            id: UUID(),
            name: "Custom",
            arabicName: "مخصوص",
            phases: [DhikrPhase(arabicText: "مخصوص", count: 50)],
            targetCount: 50,
            isBuiltIn: false
        )
        XCTAssertFalse(preset.isBuiltIn)
        XCTAssertEqual(preset.targetCount, 50)
        XCTAssertEqual(preset.phases.count, 1)
    }
}
