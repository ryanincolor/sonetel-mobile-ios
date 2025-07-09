//
//  OnboardingFlowView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // Main app with tab navigation
                MainTabView()
                    .environmentObject(authManager)
            } else {
                // Onboarding flow
                switch authManager.currentStep {
                case .welcome:
                    WelcomeView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .login:
                    LoginView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .phoneEntry:
                    PhoneNumberEntryView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .otpVerification:
                    OTPVerificationView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .permissions:
                    PermissionsView()
                        .environmentObject(authManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))

                case .completed:
                    MainTabView()
                        .environmentObject(authManager)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authManager.currentStep)
    }
}

#Preview {
    OnboardingFlowView()
}
