// Design Tokens - Typography
// Auto-generated on 7/9/2025 - Do not edit manually

import UIKit

struct DesignSystemTypography {

    // MARK: - Font Sizes


    static let fontsizeHeadlineH1: CGFloat = 40


    static let fontsizeHeadlineH2: CGFloat = 34


    static let fontsizeHeadlineH3: CGFloat = 28


    static let fontsizeHeadlineH4: CGFloat = 24


    static let fontsizeHeadlineH5: CGFloat = 20


    static let fontsizeHeadlineH6: CGFloat = 18


    static let fontsizeLabelXlarge: CGFloat = 18


    static let fontsizeLabelLarge: CGFloat = 16


    static let fontsizeLabelMedium: CGFloat = 14


    static let fontsizeLabelSmall: CGFloat = 12


    static let fontsizeDisplayLarge: CGFloat = 72


    static let fontsizeDisplayMedium: CGFloat = 64


    static let fontsizeDisplaySmall: CGFloat = 56


    static let fontsizeDisplayXl: CGFloat = 96


    static let fontsizeBodyXlarge: CGFloat = 18


    static let fontsizeBodyLarge: CGFloat = 16


    static let fontsizeBodyMedium: CGFloat = 14


    static let fontsizeBodySmall: CGFloat = 12


    static let lineheightHeadlineH1: CGFloat = 46


    static let lineheightHeadlineH2: CGFloat = 40


    static let lineheightHeadlineH3: CGFloat = 34


    static let lineheightHeadlineH4: CGFloat = 29


    static let lineheightHeadlineH5: CGFloat = 24


    static let lineheightHeadlineH6: CGFloat = 22


    static let lineheightLabelXlarge: CGFloat = 20


    static let lineheightLabelLarge: CGFloat = 18


    static let lineheightLabelMedium: CGFloat = 16


    static let lineheightLabelSmall: CGFloat = 14


    static let lineheightDisplayXl: CGFloat = 96


    static let lineheightDisplayLarge: CGFloat = 80


    static let lineheightDisplayMedium: CGFloat = 64


    static let lineheightDisplaySmall: CGFloat = 56


    static let lineheightBodyXlarge: CGFloat = 22


    static let lineheightBodyLarge: CGFloat = 20


    static let lineheightBodyMedium: CGFloat = 18


    static let lineheightBodySmall: CGFloat = 16


    // MARK: - Font Weights


    /// Reference: {font.weight.regular}
    static let weightBodyRegular: UIFont.Weight = .regular


    /// Reference: {font.weight.medium}
    static let weightBodyProminent: UIFont.Weight = .medium

}

extension UIFont {

    // MARK: - Design System Fonts

    static func systemFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - Usage Example
/*
// Use typography tokens
let titleFont = UIFont.systemFont(
    ofSize: DesignSystemTypography.headlineH1,
    weight: DesignSystemTypography.bodyProminent
)
*/