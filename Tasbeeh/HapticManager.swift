import UIKit
import AudioToolbox

enum HapticIntensity: String, CaseIterable, Codable {
    case off
    case light
    case medium
    case heavy

    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .off: return nil
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        }
    }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        }
    }
}

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func countTap(intensity: HapticIntensity) {
        guard let style = intensity.feedbackStyle else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }

    func milestoneVibration(intensity: HapticIntensity) {
        guard intensity != .off else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    func targetCompleteVibration(intensity: HapticIntensity) {
        guard intensity != .off else { return }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
