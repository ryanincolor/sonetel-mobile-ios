//
//  FigmaIntegration.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Figma Variables Integration Tool
//

import Foundation
import SwiftUI

// MARK: - Figma Integration Manager
class FigmaIntegrationManager {
    static let shared = FigmaIntegrationManager()

    private init() {}

    /// Import Figma variables JSON and generate iOS design tokens
    func importFigmaVariables(from jsonData: Data) async throws {
        print("🎨 Starting Figma variables import...")

        // 1. Parse Figma JSON
        let figmaVariables = try parseFigmaJSON(jsonData)

        // 2. Convert to cross-platform format
        let crossPlatformTokens = convertToStandardFormat(figmaVariables)

        // 3. Generate iOS tokens
        let iOSTokens = try generateiOSTokens(from: crossPlatformTokens)

        // 4. Update design system files
        try await updateDesignSystemFiles(with: iOSTokens)

        // 5. Validate integration
        try validateTokens(iOSTokens)

        print("✅ Figma variables successfully imported!")
        print("📱 iOS design tokens updated")
        print("🔄 Please rebuild your app to use the new tokens")
    }

    /// Import from JSON file in app bundle
    func importFromBundle(filename: String = "figma-tokens") async throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw FigmaIntegrationError.fileNotFound("Could not find \(filename).json in app bundle")
        }

        try await importFigmaVariables(from: data)
    }

    /// Import from file URL (for development)
    func importFromFile(at url: URL) async throws {
        let data = try Data(contentsOf: url)
        try await importFigmaVariables(from: data)
    }

    // MARK: - Private Methods

    private func parseFigmaJSON(_ data: Data) throws -> FigmaVariables {
        let decoder = JSONDecoder()

        // Try different Figma export formats
        do {
            // Standard Figma Variables format
            return try decoder.decode(FigmaVariables.self, from: data)
        } catch {
            // Try Tokens Studio format
            do {
                let tokensStudioFormat = try decoder.decode(TokensStudioFormat.self, from: data)
                return convertTokensStudioToFigma(tokensStudioFormat)
            } catch {
                // Try generic format
                let genericFormat = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                return try convertGenericToFigma(genericFormat ?? [:])
            }
        }
    }

    private func convertToStandardFormat(_ figmaVariables: FigmaVariables) -> CrossPlatformTokens {
        print("🔄 Converting Figma variables to standard format...")

        // Process each token type
        let processedColors = figmaVariables.colors.map { processColors($0) } ??
            CrossPlatformColorTokens(primitive: nil, semantic: nil)

        let processedTypography = figmaVariables.typography.map { processTypography($0) } ??
            CrossPlatformTypographyTokens(
                fontFamily: nil,
                fontWeight: nil,
                fontSize: nil,
                lineHeight: nil,
                letterSpacing: nil
            )

        let processedSpacing = figmaVariables.spacing.map { processSpacing($0) } ??
            CrossPlatformSpacingTokens(
                scale: nil,
                component: nil
            )

        let processedBorderRadius = figmaVariables.borderRadius.map { processBorderRadius($0) } ?? [:]

        // Build tokens with processed values
        let tokens = Tokens(
            color: processedColors,
            typography: processedTypography,
            spacing: processedSpacing,
            borderRadius: processedBorderRadius,
            shadow: nil
        )

        return CrossPlatformTokens(
            version: "1.0.0",
            description: "Imported from Figma Variables",
            platforms: ["ios", "android"],
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            source: "figma",
            tokens: tokens,
            components: nil
        )
    }

    private func processColors(_ figmaColors: [String: FigmaVariable]) -> CrossPlatformColorTokens {
        var primitive: [String: TokenValue] = [:]
        var semantic: [String: [String: TokenValue]] = [
            "surface": [:],
            "text": [:],
            "interactive": [:],
            "status": [:],
            "button": [:]
        ]

        for (name, variable) in figmaColors {
            let tokenValue = TokenValue(
                value: variable.value,
                type: "color",
                description: variable.description
            )

            // Categorize colors based on naming
            if name.contains("primitive") || isPrimitiveColor(name) {
                let cleanName = cleanColorName(name)
                primitive[cleanName] = tokenValue
            } else {
                categorizeSemanticColor(name: name, value: tokenValue, into: &semantic)
            }
        }

        return CrossPlatformColorTokens(
            primitive: primitive,
            semantic: SemanticColors(
                surface: semantic["surface"],
                text: semantic["text"],
                interactive: semantic["interactive"],
                status: semantic["status"],
                button: semantic["button"]
            )
        )
    }

    private func processTypography(_ figmaTypography: [String: FigmaVariable]) -> CrossPlatformTypographyTokens {
        var fontFamily: [String: TokenValue] = [:]
        var fontWeight: [String: TokenValue] = [:]
        var fontSize: [String: TokenValue] = [:]
        var lineHeight: [String: TokenValue] = [:]
        var letterSpacing: [String: TokenValue] = [:]

        for (name, variable) in figmaTypography {
            let tokenValue = TokenValue(
                value: variable.value,
                type: variable.type ?? "typography",
                description: variable.description
            )

            if name.contains("font-family") || name.contains("fontFamily") {
                fontFamily[cleanTypographyName(name)] = tokenValue
            } else if name.contains("font-weight") || name.contains("fontWeight") {
                fontWeight[cleanTypographyName(name)] = tokenValue
            } else if name.contains("font-size") || name.contains("fontSize") {
                fontSize[cleanTypographyName(name)] = tokenValue
            } else if name.contains("line-height") || name.contains("lineHeight") {
                lineHeight[cleanTypographyName(name)] = tokenValue
            } else if name.contains("letter-spacing") || name.contains("letterSpacing") {
                letterSpacing[cleanTypographyName(name)] = tokenValue
            }
        }

        return CrossPlatformTypographyTokens(
            fontFamily: fontFamily.isEmpty ? nil : fontFamily,
            fontWeight: fontWeight.isEmpty ? nil : fontWeight,
            fontSize: fontSize.isEmpty ? nil : fontSize,
            lineHeight: lineHeight.isEmpty ? nil : lineHeight,
            letterSpacing: letterSpacing.isEmpty ? nil : letterSpacing
        )
    }

    private func processSpacing(_ figmaSpacing: [String: FigmaVariable]) -> CrossPlatformSpacingTokens {
        var scale: [String: TokenValue] = [:]
        var component: [String: TokenValue] = [:]

        for (name, variable) in figmaSpacing {
            let tokenValue = TokenValue(
                value: variable.value,
                type: "spacing",
                description: variable.description
            )

            if name.contains("component") || isComponentSpacing(name) {
                component[cleanSpacingName(name)] = tokenValue
            } else {
                scale[cleanSpacingName(name)] = tokenValue
            }
        }

        return CrossPlatformSpacingTokens(
            scale: scale.isEmpty ? nil : scale,
            component: component.isEmpty ? nil : component
        )
    }

    private func processBorderRadius(_ figmaRadius: [String: FigmaVariable]) -> [String: TokenValue] {
        var radius: [String: TokenValue] = [:]

        for (name, variable) in figmaRadius {
            let cleanName = cleanRadiusName(name)
            radius[cleanName] = TokenValue(
                value: variable.value,
                type: "borderRadius",
                description: variable.description
            )
        }

        return radius
    }

    private func generateiOSTokens(from tokens: CrossPlatformTokens) throws -> String {
        let jsonData = try JSONEncoder().encode(tokens)
        return try iOSTokenGenerator.generateTokens(from: jsonData)
    }

    private func updateDesignSystemFiles(with iOSTokens: String) async throws {
        // Create generated tokens directory if it doesn't exist
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let designSystemPath = documentsPath.appendingPathComponent("DesignSystem")

        try FileManager.default.createDirectory(at: designSystemPath, withIntermediateDirectories: true)

        // Write generated tokens file
        let tokensFile = designSystemPath.appendingPathComponent("GeneratedDesignTokens.swift")
        try iOSTokens.write(to: tokensFile, atomically: true, encoding: .utf8)

        print("📝 Generated tokens saved to: \(tokensFile.path)")
        print("🔧 Copy this file to your Xcode project to use the new tokens")
    }

    private func validateTokens(_ iOSTokens: String) throws {
        // Basic validation
        guard iOSTokens.contains("struct GeneratedDesignSystem") else {
            throw FigmaIntegrationError.generationFailed("Generated tokens are invalid")
        }

        guard iOSTokens.contains("ColorTokens") else {
            throw FigmaIntegrationError.generationFailed("Color tokens missing")
        }

        print("✅ Token validation passed")
    }

    // MARK: - Helper Methods

    private func isPrimitiveColor(_ name: String) -> Bool {
        let primitiveKeywords = ["white", "black", "gray", "blue", "red", "green", "orange", "yellow"]
        return primitiveKeywords.contains { name.lowercased().contains($0) }
    }

    private func cleanColorName(_ name: String) -> String {
        return name
            .replacingOccurrences(of: "color/", with: "")
            .replacingOccurrences(of: "primitive/", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func categorizeSemanticColor(name: String, value: TokenValue, into semantic: inout [String: [String: TokenValue]]) {
        if name.contains("surface") {
            semantic["surface"]?[cleanColorName(name)] = value
        } else if name.contains("text") {
            semantic["text"]?[cleanColorName(name)] = value
        } else if name.contains("interactive") || name.contains("action") {
            semantic["interactive"]?[cleanColorName(name)] = value
        } else if name.contains("status") || name.contains("state") {
            semantic["status"]?[cleanColorName(name)] = value
        } else if name.contains("button") {
            semantic["button"]?[cleanColorName(name)] = value
        }
    }

    private func cleanTypographyName(_ name: String) -> String {
        return name
            .replacingOccurrences(of: "typography/", with: "")
            .replacingOccurrences(of: "font-", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func isComponentSpacing(_ name: String) -> Bool {
        let componentKeywords = ["padding", "margin", "header", "button", "card", "screen"]
        return componentKeywords.contains { name.lowercased().contains($0) }
    }

    private func cleanSpacingName(_ name: String) -> String {
        return name
            .replacingOccurrences(of: "spacing/", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func cleanRadiusName(_ name: String) -> String {
        return name
            .replacingOccurrences(of: "radius/", with: "")
            .replacingOccurrences(of: "border-radius/", with: "")
            .replacingOccurrences(of: "/", with: "-")
    }

    private func convertTokensStudioToFigma(_ tokensStudio: TokensStudioFormat) -> FigmaVariables {
        // Convert Tokens Studio format to standard Figma format
        // Implementation would depend on Tokens Studio export structure
        return FigmaVariables(colors: nil, typography: nil, spacing: nil, borderRadius: nil)
    }

    private func convertGenericToFigma(_ generic: [String: Any]) throws -> FigmaVariables {
        // Convert generic JSON format to Figma variables
        // This would handle various export formats
        throw FigmaIntegrationError.unsupportedFormat("Generic format conversion not yet implemented")
    }
}

// MARK: - Figma Data Models

struct FigmaVariables: Codable {
    let colors: [String: FigmaVariable]?
    let typography: [String: FigmaVariable]?
    let spacing: [String: FigmaVariable]?
    let borderRadius: [String: FigmaVariable]?

    enum CodingKeys: String, CodingKey {
        case colors = "color"
        case typography
        case spacing
        case borderRadius = "border-radius"
    }
}

struct FigmaVariable: Codable {
    let value: String
    let type: String?
    let description: String?
}

struct TokensStudioFormat: Codable {
    // Structure for Tokens Studio plugin export - simplified for now
    let global: [String: String]?
}

// MARK: - Error Types

enum FigmaIntegrationError: LocalizedError {
    case fileNotFound(String)
    case invalidJSON(String)
    case unsupportedFormat(String)
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let message):
            return "File not found: \(message)"
        case .invalidJSON(let message):
            return "Invalid JSON: \(message)"
        case .unsupportedFormat(let message):
            return "Unsupported format: \(message)"
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        }
    }
}

// MARK: - Usage Example

/*

USAGE EXAMPLES:

1. Import from app bundle:
   try await FigmaIntegrationManager.shared.importFromBundle(filename: "figma-tokens")

2. Import from file URL:
   let url = URL(fileURLWithPath: "/path/to/figma-tokens.json")
   try await FigmaIntegrationManager.shared.importFromFile(at: url)

3. Import from Data:
   try await FigmaIntegrationManager.shared.importFigmaVariables(from: jsonData)

The generated tokens will be saved to the Documents directory and can be copied to your Xcode project.

*/
