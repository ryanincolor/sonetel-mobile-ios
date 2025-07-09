//
//  AndroidTokenGenerator.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Generates Android Jetpack Compose design tokens from cross-platform JSON
//

import Foundation

// MARK: - Android Token Generator
struct AndroidTokenGenerator {

    /// Generate Android Jetpack Compose design tokens from cross-platform JSON
    static func generateTokens(from jsonData: Data) throws -> String {
        let decoder = JSONDecoder()
        let tokenSpec = try decoder.decode(CrossPlatformTokens.self, from: jsonData)

        var output = """
package com.sonetel.mobile.designsystem

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Generated Design System Tokens
 * Generated on \(Date())
 * DO NOT EDIT - This file is auto-generated from design tokens
 */

object SonetelDesignSystem {
    val colors = Colors
    val typography = Typography
    val spacing = Spacing
    val radius = BorderRadius
    val shadows = Shadows
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

        return output
    }

    // MARK: - Color Generation
    private static func generateColorTokens(from colorTokens: CrossPlatformColorTokens) -> String {
        var output = """

object Colors {
    // Primitive Colors
    object Primitive {

"""

        // Generate primitive colors
        if let primitives = colorTokens.primitive {
            output += generatePrimitiveColors(from: primitives)
        }

        output += """
    }

    // Semantic Colors
    object Surface {

"""

        // Generate semantic colors
        if let semantic = colorTokens.semantic {
            if let surface = semantic.surface {
                output += generateSurfaceColors(from: surface)
            }
        }

        output += """
    }

    object Text {

"""

        if let semantic = colorTokens.semantic, let text = semantic.text {
            output += generateTextColors(from: text)
        }

        output += """
    }

    object Interactive {

"""

        if let semantic = colorTokens.semantic, let interactive = semantic.interactive {
            output += generateInteractiveColors(from: interactive)
        }

        output += """
    }

    object Status {

"""

        if let semantic = colorTokens.semantic, let status = semantic.status {
            output += generateStatusColors(from: status)
        }

        output += """
    }

    object Button {

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
                let kotlinName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
                output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
            }
        }

        return output
    }

    private static func generateSurfaceColors(from surface: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in surface.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let kotlinName = name.camelCased().capitalized
                if value.hasPrefix("rgba") {
                    output += "        val \(kotlinName) = \(parseRGBAToCompose(value))\n"
                } else if value.hasPrefix("{") {
                    // Reference to another token
                    let reference = resolveTokenReference(value)
                    output += "        val \(kotlinName) = \(reference)\n"
                } else {
                    output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
                }
            }
        }

        return output
    }

    private static func generateTextColors(from text: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in text.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let kotlinName = name.camelCased().capitalized
                if value.hasPrefix("rgba") {
                    output += "        val \(kotlinName) = \(parseRGBAToCompose(value))\n"
                } else if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        val \(kotlinName) = \(reference)\n"
                } else {
                    output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
                }
            }
        }

        return output
    }

    private static func generateInteractiveColors(from interactive: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in interactive.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let kotlinName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
                if value.hasPrefix("rgba") {
                    output += "        val \(kotlinName) = \(parseRGBAToCompose(value))\n"
                } else if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        val \(kotlinName) = \(reference)\n"
                } else {
                    output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
                }
            }
        }

        return output
    }

    private static func generateStatusColors(from status: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in status.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let kotlinName = name.camelCased().capitalized
                if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        val \(kotlinName) = \(reference)\n"
                } else {
                    output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
                }
            }
        }

        return output
    }

    private static func generateButtonColors(from button: [String: TokenValue]) -> String {
        var output = ""

        for (name, token) in button.sorted(by: { $0.key < $1.key }) {
            if let value = token.value {
                let kotlinName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
                if value.hasPrefix("{") {
                    let reference = resolveTokenReference(value)
                    output += "        val \(kotlinName) = \(reference)\n"
                } else {
                    output += "        val \(kotlinName) = Color(0xFF\(value.replacingOccurrences(of: "#", with: "")))\n"
                }
            }
        }

        return output
    }

    // MARK: - Typography Generation
    private static func generateTypographyTokens(from typography: CrossPlatformTypographyTokens) -> String {
        var output = """

object Typography {
    val fontFamily = FontFamily.Default // TODO: Add Inter font

    object Weight {

"""

        if let fontWeight = typography.fontWeight {
            for (name, token) in fontWeight.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let kotlinName = name.camelCased().capitalized
                    let weightValue = mapFontWeight(value)
                    output += "        val \(kotlinName) = FontWeight.\(weightValue)\n"
                }
            }
        }

        output += """
    }

    object Heading {

"""

        if let fontSize = typography.fontSize {
            let headings = fontSize.filter { $0.key.hasPrefix("h") }
            for (name, token) in headings.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let kotlinName = name.uppercased()
                    output += "        val \(kotlinName) = \(Int(size)).sp\n"
                }
            }
        }

        output += """
    }

    object Body {

"""

        if let fontSize = typography.fontSize {
            let bodies = fontSize.filter { $0.key.hasPrefix("body") }
            for (name, token) in bodies.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let kotlinName = name.replacingOccurrences(of: "body-", with: "").camelCased().capitalized
                    output += "        val \(kotlinName) = \(Int(size)).sp\n"
                }
            }
        }

        output += """
    }

    object Label {

"""

        if let fontSize = typography.fontSize {
            let labels = fontSize.filter { $0.key.hasPrefix("label") }
            for (name, token) in labels.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let size = parsePixelValue(value)
                    let kotlinName = name.replacingOccurrences(of: "label-", with: "").camelCased().capitalized
                    output += "        val \(kotlinName) = \(Int(size)).sp\n"
                }
            }
        }

        output += """
    }

    object LetterSpacing {

"""

        if let letterSpacing = typography.letterSpacing {
            for (name, token) in letterSpacing.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let kotlinName = name.camelCased().capitalized
                    let spacingValue = parsePixelValue(value)
                    output += "        val \(kotlinName) = \(spacingValue).sp\n"
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

object Spacing {

"""

        if let scale = spacing.scale {
            for (name, token) in scale.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let kotlinName = name.camelCased().capitalized
                    let spacingValue = parsePixelValue(value)
                    output += "    val \(kotlinName) = \(Int(spacingValue)).dp\n"
                }
            }
        }

        output += """

    object Component {

"""

        if let component = spacing.component {
            for (name, token) in component.sorted(by: { $0.key < $1.key }) {
                if let value = token.value {
                    let kotlinName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
                    let spacingValue = parsePixelValue(value)
                    output += "        val \(kotlinName) = \(Int(spacingValue)).dp\n"
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

object BorderRadius {

"""

        for (name, token) in borderRadius.sorted(by: { $0.key < $1.key }) {
            if name != "component", let value = token.value {
                let kotlinName = name.camelCased().capitalized
                let radiusValue = parsePixelValue(value)
                output += "    val \(kotlinName) = \(Int(radiusValue)).dp\n"
            }
        }

        output += """

    object Component {
        val Button = 36.dp
        val Card = 20.dp
        val Menu = 20.dp
        val Modal = 16.dp
    }
}

"""

        return output
    }

    // MARK: - Shadow Generation
    private static func generateShadowTokens(from shadows: [String: ShadowToken]) -> String {
        var output = """

object Shadows {

"""

        for (name, shadow) in shadows.sorted(by: { $0.key < $1.key }) {
            if let shadowValue = shadow.value {
                let kotlinName = name.camelCased().capitalized
                output += """
    object \(kotlinName) {
        val color = \(parseRGBAToCompose(shadowValue.color ?? "rgba(0,0,0,0.08)"))
        val offsetX = \(Int(parsePixelValue(shadowValue.offsetX ?? "0px"))).dp
        val offsetY = \(Int(parsePixelValue(shadowValue.offsetY ?? "2px"))).dp
        val blurRadius = \(Int(parsePixelValue(shadowValue.blur ?? "8px"))).dp
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

object Components {

"""

        for (name, component) in components.sorted(by: { $0.key < $1.key }) {
            let kotlinName = name.replacingOccurrences(of: "-", with: "").camelCased().capitalized
            output += """
    object \(kotlinName) {

"""

            // Generate component properties
            for (property, value) in Mirror(reflecting: component).children {
                if let propertyName = property {
                    let kotlinPropertyName = propertyName.camelCased().capitalized
                    if let stringValue = value as? String {
                        if stringValue.hasSuffix("px") {
                            output += "        val \(kotlinPropertyName) = \(Int(parsePixelValue(stringValue))).dp\n"
                        } else if stringValue.hasPrefix("{") {
                            let reference = resolveTokenReference(stringValue)
                            output += "        val \(kotlinPropertyName) = \(reference)\n"
                        } else {
                            output += "        const val \(kotlinPropertyName) = \"\(stringValue)\"\n"
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
    private static func parseRGBAToCompose(_ rgba: String) -> String {
        // Parse rgba(r, g, b, a) to Jetpack Compose Color
        let pattern = #"rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d\.]+)\)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: rgba, range: NSRange(rgba.startIndex..., in: rgba))

        if let match = matches.first {
            let r = (rgba as NSString).substring(with: match.range(at: 1))
            let g = (rgba as NSString).substring(with: match.range(at: 2))
            let b = (rgba as NSString).substring(with: match.range(at: 3))
            let a = (rgba as NSString).substring(with: match.range(at: 4))

            let alpha = Int(Float(a)! * 255)
            let red = Int(r)!
            let green = Int(g)!
            let blue = Int(b)!

            let hex = String(format: "%02X%02X%02X%02X", alpha, red, green, blue)
            return "Color(0x\(hex))"
        }

        return "Color.Black"
    }

    private static func resolveTokenReference(_ reference: String) -> String {
        // Convert {color.primitive.white} to Primitive.White
        let cleaned = reference.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        let parts = cleaned.split(separator: ".")

        if parts.count >= 3 {
            let category = String(parts[1]).capitalized
            let name = String(parts[2]).camelCased().capitalized
            return "\(category).\(name)"
        }

        return "Color.Black"
    }

    private static func parsePixelValue(_ value: String) -> CGFloat {
        let cleaned = value.replacingOccurrences(of: "px", with: "")
        return CGFloat(Double(cleaned) ?? 0)
    }

    private static func mapFontWeight(_ weight: String) -> String {
        switch weight {
        case "400": return "Normal"
        case "500": return "Medium"
        case "600": return "SemiBold"
        case "700": return "Bold"
        default: return "Normal"
        }
    }
}

// String extension moved to shared utilities to avoid duplication
