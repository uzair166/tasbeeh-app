import SwiftUI

@main
struct TasbeehApp: App {
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .preferredColorScheme(preferredColorScheme)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch appState.appearanceMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
