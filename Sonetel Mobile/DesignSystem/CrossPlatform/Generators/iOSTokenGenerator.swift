//
//  iOSTokenGenerator.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Generates iOS SwiftUI design tokens from cross-platform JSON
//

import Foundation
import SwiftUI

// MARK: - iOS Token Generator
struct iOSTokenGenerator {

    /// Generate iOS design tokens from cross-platform JSON
    static func generateTokens(from jsonData: Data) throws -> String {
        let decoder = JSONDecoder()
        let tokenSpec = try decoder.decode(CrossPlatformTokens.self, from: jsonData)

        var output = """
//
//  GeneratedDesignTokens.swift
//  Sonetel Mobile
//
//  Generated on \(Date())
//  DO NOT EDIT - This file is auto-generated from design tokens
//

import SwiftUI

// MARK: - Generated Design System
struct GeneratedDesignSystem: DesignTokens {
    static let colors = GeneratedColorTokens()
    static let typography = GeneratedTypographyTokens()
    static let spacing = GeneratedSpacingTokens()
    static let radius = GeneratedRadiusTokens()
    static let shadows = GeneratedShadowTokens()
}

"""

        // Generate Colors
        output += generateColorTokens(from: tokenSpec.tokens.color)

        // Generate Typography
        output += generateTypographyTokens(from: tokenSpec.tokens.typography)

        // Generate Spacing
        output += generateSpacingTokens(from: tokenSpec.tokens.spacing)

        // Generate Border Radius
        output += generateRadiusTokens(from: tokenSpec.tokens.borderRadius)

        // Generate Shadows
        if let shadows = tokenSpec.tokens.shadow {
            output += generateShadowTokens(from: shadows)
        }

        // Generate Component Tokens
        if let components = tokenSpec.components {
            output += generateComponentTokens(from: components)
        }

        output += """

// MARK: - Global Access
typealias GDS = GeneratedDesignSystem
"""

        return output
    }

    // MARK: - Color Generation
    private static func generateColorTokens(from colorTokens: CrossPlatformColorTokens) -> String {
        var output = """

// MARK: - Generated Color Tokens
struct GeneratedColorTokens {
    // MARK: - Primitive Colors
    struct Primitive {

"""

        // Generate primitive colors
        if let primitives = colorTokens.primitive {
            output += generatePrimitiveColors(from: primitives)
        }

        output += """
    }

    // MARK: - Semantic Colors
    struct Surface {

"""

        // Generate semantic colors
        if let semantic = colorTokens.semantic {
            if let surface = semantic.surface {
                output += generateSurfaceColors(from: surface)
            }
        }

        output += """
    }

    struct Text {

"""

        if let semantic = colorTokens.semantic, let text = semantic.text {
            output += generateTextColors(from: text)
        }

        output += """
    }

    struct Interactive {

"""

        if let semantic = colorTokens.semantic, let interactive = semantic.interactive {
            output += generateInteractiveColors(from: interactive)
        }

        output += """
    }

    struct Status {

"""

        if let semantic = colorTokens.semantic, let status = semantic.status {
            output += generateStatusColors(from: status)
        }

        output += """
    }

    struct Button {

"""

        if let semantic = colorTokens.semantic, let button = semantic.button {
            output += generateButtonColors(from: button)
        }

        output += """
    }
}

"""

        return output
    }

    private static func generatePrimitiveColors(from primitives: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in primitives.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.replacingOccurrences(of: "-", with: "").camelCased()
                output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
            }
        }

        return output
    }

    private static func generateSurfaceColors(from surface: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in surface.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.camelCased()
                if value.hasPrefix("rgba") {
                    output += "        static let \(swiftName) = \(parseRGBAToSwiftUI(value))\n"
                } else if value.hasPrefix("{") {
                    // Reference to another token
                    let reference = resolveTokenReference(value)
                    output += "        static let \(swiftName) = \(reference)\n"
                } else {
                    output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
                }
            }
        }

        return output
    }

    private static func generateTextColors(from text: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in text.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.camelCased()
                if value.hasPrefix("rgba") {
                    output += "        static let \(swiftName) = \(parseRGBAToSwiftUI(value))\n"
                } else if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        static let \(swiftName) = \(reference)\n"
                } else {
                    output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
                }
            }
        }

        return output
    }

    private static func generateInteractiveColors(from interactive: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in interactive.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.replacingOccurrences(of: "-", with: "").camelCased()
                if value.hasPrefix("rgba") {
                    output += "        static let \(swiftName) = \(parseRGBAToSwiftUI(value))\n"
                } else if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        static let \(swiftName) = \(reference)\n"
                } else {
                    output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
                }
            }
        }

        return output
    }

    private static func generateStatusColors(from status: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in status.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.camelCased()
                if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        static let \(swiftName) = \(reference)\n"
                } else {
                    output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
                }
            }
        }

        return output
    }

    private static func generateButtonColors(from button: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in button.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let swiftName = name.replacingOccurrences(of: "-", with: "").camelCased()
                if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        static let \(swiftName) = \(reference)\n"
                } else {
                    output += "        static let \(swiftName) = Color(hex: \"\(value)\")\n"
                }
            }
        }

        return output
    }

    // MARK: - Typography Generation
    private static func generateTypographyTokens(from typography: CrossPlatformTypographyTokens) -> String {
        var output = """

// MARK: - Generated Typography Tokens
struct GeneratedTypographyTokens {
    static let fontFamily = "\(typography.fontFamily?["primary"]?.value ?? "Inter")"

    struct Weight {

"""

        if let fontWeight = typography.fontWeight {
            for (name, token) in fontWeight.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let swiftName = name.camelCased()
                    let weightValue = mapFontWeight(value)
                    output += "        static let \(swiftName): Font.Weight = \(weightValue)\n"
                }
            }
        }

        output += """
    }

    struct Heading {

"""

        if let fontSize = typography.fontSize {
            let headings = fontSize.filter { $0.key.hasPrefix("h") }
            for (name, token) in headings.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let weight = getTypographyWeight(for: name)
                    output += "        static let \(name) = Font.system(size: \(size), weight: Weight.\(weight))\n"
                }
            }
        }

        output += """
    }

    struct Body {

"""

        if let fontSize = typography.fontSize {
            let bodies = fontSize.filter { $0.key.hasPrefix("body") }
            for (name, token) in bodies.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let swiftName = name.replacingOccurrences(of: "body-", with: "").camelCased()
                    output += "        static let \(swiftName) = Font.system(size: \(size), weight: Weight.medium)\n"
                }
            }
        }

        output += """
    }

    struct Label {

"""

        if let fontSize = typography.fontSize {
            let labels = fontSize.filter { $0.key.hasPrefix("label") }
            for (name, token) in labels.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let swiftName = name.replacingOccurrences(of: "label-", with: "").camelCased()
                    output += "        static let \(swiftName) = Font.system(size: \(size), weight: Weight.semibold)\n"
                }
            }
        }

        output += """
    }

    struct Tracking {

"""

        if let letterSpacing = typography.letterSpacing {
            for (name, token) in letterSpacing.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let swiftName = name.camelCased()
                    let trackingValue = parsePixelValue(value)
                    output += "        static let \(swiftName): CGFloat = \(trackingValue)\n"
                }
            }
        }

        output += """
    }
}

"""

        return output
    }

    // MARK: - Spacing Generation
    private static func generateSpacingTokens(from spacing: CrossPlatformSpacingTokens) -> String {
        var output = """

// MARK: - Generated Spacing Tokens
struct GeneratedSpacingTokens {

"""

        if let scale = spacing.scale {
            for (name, token) in scale.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let swiftName = name.camelCased()
                    let spacingValue = parsePixelValue(value)
                    output += "    static let \(swiftName): CGFloat = \(spacingValue)\n"
                }
            }
        }

        output += """

    struct Component {

"""

        if let component = spacing.component {
            for (name, token) in component.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let swiftName = name.replacingOccurrences(of: "-", with: "").camelCased()
                    let spacingValue = parsePixelValue(value)
                    output += "        static let \(swiftName): CGFloat = \(spacingValue)\n"
                }
            }
        }

        output += """
    }
}

"""

        return output
    }

    // MARK: - Border Radius Generation
    private static func generateRadiusTokens(from borderRadius: BorderRadiusTokens) -> String {
        var output = """

// MARK: - Generated Border Radius Tokens
struct GeneratedRadiusTokens {

"""

        for (name, token) in borderRadius.sorted(by: { $0.key < $1.key }) {
            if name != "component", let value = token.value {
                let swiftName = name.camelCased()
                let radiusValue = parsePixelValue(value)
                output += "    static let \(swiftName): CGFloat = \(radiusValue)\n"
            }
        }

        output += """

    struct Component {

"""

        // Handle component-specific radius if it exists
        // This would need to be parsed from the component section

        output += """
        static let button: CGFloat = 36
        static let card: CGFloat = 20
        static let menu: CGFloat = 20
        static let modal: CGFloat = 16
    }
}

"""

        return output
    }

    // MARK: - Shadow Generation
    private static func generateShadowTokens(from shadows: [String: ShadowToken]) -> String {
        var output = """

// MARK: - Generated Shadow Tokens
struct GeneratedShadowTokens {

"""

        for (name, shadow) in shadows.sorted(by: { $0.key < $1.key }) {
            if let shadowValue = shadow.value {
                let swiftName = name.camelCased()
                output += """
    struct \(swiftName.capitalized) {
        static let color = Color(hex: "\(shadowValue.color ?? "rgba(0,0,0,0.08)")")
        static let radius: CGFloat = \(parsePixelValue(shadowValue.blur ?? "8px"))
        static let x: CGFloat = \(parsePixelValue(shadowValue.offsetX ?? "0px"))
        static let y: CGFloat = \(parsePixelValue(shadowValue.offsetY ?? "2px"))
    }

"""
            }
        }

        output += "}\n\n"

        return output
    }

    // MARK: - Component Generation
    private static func generateComponentTokens(from components: [String: ComponentToken]) -> String {
        var output = """

// MARK: - Generated Component Tokens
struct GeneratedComponentTokens {

"""

        for (name, component) in components.sorted(by: { $0.key < $1.key }) {
            let swiftName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
            output += """
    struct \(swiftName) {

"""

            // Generate component properties
            for (property, value) in Mirror(reflecting: component).children {
                if let propertyName = property {
                    let swiftPropertyName = propertyName.camelCased()
                    if let stringValue = value as? String {
                        if stringValue.hasSuffix("px") {
                            output += "        static let \(swiftPropertyName): CGFloat = \(parsePixelValue(stringValue))\n"
                        } else if stringValue.hasPrefix("{") {
                            let reference = resolveTokenReference(stringValue)
                            output += "        static let \(swiftPropertyName) = \(reference)\n"
                        } else {
                            output += "        static let \(swiftPropertyName) = \"\(stringValue)\"\n"
                        }
                    }
                }
            }

            output += "    }\n\n"
        }

        output += "}\n\n"

        return output
    }

    // MARK: - Helper Methods
    private static func parseRGBAToSwiftUI(_ rgba: String) -> String {
        // Parse rgba(r, g, b, a) to SwiftUI Color
        let pattern = #"rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d\.]+)\)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: rgba, range: NSRange(rgba.startIndex..., in: rgba))

        if let match = matches.first {
            let r = (rgba as NSString).substring(with: match.range(at: 1))
            let g = (rgba as NSString).substring(with: match.range(at: 2))
            let b = (rgba as NSString).substring(with: match.range(at: 3))
            let a = (rgba as NSString).substring(with: match.range(at: 4))

            return "Color(red: \(Double(r)! / 255.0), green: \(Double(g)! / 255.0), blue: \(Double(b)! / 255.0), opacity: \(a))"
        }

        return "Color.black"
    }

    private static func resolveTokenReference(_ reference: String) -> String {
        // Convert {color.primitive.white} to Primitive.white
        let cleaned = reference.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        let parts = cleaned.split(separator: ".")

        if parts.count >= 3 {
            let category = String(parts[1]).capitalized
            let name = String(parts[2]).camelCased()
            return "\(category).\(name)"
        }

        return "Color.black"
    }

    private static func parsePixelValue(_ value: String) -> CGFloat {
        let cleaned = value.replacingOccurrences(of: "px", with: "")
        return CGFloat(Double(cleaned) ?? 0)
    }

    private static func mapFontWeight(_ weight: String) -> String {
        switch weight {
        case "400": return ".regular"
        case "500": return ".medium"
        case "600": return ".semibold"
        case "700": return ".bold"
        default: return ".regular"
        }
    }

    private static func getTypographyWeight(for fontSize: String) -> String {
        switch fontSize {
        case "h1", "h2": return "semibold"
        case "h3", "h4", "h5", "h6": return "semibold"
        default: return "medium"
        }
    }
}

// MARK: - String Extensions
extension String {
    func camelCased() -> String {
        let components = self.components(separatedBy: CharacterSet(charactersIn: "-_"))
        return components.enumerated().map { index, component in
            index == 0 ? component.lowercased() : component.capitalized
        }.joined()
    }
}
