import Foundation

struct DhikrPhase: Codable, Equatable, Hashable {
    let arabicText: String
    let transliteration: String
    let count: Int

    init(arabicText: String, transliteration: String = "", count: Int) {
        self.arabicText = arabicText
        self.transliteration = transliteration
        self.count = count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arabicText = try container.decode(String.self, forKey: .arabicText)
        transliteration = try container.decodeIfPresent(String.self, forKey: .transliteration) ?? ""
        count = try container.decode(Int.self, forKey: .count)
    }
}

struct DhikrPreset: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var arabicName: String
    var phases: [DhikrPhase]
    var targetCount: Int
    var isBuiltIn: Bool
    var iconText: String
    var isQuickCounter: Bool

    init(id: UUID, name: String, arabicName: String, phases: [DhikrPhase], targetCount: Int, isBuiltIn: Bool, iconText: String = "", isQuickCounter: Bool = false) {
        self.id = id
        self.name = name
        self.arabicName = arabicName
        self.phases = phases
        self.targetCount = targetCount
        self.isBuiltIn = isBuiltIn
        self.iconText = iconText
        self.isQuickCounter = isQuickCounter
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        arabicName = try container.decode(String.self, forKey: .arabicName)
        phases = try container.decode([DhikrPhase].self, forKey: .phases)
        targetCount = try container.decode(Int.self, forKey: .targetCount)
        isBuiltIn = try container.decode(Bool.self, forKey: .isBuiltIn)
        iconText = try container.decodeIfPresent(String.self, forKey: .iconText) ?? ""
        isQuickCounter = try container.decodeIfPresent(Bool.self, forKey: .isQuickCounter) ?? false
    }

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

// MARK: - Quick Counter

extension DhikrPreset {
    static let quickCounterID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    static let quickCounter = DhikrPreset(
        id: quickCounterID,
        name: "Quick Counter",
        arabicName: "سُبْحَانَ اللّٰهِ",
        phases: [DhikrPhase(arabicText: "سُبْحَانَ اللّٰهِ", transliteration: "SubhanAllah", count: 33)],
        targetCount: 33,
        isBuiltIn: true,
        isQuickCounter: true
    )
}

// MARK: - Built-in Presets

extension DhikrPreset {
    static let standardTasbeeh = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Standard Tasbeeh",
        arabicName: "تسبیح",
        phases: [
            DhikrPhase(arabicText: "سُبْحَانَ اللّٰهِ", transliteration: "SubhanAllah", count: 33),
            DhikrPhase(arabicText: "اَلْحَمْدُ لِلّٰهِ", transliteration: "Alhamdulillah", count: 33),
            DhikrPhase(arabicText: "اَللّٰهُ أَكْبَرُ", transliteration: "Allahu Akbar", count: 33),
            DhikrPhase(arabicText: "لَا إِلٰهَ إِلَّا اللّٰهُ", transliteration: "La ilaha illallah", count: 1)
        ],
        targetCount: 100,
        isBuiltIn: true,
        iconText: "تسب"
    )

    static let subhanAllah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "SubhanAllah",
        arabicName: "سُبْحَانَ اللّٰهِ",
        phases: [DhikrPhase(arabicText: "سُبْحَانَ اللّٰهِ", transliteration: "SubhanAllah", count: 33)],
        targetCount: 33,
        isBuiltIn: true,
        iconText: "سبح"
    )

    static let alhamdulillah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Alhamdulillah",
        arabicName: "اَلْحَمْدُ لِلّٰهِ",
        phases: [DhikrPhase(arabicText: "اَلْحَمْدُ لِلّٰهِ", transliteration: "Alhamdulillah", count: 33)],
        targetCount: 33,
        isBuiltIn: true,
        iconText: "حمد"
    )

    static let astaghfirullah = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "Astaghfirullah",
        arabicName: "أَسْتَغْفِرُ اللّٰهَ",
        phases: [DhikrPhase(arabicText: "أَسْتَغْفِرُ اللّٰهَ", transliteration: "Astaghfirullah", count: 100)],
        targetCount: 100,
        isBuiltIn: true,
        iconText: "است"
    )

    static let duroodShareef = DhikrPreset(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        name: "Durood Shareef",
        arabicName: "صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ",
        phases: [DhikrPhase(arabicText: "صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ", transliteration: "Sallallahu Alaihi Wasallam", count: 100)],
        targetCount: 100,
        isBuiltIn: true,
        iconText: "صلو"
    )

    static let allBuiltIn: [DhikrPreset] = [
        .standardTasbeeh,
        .subhanAllah,
        .alhamdulillah,
        .astaghfirullah,
        .duroodShareef
    ]
}
