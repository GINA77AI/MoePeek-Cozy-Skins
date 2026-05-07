// MoePeek Themes — Cozy Skin System
//
// A theming layer that sits on top of MoePeek's popup panel & trigger icon,
// replacing hardcoded macOS-default visuals with warm, cozy aesthetics.
//
// ## How it works
// 1. `Theme` holds every visual parameter for one skin.
// 2. `ThemeManager` holds the active theme (persisted in UserDefaults).
// 3. Each view reads from `ThemeManager.shared.current`.
// 4. Switching themes updates everything on next render.

import AppKit
import Defaults
import SwiftUI

// MARK: - UserDefaults Key

extension Defaults.Keys {
    static let selectedSkin = Key<String>("selectedSkin", default: "forest")
}

// MARK: - Theme Definition

struct Theme: Equatable {
    let id: String
    let name: String
    let emoji: String
    let description: String

    // Panel Background
    let panelBaseColor: Color
    let panelGradientTop: Color
    let panelGradientMid: Color
    let panelGradientBottom: Color?
    let panelShadowColor: Color
    let panelShadowRadius: CGFloat
    let panelCornerRadius: CGFloat

    // Result Card
    let cardBackgroundColor: Color
    let cardBorderColor: Color
    let cardBorderOpacity: Double
    let cardCornerRadius: CGFloat
    let cardBorderWidth: CGFloat

    // Text Colors
    let translationTextPrimary: Color
    let translationTextSecondary: Color
    let providerNameColor: Color
    let providerIconColor: Color
    let chevronColor: Color
    let hintTextColor: Color
    let secondaryHintColor: Color

    // Status Indicators
    let successColor: Color
    let waitingDotColor: Color
    let translatingColor: Color

    // Interactive Elements
    let actionButtonColor: Color
    let languageBarBackground: Color

    // Source Input
    let inputAreaBackground: Color

    // Trigger Icon (NSColor for AppKit draw())
    let triggerBaseColor: NSColor
    let triggerBorderColor: NSColor
    let triggerBorderOpacity: CGFloat
    let triggerGlowColor: NSColor
    let triggerGlowOpacity: CGFloat
    let triggerGlowBlur: CGFloat
    let triggerIconColor: NSColor
    let triggerInnerGradientTopAlpha: CGFloat

    // Divider
    let dividerOpacity: Double
}

// MARK: - Theme Manager

@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var current: Theme

    init() {
        let key = Defaults[.selectedSkin]
        self.current = Theme.fromId(key)
    }

    func apply(_ theme: Theme) {
        current = theme
        Defaults[.selectedSkin] = theme.id
    }

    // Nonisolated accessor so any context can read the list
    nonisolated static var allSkins: [Theme] {
        [.defaultMoePeek, .forestBreath, .cherryBlossom, .sunsetWarmth, .cloudSoft]
    }
}

// MARK: - Theme Lookup

extension Theme {
    static func fromId(_ id: String) -> Theme {
        ThemeManager.allSkins.first { $0.id == id } ?? .forestBreath
    }
}

// MARK: - Built-in Skins

extension Theme {

    // ──────────────────────────────────────────────
    // 📦 Default — Original MoePeek look
    // ──────────────────────────────────────────────
    static let defaultMoePeek = Theme(
        id: "default",
        name: "Default",
        emoji: "📦",
        description: "Original MoePeek appearance — clean & neutral",

        // Panel
        panelBaseColor: Color(red: 0.93, green: 0.93, blue: 0.94),
        panelGradientTop: Color.white.opacity(0),
        panelGradientMid: Color.clear,
        panelGradientBottom: nil,
        panelShadowColor: Color.black.opacity(0.12),
        panelShadowRadius: 12,
        panelCornerRadius: 12,

        // Card
        cardBackgroundColor: Color(red: 0.85, green: 0.85, blue: 0.86).opacity(0.50),
        cardBorderColor: Color(red: 0.70, green: 0.70, blue: 0.72),
        cardBorderOpacity: 0.06,
        cardCornerRadius: 6,
        cardBorderWidth: 0.5,

        // Text — use explicit grays instead of .primary/.secondary/.tertiary
        translationTextPrimary: Color(red: 0.10, green: 0.10, blue: 0.11),
        translationTextSecondary: Color(red: 0.25, green: 0.25, blue: 0.27),
        providerNameColor: Color(red: 0.30, green: 0.30, blue: 0.32),
        providerIconColor: Color(red: 0.35, green: 0.35, blue: 0.37),
        chevronColor: Color(red: 0.55, green: 0.55, blue: 0.57),
        hintTextColor: Color(red: 0.65, green: 0.65, blue: 0.67),
        secondaryHintColor: Color(red: 0.55, green: 0.55, blue: 0.57),

        // Status
        successColor: Color(red: 0.20, green: 0.60, blue: 0.20),
        waitingDotColor: Color(red: 0.65, green: 0.65, blue: 0.67),
        translatingColor: Color(red: 0.40, green: 0.40, blue: 0.42),

        // Interactive
        actionButtonColor: Color(red: 0.40, green: 0.40, blue: 0.42),
        languageBarBackground: Color.clear,

        // Input
        inputAreaBackground: Color.clear,

        // Trigger — use explicit NSColors
        triggerBaseColor: NSColor(red: 0.90, green: 0.90, blue: 0.91, alpha: 1.0),
        triggerBorderColor: NSColor(red: 0.75, green: 0.75, blue: 0.77, alpha: 1.0),
        triggerBorderOpacity: 0.6,
        triggerGlowColor: NSColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0),
        triggerGlowOpacity: 0.08,
        triggerGlowBlur: 4,
        triggerIconColor: NSColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1.0),
        triggerInnerGradientTopAlpha: 0.25,

        // Divider
        dividerOpacity: 0.3
    )

    // ──────────────────────────────────────────────
    // 🌿 Forest Breath — 森林呼吸
    // ──────────────────────────────────────────────
    static let forestBreath = Theme(
        id: "forest",
        name: "Forest Breath",
        emoji: "🌿",
        description: "Moss green & cream — like reading under an oak tree",

        // Panel
        panelBaseColor: Color(red: 0.95, green: 0.97, blue: 0.93),
        panelGradientTop: Color.white.opacity(0.30),
        panelGradientMid: Color(red: 0.88, green: 0.94, blue: 0.87).opacity(0.20),
        panelGradientBottom: Color.clear,
        panelShadowColor: Color.black.opacity(0.06),
        panelShadowRadius: 20,
        panelCornerRadius: 16,

        // Card
        cardBackgroundColor: Color(red: 0.93, green: 0.96, blue: 0.91).opacity(0.50),
        cardBorderColor: Color(red: 0.55, green: 0.72, blue: 0.48),
        cardBorderOpacity: 0.20,
        cardCornerRadius: 10,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.20, green: 0.28, blue: 0.18),
        translationTextSecondary: Color(red: 0.22, green: 0.30, blue: 0.20),
        providerNameColor: Color(red: 0.40, green: 0.52, blue: 0.36),
        providerIconColor: Color(red: 0.50, green: 0.64, blue: 0.46),
        chevronColor: Color(red: 0.60, green: 0.70, blue: 0.56),
        hintTextColor: Color(red: 0.62, green: 0.72, blue: 0.58),
        secondaryHintColor: Color(red: 0.50, green: 0.60, blue: 0.46),

        // Status
        successColor: Color(red: 0.38, green: 0.58, blue: 0.33),
        waitingDotColor: Color(red: 0.68, green: 0.78, blue: 0.64),
        translatingColor: Color(red: 0.45, green: 0.58, blue: 0.40),

        // Interactive
        actionButtonColor: Color(red: 0.40, green: 0.58, blue: 0.36),
        languageBarBackground: Color(red: 0.92, green: 0.95, blue: 0.89).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.95, green: 0.97, blue: 0.93).opacity(0.60),

        // Trigger
        triggerBaseColor: NSColor(red: 0.95, green: 0.97, blue: 0.92, alpha: 1.0),
        triggerBorderColor: NSColor(red: 0.58, green: 0.76, blue: 0.51, alpha: 1.0),
        triggerBorderOpacity: 0.35,
        triggerGlowColor: NSColor(red: 0.48, green: 0.66, blue: 0.42, alpha: 1.0),
        triggerGlowOpacity: 0.25,
        triggerGlowBlur: 6,
        triggerIconColor: NSColor(red: 0.32, green: 0.48, blue: 0.26, alpha: 1.0),
        triggerInnerGradientTopAlpha: 0.45,

        // Divider
        dividerOpacity: 0.12
    )

    // ──────────────────────────────────────────────
    // 🌸 Cherry Blossom — 春日樱花
    // ──────────────────────────────────────────────
    static let cherryBlossom = Theme(
        id: "cherry",
        name: "Cherry Blossom",
        emoji: "🌸",
        description: "Soft pink & cream — like receiving a gentle note",

        // Panel
        panelBaseColor: Color(red: 0.98, green: 0.95, blue: 0.96),
        panelGradientTop: Color.white.opacity(0.35),
        panelGradientMid: Color(red: 0.96, green: 0.90, blue: 0.93).opacity(0.18),
        panelGradientBottom: Color.clear,
        panelShadowColor: Color(red: 0.82, green: 0.72, blue: 0.78).opacity(0.10),
        panelShadowRadius: 22,
        panelCornerRadius: 20,

        // Card
        cardBackgroundColor: Color(red: 0.96, green: 0.92, blue: 0.94).opacity(0.55),
        cardBorderColor: Color(red: 0.75, green: 0.58, blue: 0.68),
        cardBorderOpacity: 0.22,
        cardCornerRadius: 12,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.28, green: 0.18, blue: 0.24),
        translationTextSecondary: Color(red: 0.32, green: 0.22, blue: 0.28),
        providerNameColor: Color(red: 0.54, green: 0.36, blue: 0.46),
        providerIconColor: Color(red: 0.64, green: 0.44, blue: 0.56),
        chevronColor: Color(red: 0.70, green: 0.56, blue: 0.64),
        hintTextColor: Color(red: 0.72, green: 0.64, blue: 0.69),
        secondaryHintColor: Color(red: 0.62, green: 0.53, blue: 0.60),

        // Status
        successColor: Color(red: 0.74, green: 0.42, blue: 0.58),
        waitingDotColor: Color(red: 0.81, green: 0.75, blue: 0.79),
        translatingColor: Color(red: 0.62, green: 0.46, blue: 0.56),

        // Interactive
        actionButtonColor: Color(red: 0.64, green: 0.44, blue: 0.56),
        languageBarBackground: Color(red: 0.95, green: 0.91, blue: 0.93).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.97, green: 0.95, blue: 0.96).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.96, green: 0.93, blue: 0.95, alpha: 1.0),
        triggerBorderColor: NSColor(red: 0.75, green: 0.61, blue: 0.70, alpha: 1.0),
        triggerBorderOpacity: 0.38,
        triggerGlowColor: NSColor(red: 0.78, green: 0.58, blue: 0.72, alpha: 1.0),
        triggerGlowOpacity: 0.22,
        triggerGlowBlur: 7,
        triggerIconColor: NSColor(red: 0.48, green: 0.29, blue: 0.43, alpha: 1.0),
        triggerInnerGradientTopAlpha: 0.50,

        // Divider
        dividerOpacity: 0.13
    )

    // ──────────────────────────────────────────────
    // 🎐 Sunset Warmth — 日落暖光
    // ──────────────────────────────────────────────
    static let sunsetWarmth = Theme(
        id: "sunset",
        name: "Sunset Warmth",
        emoji: "🎐",
        description: "Warm amber & ivory — like evening light by the window",

        // Panel
        panelBaseColor: Color(red: 0.98, green: 0.95, blue: 0.90),
        panelGradientTop: Color.white.opacity(0.30),
        panelGradientMid: Color(red: 0.96, green: 0.89, blue: 0.80).opacity(0.18),
        panelGradientBottom: Color(red: 0.93, green: 0.85, blue: 0.75).opacity(0.10),
        panelShadowColor: Color(red: 0.76, green: 0.64, blue: 0.46).opacity(0.11),
        panelShadowRadius: 24,
        panelCornerRadius: 14,

        // Card
        cardBackgroundColor: Color(red: 0.96, green: 0.93, blue: 0.88).opacity(0.50),
        cardBorderColor: Color(red: 0.78, green: 0.68, blue: 0.50),
        cardBorderOpacity: 0.20,
        cardCornerRadius: 10,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.26, green: 0.20, blue: 0.15),
        translationTextSecondary: Color(red: 0.30, green: 0.24, blue: 0.18),
        providerNameColor: Color(red: 0.54, green: 0.42, blue: 0.28),
        providerIconColor: Color(red: 0.62, green: 0.50, blue: 0.34),
        chevronColor: Color(red: 0.67, green: 0.55, blue: 0.41),
        hintTextColor: Color(red: 0.71, green: 0.63, blue: 0.53),
        secondaryHintColor: Color(red: 0.61, green: 0.53, blue: 0.41),

        // Status
        successColor: Color(red: 0.71, green: 0.54, blue: 0.28),
        waitingDotColor: Color(red: 0.80, green: 0.74, blue: 0.66),
        translatingColor: Color(red: 0.60, green: 0.48, blue: 0.34),

        // Interactive
        actionButtonColor: Color(red: 0.62, green: 0.47, blue: 0.31),
        languageBarBackground: Color(red: 0.94, green: 0.90, blue: 0.85).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.97, green: 0.95, blue: 0.91).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1.0),
        triggerBorderColor: NSColor(red: 0.75, green: 0.63, blue: 0.45, alpha: 1.0),
        triggerBorderOpacity: 0.34,
        triggerGlowColor: NSColor(red: 0.77, green: 0.61, blue: 0.36, alpha: 1.0),
        triggerGlowOpacity: 0.23,
        triggerGlowBlur: 6,
        triggerIconColor: NSColor(red: 0.46, green: 0.34, blue: 0.21, alpha: 1.0),
        triggerInnerGradientTopAlpha: 0.42,

        // Divider
        dividerOpacity: 0.13
    )

    // ──────────────────────────────────────────────
    // ☁️ Cloud Soft — 云朵软绵绵
    // ──────────────────────────────────────────────
    static let cloudSoft = Theme(
        id: "cloud",
        name: "Cloud Soft",
        emoji: "☁️",
        description: "Sky blue & lavender — light as lying on clouds",

        // Panel
        panelBaseColor: Color(red: 0.96, green: 0.96, blue: 0.99),
        panelGradientTop: Color.white.opacity(0.40),
        panelGradientMid: Color(red: 0.92, green: 0.92, blue: 0.98).opacity(0.18),
        panelGradientBottom: Color(red: 0.88, green: 0.88, blue: 0.96).opacity(0.08),
        panelShadowColor: Color(red: 0.66, green: 0.66, blue: 0.84).opacity(0.12),
        panelShadowRadius: 28,
        panelCornerRadius: 24,

        // Card
        cardBackgroundColor: Color(red: 0.94, green: 0.94, blue: 0.97).opacity(0.50),
        cardBorderColor: Color(red: 0.70, green: 0.70, blue: 0.85),
        cardBorderOpacity: 0.22,
        cardCornerRadius: 14,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.22, green: 0.22, blue: 0.32),
        translationTextSecondary: Color(red: 0.26, green: 0.26, blue: 0.36),
        providerNameColor: Color(red: 0.46, green: 0.46, blue: 0.60),
        providerIconColor: Color(red: 0.54, green: 0.54, blue: 0.68),
        chevronColor: Color(red: 0.63, green: 0.63, blue: 0.74),
        hintTextColor: Color(red: 0.70, green: 0.70, blue: 0.80),
        secondaryHintColor: Color(red: 0.60, green: 0.60, blue: 0.72),

        // Status
        successColor: Color(red: 0.46, green: 0.49, blue: 0.76),
        waitingDotColor: Color(red: 0.79, green: 0.79, blue: 0.87),
        translatingColor: Color(red: 0.55, green: 0.55, blue: 0.69),

        // Interactive
        actionButtonColor: Color(red: 0.49, green: 0.51, blue: 0.73),
        languageBarBackground: Color(red: 0.93, green: 0.93, blue: 0.97).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.96, green: 0.96, blue: 0.98).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0),
        triggerBorderColor: NSColor(red: 0.68, green: 0.68, blue: 0.84, alpha: 1.0),
        triggerBorderOpacity: 0.38,
        triggerGlowColor: NSColor(red: 0.61, green: 0.61, blue: 0.84, alpha: 1.0),
        triggerGlowOpacity: 0.24,
        triggerGlowBlur: 8,
        triggerIconColor: NSColor(red: 0.35, green: 0.35, blue: 0.57, alpha: 1.0),
        triggerInnerGradientTopAlpha: 0.50,

        // Divider
        dividerOpacity: 0.12
    )
}
