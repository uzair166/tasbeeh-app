import AudioToolbox

final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    private var soundID: SystemSoundID = 0
    private var isLoaded = false

    private func loadSound() {
        guard !isLoaded else { return }
        // Use system tock sound (1105 = Tock)
        soundID = 1105
        isLoaded = true
    }

    func playClick() {
        loadSound()
        AudioServicesPlaySystemSound(soundID)
    }
}
