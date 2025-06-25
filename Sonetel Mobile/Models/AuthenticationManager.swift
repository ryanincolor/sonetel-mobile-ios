//
//  AuthenticationManager.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation
import SwiftUI

@MainActor
class AuthenticationManager: ObservableObject {
    // MARK: - Development Configuration
    /*
     Development Mode Instructions:

     1. Set `isDevelopmentMode = true` to automatically log in when the app starts
     2. Set `isDevelopmentMode = false` for production or to test the full login flow
     3. Use the Settings > Development section to:
        - "Test Login Flow": Reset to welcome screen to test authentication
        - "Quick Login": Instantly log back in without going through the flow

     This allows for rapid testing without having to complete the login flow every time.
     */
    private let isDevelopmentMode: Bool = true // Change to false for production

    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentUser: AuthenticatedUser?

    enum AuthenticationStep {
        case welcome
        case login
        case phoneEntry
        case otpVerification
        case permissions
        case completed
    }

    @Published var currentStep: AuthenticationStep = .welcome

    // Login state
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showPasswordField: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Phone verification state
    @Published var selectedCountry: Country = .sweden
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""
    @Published var otpTimer: Int = 59
    @Published var canResendOTP: Bool = false

    // Permissions state
    @Published var hasNotificationPermission: Bool = false
    @Published var hasContactsPermission: Bool = false

    init() {
        if isDevelopmentMode {
            // Auto-authenticate for development
            setupDevelopmentUser()
        }
    }

    private func setupDevelopmentUser() {
        print("🚀 Development Mode: Auto-authenticating user")
        isAuthenticated = true
        hasCompletedOnboarding = true
        currentUser = AuthenticatedUser(
            email: "developer@sonetel.com",
            phoneNumber: "+1234567890",
            name: "Developer User"
        )
        currentStep = .completed
        hasNotificationPermission = true
        hasContactsPermission = true
    }

    func startAuthentication() {
        currentStep = .login
    }

    func continueWithEmail() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        showPasswordField = true
        errorMessage = nil
    }

    func signInWithEmail() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoading = true
        errorMessage = nil

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false

            // Simulate authentication success - be more lenient with email comparison
            let normalizedEmail = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if normalizedEmail == "joanna@taylored.com" && self.password == "password123" {
                self.currentStep = .phoneEntry
            } else {
                self.errorMessage = "Invalid email or password"
            }
        }
    }

    func signInWithGoogle() {
        isLoading = true

        // Simulate Google sign-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.currentStep = .phoneEntry
        }
    }

    func signInWithApple() {
        isLoading = true

        // Simulate Apple sign-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.currentStep = .phoneEntry
        }
    }

    func submitPhoneNumber() {
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number"
            return
        }

        guard isValidPhoneNumber(phoneNumber) else {
            errorMessage = "Please enter a valid phone number"
            return
        }

        isLoading = true
        errorMessage = nil

        // Simulate sending OTP
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.currentStep = .otpVerification
            self.startOTPTimer()
        }
    }

    func verifyOTP() {
        guard otpCode.count == 6 else {
            errorMessage = "Please enter the complete verification code"
            return
        }

        isLoading = true
        errorMessage = nil

        // Simulate OTP verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false

            // Simulate success with code "123456"
            if self.otpCode == "123456" {
                self.currentStep = .permissions
            } else {
                self.errorMessage = "Invalid verification code"
                self.otpCode = ""
            }
        }
    }

    func requestNotificationPermission() {
        // In a real app, request actual notification permission
        hasNotificationPermission = true
    }

    func requestContactsPermission() {
        // In a real app, request actual contacts permission
        hasContactsPermission = true
    }

    func completeOnboarding() {
        // Prevent multiple completion calls
        guard !hasCompletedOnboarding && !isAuthenticated else {
            print("AuthenticationManager: Onboarding already completed, ignoring duplicate call")
            return
        }

        print("AuthenticationManager: Completing onboarding")
        hasCompletedOnboarding = true
        isAuthenticated = true
        currentUser = AuthenticatedUser(
            email: email,
            phoneNumber: phoneNumber,
            name: nil // Will be populated from API in real implementation
        )
        currentStep = .completed
        print("AuthenticationManager: Onboarding completed, isAuthenticated: \(isAuthenticated)")
    }

    func logout() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentUser = nil
        currentStep = .welcome
        resetState()
    }

    // MARK: - Development Helper Methods

    /// For development: Force login without going through the flow
    func quickLoginForTesting() {
        setupDevelopmentUser()
    }

    /// For development: Test the login flow by resetting authentication
    func testLoginFlow() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentUser = nil
        currentStep = .welcome
        resetState()
    }

    private func resetState() {
        email = ""
        password = ""
        phoneNumber = ""
        otpCode = ""
        showPasswordField = false
        isLoading = false
        errorMessage = nil
        hasNotificationPermission = false
        hasContactsPermission = false
    }

    private func startOTPTimer() {
        otpTimer = 59
        canResendOTP = false

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.otpTimer > 0 {
                    self.otpTimer -= 1
                } else {
                    self.canResendOTP = true
                    timer.invalidate()
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        return cleanPhone.count >= 7 && cleanPhone.allSatisfy { $0.isNumber }
    }
}

struct AuthenticatedUser {
    let email: String
    let phoneNumber: String
    let name: String?

    /// Returns the first letter of the user's name, or first letter of email if no name
    var initial: String {
        if let name = name, !name.isEmpty {
            return String(name.prefix(1)).uppercased()
        } else {
            return String(email.prefix(1)).uppercased()
        }
    }
}

struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String

    static let sweden = Country(name: "Sweden", code: "+46", flag: "🇸🇪")
    static let usa = Country(name: "United States", code: "+1", flag: "🇺🇸")
    static let uk = Country(name: "United Kingdom", code: "+44", flag: "🇬🇧")
    static let germany = Country(name: "Germany", code: "+49", flag: "🇩🇪")

    static let all: [Country] = [.sweden, .usa, .uk, .germany]
}
