// MoePeek Themes — Cozy Skin System
//
// A theming layer that sits on top of MoePeek's popup panel & trigger icon,
// replacing hardcoded macOS-default visuals with warm, cozy aesthetics.
//
// ## How it works
// 1. `Theme` is a struct holding every visual parameter for one skin.
// 2. `ThemeManager` holds the active theme (persisted in UserDefaults).
// 3. Each SwiftUI/AppKit view reads from `ThemeManager.shared.current`.
// 4. Switching themes updates everything on next render — no restart needed.
//
// ## Adding a new skin
// Define a static `Theme` here → add to `allThemes` array → done!
//

import AppKit
import Defaults
import SwiftUI

// MARK: - UserDefaults Key

extension Defaults.Keys {
    static let selectedSkin = Key<String>("selectedSkin", default: "forest")
}

// MARK: - Theme Definition

/// Complete visual specification for one skin.
struct Theme: Equatable {
    // --- Identity ---
    let id: String
    let name: String
    let emoji: String
    let description: String

    // --- Panel Background ---
    let panelBaseColor: Color          // Main background fill (semi-transparent recommended)
    let panelGradientTop: Color        // Gradient overlay top
    let panelGradientMid: Color        // Gradient overlay mid
    let panelGradientBottom: Color?    // Gradient overlay bottom (nil = transparent)
    let panelShadowColor: Color
    let panelShadowRadius: CGFloat
    let panelCornerRadius: CGFloat

    // --- Result Card ---
    let cardBackgroundColor: Color
    let cardBorderColor: Color
    let cardBorderOpacity: Double
    let cardCornerRadius: CGFloat
    let cardBorderWidth: CGFloat

    // --- Text Colors ---
    let translationTextPrimary: Color    // Final translation text
    let translationTextSecondary: Color   // Streaming/partial text
    let providerNameColor: Color          // Provider display name
    let providerIconColor: Color          // Provider icon tint
    let chevronColor: Color               // Expand/collapse chevron
    let hintTextColor: Color              // "Translate" / "Waiting..." hints
    let secondaryHintColor: Color         // TTS accent label etc.

    // --- Status Indicators ---
    let successColor: Color               // ✓ completed checkmark
    let waitingDotColor: Color            // ● waiting circle
    let translatingColor: Color           // "Translating..." text

    // --- Interactive Elements ---
    let actionButtonColor: Color          // TTS / swap buttons
    let languageBarBackground: Color

    // --- Source Input ---
    let inputAreaBackground: Color

    // --- Trigger Icon ---
    let triggerBaseColor: NSColor
    let triggerBorderColor: NSColor
    let triggerBorderOpacity: CGFloat
    let triggerGlowColor: NSColor
    let triggerGlowOpacity: CGFloat
    let triggerGlowBlur: CGFloat
    let triggerIconColor: NSColor
    let triggerInnerGradientTopAlpha: CGFloat

    // --- Divider ---
    let dividerOpacity: Double
}

// MARK: - Theme Manager

/// Singleton that manages which skin is currently active.
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

    /// All available skins, ordered for presentation.
    static var allSkins: [Theme] [
        .defaultMoePeek,
        .forestBreath,
        .cherryBlossom,
        .sunsetWarmth,
        .cloudSoft,
    ]
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
        panelBaseColor: Color(nsColor: .controlBackgroundColor),
        panelGradientTop: .white.opacity(0),
        panelGradientMid: .clear,
        panelGradientBottom: nil,
        panelShadowColor: .black.opacity(0.12),
        panelShadowRadius: 12,
        panelCornerRadius: 12,

        // Card
        cardBackgroundColor: Color.primary.opacity(0.03),
        cardBorderColor: .primary,
        cardBorderOpacity: 0.06,
        cardCornerRadius: 6,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: .primary,
        translationTextSecondary: .primary,
        providerNameColor: .primary,
        providerIconColor: .primary,
        chevronColor: .secondary,
        hintTextColor: .tertiary,
        secondaryHintColor: .secondary,

        // Status
        successColor: .green,
        waitingDotColor: .tertiary,
        translatingColor: .secondary,

        // Interactive
        actionButtonColor: .secondary,
        languageBarBackground: .clear,

        // Input
        inputAreaBackground: .clear,

        // Trigger
        triggerBaseColor: NSColor.controlBackgroundColor,
        triggerBorderColor: NSColor.separatorColor,
        triggerBorderOpacity: 0.6,
        triggerGlowColor: .black,
        triggerGlowOpacity: 0.08,
        triggerGlowBlur: 4,
        triggerIconColor: .labelColor,
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
        panelGradientTop: .white.opacity(0.30),
        panelGradientMid: Color(red: 0.88, green: 0.94, blue: 0.87).opacity(0.20),
        panelGradientBottom: .clear,
        panelShadowColor: .black.opacity(0.06),
        panelShadowRadius: 20,
        panelCornerRadius: 16,

        // Card
        cardBackgroundColor: Color(red: 0.93, green: 0.96, blue: 0.91).opacity(0.50),
        cardBorderColor: Color(red: 0.72, green: 0.84, blue: 0.68),
        cardBorderOpacity: 0.20,
        cardCornerRadius: 10,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.20, green: 0.28, blue: 0.18),   // Deep forest ink
        translationTextSecondary: Color(red: 0.22, green: 0.30, blue: 0.20),
        providerNameColor: Color(red: 0.40, green: 0.52, blue: 0.36),         // Warm olive
        providerIconColor: Color(red: 0.50, green: 0.64, blue: 0.46),
        chevronColor: Color(red: 0.60, green: 0.70, blue: 0.56),
        hintTextColor: Color(red: 0.70, green: 0.78, blue: 0.68),
        secondaryHintColor: Color(red: 0.55, green: 0.65, blue: 0.52),

        // Status
        successColor: Color(red: 0.45, green: 0.65, blue: 0.40),             // Moss green
        waitingDotColor: Color(red: 0.75, green: 0.82, blue: 0.71),
        translatingColor: Color(red: 0.50, green: 0.62, blue: 0.46),

        // Interactive
        actionButtonColor: Color(red: 0.45, green: 0.62, blue: 0.42),
        languageBarBackground: Color(red: 0.94, green: 0.96, blue: 0.91).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.96, green: 0.98, blue: 0.94).opacity(0.60),

        // Trigger
        triggerBaseColor: NSColor(red: 0.95, green: 0.97, blue: 0.92),
        triggerBorderColor: NSColor(red: 0.65, green: 0.80, blue: 0.58),
        triggerBorderOpacity: 0.35,
        triggerGlowColor: NSColor(red: 0.55, green: 0.72, blue: 0.50),
        triggerGlowOpacity: 0.25,
        triggerGlowBlur: 6,
        triggerIconColor: NSColor(red: 0.35, green: 0.52, blue: 0.32),
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
        panelGradientTop: .white.opacity(0.35),
        panelGradientMid: Color(red: 0.96, green: 0.90, blue: 0.93).opacity(0.18),
        panelGradientBottom: .clear,
        panelShadowColor: Color(red: 0.85, green: 0.75, blue: 0.82).opacity(0.10),
        panelShadowRadius: 22,
        panelCornerRadius: 20,

        // Card
        cardBackgroundColor: Color(red: 0.97, green: 0.93, blue: 0.95).opacity(0.55),
        cardBorderColor: Color(red: 0.88, green: 0.72, blue: 0.80),
        cardBorderOpacity: 0.22,
        cardCornerRadius: 12,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.28, green: 0.18, blue: 0.24),   // Rose ink
        translationTextSecondary: Color(red: 0.32, green: 0.22, blue: 0.28),
        providerNameColor: Color(red: 0.58, green: 0.40, blue: 0.50),         // Dusty rose
        providerIconColor: Color(red: 0.68, green: 0.48, blue: 0.60),
        chevronColor: Color(red: 0.74, green: 0.60, blue: 0.68),
        hintTextColor: Color(red: 0.76, green: 0.68, blue: 0.73),
        secondaryHintColor: Color(red: 0.66, green: 0.56, blue: 0.63),

        // Status
        successColor: Color(red: 0.80, green: 0.48, blue: 0.64),             // Soft rose
        waitingDotColor: Color(red: 0.86, green: 0.80, blue: 0.84),
        translatingColor: Color(red: 0.66, green: 0.50, blue: 0.60),

        // Interactive
        actionButtonColor: Color(red: 0.70, green: 0.50, blue: 0.62),
        languageBarBackground: Color(red: 0.96, green: 0.92, blue: 0.94).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.98, green: 0.96, blue: 0.97).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.97, green: 0.94, blue: 0.96),
        triggerBorderColor: NSColor(red: 0.82, green: 0.68, blue: 0.76),
        triggerBorderOpacity: 0.38,
        triggerGlowColor: NSColor(red: 0.85, green: 0.65, blue: 0.78),
        triggerGlowOpacity: 0.22,
        triggerGlowBlur: 7,
        triggerIconColor: NSColor(red: 0.54, green: 0.34, blue: 0.48),
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
        panelGradientTop: .white.opacity(0.30),
        panelGradientMid: Color(red: 0.96, green: 0.90, blue: 0.82).opacity(0.18),
        panelGradientBottom: Color(red: 0.94, green: 0.87, blue: 0.78).opacity(0.10),
        panelShadowColor: Color(red: 0.80, green: 0.68, blue: 0.50).opacity(0.11),
        panelShadowRadius: 24,
        panelCornerRadius: 14,

        // Card
        cardBackgroundColor: Color(red: 0.97, green: 0.94, blue: 0.89).opacity(0.50),
        cardBorderColor: Color(red: 0.84, green: 0.74, blue: 0.58),
        cardBorderOpacity: 0.20,
        cardCornerRadius: 10,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.26, green: 0.20, blue: 0.15),   // Warm charcoal
        translationTextSecondary: Color(red: 0.30, green: 0.24, blue: 0.18),
        providerNameColor: Color(red: 0.56, green: 0.44, blue: 0.30),         // Amber brown
        providerIconColor: Color(red: 0.64, green: 0.52, blue: 0.36),
        chevronColor: Color(red: 0.70, green: 0.58, blue: 0.44),
        hintTextColor: Color(red: 0.74, green: 0.66, blue: 0.56),
        secondaryHintColor: Color(red: 0.64, green: 0.56, blue: 0.44),

        // Status
        successColor: Color(red: 0.75, green: 0.58, blue: 0.32),             // Golden amber
        waitingDotColor: Color(red: 0.84, green: 0.78, blue: 0.70),
        translatingColor: Color(red: 0.64, green: 0.52, blue: 0.38),

        // Interactive
        actionButtonColor: Color(red: 0.66, green: 0.50, blue: 0.34),
        languageBarBackground: Color(red: 0.95, green: 0.92, blue: 0.87).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.98, green: 0.96, blue: 0.92).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.97, green: 0.94, blue: 0.90),
        triggerBorderColor: NSColor(red: 0.80, green: 0.68, blue: 0.50),
        triggerBorderOpacity: 0.34,
        triggerGlowColor: NSColor(red: 0.82, green: 0.66, blue: 0.40),
        triggerGlowOpacity: 0.23,
        triggerGlowBlur: 6,
        triggerIconColor: NSColor(red: 0.50, green: 0.38, blue: 0.24),
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
        panelGradientTop: .white.opacity(0.40),
        panelGradientMid: Color(red: 0.92, green: 0.92, blue: 0.98).opacity(0.18),
        panelGradientBottom: Color(red: 0.88, green: 0.89, blue: 0.97).opacity(0.08),
        panelShadowColor: Color(red: 0.70, green: 0.70, blue: 0.88).opacity(0.12),
        panelShadowRadius: 28,
        panelCornerRadius: 24,

        // Card
        cardBackgroundColor: Color(red: 0.95, green: 0.95, blue: 0.98).opacity(0.50),
        cardBorderColor: Color(red: 0.76, green: 0.76, blue: 0.90),
        cardBorderOpacity: 0.22,
        cardCornerRadius: 14,
        cardBorderWidth: 0.5,

        // Text
        translationTextPrimary: Color(red: 0.22, green: 0.22, blue: 0.32),   // Deep indigo
        translationTextSecondary: Color(red: 0.26, green: 0.26, blue: 0.36),
        providerNameColor: Color(red: 0.48, green: 0.48, blue: 0.62),         // Slate purple
        providerIconColor: Color(red: 0.56, green: 0.56, blue: 0.70),
        chevronColor: Color(red: 0.66, green: 0.66, blue: 0.77),
        hintTextColor: Color(red: 0.72, green: 0.72, blue: 0.82),
        secondaryHintColor: Color(red: 0.62, green: 0.62, blue: 0.74),

        // Status
        successColor: Color(red: 0.50, green: 0.52, blue: 0.80),             // Periwinkle
        waitingDotColor: Color(red: 0.82, green: 0.82, blue: 0.90),
        translatingColor: Color(red: 0.58, green: 0.58, blue: 0.72),

        // Interactive
        actionButtonColor: Color(red: 0.52, green: 0.54, blue: 0.76),
        languageBarBackground: Color(red: 0.94, green: 0.94, blue: 0.98).opacity(0.50),

        // Input
        inputAreaBackground: Color(red: 0.97, green: 0.97, blue: 0.99).opacity(0.55),

        // Trigger
        triggerBaseColor: NSColor(red: 0.96, green: 0.96, blue: 0.99),
        triggerBorderColor: NSColor(red: 0.72, green: 0.72, blue: 0.88),
        triggerBorderOpacity: 0.38,
        triggerGlowColor: NSColor(red: 0.65, green: 0.65, blue: 0.88),
        triggerGlowOpacity: 0.24,
        triggerGlowBlur: 8,
        triggerIconColor: NSColor(red: 0.38, green: 0.38, blue: 0.60),
        triggerInnerGradientTopAlpha: 0.50,

        // Divider
        dividerOpacity: 0.12
    )
}
