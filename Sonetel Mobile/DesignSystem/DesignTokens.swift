//
//  DesignTokens.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Design System Tokens - Centralized design values from Figma
//

import SwiftUI

// MARK: - Design System Protocol
protocol DesignTokens {
    static var colors: LegacyColorTokens { get }
    static var typography: LegacyTypographyTokens { get }
    static var spacing: LegacySpacingTokens { get }
    static var radius: RadiusTokens { get }
    static var shadows: ShadowTokens { get }
}

// MARK: - Sonetel Design System
struct SonetelDesignSystem: DesignTokens {
    static let colors = LegacyColorTokens()
    static let typography = LegacyTypographyTokens()
    static let spacing = LegacySpacingTokens()
    static let radius = RadiusTokens()
    static let shadows = ShadowTokens()
}

// MARK: - Color Tokens
struct LegacyColorTokens {
    // MARK: - Primitive Colors (Base Palette)
    struct Primitive {
        static let white = Color.white
        static let black = Color.black
        static let gray50 = Color(red: 0.98, green: 0.98, blue: 0.98)  // #FAFAFA
        static let gray100 = Color(red: 0.961, green: 0.961, blue: 0.961) // #F5F5F5
        static let gray200 = Color(red: 0.953, green: 0.953, blue: 0.953) // #F3F3F3
        static let gray300 = Color(red: 0.878, green: 0.878, blue: 0.878) // #E0E0E0
        static let gray400 = Color(red: 0.741, green: 0.741, blue: 0.741) // #BDBDBD
        static let gray500 = Color(red: 0.620, green: 0.620, blue: 0.620) // #9E9E9E
        static let gray600 = Color(red: 0.459, green: 0.459, blue: 0.459) // #757575
        static let gray700 = Color(red: 0.259, green: 0.259, blue: 0.259) // #424242
        static let gray800 = Color(red: 0.129, green: 0.129, blue: 0.129) // #212121
        static let gray900 = Color(red: 0.067, green: 0.067, blue: 0.067) // #111111

        static let blue500 = Color(red: 0.129, green: 0.588, blue: 0.953) // #2196F3
        static let red500 = Color(red: 0.957, green: 0.263, blue: 0.212) // #F44336
        static let green500 = Color(red: 0.298, green: 0.686, blue: 0.314) // #4CAF50
        static let orange500 = Color(red: 1.0, green: 0.596, blue: 0.0) // #FF9800
        static let yellow500 = Color(red: 1.0, green: 0.937, blue: 0.384) // #FFEF62
    }

    // MARK: - Semantic Colors (Contextual Usage)
    struct Surface {
        static let primary = Primitive.white
        static let secondary = Primitive.gray200  // #F3F3F3
        static let tertiary = Primitive.gray100   // #F5F5F5
        static let overlay = Color(red: 0, green: 0, blue: 0, opacity: 0.04)
        static let border = Primitive.gray100     // #F5F5F5
        static let divider = Color(red: 0, green: 0, blue: 0, opacity: 0.04)
    }

    struct Text {
        static let primary = Primitive.gray900     // #111111
        static let secondary = FigmaColorTokens.textPrimary // Updated to use solid/z7
        static let tertiary = Color(red: 0, green: 0, blue: 0, opacity: 0.6)
        static let disabled = Color(red: 0, green: 0, blue: 0, opacity: 0.3)
        static let inverse = Primitive.white
    }

    struct Interactive {
        static let primary = Primitive.blue500
        static let primaryHover = Color(red: 0.098, green: 0.549, blue: 0.918)
        static let destructive = Primitive.red500
        static let destructiveHover = Color(red: 0.918, green: 0.239, blue: 0.192)
        static let pressed = Color(red: 0, green: 0, blue: 0, opacity: 0.08)
        static let disabled = Primitive.gray400
    }

    struct Status {
        static let success = Primitive.green500
        static let warning = Primitive.orange500
        static let error = Primitive.red500
        static let info = Primitive.blue500
    }

    struct Button {
        static let background = Primitive.gray200  // #F3F3F3
        static let backgroundPressed = Interactive.pressed
        static let text = Text.primary
        static let textDisabled = Text.disabled
    }
}

// MARK: - Typography Tokens
struct LegacyTypographyTokens {
    // MARK: - Font Family
    static let fontFamily = "Inter"

    // MARK: - Font Weights
    struct Weight {
        static let regular: Font.Weight = .regular    // 400
        static let medium: Font.Weight = .medium      // 500
        static let semibold: Font.Weight = .semibold  // 600
        static let bold: Font.Weight = .bold          // 700
    }

    // MARK: - Typography Scale
    struct Heading {
        static let h1 = Font.system(size: 34, weight: Weight.semibold)
        static let h2 = Font.system(size: 28, weight: Weight.bold)
        static let h3 = Font.system(size: 24, weight: Weight.semibold)
        static let h4 = Font.system(size: 22, weight: Weight.semibold)
        static let h5 = Font.system(size: 20, weight: Weight.semibold)
        static let h6 = Font.system(size: 18, weight: Weight.semibold)
    }

    struct Body {
        static let large = Font.system(size: 18, weight: Weight.medium)
        static let medium = Font.system(size: 16, weight: Weight.medium)
        static let small = Font.system(size: 14, weight: Weight.medium)
        static let xsmall = Font.system(size: 12, weight: Weight.medium)
    }

    struct Label {
        static let large = Font.system(size: 16, weight: Weight.semibold)
        static let medium = Font.system(size: 14, weight: Weight.semibold)
        static let small = Font.system(size: 12, weight: Weight.semibold)
    }

    // MARK: - Letter Spacing (Tracking)
    struct Tracking {
        static let tight: CGFloat = -0.4
        static let normal: CGFloat = -0.36
        static let wide: CGFloat = 0.374
    }
}

// MARK: - Spacing Tokens
struct LegacySpacingTokens {
    // Base spacing unit (4px)
    static let base: CGFloat = 4

    // Spacing Scale (multiples of base)
    static let xs: CGFloat = base          // 4px
    static let sm: CGFloat = base * 2      // 8px
    static let md: CGFloat = base * 3      // 12px
    static let lg: CGFloat = base * 4      // 16px
    static let xl: CGFloat = base * 5      // 20px
    static let xxl: CGFloat = base * 6     // 24px
    static let xxxl: CGFloat = base * 7    // 28px

    // Component-specific spacing
    struct Component {
        static let buttonPadding: CGFloat = 12
        static let cardPadding: CGFloat = 16
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let listItemHeight: CGFloat = 56
        static let headerHeight: CGFloat = 72
    }
}

// MARK: - Border Radius Tokens
struct RadiusTokens {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 1000 // Fully rounded

    // Component-specific radius
    struct Component {
        static let button: CGFloat = 36      // Circular buttons
        static let card: CGFloat = xl        // 20px
        static let menu: CGFloat = xl        // 20px
        static let modal: CGFloat = lg       // 16px
    }
}

// MARK: - Shadow Tokens
struct ShadowTokens {
    struct Card {
        static let color = Color.black.opacity(0.08)
        static let radius: CGFloat = 8
        static let x: CGFloat = 0
        static let y: CGFloat = 2
    }

    struct Modal {
        static let color = Color.black.opacity(0.15)
        static let radius: CGFloat = 16
        static let x: CGFloat = 0
        static let y: CGFloat = 8
    }
}

// MARK: - Global Design System Access
// Using FigmaDesignSystem as primary design system
typealias DS = FigmaDesignSystem
