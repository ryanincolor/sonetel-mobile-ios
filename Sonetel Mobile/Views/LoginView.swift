//
//  LoginView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

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
                .background(Color.white)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
        .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.errorMessage = nil
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
    }

    private var statusBarView: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)

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
                    .foregroundColor(.black)

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
        .background(Color.white)
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Main content
            VStack(spacing: 40) {
                // Title
                Text("Welcome")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.black)
                    .tracking(-0.68)

                // Forms and buttons
                VStack(spacing: 28) {
                    // Email form
                    emailFormView

                    // Social sign-in methods
                    socialSignInView
                }
                .frame(maxWidth: 360)
            }

            Spacer()

            // Footer
            footerView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }

    private var emailFormView: some View {
        VStack(spacing: 12) {
            // Email input
            VStack(spacing: authManager.showPasswordField ? 12 : 0) {
                // Email field
                ZStack(alignment: .leading) {
                    HStack {
                        if authManager.email.isEmpty {
                            Text("Email address")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color.black.opacity(0.6))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)

                    HStack {
                        TextField("", text: $authManager.email)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .focused($isEmailFocused)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .disabled(authManager.showPasswordField && !authManager.email.isEmpty)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .frame(height: 48)
                .background(Color.black.opacity(isEmailFocused ? 0.06 : 0.04))
                .cornerRadius(40)

                // Password field (animated in)
                if authManager.showPasswordField {
                    ZStack(alignment: .leading) {
                        HStack {
                            if authManager.password.isEmpty {
                                Text("Password")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)

                        HStack {
                            SecureField("", text: $authManager.password)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .focused($isPasswordFocused)

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .frame(height: 48)
                    .background(Color.black.opacity(isPasswordFocused ? 0.06 : 0.04))
                    .cornerRadius(40)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        // Auto-focus password field when it appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPasswordFocused = true
                        }
                    }
                }
            }

            // Continue button
            Button(action: {
                if authManager.showPasswordField {
                    authManager.signInWithEmail()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        authManager.continueWithEmail()
                    }
                    // Auto-focus password field after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPasswordFocused = true
                    }
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }

                    Text(authManager.showPasswordField ? "Continue" : "Continue with email")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .tracking(-0.32)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.black)
                .cornerRadius(36)
            }
            .disabled(authManager.isLoading)
        }
    }

    private var socialSignInView: some View {
        VStack(spacing: 8) {
            // Google sign-in
            Button(action: {
                authManager.signInWithGoogle()
            }) {
                HStack(spacing: 15) {
                    Text("Continue with Google")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .tracking(-0.32)

                    Image(systemName: "globe")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black.opacity(0.04))
                .cornerRadius(100)
            }
            .disabled(authManager.isLoading)

            // Apple sign-in
            Button(action: {
                authManager.signInWithApple()
            }) {
                HStack(spacing: 15) {
                    Text("Continue with Apple")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .tracking(-0.32)

                    Image(systemName: "applelogo")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.black.opacity(0.04))
                .cornerRadius(100)
            }
            .disabled(authManager.isLoading)
        }
    }

    private var footerView: some View {
        Button(action: {
            // Terms of use action
        }) {
            Text("Terms of use")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .underline()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}
