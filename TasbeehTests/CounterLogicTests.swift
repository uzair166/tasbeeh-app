import XCTest
@testable import Tasbeeh

final class CounterLogicTests: XCTestCase {

    // MARK: - Phase Transitions

    func testStandardTasbeehPhaseProgression() {
        let preset = DhikrPreset.standardTasbeeh

        // Verify all phases in order
        let expectedPhases = [
            (0, "سُبْحَانَ اللّٰهِ"),
            (32, "سُبْحَانَ اللّٰهِ"),
            (33, "اَلْحَمْدُ لِلّٰهِ"),
            (65, "اَلْحَمْدُ لِلّٰهِ"),
            (66, "اَللّٰهُ أَكْبَرُ"),
            (98, "اَللّٰهُ أَكْبَرُ"),
            (99, "لَا إِلٰهَ إِلَّا اللّٰهُ"),
        ]

        for (count, expectedText) in expectedPhases {
            let phase = preset.currentPhase(for: count)
            XCTAssertEqual(phase?.arabicText, expectedText, "At count \(count)")
        }
    }

    func testMilestoneDetectionAtBoundaries() {
        let preset = DhikrPreset.standardTasbeeh

        // Just before milestone: not a transition
        XCTAssertFalse(preset.isPhaseTransition(at: 32))
        // At milestone: is a transition
        XCTAssertTrue(preset.isPhaseTransition(at: 33))
        // Just after milestone: not a transition
        XCTAssertFalse(preset.isPhaseTransition(at: 34))
    }

    func testTargetReached() {
        let preset = DhikrPreset.standardTasbeeh
        // Simulate reaching target
        for count in 0..<100 {
            XCTAssertTrue(count < preset.targetCount, "Count \(count) should be below target")
        }
        XCTAssertTrue(100 >= preset.targetCount)
    }

    // MARK: - Custom Presets

    func testCustomPresetSinglePhase() {
        let preset = DhikrPreset(
            id: UUID(),
            name: "Custom 50",
            arabicName: "custom",
            phases: [DhikrPhase(arabicText: "custom", count: 50)],
            targetCount: 50,
            isBuiltIn: false
        )

        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "custom")
        XCTAssertEqual(preset.currentPhase(for: 49)?.arabicText, "custom")
        XCTAssertTrue(preset.milestoneIndices().isEmpty)
    }

    func testCustomPresetMultiPhase() {
        let preset = DhikrPreset(
            id: UUID(),
            name: "Two Phase",
            arabicName: "two",
            phases: [
                DhikrPhase(arabicText: "phase1", count: 25),
                DhikrPhase(arabicText: "phase2", count: 25),
            ],
            targetCount: 50,
            isBuiltIn: false
        )

        XCTAssertEqual(preset.currentPhase(for: 0)?.arabicText, "phase1")
        XCTAssertEqual(preset.currentPhase(for: 24)?.arabicText, "phase1")
        XCTAssertEqual(preset.currentPhase(for: 25)?.arabicText, "phase2")
        XCTAssertEqual(preset.currentPhase(for: 49)?.arabicText, "phase2")
        XCTAssertEqual(preset.milestoneIndices(), [25])
    }

    // MARK: - Haptic Intensity

    func testHapticIntensityAllCases() {
        XCTAssertEqual(HapticIntensity.allCases.count, 4)
        XCTAssertNil(HapticIntensity.off.feedbackStyle)
        XCTAssertNotNil(HapticIntensity.light.feedbackStyle)
        XCTAssertNotNil(HapticIntensity.medium.feedbackStyle)
        XCTAssertNotNil(HapticIntensity.heavy.feedbackStyle)
    }

    func testHapticIntensityCodable() throws {
        for intensity in HapticIntensity.allCases {
            let data = try JSONEncoder().encode(intensity)
            let decoded = try JSONDecoder().decode(HapticIntensity.self, from: data)
            XCTAssertEqual(intensity, decoded)
        }
    }

    // MARK: - Segment Fraction Logic

    func testSegmentFractionSinglePhase() {
        let preset = DhikrPreset.subhanAllah
        // At count 16 (roughly half of 33)
        let fraction = Double(16) / Double(preset.targetCount)
        XCTAssertEqual(fraction, 16.0 / 33.0, accuracy: 0.01)
    }
}
