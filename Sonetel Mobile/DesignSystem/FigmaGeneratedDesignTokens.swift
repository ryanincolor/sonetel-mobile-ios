//
//  FigmaGeneratedDesignTokens.swift
//  Sonetel Mobile
//
//  Generated from Figma Design Tokens on Jan 4, 2025 at 2:45 PM
//  DO NOT EDIT - This file is auto-generated
//

import SwiftUI

// MARK: - Figma Generated Design System
struct FigmaDesignSystem {
    struct colors {
        static let Light = FigmaColorTokens.Light.self
        static let Dark = FigmaColorTokens.Dark.self
        static let surfacePrimary = FigmaColorTokens.surfacePrimary
        static let surfaceSecondary = FigmaColorTokens.surfaceSecondary
        static let textPrimary = FigmaColorTokens.textPrimary
        static let textSecondary = FigmaColorTokens.textSecondary
        static let accentBlue = FigmaColorTokens.accentBlue
        static let accentGreen = FigmaColorTokens.accentGreen
        static let critical = FigmaColorTokens.critical
    }

    struct typography {
        static let headline_h1 = FigmaTypographyTokens.headline_h1
        static let headline_h2 = FigmaTypographyTokens.headline_h2
        static let headline_h3 = FigmaTypographyTokens.headline_h3
        static let headline_h4 = FigmaTypographyTokens.headline_h4
        static let headline_h5 = FigmaTypographyTokens.headline_h5
        static let headline_h6 = FigmaTypographyTokens.headline_h6
        static let body_large = FigmaTypographyTokens.body_large
        static let body_medium = FigmaTypographyTokens.body_medium
        static let body_small = FigmaTypographyTokens.body_small
        static let label_large = FigmaTypographyTokens.label_large
        static let label_medium = FigmaTypographyTokens.label_medium
        static let label_small = FigmaTypographyTokens.label_small
    }

    struct spacing {
        static let xs = FigmaSpacingTokens.xs
        static let s = FigmaSpacingTokens.s
        static let m = FigmaSpacingTokens.m
        static let l = FigmaSpacingTokens.l
        static let xl = FigmaSpacingTokens.xl
        static let _2xl = FigmaSpacingTokens._2xl
        static let _3xl = FigmaSpacingTokens._3xl
        static let _4xl = FigmaSpacingTokens._4xl
        static let _5xl = FigmaSpacingTokens._5xl
    }

    struct radius {
        static let small = FigmaBorderRadiusTokens.small
        static let medium = FigmaBorderRadiusTokens.medium
        static let large = FigmaBorderRadiusTokens.large
    }
}

// MARK: - Figma Color Tokens
struct FigmaColorTokens {
    // MARK: - Light Mode Colors
    struct Light {
        // MARK: - Accents
        static let blue = Color(hex: "#638eff")
        static let green = Color(hex: "#7ad085")
        static let orange = Color(hex: "#ff9e9e")
        static let pink = Color(hex: "#ff68b0")
        static let purple = Color(hex: "#aaa1f1")
        static let yellow = Color(hex: "#ffef62")

        // MARK: - Alert
        static let critical = Color(hex: "#EF4444")

        // MARK: - Interact
        static let hover = Color(hex: "rgba(0, 0, 0, 0.2)")

        // MARK: - On-Surface
        static let on_surface_inverse = Color(hex: "#FFFFFF")
        static let on_surface_primary = Color(hex: "#0A0A0A")
        static let on_surface_secondary = Color(hex: "#666666")
        static let on_surface_tertiary = Color(hex: "#E0E0E0")

        // MARK: - Outline
        static let subtle = Color(hex: "#e1e1e1")

        // MARK: - Solid
        static let Z0 = Color(hex: "#FFFFFF")
        static let Z1 = Color(hex: "#F5F5F5")
        static let Z2 = Color(hex: "#E6E6E6")
        static let Z3 = Color(hex: "#E0E0E0")
        static let Z4 = Color(hex: "#B8B8B8")
        static let Z5 = Color(hex: "#666666")
        static let Z6 = Color(hex: "#292929")
        static let Z7 = Color(hex: "#0A0A0A")

        // MARK: - Transparent
        static let T1 = Color.black.opacity(0.04)
        static let T2 = Color.black.opacity(0.08)
        static let T3 = Color.black.opacity(0.12)
        static let T4 = Color.black.opacity(0.16)
        static let T5 = Color.black.opacity(0.20)
        static let T6 = Color.black.opacity(0.24)
        static let T7 = Color.black.opacity(0.28)

        // MARK: - Other
        static let on_accent_surface_primary = Color(hex: "#111827")
        static let on_accent_surface_secondary = Color(hex: "#4B5563")
    }

    // MARK: - Dark Mode Colors
    struct Dark {
        // MARK: - Accents
        static let blue = Color(hex: "#638eff")
        static let green = Color(hex: "#7ad085")
        static let orange = Color(hex: "#ff9e9e")
        static let pink = Color(hex: "#ff68b0")
        static let purple = Color(hex: "#aaa1f1")
        static let yellow = Color(hex: "#ffef62")

        // MARK: - Alert
        static let critical = Color(hex: "#EF4444")

        // MARK: - Interact
        static let hover = Color(hex: "rgba(0, 0, 0, 0.2)")

        // MARK: - On-Surface
        static let on_surface_inverse = Color(hex: "#0A0A0A")
        static let on_surface_primary = Color(hex: "#FFFFFF")
        static let on_surface_secondary = Color(hex: "#B3B3B3")
        static let on_surface_tertiary = Color(hex: "#3f3f3f")

        // MARK: - Outline
        static let subtle = Color(hex: "#e1e1e1")

        // MARK: - Solid
        static let Z0 = Color(hex: "#0A0A0A")
        static let Z1 = Color(hex: "#141414")
        static let Z2 = Color(hex: "#1F1F1F")
        static let Z3 = Color(hex: "#333333")
        static let Z4 = Color(hex: "#3D3D3D")
        static let Z5 = Color(hex: "#808080")
        static let Z6 = Color(hex: "#B3B3B3")
        static let Z7 = Color(hex: "#FFFFFF")

        // MARK: - Transparent
        static let T1 = Color.white.opacity(0.04)
        static let T2 = Color.white.opacity(0.08)
        static let T3 = Color.white.opacity(0.12)
        static let T4 = Color.white.opacity(0.16)
        static let T5 = Color.white.opacity(0.20)
        static let T6 = Color.white.opacity(0.24)
        static let T7 = Color.white.opacity(0.28)

        // MARK: - Other
        static let on_accent_surface_primary = Color(hex: "#111827")
        static let on_accent_surface_secondary = Color(hex: "#4B5563")
    }
}

// MARK: - Figma Typography Tokens
struct FigmaTypographyTokens {
    // MARK: - Font Sizes
    static let body_large = Font.system(size: 16.0)
    static let body_medium = Font.system(size: 14.0)
    static let body_small = Font.system(size: 12.0)
    static let body_x_large = Font.system(size: 18.0)
    static let display_large = Font.system(size: 72.0)
    static let display_medium = Font.system(size: 64.0)
    static let display_small = Font.system(size: 56.0)
    static let display_xl = Font.system(size: 96.0)
    static let headline_h1 = Font.system(size: 40.0)
    static let headline_h2 = Font.system(size: 34.0)
    static let headline_h3 = Font.system(size: 28.0)
    static let headline_h4 = Font.system(size: 24.0)
    static let headline_h5 = Font.system(size: 20.0)
    static let headline_h6 = Font.system(size: 18.0)
    static let label_large = Font.system(size: 16.0)
    static let label_medium = Font.system(size: 14.0)
    static let label_small = Font.system(size: 12.0)
    static let label_x_large = Font.system(size: 18.0)

    // MARK: - Line Heights
    static let body_largeLineHeight: CGFloat = 20.0
    static let body_mediumLineHeight: CGFloat = 18.0
    static let body_smallLineHeight: CGFloat = 16.0
    static let body_x_largeLineHeight: CGFloat = 22.0
    static let display_largeLineHeight: CGFloat = 80.0
    static let display_mediumLineHeight: CGFloat = 64.0
    static let display_smallLineHeight: CGFloat = 56.0
    static let display_xlLineHeight: CGFloat = 96.0
    static let headline_h1LineHeight: CGFloat = 46.0
    static let headline_h2LineHeight: CGFloat = 40.0
    static let headline_h3LineHeight: CGFloat = 34.0
    static let headline_h4LineHeight: CGFloat = 29.0
    static let headline_h5LineHeight: CGFloat = 24.0
    static let headline_h6LineHeight: CGFloat = 22.0
    static let label_largeLineHeight: CGFloat = 18.0
    static let label_mediumLineHeight: CGFloat = 16.0
    static let label_smallLineHeight: CGFloat = 14.0
    static let label_x_largeLineHeight: CGFloat = 20.0
}

// MARK: - Figma Spacing Tokens
struct FigmaSpacingTokens {
    static let _2xs: CGFloat = 2.0
    static let _2xl: CGFloat = 24.0
    static let _3xl: CGFloat = 28.0
    static let _4xl: CGFloat = 32.0
    static let _5xl: CGFloat = 20.0
    static let _6xl: CGFloat = 48.0
    static let _7xl: CGFloat = 56.0
    static let _8xl: CGFloat = 64.0
    static let _9xl: CGFloat = 72.0
    static let _10xl: CGFloat = 80.0
    static let _11xl: CGFloat = 96.0
    static let _12xl: CGFloat = 128.0
    static let l: CGFloat = 16.0
    static let m: CGFloat = 12.0
    static let s: CGFloat = 8.0
    static let xl: CGFloat = 20.0
    static let xs: CGFloat = 4.0
}

// MARK: - Figma Border Radius Tokens
struct FigmaBorderRadiusTokens {
    static let large: CGFloat = 20.0
    static let medium: CGFloat = 16.0
    static let small: CGFloat = 8.0
}

// MARK: - SwiftUI Extensions for Figma Tokens
extension View {
    // MARK: - Spacing Extensions
    func figmaPadding(_ size: String) -> some View {
        switch size {
        case "xs": return self.padding(FigmaSpacingTokens.xs)
        case "s": return self.padding(FigmaSpacingTokens.s)
        case "m": return self.padding(FigmaSpacingTokens.m)
        case "l": return self.padding(FigmaSpacingTokens.l)
        case "xl": return self.padding(FigmaSpacingTokens.xl)
        case "2xl": return self.padding(FigmaSpacingTokens._2xl)
        case "3xl": return self.padding(FigmaSpacingTokens._3xl)
        case "4xl": return self.padding(FigmaSpacingTokens._4xl)
        case "5xl": return self.padding(FigmaSpacingTokens._5xl)
        default: return self.padding(FigmaSpacingTokens.m)
        }
    }

    // MARK: - Border Radius Extensions
    func figmaCornerRadius(_ size: String) -> some View {
        switch size {
        case "small": return self.cornerRadius(FigmaBorderRadiusTokens.small)
        case "medium": return self.cornerRadius(FigmaBorderRadiusTokens.medium)
        case "large": return self.cornerRadius(FigmaBorderRadiusTokens.large)
        default: return self.cornerRadius(FigmaBorderRadiusTokens.medium)
        }
    }

    // MARK: - Color Extensions
    func figmaBackground(_ colorName: String, mode: ColorScheme = .light) -> some View {
        let color: Color

        if mode == .light {
            switch colorName {
            case "surface.primary": color = FigmaColorTokens.Light.Z0
            case "surface.secondary": color = FigmaColorTokens.Light.Z1
            case "surface.tertiary": color = FigmaColorTokens.Light.Z2
            default: color = FigmaColorTokens.Light.Z0
            }
        } else {
            switch colorName {
            case "surface.primary": color = FigmaColorTokens.Dark.Z0
            case "surface.secondary": color = FigmaColorTokens.Dark.Z1
            case "surface.tertiary": color = FigmaColorTokens.Dark.Z2
            default: color = FigmaColorTokens.Dark.Z0
            }
        }

        return self.background(color)
    }

    // MARK: - Typography Extensions
    func figmaTypography(_ style: String) -> some View {
        switch style {
        case "headline.h1": return self.font(FigmaTypographyTokens.headline_h1)
        case "headline.h2": return self.font(FigmaTypographyTokens.headline_h2)
        case "headline.h3": return self.font(FigmaTypographyTokens.headline_h3)
        case "headline.h4": return self.font(FigmaTypographyTokens.headline_h4)
        case "headline.h5": return self.font(FigmaTypographyTokens.headline_h5)
        case "headline.h6": return self.font(FigmaTypographyTokens.headline_h6)
        case "body.large": return self.font(FigmaTypographyTokens.body_large)
        case "body.medium": return self.font(FigmaTypographyTokens.body_medium)
        case "body.small": return self.font(FigmaTypographyTokens.body_small)
        case "label.large": return self.font(FigmaTypographyTokens.label_large)
        case "label.medium": return self.font(FigmaTypographyTokens.label_medium)
        case "label.small": return self.font(FigmaTypographyTokens.label_small)
        default: return self.font(FigmaTypographyTokens.body_medium)
        }
    }
}

// MARK: - Color Extension for Hex Support (Figma specific)
extension Color {
    init(figmaHex: String) {
        let hex = figmaHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Adaptive Color Support
extension FigmaColorTokens {
    /// Get adaptive color that changes based on system appearance
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - Semantic Adaptive Colors

    // Surface Colors
    static let surfacePrimary = adaptiveColor(
        light: Light.Z0,
        dark: Dark.Z0
    )

    static let surfaceSecondary = adaptiveColor(
        light: Light.Z1,
        dark: Dark.Z1
    )

    static let surfaceTertiary = adaptiveColor(
        light: Light.Z2,
        dark: Dark.Z2
    )

    // Text Colors - Updated to use solid/z7 for dark text and solid/z5 for gray text
    static let textPrimary = adaptiveColor(
        light: Light.Z7,  // solid/z7 in light mode
        dark: Dark.Z7     // solid/z7 in dark mode
    )

    static let textSecondary = adaptiveColor(
        light: Light.Z5,  // solid/z5 in light mode
        dark: Dark.Z5     // solid/z5 in dark mode
    )

    // Transparent Overlays (adaptive) - Using exact Figma token values
    static let adaptiveT1 = adaptiveColor(
        light: Light.T1,
        dark: Dark.T1
    )

    static let adaptiveT2 = adaptiveColor(
        light: Light.T2,
        dark: Dark.T2
    )

    // Fixed Colors (same in both modes)
    static let accentBlue = Light.blue
    static let accentGreen = Light.green
    static let critical = Light.critical
}

// MARK: - Global Access
typealias FDS = FigmaDesignSystem
