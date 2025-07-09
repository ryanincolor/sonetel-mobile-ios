//
//  UpdatedDesignTokens.swift
//  Sonetel Mobile
//
//  Updated to integrate with Figma Generated Design Tokens
//

import SwiftUI

// MARK: - Unified Design System
struct UnifiedDesignSystem {
    // Use Figma tokens as the primary source
    static let figma = FigmaDesignSystem.self

    // Legacy tokens for backward compatibility
    static let legacy = LegacyDesignTokens.self
}

// MARK: - Legacy Design Tokens (for backward compatibility)
struct LegacyDesignTokens {
    // Keep existing tokens for components that haven't migrated yet
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color.white
        static let surface = Color(red: 0.97, green: 0.98, blue: 0.98)
    }

    struct Typography {
        static let h1 = Font.system(size: 32, weight: .bold)
        static let h2 = Font.system(size: 28, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
    }

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

// MARK: - Migration Helpers
extension View {
    /// Convenient method to apply Figma design system styles
    func sonetelCard() -> some View {
        self
            .figmaPadding("l")
            .figmaBackground("surface.primary")
            .figmaCornerRadius("medium")
    }

    func sonetelHeadline() -> some View {
        self
            .figmaTypography("headline.h3")
            .foregroundColor(FigmaColorTokens.textPrimary)
    }

    func sonetelBody() -> some View {
        self
            .figmaTypography("body.medium")
            .foregroundColor(FigmaColorTokens.textSecondary)
    }
}

// MARK: - Design System Usage Guidelines
/*

FIGMA DESIGN SYSTEM USAGE:

1. Colors:
   - Use FigmaDesignSystem.colors.Light.* for light mode
   - Use FigmaDesignSystem.colors.Dark.* for dark mode
   - Use adaptive colors: FigmaColorTokens.surfacePrimary, .textPrimary, etc.

2. Typography:
   - Headlines: FigmaDesignSystem.typography.headline_h1 to h6
   - Body text: FigmaDesignSystem.typography.body_large/medium/small
   - Labels: FigmaDesignSystem.typography.label_large/medium/small

3. Spacing:
   - Use .figmaPadding("size") for consistent padding
   - Available sizes: xs, s, m, l, xl, 2xl, 3xl, 4xl, 5xl
   - Direct access: FigmaDesignSystem.spacing.m, .l, etc.

4. Border Radius:
   - Use .figmaCornerRadius("size") for consistent corners
   - Available sizes: small, medium, large
   - Direct access: FigmaDesignSystem.radius.small, .medium, .large

EXAMPLES:

Text("Hello World")
    .figmaTypography("headline.h2")
    .foregroundColor(FigmaDesignSystem.colors.textPrimary)
    .figmaPadding("l")
    .figmaBackground("surface.secondary")
    .figmaCornerRadius("medium")

VStack {
    // Content
}
.sonetelCard() // Applies card styling from Figma tokens

*/
