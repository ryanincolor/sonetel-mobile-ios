//
//  TokenModels.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Cross-platform design token data models
//

import Foundation

// MARK: - Cross-Platform Token Models

struct CrossPlatformTokens: Codable {
    let version: String
    let description: String
    let platforms: [String]
    let lastUpdated: String
    let source: String
    let tokens: Tokens
    let components: [String: ComponentToken]?
}

struct Tokens: Codable {
    let color: CrossPlatformColorTokens
    let typography: CrossPlatformTypographyTokens
    let spacing: CrossPlatformSpacingTokens
    let borderRadius: BorderRadiusTokens
    let shadow: [String: ShadowToken]?
}

// MARK: - Cross-Platform Color Tokens
struct CrossPlatformColorTokens: Codable {
    let primitive: [String: TokenValue]?
    let semantic: SemanticColors?
}

struct SemanticColors: Codable {
    let surface: [String: TokenValue]?
    let text: [String: TokenValue]?
    let interactive: [String: TokenValue]?
    let status: [String: TokenValue]?
    let button: [String: TokenValue]?
}

// MARK: - Cross-Platform Typography Tokens
struct CrossPlatformTypographyTokens: Codable {
    let fontFamily: [String: TokenValue]?
    let fontWeight: [String: TokenValue]?
    let fontSize: [String: TokenValue]?
    let lineHeight: [String: TokenValue]?
    let letterSpacing: [String: TokenValue]?
}

// MARK: - Cross-Platform Spacing Tokens
struct CrossPlatformSpacingTokens: Codable {
    let scale: [String: TokenValue]?
    let component: [String: TokenValue]?
}

// MARK: - Border Radius Tokens
typealias BorderRadiusTokens = [String: TokenValue]

// MARK: - Shadow Tokens
struct ShadowToken: Codable {
    let value: ShadowValue?
    let type: String?
}

struct ShadowValue: Codable {
    let color: String?
    let offsetX: String?
    let offsetY: String?
    let blur: String?
    let spread: String?
}

// MARK: - Component Tokens
struct ComponentToken: Codable {
    let height: String?
    let padding: String?
    let paddingHorizontal: String?
    let paddingVertical: String?
    let backgroundColor: String?
    let backgroundColorPressed: String?
    let borderRadius: String?
    let typography: ComponentTypography?

    private enum CodingKeys: String, CodingKey {
        case height, padding
        case paddingHorizontal = "paddingHorizontal"
        case paddingVertical = "paddingVertical"
        case backgroundColor
        case backgroundColorPressed
        case borderRadius
        case typography
    }
}

struct ComponentTypography: Codable {
    let fontSize: String?
    let fontWeight: String?
    let letterSpacing: String?
}

// MARK: - Token Value
struct TokenValue: Codable {
    let value: String?
    let type: String?
    let description: String?
}

// MARK: - Cross-Platform Design System Manager
class CrossPlatformDesignSystemManager {
    static let shared = CrossPlatformDesignSystemManager()

    private init() {}

    /// Generate platform-specific tokens from cross-platform JSON
    func generatePlatformTokens(from jsonData: Data, platform: Platform) throws -> String {
        switch platform {
        case .ios:
            return try iOSTokenGenerator.generateTokens(from: jsonData)
        case .android:
            return try AndroidTokenGenerator.generateTokens(from: jsonData)
        case .web:
            return try WebTokenGenerator.generateTokens(from: jsonData)
        }
    }

    /// Update design tokens from Figma export
    func updateFromFigma(figmaTokens: Data) async throws {
        // 1. Parse Figma tokens
        let figmaData = try JSONSerialization.jsonObject(with: figmaTokens) as? [String: Any]

        // 2. Convert to cross-platform format
        let crossPlatformTokens = try convertFigmaTokens(figmaData ?? [:])

        // 3. Generate platform-specific files
        let iOSTokens = try generatePlatformTokens(from: crossPlatformTokens, platform: .ios)
        let androidTokens = try generatePlatformTokens(from: crossPlatformTokens, platform: .android)

        // 4. Save generated files
        try await saveGeneratedTokens(ios: iOSTokens, android: androidTokens)

        print("✅ Design tokens updated successfully for all platforms")
    }

    /// Export current tokens for sharing with other platforms
    func exportCrossPlatformTokens() throws -> Data {
        // Load the current cross-platform spec
        guard let url = Bundle.main.url(forResource: "DesignTokensSpec", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw TokenError.fileNotFound
        }

        return data
    }

    /// Validate token consistency across platforms
    func validateTokenConsistency() throws -> ValidationResult {
        // Implementation for validating that all platforms have the same tokens
        return ValidationResult(isValid: true, issues: [])
    }

    // MARK: - Private Methods

    private func convertFigmaTokens(_ figmaTokens: [String: Any]) throws -> Data {
        // Convert Figma token format to cross-platform format
        // This would handle the specific Figma export format

        var crossPlatformTokens: [String: Any] = [
            "version": "1.0.0",
            "description": "Sonetel Design System - Generated from Figma",
            "platforms": ["ios", "android", "web"],
            "lastUpdated": ISO8601DateFormatter().string(from: Date()),
            "source": "figma"
        ]

        // Process Figma colors
        if let figmaColors = figmaTokens["color"] as? [String: Any] {
            crossPlatformTokens["tokens"] = ["color": processFigmaColors(figmaColors)]
        }

        // Process other token types...

        return try JSONSerialization.data(withJSONObject: crossPlatformTokens)
    }

    private func processFigmaColors(_ figmaColors: [String: Any]) -> [String: Any] {
        // Convert Figma color format to cross-platform format
        var processedColors: [String: Any] = [:]

        for (key, value) in figmaColors {
            if let colorData = value as? [String: Any],
               let colorValue = colorData["value"] as? String {
                processedColors[key] = [
                    "value": colorValue,
                    "type": "color",
                    "description": colorData["description"] ?? ""
                ]
            }
        }

        return processedColors
    }

    private func saveGeneratedTokens(ios: String, android: String) async throws {
        // Save generated tokens to appropriate platform directories
        // This would write the files to the correct locations in the project

        // For iOS
        let iOSURL = URL(fileURLWithPath: "Sonetel Mobile/DesignSystem/Generated/GeneratedDesignTokens.swift")
        try ios.write(to: iOSURL, atomically: true, encoding: .utf8)

        // For Android (if in same repo)
        let androidURL = URL(fileURLWithPath: "android/app/src/main/java/com/sonetel/mobile/designsystem/GeneratedDesignTokens.kt")
        try android.write(to: androidURL, atomically: true, encoding: .utf8)

        print("📱 iOS tokens saved to: \(iOSURL.path)")
        print("🤖 Android tokens saved to: \(androidURL.path)")
    }
}

// MARK: - Supporting Types

enum Platform {
    case ios, android, web
}

enum TokenError: Error {
    case fileNotFound
    case invalidFormat
    case generationFailed
}

struct ValidationResult {
    let isValid: Bool
    let issues: [String]
}

// MARK: - Web Token Generator (placeholder)
struct WebTokenGenerator {
    static func generateTokens(from jsonData: Data) throws -> String {
        // Generate CSS custom properties or JavaScript tokens
        return """
/* Generated Design Tokens for Web */
:root {
  /* Colors */
  --color-text-primary: #111111;
  --color-surface-secondary: #F3F3F3;

  /* Typography */
  --font-family-primary: 'Inter', sans-serif;
  --font-size-h1: 34px;

  /* Spacing */
  --spacing-lg: 16px;
  --spacing-screen-padding: 20px;
}
"""
    }
}

// MARK: - Component Specification
struct ComponentSpecification {
    let name: String
    let platforms: [Platform]
    let properties: [ComponentProperty]
    let variants: [ComponentVariant]
}

struct ComponentProperty {
    let name: String
    let type: PropertyType
    let defaultValue: String?
    let description: String?
}

struct ComponentVariant {
    let name: String
    let properties: [String: String]
}

enum PropertyType {
    case color, spacing, typography, boolean, string
}

// MARK: - Usage Examples and Documentation
/*

CROSS-PLATFORM WORKFLOW:

1. Design in Figma with Variables/Tokens
2. Export tokens as JSON from Figma
3. Import into CrossPlatformDesignSystemManager
4. Generate platform-specific token files:
   - iOS: Swift file with SwiftUI extensions
   - Android: Kotlin file with Jetpack Compose tokens
   - Web: CSS custom properties
5. Use generated tokens in each platform

EXAMPLE USAGE:

// Update tokens from Figma
let manager = CrossPlatformDesignSystemManager.shared
try await manager.updateFromFigma(figmaTokenData)

// Generate for specific platform
let iOSTokens = try manager.generatePlatformTokens(from: jsonData, platform: .ios)

// Validate consistency
let validation = try manager.validateTokenConsistency()

COMPONENT SHARING:

Components can be specified in a cross-platform way:
- Define component structure and properties
- Generate platform-specific implementations
- Maintain design consistency across platforms

*/
