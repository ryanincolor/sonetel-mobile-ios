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
    @State private var showingTerms = false
    @State private var showingLanguageSelection = false
    @State private var showingColorSchemeSelection = false
    @State private var showingVersionCopied = false
    @State private var showingPhoneNumbers = false
    @State private var showingCallSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // User profile section
                        UserProfileView(userProfile: currentUserProfile)

                        // Main menu sections
                        mainMenuSection

                        // Development section (only in debug builds)
                        #if DEBUG
                        developmentSection
                        #endif

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
            .background(Color.white)
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: "https://sonetel.com/en/help/support-center/")!)
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showingLanguageSelection) {
            LanguageSelectionView()
        }
        .sheet(isPresented: $showingColorSchemeSelection) {
            ColorSchemeSelectionView()
        }
        .sheet(isPresented: $showingPhoneNumbers) {
            NavigationStack {
                PhoneNumbersView()
            }
        }
        .sheet(isPresented: $showingCallSettings) {
            NavigationStack {
                CallSettingsView()
            }
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
                        .padding(.bottom, 100)
                    }
                }
            }
        )
    }

    private var headerView: some View {
        HStack {
            Spacer()

            Text("Settings")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 32, height: 32)

                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var mainMenuSection: some View {
        VStack(spacing: 0) {
            SettingsMenuItemView(title: "Phone numbers") {
                showingPhoneNumbers = true
            }

            Rectangle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                .frame(height: 1)

            SettingsMenuItemView(title: "Call settings") {
                showingCallSettings = true
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
    }

    private var appSection: some View {
        VStack(spacing: 8) {
            // Section header
            HStack {
                Text("App")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                Spacer()
            }
            .padding(.horizontal, 16)

            // Menu items
            VStack(spacing: 0) {
                SettingsMenuItemView(title: "Language", value: currentLanguageDisplayName) {
                    showingLanguageSelection = true
                }

                Rectangle()
                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                    .frame(height: 1)

                SettingsMenuItemView(title: "Color scheme", value: currentColorSchemeDisplayName) {
                    showingColorSchemeSelection = true
                }
            }
            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
            .cornerRadius(20)
        }
    }

    private var aboutSection: some View {
        VStack(spacing: 8) {
            // Section header
            HStack {
                Text("About")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                Spacer()
            }
            .padding(.horizontal, 16)

            // Menu items
            VStack(spacing: 0) {
                SettingsMenuItemView(title: "Help center") {
                    showingSafari = true
                }

                Rectangle()
                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                    .frame(height: 1)

                SettingsMenuItemView(title: "Terms of use") {
                    showingTerms = true
                }

                Rectangle()
                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                    .frame(height: 1)

                SettingsMenuItemView(title: "Sonetel for iOS", value: appVersion, hasChevron: false) {
                    copyVersionToClipboard()
                }
            }
            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
            .cornerRadius(20)
        }
    }

    #if DEBUG
    private var developmentSection: some View {
        VStack(spacing: 8) {
            // Section header
            HStack {
                Text("🚀 Development")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                Spacer()
            }
            .padding(.horizontal, 16)

            // Menu items
            VStack(spacing: 0) {
                Button(action: {
                    authManager.testLoginFlow()
                    dismiss()
                }) {
                    HStack {
                        Text("Test Login Flow")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: 56)
                }
                .buttonStyle(PlainButtonStyle())

                Rectangle()
                    .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                    .frame(height: 1)

                Button(action: {
                    authManager.quickLoginForTesting()
                }) {
                    HStack {
                        Text("Quick Login")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: 56)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.orange.opacity(0.1))
            .cornerRadius(20)
        }
    }
    #endif

    private var logoutSection: some View {
        VStack(spacing: 0) {
            SettingsMenuItemView(
                title: "Logout",
                hasChevron: false,
                isDestructive: true
            ) {
                authManager.logout()
                dismiss()
            }
        }
        .background(Color(red: 0.953, green: 0.953, blue: 0.953))
        .cornerRadius(20)
    }

    // MARK: - Computed Properties

    private var currentUserProfile: UserProfile {
        if let user = authManager.currentUser {
            // Use actual name if available, otherwise extract from email
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
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
}
