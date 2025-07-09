//
//  SettingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("selectedLanguage") private var selectedLanguage = ""
    @AppStorage("selectedColorScheme") private var selectedColorScheme = "system"
    @State private var showingSafari = false


    @State private var showingVersionCopied = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with close button
                NavigationHeaderView(title: "Settings", showBackButton: false, showCloseButton: true) {
                    dismiss()
                }

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // User profile section
                        UserProfileView(userProfile: currentUserProfile)

                        // Main menu sections
                        mainMenuSection



                        // Development section (only in debug builds)


                        // App section
                        appSection

                        // About section
                        aboutSection

                        // Logout section
                        logoutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
            .background(FigmaColorTokens.surfacePrimary)
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: "https://sonetel.com/en/help/support-center/")!)
        }



        .overlay(
            Group {
                if showingVersionCopied {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Version copied to clipboard")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
        )
    }



    // MARK: - Menu Sections
    private var mainMenuSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: PhoneNumbersView()) {
                MenuItemView(title: "Phone Numbers", type: .navigation)
            }

            NavigationLink(destination: CallSettingsView()) {
                MenuItemView(title: "Call Settings", type: .navigation, hasDivider: false)
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }

    private var appSection: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                NavigationLink(destination: LanguageSelectionView()) {
                    MenuItemView(
                        title: "Language",
                        value: currentLanguageDisplayName,
                        type: .navigation
                    )
                }

                NavigationLink(destination: ColorSchemeSelectionView()) {
                    MenuItemView(
                        title: "Appearance",
                        value: currentColorSchemeDisplayName,
                        type: .navigation,
                        hasDivider: false
                    )
                }
            }
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var aboutSection: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                MenuItemView(
                    title: "Help & Support",
                    type: .navigation
                ) {
                    showingSafari = true
                }

                NavigationLink(destination: TermsOfUseView()) {
                    MenuItemView(
                        title: "Terms of Use",
                        type: .navigation
                    )
                }

                MenuItemView(
                    title: "Version",
                    value: appVersion,
                    type: .select,
                    hasDivider: false
                ) {
                    copyVersionToClipboard()
                }
            }
            .background(FigmaColorTokens.adaptiveT1)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }





    private var logoutSection: some View {
        VStack(spacing: 0) {
            MenuItemView(
                title: "Logout",
                type: .select,
                hasDivider: false
            ) {
                authManager.logout()
                dismiss()
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Helper Views
    private func accountInfoRow(title: String, value: String, truncate: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                Spacer()
                Text(value)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                    .lineLimit(truncate ? 1 : nil)
                    .truncationMode(truncate ? .middle : .tail)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 56)

            Rectangle().fill(FigmaColorTokens.adaptiveT1).frame(height: 1)
        }
    }

    // MARK: - Computed Properties
    var currentUserProfile: UserProfile {
        if let user = authManager.currentUser {
            let displayName: String
            if let name = user.name, !name.isEmpty {
                displayName = name
            } else {
                displayName = user.email.components(separatedBy: "@").first?.capitalized ?? "User"
            }

            return UserProfile(
                name: displayName,
                email: user.email,
                backgroundColor: "#FFEF62"
            )
        } else {
            return UserProfile.current
        }
    }

    private var deviceLanguage: String {
        Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "en"
    }

    private var currentLanguageDisplayName: String {
        let currentCode = selectedLanguage.isEmpty ? deviceLanguage : selectedLanguage
        switch currentCode {
        case "en": return "English"
        case "sv": return "Svenska"
        case "de": return "Deutsch"
        case "fr": return "Français"
        case "es": return "Español"
        case "it": return "Italiano"
        case "pt": return "Português"
        case "da": return "Dansk"
        case "no": return "Norsk"
        case "fi": return "Suomi"
        default: return "English"
        }
    }

    private var currentColorSchemeDisplayName: String {
        switch selectedColorScheme {
        case "light": return "Light"
        case "dark": return "Dark"
        default: return "Automatic"
        }
    }

    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "v\(version) (\(build))"
        }
        return "v1.0 (1)"
    }

    // MARK: - Helper Methods
    private func copyVersionToClipboard() {
        UIPasteboard.general.string = appVersion
        showingVersionCopied = true

        // Hide the message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingVersionCopied = false
        }
    }

    private func formatDate(_ dateString: String) -> String {
        // Try to parse common date formats from API
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        for format in dateFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format

            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateStyle = .medium
                displayFormatter.timeStyle = .short
                return displayFormatter.string(from: date)
            }
        }

        // If parsing fails, return the original string
        return dateString
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
}
