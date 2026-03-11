import SwiftUI

struct TasbeehTheme {
    // Background
    let background: Color
    let gradientTop: Color
    let gradientBottom: Color

    // Text
    let primaryText: Color
    let secondaryText: Color
    let tertiaryText: Color

    // Surfaces
    let surface: Color
    let surfaceBorder: Color

    // Accent gradient
    let accentStart: Color // lilac
    let accentEnd: Color   // blue

    // Ring
    let ringTrack: Color
    let ringGlow: Color

    // Phase dots
    let dotActive: Color
    let dotInactive: Color

    // Heatmap tiers (0 = none, 1-4 = low to high)
    let heatmap1: Color
    let heatmap2: Color
    let heatmap3: Color
    let heatmap4: Color

    // Source badge
    let sourceBadgeBg: Color
    let sourceBadgeText: Color

    // Misc
    let isDark: Bool

    var accentGradient: LinearGradient {
        LinearGradient(colors: [accentStart, accentEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var ringGradient: LinearGradient {
        LinearGradient(colors: [accentStart, accentEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var headerGradient: LinearGradient {
        let blueStrong = accentEnd.opacity(isDark ? 0.60 : 0.75)
        let lilacStrong = accentStart.opacity(isDark ? 0.55 : 0.65)
        let lilacSoft = accentStart.opacity(isDark ? 0.32 : 0.38)
        let nearBg = background.opacity(isDark ? 0.72 : 0.76)

        return LinearGradient(
            gradient: Gradient(stops: [
                .init(color: blueStrong, location: 0.00),
                .init(color: lilacStrong, location: 0.28),
                .init(color: lilacSoft, location: 0.54),
                .init(color: nearBg, location: 0.80),
                .init(color: background, location: 1.00),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    init(for colorScheme: ColorScheme) {
        let dark = colorScheme == .dark
        self.isDark = dark

        // lilac #c0b3f0, blue #93c5f7
        let lilac = Color(red: 0.753, green: 0.702, blue: 0.941)
        let blue = Color(red: 0.576, green: 0.773, blue: 0.969)

        self.accentStart = lilac
        self.accentEnd = blue

        if dark {
            self.background = Color(red: 0.047, green: 0.047, blue: 0.055) // #0c0c0e
            self.gradientTop = blue.opacity(0.12)
            self.gradientBottom = Color.clear
            self.primaryText = .white
            self.secondaryText = Color.white.opacity(0.40)
            self.tertiaryText = Color.white.opacity(0.20)
            self.surface = Color.white.opacity(0.06)
            self.surfaceBorder = Color.white.opacity(0.08)
            self.ringTrack = Color.white.opacity(0.08)
            self.ringGlow = blue.opacity(0.50)
            self.dotActive = lilac
            self.dotInactive = Color.white.opacity(0.15)
            self.heatmap1 = lilac.opacity(0.15)
            self.heatmap2 = lilac.opacity(0.30)
            self.heatmap3 = Color(red: 0.66, green: 0.74, blue: 0.95).opacity(0.50)
            self.heatmap4 = blue.opacity(0.70)
            self.sourceBadgeBg = lilac.opacity(0.15)
            self.sourceBadgeText = lilac
        } else {
            self.background = .white
            self.gradientTop = Color(red: 0.839, green: 0.910, blue: 0.988)
            self.gradientBottom = Color.clear
            self.primaryText = Color(red: 0.1, green: 0.1, blue: 0.12)
            self.secondaryText = Color(red: 0.4, green: 0.4, blue: 0.45).opacity(0.75)
            self.tertiaryText = Color.black.opacity(0.24)
            self.surface = Color.black.opacity(0.025)
            self.surfaceBorder = Color.black.opacity(0.06)
            self.ringTrack = Color.black.opacity(0.05)
            self.ringGlow = lilac.opacity(0.25)
            self.dotActive = lilac
            self.dotInactive = Color.black.opacity(0.10)
            self.heatmap1 = lilac.opacity(0.12)
            self.heatmap2 = lilac.opacity(0.25)
            self.heatmap3 = Color(red: 0.66, green: 0.74, blue: 0.95).opacity(0.40)
            self.heatmap4 = blue.opacity(0.55)
            self.sourceBadgeBg = lilac.opacity(0.12)
            self.sourceBadgeText = Color(red: 0.55, green: 0.45, blue: 0.80)
        }
    }
}
