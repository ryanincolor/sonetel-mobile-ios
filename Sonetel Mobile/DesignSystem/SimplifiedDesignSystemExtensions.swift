//
//  SimplifiedDesignSystemExtensions.swift
//  Sonetel Mobile
//
//  Simplified design system extensions using Figma tokens
//

import SwiftUI

// MARK: - Simple Design System Access
// Note: DS is already declared in DesignTokens.swift and points to FigmaDesignSystem

struct SimpleDesignSystem {
    struct spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    struct colors {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let background = Color(UIColor.systemBackground)
        static let surface = Color(UIColor.secondarySystemBackground)
    }

    struct typography {
        static let h1 = Font.system(size: 32, weight: .bold)
        static let h2 = Font.system(size: 28, weight: .semibold)
        static let h3 = Font.system(size: 24, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let label = Font.system(size: 14, weight: .medium)
    }
}

// MARK: - Typography Extensions
extension View {
    func h1() -> some View {
        self.font(SimpleDesignSystem.typography.h1)
    }

    func h2() -> some View {
        self.font(SimpleDesignSystem.typography.h2)
    }

    func h3() -> some View {
        self.font(SimpleDesignSystem.typography.h3)
    }

    func bodyText() -> some View {
        self.font(SimpleDesignSystem.typography.body)
    }

    func labelText() -> some View {
        self.font(SimpleDesignSystem.typography.label)
    }
}
