// Design Tokens - Spacing & Layout
// Auto-generated on 7/9/2025 - Do not edit manually

import UIKit

struct DesignSystemSpacing {

    // MARK: - Spacing Values


    static let spacing2xs: CGFloat = 2


    static let spacingS: CGFloat = 8


    static let spacing2xl: CGFloat = 24


    static let spacingM: CGFloat = 12


    static let spacingXl: CGFloat = 20


    static let spacingXs: CGFloat = 4


    static let spacingL: CGFloat = 16


    static let spacing6xl: CGFloat = 48


    static let spacing3xl: CGFloat = 28


    static let spacing4xl: CGFloat = 32


    static let spacing5xl: CGFloat = 20


    static let spacing7xl: CGFloat = 56


    static let spacing8xl: CGFloat = 64


    static let spacing9xl: CGFloat = 72


    static let spacing10xl: CGFloat = 80


    static let spacing11xl: CGFloat = 96


    static let spacing12xl: CGFloat = 128


    // MARK: - Border Radius Values


    static let large: CGFloat = 20


    static let medium: CGFloat = 16


    static let small: CGFloat = 8

}

// MARK: - UIEdgeInsets Helper
extension UIEdgeInsets {

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
}

// MARK: - Usage Example
/*
// Use spacing tokens
view.layer.cornerRadius = DesignSystemSpacing.radiusMd
stackView.spacing = DesignSystemSpacing.spacingLg

// Use insets helper
button.contentEdgeInsets = .all(DesignSystemSpacing.spacingSm)
*/