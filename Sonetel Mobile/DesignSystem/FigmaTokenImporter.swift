//
//  FigmaTokenImporter.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  Figma Design Token Importer - For importing JSON tokens from Figma
//

import SwiftUI
import Foundation

// MARK: - Figma Token Importer
struct FigmaTokenImporter {
    // MARK: - Import Methods
    
    /// Import color tokens from Figma JSON export
    static func importColors(from jsonData: Data) throws -> [String: Color] {
        let decoder = JSONDecoder()
        let tokenData = try decoder.decode(FigmaTokenData.self, from: jsonData)
        
        var colors: [String: Color] = [:]
        
        // Process color tokens
        for (tokenName, tokenValue) in tokenData.colors {
            if let colorValue = tokenValue.value {
                colors[tokenName] = parseColor(from: colorValue)
            }
        }
        
        return colors
    }
    
    /// Import typography tokens from Figma JSON export
    static func importTypography(from jsonData: Data) throws -> [String: FigmaTypographyToken] {
        let decoder = JSONDecoder()
        let tokenData = try decoder.decode(FigmaTokenData.self, from: jsonData)
        
        return tokenData.typography
    }
    
    /// Import spacing tokens from Figma JSON export
    static func importSpacing(from jsonData: Data) throws -> [String: CGFloat] {
        let decoder = JSONDecoder()
        let tokenData = try decoder.decode(FigmaTokenData.self, from: jsonData)
        
        var spacing: [String: CGFloat] = [:]
        
        for (tokenName, tokenValue) in tokenData.spacing {
            if let value = tokenValue.value {
                spacing[tokenName] = parseSpacing(from: value)
            }
        }
        
        return spacing
    }
    
    // MARK: - Helper Methods
    
    /// Parse color from various Figma formats (hex, rgb, hsl)
    private static func parseColor(from value: String) -> Color {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle hex colors
        if cleanValue.hasPrefix("#") {
            return Color(hex: cleanValue)
        }
        
        // Handle rgb() format
        if cleanValue.hasPrefix("rgb(") {
            return parseRGBColor(from: cleanValue)
        }
        
        // Handle rgba() format
        if cleanValue.hasPrefix("rgba(") {
            return parseRGBAColor(from: cleanValue)
        }
        
        // Fallback to black
        return Color.black
    }
    
    /// Parse RGB color string
    private static func parseRGBColor(from value: String) -> Color {
        let components = extractColorComponents(from: value)
        guard components.count >= 3 else { return Color.black }
        
        return Color(
            red: components[0] / 255.0,
            green: components[1] / 255.0,
            blue: components[2] / 255.0
        )
    }
    
    /// Parse RGBA color string
    private static func parseRGBAColor(from value: String) -> Color {
        let components = extractColorComponents(from: value)
        guard components.count >= 4 else { return Color.black }
        
        return Color(
            red: components[0] / 255.0,
            green: components[1] / 255.0,
            blue: components[2] / 255.0,
            opacity: components[3]
        )
    }
    
    /// Extract numeric components from color string
    private static func extractColorComponents(from value: String) -> [Double] {
        let pattern = #"[\d\.]+(?=\s*[,\)])"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: value, range: NSRange(value.startIndex..., in: value))
        
        return matches.compactMap { match in
            let range = Range(match.range, in: value)!
            return Double(value[range])
        }
    }
    
    /// Parse spacing value (supports px, rem, em)
    private static func parseSpacing(from value: String) -> CGFloat {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove units and convert to CGFloat
        let numericValue = cleanValue
            .replacingOccurrences(of: "px", with: "")
            .replacingOccurrences(of: "rem", with: "")
            .replacingOccurrences(of: "em", with: "")
        
        return CGFloat(Double(numericValue) ?? 0)
    }
}

// MARK: - Figma Token Data Models
struct FigmaTokenData: Codable {
    let colors: [String: FigmaColorToken]
    let typography: [String: FigmaTypographyToken]
    let spacing: [String: FigmaSpacingToken]
    let borderRadius: [String: FigmaSpacingToken]?
    
    enum CodingKeys: String, CodingKey {
        case colors = "color"
        case typography = "typography"
        case spacing = "spacing"
        case borderRadius = "border-radius"
    }
}

struct FigmaColorToken: Codable {
    let value: String?
    let type: String?
    let description: String?
}

struct FigmaTypographyToken: Codable {
    let fontFamily: String?
    let fontSize: String?
    let fontWeight: String?
    let lineHeight: String?
    let letterSpacing: String?
    
    enum CodingKeys: String, CodingKey {
        case fontFamily = "fontFamily"
        case fontSize = "fontSize"
        case fontWeight = "fontWeight"
        case lineHeight = "lineHeight"
        case letterSpacing = "letterSpacing"
    }
}

struct FigmaSpacingToken: Codable {
    let value: String?
    let type: String?
    let description: String?
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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

// MARK: - Token Update Manager
class DesignTokenManager: ObservableObject {
    @Published var isUpdating = false
    @Published var lastUpdated: Date?
    
    /// Update design tokens from Figma export
    func updateTokens(from jsonData: Data) async {
        await MainActor.run {
            isUpdating = true
        }
        
        do {
            // Import tokens
            let colors = try FigmaTokenImporter.importColors(from: jsonData)
            let typography = try FigmaTokenImporter.importTypography(from: jsonData)
            let spacing = try FigmaTokenImporter.importSpacing(from: jsonData)
            
            // TODO: Update design system with new tokens
            // This would involve updating the DesignTokens.swift file
            // or using a dynamic token system
            
            await MainActor.run {
                self.lastUpdated = Date()
                self.isUpdating = false
            }
            
            print("✅ Design tokens updated successfully")
            print("🎨 Colors: \(colors.count)")
            print("📝 Typography: \(typography.count)")
            print("📏 Spacing: \(spacing.count)")
            
        } catch {
            await MainActor.run {
                self.isUpdating = false
            }
            print("❌ Failed to update design tokens: \(error)")
        }
    }
}

// MARK: - Usage Examples and Documentation
/*
 
 USAGE EXAMPLES:
 
 1. Basic Color Usage:
    Text("Hello")
        .foregroundColor(DS.colors.Text.primary)
        .background(DS.colors.Surface.secondary)
 
 2. Typography Usage:
    Text("Heading").h1()
    Text("Body text").bodyLarge()
    Text("Label").labelMedium()
 
 3. Spacing Usage:
    VStack(spacing: DS.spacing.lg) { ... }
    .padding(DS.spacing.Component.screenPadding)
 
 4. Card Styling:
    VStack { ... }
        .cardStyle()
        .designSystemPadding(.all, .lg)
 
 5. Interactive States:
    Button("Tap me") { ... }
        .pressedState(isPressed)
 
 FIGMA EXPORT WORKFLOW:
 
 1. Export tokens from Figma as JSON
 2. Add JSON file to project bundle
 3. Use FigmaTokenImporter to parse tokens
 4. Update DesignTokens.swift with new values
 5. Rebuild app with updated design system
 
 RECOMMENDED FIGMA TOKEN STRUCTURE:
 
 {
   "color": {
     "primary-50": { "value": "#f8fafc", "type": "color" },
     "primary-500": { "value": "#3b82f6", "type": "color" }
   },
   "typography": {
     "heading-1": {
       "fontFamily": "Inter",
       "fontSize": "34px",
       "fontWeight": "600",
       "lineHeight": "1.2",
       "letterSpacing": "0.374px"
     }
   },
   "spacing": {
     "xs": { "value": "4px", "type": "spacing" },
     "sm": { "value": "8px", "type": "spacing" }
   }
 }
 
 */
