import SwiftUI

// MARK: - App Theme

enum AppTheme: String, CaseIterable {
    case light
    case dark

    var colors: ThemeColors {
        switch self {
        case .light: return .light
        case .dark:  return .dark
        }
    }
}

// MARK: - Theme Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .light
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Theme Colors

struct ThemeColors {
    let bg:             Color
    let surface:        Color
    let border:         Color
    let navBg:          Color
    let navBorder:      Color
    let t1:             Color   // primary text
    let t2:             Color
    let t3:             Color
    let t4:             Color
    let accent:         Color
    let accentBg:       Color
    let accentBorder:   Color
    let card:           Color
    let placeholder:    Color
    let chipBg:         Color
    let chipBorder:     Color
    let chipText:       Color
    let obCardBg:       Color
    let obCardSelected: Color
    let inputText:      Color

    // MARK: Light (default)
    static let light = ThemeColors(
        bg:             Color(hex: "fdf8f1"),
        surface:        Color(hex: "fff8ee"),
        border:         Color(hex: "e8d5bc"),
        navBg:          Color(hex: "fdf8f1"),
        navBorder:      Color(hex: "ead8c2"),
        t1:             Color(hex: "1c1008"),
        t2:             Color(hex: "7a5e3a"),
        t3:             Color(hex: "a07848"),
        t4:             Color(hex: "c4a070"),
        accent:         Color(hex: "c4893a"),
        accentBg:       Color(hex: "c4893a").opacity(0.10),
        accentBorder:   Color(hex: "c4893a").opacity(0.28),
        card:           Color(hex: "fff3e4"),
        placeholder:    Color(hex: "c8ab82"),
        chipBg:         Color(hex: "fff8ee"),
        chipBorder:     Color(hex: "e8d5bc"),
        chipText:       Color(hex: "9a7a50"),
        obCardBg:       Color(hex: "fff8ee"),
        obCardSelected: Color(hex: "fff0dc"),
        inputText:      Color(hex: "1c1008")
    )

    // MARK: Dark
    static let dark = ThemeColors(
        bg:             Color(hex: "0a0907"),
        surface:        Color(hex: "13100d"),
        border:         Color(hex: "2a231c"),
        navBg:          Color(hex: "0d0b09"),
        navBorder:      Color(hex: "1a1510"),
        t1:             Color(hex: "f0e6d3"),
        t2:             Color(hex: "8a7a6a"),
        t3:             Color(hex: "5a4e42"),
        t4:             Color(hex: "3a3028"),
        accent:         Color(hex: "c9a96e"),
        accentBg:       Color(hex: "c9a96e").opacity(0.12),
        accentBorder:   Color(hex: "c9a96e").opacity(0.22),
        card:           Color(hex: "1c160f"),
        placeholder:    Color(hex: "3a3028"),
        chipBg:         Color(hex: "13100d"),
        chipBorder:     Color(hex: "2a231c"),
        chipText:       Color(hex: "8a7a6a"),
        obCardBg:       Color(hex: "13100d"),
        obCardSelected: Color(hex: "1c160f"),
        inputText:      Color(hex: "f0e6d3")
    )
}

// MARK: - Feed Colors (always dark, regardless of theme)

enum FeedColors {
    static let bg         = Color(hex: "060504")
    static let brand      = Color(hex: "c9a96e")
    static let name       = Color(hex: "f0e6d3")
    static let price      = Color(hex: "8a7a6a")
    static let tagBg      = Color(hex: "c9a96e").opacity(0.12)
    static let tagBorder  = Color(hex: "c9a96e").opacity(0.20)
    static let tagText    = Color(hex: "c9a96e")
    static let skipBadge  = Color(hex: "d45858")
    static let topBarBg   = Color.black.opacity(0.70)
}

// MARK: - Occasion Chip Colors (light mode only)

struct ChipColor {
    let bg: Color; let border: Color; let text: Color
    static let weddingGuest = ChipColor(bg: Color(hex: "ffeef2"), border: Color(hex: "e8849a"), text: Color(hex: "c04060"))
    static let sangeetNight = ChipColor(bg: Color(hex: "fff4e6"), border: Color(hex: "d4893a"), text: Color(hex: "a05e1a"))
    static let diwaliParty  = ChipColor(bg: Color(hex: "e8f8f5"), border: Color(hex: "3aaa8e"), text: Color(hex: "1a7a64"))
    static let eidLunch     = ChipColor(bg: Color(hex: "f0eaf8"), border: Color(hex: "9060c0"), text: Color(hex: "6040a0"))
    static let reception    = ChipColor(bg: Color(hex: "e8f2ff"), border: Color(hex: "4080d0"), text: Color(hex: "2060a8"))
    static let all: [ChipColor] = [.weddingGuest, .sangeetNight, .diwaliParty, .eidLunch, .reception]
}

// MARK: - Typography
//
// SETUP: Download and bundle these fonts before building:
//   Playfair Display: https://fonts.google.com/specimen/Playfair+Display
//   DM Sans:          https://fonts.google.com/specimen/DM+Sans
//
// In Xcode: drag all .ttf files into the shauk/ group (check "Add to target: shauk"),
// then add each filename to Info.plist under "Fonts provided by application".
//
// Required Playfair Display variants: Regular, Medium, SemiBold, Bold, Italic
// Required DM Sans variants: Light (300), Regular (400), Medium (500), SemiBold (600)

enum DesignFonts {
    static func playfair(size: CGFloat, weight: Font.Weight = .regular, italic: Bool = false) -> Font {
        let name: String
        switch (weight, italic) {
        case (.medium, false):   name = "PlayfairDisplay-Medium"
        case (.semibold, false): name = "PlayfairDisplay-SemiBold"
        case (.bold, false):     name = "PlayfairDisplay-Bold"
        case (_, true):          name = "PlayfairDisplay-Italic"
        default:                 name = "PlayfairDisplay-Regular"
        }
        return .custom(name, size: size)
    }

    static func dmSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .light:    name = "DMSans-Light"
        case .medium:   name = "DMSans-Medium"
        case .semibold: name = "DMSans-SemiBold"
        case .bold:     name = "DMSans-Bold"
        default:        name = "DMSans-Regular"
        }
        return .custom(name, size: size)
    }
}

// MARK: - Spacing

enum Spacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 28
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius

enum Radius {
    static let xs:   CGFloat = 10
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 14
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 20
    static let pill: CGFloat = 100
}

// MARK: - Animations

extension Animation {
    /// Standard screen slide-in: cubic-bezier(0.25, 0.46, 0.45, 0.94)
    static let shaukSlide    = Animation.timingCurve(0.25, 0.46, 0.45, 0.94, duration: 0.35)
    static let shaukFade     = Animation.easeInOut(duration: 0.4)
    static let shaukSnap     = Animation.easeOut(duration: 0.2)
    /// Card exit animation: cubic-bezier(0.4, 0, 1, 1)
    static let shaukCardExit = Animation.timingCurve(0.4, 0, 1, 1, duration: 0.28)
}

// MARK: - View Transitions

extension AnyTransition {
    /// Slide up from bottom + fade — used for onboarding screen changes
    static let shaukSlideUp: AnyTransition = .asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .opacity
    )
}

// MARK: - Color Hex Initialiser

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable View Modifiers

/// Standard onboarding/app-wide CTA button style
struct PrimaryButtonStyle: ButtonStyle {
    let colors: ThemeColors
    var disabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignFonts.dmSans(size: 15, weight: .semibold))
            .foregroundColor(Color(hex: "0a0907"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(disabled ? colors.accent.opacity(0.3) : colors.accent)
            .cornerRadius(Radius.lg)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.shaukSnap, value: configuration.isPressed)
    }
}

/// Ghost/secondary CTA button (e.g. "Skip measurements")
struct GhostButtonStyle: ButtonStyle {
    let colors: ThemeColors

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignFonts.dmSans(size: 14))
            .foregroundColor(colors.t3)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}
