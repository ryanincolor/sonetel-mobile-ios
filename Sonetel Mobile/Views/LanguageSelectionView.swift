//
//  LanguageSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedLanguage") private var selectedLanguage = ""

    let languages = [
        Language(code: "en", name: "English", nativeName: "English"),
        Language(code: "sv", name: "Swedish", nativeName: "Svenska"),
        Language(code: "de", name: "German", nativeName: "Deutsch"),
        Language(code: "fr", name: "French", nativeName: "Français"),
        Language(code: "es", name: "Spanish", nativeName: "Español"),
        Language(code: "it", name: "Italian", nativeName: "Italiano"),
        Language(code: "pt", name: "Portuguese", nativeName: "Português"),
        Language(code: "da", name: "Danish", nativeName: "Dansk"),
        Language(code: "no", name: "Norwegian", nativeName: "Norsk"),
        Language(code: "fi", name: "Finnish", nativeName: "Suomi")
    ]

    private var deviceLanguage: String {
        Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    }

    private var currentLanguage: String {
        selectedLanguage.isEmpty ? deviceLanguage : selectedLanguage
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Language") {
                dismiss()
            }

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    menuView
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .navigationBarHidden(true)
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(languages.indices, id: \.self) { index in
                let language = languages[index]

                Button(action: {
                    selectedLanguage = language.code
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                                .tracking(-0.36)

                            Text(language.nativeName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textSecondary)
                                .tracking(-0.32)
                        }

                        Spacer()

                        if language.code == currentLanguage {
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

                if index < languages.count - 1 {
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
}

struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let nativeName: String
}

#Preview {
    LanguageSelectionView()
}
