//
//  FigmaTokensDemoView.swift
//  Sonetel Mobile
//
//  Demonstration of Figma Design Tokens Integration
//

import SwiftUI

struct FigmaTokensDemoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: FigmaDesignSystem.spacing.l) {
                    // Header Section
                    headerSection
                    
                    // Colors Section
                    colorsSection
                    
                    // Typography Section
                    typographySection
                    
                    // Spacing Section
                    spacingSection
                    
                    // Components Section
                    componentsSection
                }
                .figmaPadding("l")
            }
            .navigationTitle("Figma Design Tokens")
            .navigationBarTitleDisplayMode(.large)
            .figmaBackground("surface.primary", mode: colorScheme)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.m) {
            Text("🎨 Design System Integration")
                .figmaTypography("headline.h2")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
            
            Text("Successfully integrated Figma design tokens with automatic light/dark mode support and semantic color system.")
                .figmaTypography("body.medium")
                .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sonetelCard()
    }
    
    // MARK: - Colors Section
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.m) {
            Text("Colors")
                .figmaTypography("headline.h3")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
            
            // Surface Colors
            VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.s) {
                Text("Surface Colors")
                    .figmaTypography("label.medium")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                
                HStack(spacing: FigmaDesignSystem.spacing.s) {
                    colorSwatch("Z0", color: colorScheme == .light ? 
                               FigmaDesignSystem.colors.Light.Z0 : 
                               FigmaDesignSystem.colors.Dark.Z0)
                    colorSwatch("Z1", color: colorScheme == .light ? 
                               FigmaDesignSystem.colors.Light.Z1 : 
                               FigmaDesignSystem.colors.Dark.Z1)
                    colorSwatch("Z2", color: colorScheme == .light ? 
                               FigmaDesignSystem.colors.Light.Z2 : 
                               FigmaDesignSystem.colors.Dark.Z2)
                    colorSwatch("Z3", color: colorScheme == .light ? 
                               FigmaDesignSystem.colors.Light.Z3 : 
                               FigmaDesignSystem.colors.Dark.Z3)
                }
            }
            
            // Accent Colors
            VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.s) {
                Text("Accent Colors")
                    .figmaTypography("label.medium")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                
                HStack(spacing: FigmaDesignSystem.spacing.s) {
                    colorSwatch("Blue", color: FigmaDesignSystem.colors.Light.blue)
                    colorSwatch("Green", color: FigmaDesignSystem.colors.Light.green)
                    colorSwatch("Purple", color: FigmaDesignSystem.colors.Light.purple)
                    colorSwatch("Pink", color: FigmaDesignSystem.colors.Light.pink)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sonetelCard()
    }
    
    // MARK: - Typography Section
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.m) {
            Text("Typography")
                .figmaTypography("headline.h3")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
            
            VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.s) {
                Text("Headline H1")
                    .figmaTypography("headline.h1")
                    .foregroundColor(FigmaDesignSystem.colors.textPrimary)
                
                Text("Headline H2")
                    .figmaTypography("headline.h2")
                    .foregroundColor(FigmaDesignSystem.colors.textPrimary)
                
                Text("Headline H3")
                    .figmaTypography("headline.h3")
                    .foregroundColor(FigmaDesignSystem.colors.textPrimary)
                
                Text("Body Large - This is body large text for reading content.")
                    .figmaTypography("body.large")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                
                Text("Body Medium - This is body medium text for regular content.")
                    .figmaTypography("body.medium")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                
                Text("Body Small - This is body small text for captions.")
                    .figmaTypography("body.small")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sonetelCard()
    }
    
    // MARK: - Spacing Section
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.m) {
            Text("Spacing")
                .figmaTypography("headline.h3")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
            
            VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.xs) {
                spacingExample("XS", spacing: FigmaDesignSystem.spacing.xs)
                spacingExample("S", spacing: FigmaDesignSystem.spacing.s)
                spacingExample("M", spacing: FigmaDesignSystem.spacing.m)
                spacingExample("L", spacing: FigmaDesignSystem.spacing.l)
                spacingExample("XL", spacing: FigmaDesignSystem.spacing.xl)
                spacingExample("2XL", spacing: FigmaDesignSystem.spacing._2xl)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sonetelCard()
    }
    
    // MARK: - Components Section
    private var componentsSection: some View {
        VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.m) {
            Text("Component Examples")
                .figmaTypography("headline.h3")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
            
            // Button Examples
            VStack(spacing: FigmaDesignSystem.spacing.s) {
                // Primary Button
                Button("Primary Button") {
                    // Action
                }
                .figmaTypography("label.medium")
                .foregroundColor(.white)
                .figmaPadding("m")
                .frame(maxWidth: .infinity)
                .background(FigmaDesignSystem.colors.Light.blue)
                .figmaCornerRadius("medium")
                
                // Secondary Button
                Button("Secondary Button") {
                    // Action
                }
                .figmaTypography("label.medium")
                .foregroundColor(FigmaDesignSystem.colors.textPrimary)
                .figmaPadding("m")
                .frame(maxWidth: .infinity)
                .background(colorScheme == .light ? 
                           FigmaDesignSystem.colors.Light.Z2 : 
                           FigmaDesignSystem.colors.Dark.Z2)
                .figmaCornerRadius("medium")
                .overlay(
                    RoundedRectangle(cornerRadius: FigmaDesignSystem.radius.medium)
                        .stroke(colorScheme == .light ? 
                               FigmaDesignSystem.colors.Light.Z4 : 
                               FigmaDesignSystem.colors.Dark.Z4, lineWidth: 1)
                )
            }
            
            // Card Example
            VStack(alignment: .leading, spacing: FigmaDesignSystem.spacing.s) {
                Text("Card Title")
                    .figmaTypography("headline.h4")
                    .foregroundColor(FigmaDesignSystem.colors.textPrimary)
                
                Text("This is a card component built using Figma design tokens. It automatically adapts to light and dark modes.")
                    .figmaTypography("body.medium")
                    .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                
                HStack {
                    Button("Action") {
                        // Action
                    }
                    .figmaTypography("label.small")
                    .foregroundColor(FigmaDesignSystem.colors.Light.blue)
                    
                    Spacer()
                    
                    Text("Meta info")
                        .figmaTypography("label.small")
                        .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                }
            }
            .figmaPadding("l")
            .background(colorScheme == .light ? 
                       FigmaDesignSystem.colors.Light.Z1 : 
                       FigmaDesignSystem.colors.Dark.Z1)
            .figmaCornerRadius("large")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sonetelCard()
    }
    
    // MARK: - Helper Views
    private func colorSwatch(_ name: String, color: Color) -> some View {
        VStack(spacing: FigmaDesignSystem.spacing.xs) {
            Rectangle()
                .fill(color)
                .frame(width: 40, height: 40)
                .figmaCornerRadius("small")
                .overlay(
                    RoundedRectangle(cornerRadius: FigmaDesignSystem.radius.small)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Text(name)
                .figmaTypography("label.small")
                .foregroundColor(FigmaDesignSystem.colors.textSecondary)
        }
    }
    
    private func spacingExample(_ name: String, spacing: CGFloat) -> some View {
        HStack(spacing: FigmaDesignSystem.spacing.s) {
            Text(name)
                .figmaTypography("label.small")
                .foregroundColor(FigmaDesignSystem.colors.textSecondary)
                .frame(width: 30, alignment: .leading)
            
            Rectangle()
                .fill(FigmaDesignSystem.colors.Light.blue)
                .frame(width: spacing, height: 20)
                .figmaCornerRadius("small")
            
            Text("\(Int(spacing))px")
                .figmaTypography("label.small")
                .foregroundColor(FigmaDesignSystem.colors.textSecondary)
        }
    }
}

#Preview {
    FigmaTokensDemoView()
}

#Preview("Dark Mode") {
    FigmaTokensDemoView()
        .preferredColorScheme(.dark)
}
