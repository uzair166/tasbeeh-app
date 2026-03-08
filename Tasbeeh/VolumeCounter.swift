import AVFoundation
import MediaPlayer
import UIKit

final class VolumeCounter: ObservableObject {
    @Published var count: Int = 0

    private let appState: AppState
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var volumeObservation: NSKeyValueObservation?
    private var interruptionObserver: NSObjectProtocol?
    private var isAwaitingResetKVO = false
    private let targetVolume: Float = 0.5
    private let edgeThreshold: Float = 0.15
    private weak var volumeSlider: UISlider?

    init(appState: AppState = .shared) {
        self.appState = appState
        setupAudioSession()
    }

    deinit {
        volumeObservation?.invalidate()
        audioEngine?.stop()
        if let observer = interruptionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func setupVolumeView(in window: UIWindow?) {
        guard let window = window else { return }
        let mpView = MPVolumeView(frame: CGRect(x: -300, y: -300, width: 100, height: 100))
        window.addSubview(mpView)
        volumeSlider = mpView.subviews.first(where: { $0 is UISlider }) as? UISlider
        setSystemVolume(targetVolume)
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[Tasbeeh] Audio session setup failed: \(error)")
        }

        UIApplication.shared.isIdleTimerDisabled = true
        startSilentAudioEngine()
        startVolumeObservation()
        observeAudioInterruptions()
    }

    private func startSilentAudioEngine() {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.0001

        let frameCount: AVAudioFrameCount = 44100
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        player.scheduleBuffer(buffer, at: nil, options: .loops)
        do {
            try engine.start()
            player.play()
            audioEngine = engine
            playerNode = player
        } catch {
            print("[Tasbeeh] Audio engine failed: \(error)")
        }
    }

    private func observeAudioInterruptions() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let info = notification.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

            if type == .ended {
                let options = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
                if AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) {
                    self.restartAudioEngine()
                }
            }
        }
    }

    private func restartAudioEngine() {
        audioEngine?.stop()
        playerNode = nil
        audioEngine = nil

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
        } catch {
            print("[Tasbeeh] Failed to reactivate audio session: \(error)")
        }
        startSilentAudioEngine()
    }

    // MARK: - Volume Observation

    private func startVolumeObservation() {
        let session = AVAudioSession.sharedInstance()
        volumeObservation = session.observe(\.outputVolume, options: [.new, .old]) { [weak self] _, change in
            guard let self = self else { return }

            DispatchQueue.main.async {
                guard let newVal = change.newValue, let oldVal = change.oldValue,
                      abs(newVal - oldVal) > 0.01 else { return }

                if self.isAwaitingResetKVO {
                    self.isAwaitingResetKVO = false
                    return
                }

                self.handleButtonPress()

                if newVal <= self.edgeThreshold || newVal >= (1.0 - self.edgeThreshold) {
                    self.isAwaitingResetKVO = true
                    self.setSystemVolume(self.targetVolume)
                }
            }
        }
    }

    // MARK: - Counting

    private func handleButtonPress() {
        count += 1
        appState.recordCount()

        let preset = appState.activePreset
        let intensity = appState.hapticIntensity

        if appState.soundEnabled {
            SoundManager.shared.playClick()
        }

        if count >= preset.targetCount {
            HapticManager.shared.targetCompleteVibration(intensity: intensity)
            appState.completeLap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.count = 0
            }
        } else if preset.isPhaseTransition(at: count) {
            HapticManager.shared.milestoneVibration(intensity: intensity)
        } else {
            HapticManager.shared.countTap(intensity: intensity)
        }
    }

    private func setSystemVolume(_ volume: Float) {
        volumeSlider?.value = volume
    }

    func manualReset() {
        count = 0
        HapticManager.shared.milestoneVibration(intensity: appState.hapticIntensity)
    }
}
