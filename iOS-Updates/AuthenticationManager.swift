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
    @Published var selectedCountry: Country = Country.countries.first { $0.code == "+1" } ?? Country.countries[0]
    @Published var phoneNumber: String = ""
    @Published var otpCode: String = ""

    init() {
        if isDevelopmentMode {
            startDevelopmentSession()
        }
    }

    // MARK: - Development Methods

    private func startDevelopmentSession() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAuthenticated = true
            self.hasCompletedOnboarding = true
            self.currentUser = AuthenticatedUser(
                email: "developer@sonetel.com",
                phoneNumber: "+1234567890",
                name: "Developer User"
            )
        }
    }

    func resetToWelcomeForTesting() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentUser = nil
        currentStep = .welcome
        clearForm()
    }

    func quickLogin() {
        isAuthenticated = true
        hasCompletedOnboarding = true
        currentUser = AuthenticatedUser(
            email: "developer@sonetel.com",
            phoneNumber: "+1234567890",
            name: "Developer User"
        )
    }

    // MARK: - Authentication Flow

    func startLoginFlow() {
        currentStep = .login
    }

    func submitEmail() {
        // Clear any previous errors
        errorMessage = nil
        isLoading = true

        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false

            // Check if this email exists (simplified for demo)
            let normalizedEmail = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if normalizedEmail == "joanna@taylored.com" && self.password == "password123" {
                self.currentStep = .phoneEntry
            } else if normalizedEmail.contains("@") {
                self.showPasswordField = true
            } else {
                self.errorMessage = "Please enter a valid email address."
            }
        }
    }

    func submitLogin() {
        // Clear any previous errors
        errorMessage = nil
        isLoading = true

        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false

            // Simple validation for demo purposes
            let normalizedEmail = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if normalizedEmail == "joanna@taylored.com" && self.password == "password123" {
                self.currentStep = .phoneEntry
            } else {
                self.errorMessage = "Invalid email or password. Please try again."
            }
        }
    }

    func submitPhoneNumber() {
        // Validate phone number
        let cleanPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanPhoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number."
            return
        }
        
        guard cleanPhoneNumber.count >= 7 else {
            errorMessage = "Please enter a valid phone number."
            return
        }

        // Clear any previous errors
        errorMessage = nil
        isLoading = true

        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.currentStep = .otpVerification
        }
    }

    func submitOTP() {
        // Validate OTP
        guard otpCode.count == 6 else {
            errorMessage = "Please enter the complete 6-digit code."
            return
        }

        // Clear any previous errors
        errorMessage = nil
        isLoading = true

        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false

            // For demo purposes, accept any 6-digit code
            if self.otpCode.count == 6 {
                self.completeAuthentication()
            } else {
                self.errorMessage = "Invalid verification code. Please try again."
            }
        }
    }

    private func completeAuthentication() {
        isAuthenticated = true
        currentUser = AuthenticatedUser(
            email: email,
            phoneNumber: phoneNumber,
            name: nil // Will be populated from API in real implementation
        )
        currentStep = .permissions
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentStep = .completed
    }

    func logout() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentUser = nil
        currentStep = .welcome
        clearForm()
    }

    // MARK: - Utility Methods

    private func clearForm() {
        email = ""
        password = ""
        phoneNumber = ""
        otpCode = ""
        showPasswordField = false
        errorMessage = nil
        isLoading = false
    }

    func resendOTP() {
        // Simulate resending OTP
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            // In a real app, you would call your API here
            print("OTP resent to \(self.selectedCountry.code)\(self.phoneNumber)")
        }
    }
}

// MARK: - Models

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

    static let countries = [
        Country(name: "United States", code: "+1", flag: "🇺🇸"),
        Country(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
        Country(name: "Sweden", code: "+46", flag: "🇸🇪"),
        Country(name: "Canada", code: "+1", flag: "🇨🇦"),
        Country(name: "Australia", code: "+61", flag: "🇦🇺"),
        Country(name: "Germany", code: "+49", flag: "🇩🇪"),
        Country(name: "France", code: "+33", flag: "🇫🇷"),
        Country(name: "Spain", code: "+34", flag: "🇪🇸"),
        Country(name: "Italy", code: "+39", flag: "🇮🇹"),
        Country(name: "Netherlands", code: "+31", flag: "🇳🇱")
    ]
}
