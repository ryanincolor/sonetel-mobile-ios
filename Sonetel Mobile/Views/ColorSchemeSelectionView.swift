//
//  ColorSchemeSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct ColorSchemeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedColorScheme") private var selectedColorScheme = "system"

    let colorSchemes = [
        ColorSchemeOption(id: "system", name: "Automatic", description: "Use device setting", systemImage: "circle.lefthalf.filled"),
        ColorSchemeOption(id: "light", name: "Light", description: "Always use light mode", systemImage: "sun.max"),
        ColorSchemeOption(id: "dark", name: "Dark", description: "Always use dark mode", systemImage: "moon")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Appearance") {
                dismiss()
            }

            // Content
            VStack(spacing: 0) {
                menuView
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .frame(maxHeight: .infinity)
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
    }



    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(colorSchemes.indices, id: \.self) { index in
                let scheme = colorSchemes[index]

                Button(action: {
                    selectedColorScheme = scheme.id
                    updateColorScheme()
                    dismiss()
                }) {
                    HStack(spacing: 16) {
                        // Icon
                        Image(systemName: scheme.systemImage)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(scheme.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                                .tracking(-0.36)

                            Text(scheme.description)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textSecondary)
                                .tracking(-0.32)
                        }

                        Spacer()

                        if scheme.id == selectedColorScheme {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: 72)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                if index < colorSchemes.count - 1 {
                    Rectangle()
                        .fill(FigmaColorTokens.adaptiveT1)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }

    private func updateColorScheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        switch selectedColorScheme {
        case "light":
            window.overrideUserInterfaceStyle = .light
        case "dark":
            window.overrideUserInterfaceStyle = .dark
        default:
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
}

struct ColorSchemeOption: Identifiable {
    let id: String
    let name: String
    let description: String
    let systemImage: String
}

#Preview {
    ColorSchemeSelectionView()
}
