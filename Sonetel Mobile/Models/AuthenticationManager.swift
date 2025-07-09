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
    private let isDevelopmentMode: Bool = false // Change to true for development mode

    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentUser: AuthenticatedUser?
    @Published var accountInfo: AccountInfo?
    @Published var userProfile: SonetelUserProfile?

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
        } else {
            // Disabled automatic session restoration to prevent auto sign-in
            // Users must manually sign in each time
            print("ℹ️ AuthenticationManager: Auto sign-in disabled, user must sign in manually")
        }
    }

    /// Check if user is already authenticated and restore session
    private func checkExistingAuthentication() {
        // Only check for existing authentication if we have stored tokens
        guard SonetelAPIService.shared.isAuthenticated else {
            print("ℹ️ No stored authentication tokens found")
            return
        }

        print("🔍 Found stored tokens, validating authentication...")

        Task {
            do {
                // Try to get account info with existing tokens
                let accountInfo = try await SonetelAPIService.shared.getAccountInfo()

                await MainActor.run {
                    // Restore authenticated state only if account info was successfully retrieved
                    self.isAuthenticated = true
                    self.hasCompletedOnboarding = true
                    self.accountInfo = accountInfo
                    self.currentUser = AuthenticatedUser(
                        email: accountInfo.email ?? "",
                        phoneNumber: accountInfo.phone_number ?? "",
                        name: accountInfo.name
                    )
                    self.currentStep = .completed
                    self.hasNotificationPermission = true
                    self.hasContactsPermission = true

                    print("✅ Restored authentication session for: \(accountInfo.email ?? "Unknown")")
                }
            } catch {
                // Clear invalid stored authentication data
                print("⚠️ Stored authentication is invalid, clearing tokens: \(error)")
                await MainActor.run {
                    SonetelAPIService.shared.clearTokens()
                    self.resetToWelcomeScreen()
                }
            }
        }
    }

    /// Reset authentication state to welcome screen
    private func resetToWelcomeScreen() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        currentUser = nil
        accountInfo = nil
        currentStep = .welcome
        resetState()
        print("🔄 Reset to welcome screen")
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

        print("🔐 AuthManager: Starting sign in process for: \(email)")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("🔐 AuthManager: Testing connectivity to Sonetel...")

                // Test connectivity first
                let isConnected = try await SonetelAPIService.shared.testConnectivity()
                if !isConnected {
                    throw SonetelAPIError.networkError("Cannot reach Sonetel servers")
                }

                print("🔐 AuthManager: Calling Sonetel API for authentication...")

                // Authenticate with Sonetel API
                _ = try await SonetelAPIService.shared.createToken(
                    email: email,
                    password: password
                )

                print("✅ AuthManager: Token creation completed")
                print("🔐 AuthManager: API service authenticated: \(SonetelAPIService.shared.isAuthenticated)")
                print("✅ AuthManager: Getting account info...")

                // Get account information
                let accountInfo = try await SonetelAPIService.shared.getAccountInfo(userEmail: self.email)
                print("✅ AuthManager: Account info received successfully")

                // Get user profile information
                print("🔍 AuthManager: Fetching user profile data...")
                let userProfile = try await SonetelAPIService.shared.getUserProfile()
                print("✅ AuthManager: User profile received successfully")

                print("✅ AuthManager: Account info received, updating UI...")

                // Authentication successful
                await MainActor.run {
                    self.isLoading = false

                    // Store account info and user profile
                    self.accountInfo = accountInfo
                    self.userProfile = userProfile

                    // Update current user with real account and profile data
                    let displayName = userProfile.full_name ?? userProfile.first_name ?? accountInfo.name
                    let phoneNumber = userProfile.phone ?? userProfile.mobile ?? accountInfo.phone_number ?? ""

                    self.currentUser = AuthenticatedUser(
                        email: userProfile.email ?? accountInfo.email ?? self.email,
                        phoneNumber: phoneNumber,
                        name: displayName
                    )

                    print("✅ AuthManager: User created: \(self.currentUser?.email ?? "unknown")")

                    // If user has a verified phone number, skip phone entry
                    if let phoneNumber = accountInfo.phone_number, !phoneNumber.isEmpty, accountInfo.verified == true {
                        self.phoneNumber = phoneNumber
                        self.currentStep = .permissions
                        print("✅ AuthManager: Verified user, skipping to permissions")
                    } else {
                        self.currentStep = .phoneEntry
                        print("✅ AuthManager: Unverified user, going to phone entry")
                    }
                }

            } catch let error as SonetelAPIError {
                print("❌ AuthManager: Sonetel API error: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    switch error {
                    case .authenticationFailed(let message):
                        self.errorMessage = message.contains("invalid_grant") ?
                            "Invalid email or password" : message
                    case .networkError(let message):
                        self.errorMessage = "Network error: \(message)"
                    case .unauthorizedAccess:
                        self.errorMessage = "Unauthorized access - please check your credentials"
                        print("❌ AuthManager: Unauthorized access error occurred")
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                    print("❌ AuthManager: Error message set to: \(self.errorMessage ?? "none")")
                }
            } catch {
                print("❌ AuthManager: General error: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Connection failed: \(error.localizedDescription)"
                    print("❌ AuthManager: Error message set to: \(self.errorMessage ?? "none")")
                }
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
        accountInfo = nil
        userProfile = nil
        currentStep = .welcome

        // Clear API tokens
        SonetelAPIService.shared.clearTokens()

        resetState()
    }

    // MARK: - Development Helper Methods

    /// For development: Force login without going through the flow
    func quickLoginForTesting() {
        setupDevelopmentUser()
    }

    /// Development quick login with real API authentication
    func devQuickLogin() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("🚀 Development Quick Login: Authenticating with real API...")

                // Use hardcoded development credentials
                let devEmail = "appdev@sonetell.com"
                let devPassword = "test1234"

                // Test connectivity first
                let isConnected = try await SonetelAPIService.shared.testConnectivity()
                if !isConnected {
                    throw SonetelAPIError.networkError("Cannot reach Sonetel servers")
                }

                // Authenticate with Sonetel API
                _ = try await SonetelAPIService.shared.createToken(
                    email: devEmail,
                    password: devPassword
                )

                // Get account information
                let accountInfo = try await SonetelAPIService.shared.getAccountInfo(userEmail: devEmail)

                // Get user profile information
                let userProfile = try await SonetelAPIService.shared.getUserProfile()

                // Authentication successful
                await MainActor.run {
                    self.isLoading = false
                    self.accountInfo = accountInfo
                    self.userProfile = userProfile

                    // Update current user with real account and profile data
                    let displayName = userProfile.full_name ?? userProfile.first_name ?? accountInfo.name
                    let phoneNumber = userProfile.phone ?? userProfile.mobile ?? accountInfo.phone_number ?? ""

                    self.currentUser = AuthenticatedUser(
                        email: userProfile.email ?? accountInfo.email ?? devEmail,
                        phoneNumber: phoneNumber,
                        name: displayName
                    )

                    self.email = devEmail
                    self.isAuthenticated = true
                    self.hasCompletedOnboarding = true
                    self.currentStep = .completed
                    self.hasNotificationPermission = true
                    self.hasContactsPermission = true

                    print("✅ Development Quick Login: Successfully authenticated!")
                }

            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Quick login failed: \(error.localizedDescription)"
                    print("❌ Development Quick Login failed: \(error)")
                }
            }
        }
    }

    /// Dummy account login with mock data for testing UI
    func dummyAccountLogin() {
        isLoading = true
        errorMessage = nil

        // Simulate login delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("🎭 Dummy Account Login: Logging in with mock data...")

            // Set up dummy account data
            self.accountInfo = AccountInfo(
                account_id: "999999999",
                currency: "USD",
                email: "demo@sonetel.com",
                name: "Demo User",
                phone_number: "+1234567890",
                verified: true
            )

            self.userProfile = SonetelUserProfile(
                user_id: "demo_user_123",
                email: "demo@sonetel.com",
                first_name: "Demo",
                last_name: "User",
                full_name: "Demo User",
                phone: "+1234567890",
                mobile: "+1234567890",
                status: "active"
            )

            self.currentUser = AuthenticatedUser(
                email: "demo@sonetel.com",
                phoneNumber: "+1234567890",
                name: "Demo User"
            )

            self.email = "demo@sonetel.com"
            self.phoneNumber = "+1234567890"
            self.isAuthenticated = true
            self.hasCompletedOnboarding = true
            self.currentStep = .completed
            self.hasNotificationPermission = true
            self.hasContactsPermission = true
            self.isLoading = false

            // Enable dummy data mode in API service
            SonetelAPIService.shared.enableDummyDataMode()

            print("✅ Dummy Account Login: Successfully logged in with mock data!")
        }
    }

    /// For development: Test the login flow by resetting authentication
    func testLoginFlow() {
        print("🧪 Testing login flow - clearing all authentication data")
        SonetelAPIService.shared.clearTokens()
        resetToWelcomeScreen()
    }

    /// Completely reset all authentication data (for debugging)
    func completeAuthenticationReset() {
        print("🔄 Complete authentication reset")
        SonetelAPIService.shared.clearTokens()
        resetToWelcomeScreen()
    }

    /// Refresh account information and user profile from Sonetel API
    func refreshAccountInfo() {
        Task {
            do {
                print("🔄 AuthManager: Refreshing account info and user profile...")

                // Refresh both account info and user profile
                async let accountInfoTask = SonetelAPIService.shared.getAccountInfo(userEmail: self.email)
                async let userProfileTask = SonetelAPIService.shared.getUserProfile()

                let (accountInfo, userProfile) = try await (accountInfoTask, userProfileTask)

                await MainActor.run {
                    self.accountInfo = accountInfo
                    self.userProfile = userProfile

                    // Update current user with fresh data from both sources
                    let displayName = userProfile.full_name ?? userProfile.first_name ?? accountInfo.name ?? self.currentUser?.name
                    let phoneNumber = userProfile.phone ?? userProfile.mobile ?? accountInfo.phone_number ?? self.currentUser?.phoneNumber ?? ""
                    let email = userProfile.email ?? accountInfo.email ?? self.currentUser?.email ?? self.email

                    self.currentUser = AuthenticatedUser(
                        email: email,
                        phoneNumber: phoneNumber,
                        name: displayName
                    )

                    print("✅ AuthManager: Successfully refreshed account info and user profile")
                }
            } catch {
                print("❌ AuthManager: Failed to refresh account info or user profile: \(error)")
            }
        }
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

    static let sweden = Country(name: "Sweden", code: "+46", flag: "���🇪")
    static let usa = Country(name: "United States", code: "+1", flag: "🇺🇸")
    static let uk = Country(name: "United Kingdom", code: "+44", flag: "🇬🇧")
    static let germany = Country(name: "Germany", code: "+49", flag: "🇩🇪")

    static let all: [Country] = [.sweden, .usa, .uk, .germany]
}
