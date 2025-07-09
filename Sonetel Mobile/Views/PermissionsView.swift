//
//  PermissionsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI
import UserNotifications
import Contacts

struct PermissionsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isRequestingPermissions = false
    @State private var permissionStep = 0 // 0: waiting, 1: notifications requested, 2: contacts requested, 3: completed

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Status bar
                statusBarView

                // Main content
                VStack(spacing: 0) {
                    contentView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FigmaColorTokens.surfacePrimary)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .ignoresSafeArea(.all, edges: .top)
    }

    private var statusBarView: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(FigmaColorTokens.textPrimary)

            Spacer()

            HStack(spacing: 7) {
                // Signal strength bars
                HStack(spacing: 2) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.black)
                            .frame(width: 3, height: CGFloat(4 + index * 2))
                            .opacity(index < 3 ? 1.0 : 0.4)
                    }
                }

                // WiFi icon
                Image(systemName: "wifi")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)

                // Battery
                ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .stroke(.black, lineWidth: 1)
                        .frame(width: 24, height: 12)
                        .opacity(0.35)

                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black)
                        .frame(width: 20, height: 8)

                    // Battery tip
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black.opacity(0.4))
                        .frame(width: 1, height: 4)
                        .offset(x: 14)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 21)
        .frame(height: 50)
        .background(FigmaColorTokens.surfacePrimary)
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Main content
            VStack(spacing: 40) {
                // Title and description
                VStack(spacing: 8) {
                    Text("Allow permissions")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .tracking(-0.68)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 353)

                    Text("By allowing permissions you ensure that you will get the best experience.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 353)
                }

                // Permission cards
                VStack(spacing: 20) {
                    PermissionCardView(
                        icon: "bell.fill",
                        iconColor: .blue,
                        title: "Notifications",
                        description: "Sonetel will make sure you don't miss any calls when the app is not open."
                    )

                    PermissionCardView(
                        icon: "person.2.fill",
                        iconColor: .orange,
                        title: "Contacts",
                        description: "Sonetel uses your contacts to make to easily make and receive calls. We do not store your contacts on the server."
                    )
                }
            }

            Spacer()

            // Continue button
            Button(action: {
                handleContinueButton()
            }) {
                Text(buttonText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .tracking(-0.36)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .cornerRadius(36)
            }
            .disabled(isRequestingPermissions)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var buttonText: String {
        switch permissionStep {
        case 1:
            return "Requesting notifications..."
        case 2:
            return "Requesting contacts..."
        case 3:
            return "Completing..."
        default:
            return "Continue"
        }
    }
    
    private func handleContinueButton() {
        guard permissionStep == 0 else { return }
        
        isRequestingPermissions = true
        permissionStep = 1
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        print("Requesting notification permission...")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("Notification permission result: granted=\(granted), error=\(String(describing: error))")
            
            // Move to next step
            DispatchQueue.main.async {
                self.permissionStep = 2
                self.requestContactsPermission()
            }
        }
    }
    
    private func requestContactsPermission() {
        print("Requesting contacts permission...")
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            print("Contacts permission result: granted=\(granted), error=\(String(describing: error))")
            
            // Complete the flow
            DispatchQueue.main.async {
                self.permissionStep = 3
                self.completeFlow()
            }
        }
    }
    
    private func completeFlow() {
        print("Completing permission flow...")
        
        // Small delay to show completion state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Complete onboarding
            self.authManager.completeOnboarding()
        }
    }
}

struct PermissionCardView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.36)

                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: 353)
        .background(Color(red: 0.961, green: 0.961, blue: 0.961))
        .cornerRadius(12)
    }
}

#Preview {
    PermissionsView()
        .environmentObject(AuthenticationManager())
}
