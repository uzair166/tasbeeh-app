import Foundation

struct DhikrPhase: Codable, Equatable, Hashable {
    let arabicText: String
    let count: Int
}

struct DhikrPreset: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var arabicName: String
    var phases: [DhikrPhase]
    var targetCount: Int
    var isBuiltIn: Bool

    var phaseTargetCount: Int {
        phases.reduce(0) { $0 + $1.count }
    }

    func currentPhase(for count: Int) -> DhikrPhase? {
        guard !phases.isEmpty else { return nil }
        var remaining = count % max(targetCount, 1)
        for phase in phases {
            if remaining < phase.count {
                return phase
            }
            remaining -= phase.count
        }
        return phases.last
    }

    func milestoneIndices() -> [Int] {
        guard phases.count > 1 else { return [] }
        var milestones: [Int] = []
        var cumulative = 0
        for phase in phases.dropLast() {
            cumulative += phase.count
            milestones.append(cumulative)
        }
        return milestones
    }

    func isPhaseTransition(at count: Int) -> Bool {
        milestoneIndices().contains(count)
    }
}

// MARK: - Built-in Presets

extension DhikrPreset {
    static let standardTasbeeh = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Standard Tasbeeh",
        arabicName: "تسبیح",
        phases: [
            DhikrPhase(arabicText: "سُبْحَانَ اللّٰهِ", count: 33),
            DhikrPhase(arabicText: "اَلْحَمْدُ لِلّٰهِ", count: 33),
            DhikrPhase(arabicText: "اَللّٰهُ أَكْبَرُ", count: 33),
            DhikrPhase(arabicText: "لَا إِلٰهَ إِلَّا اللّٰهُ", count: 1)
        ],
        targetCount: 100,
        isBuiltIn: true
    )

    static let subhanAllah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "SubhanAllah",
        arabicName: "سُبْحَانَ اللّٰهِ",
        phases: [DhikrPhase(arabicText: "سُبْحَانَ اللّٰهِ", count: 33)],
        targetCount: 33,
        isBuiltIn: true
    )

    static let alhamdulillah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Alhamdulillah",
        arabicName: "اَلْحَمْدُ لِلّٰهِ",
        phases: [DhikrPhase(arabicText: "اَلْحَمْدُ لِلّٰهِ", count: 33)],
        targetCount: 33,
        isBuiltIn: true
    )

    static let astaghfirullah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "Astaghfirullah",
        arabicName: "أَسْتَغْفِرُ اللّٰهَ",
        phases: [DhikrPhase(arabicText: "أَسْتَغْفِرُ اللّٰهَ", count: 100)],
        targetCount: 100,
        isBuiltIn: true
    )

    static let duroodShareef = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        name: "Durood Shareef",
        arabicName: "صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ",
        phases: [DhikrPhase(arabicText: "صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ", count: 100)],
        targetCount: 100,
        isBuiltIn: true
    )

    static let allBuiltIn: [DhikrPreset] = [
        .standardTasbeeh,
        .subhanAllah,
        .alhamdulillah,
        .astaghfirullah,
        .duroodShareef
    ]
}
