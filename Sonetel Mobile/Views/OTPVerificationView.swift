//
//  OTPVerificationView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?

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
        .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.errorMessage = nil
                // Clear OTP on error
                otpDigits = Array(repeating: "", count: 6)
                focusedField = 0
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
        .onChange(of: otpDigits) { _, newValue in
            // Update authManager OTP
            authManager.otpCode = newValue.joined()

            // Auto-verify when complete
            if authManager.otpCode.count == 6 {
                authManager.verifyOTP()
            }
        }
        .onAppear {
            // Auto-focus first field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
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
        VStack(spacing: 40) {
            // Title and description - aligned to top
            VStack(spacing: 4) {
                Text("Verification code")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.68)
                    .multilineTextAlignment(.center)

                Text("Enter the pin we just sent to \(authManager.selectedCountry.code)\(authManager.phoneNumber)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 353)
            }
            .padding(.top, 40)

            // OTP input fields
            VStack(spacing: 20) {
                // OTP digits
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        OTPDigitField(
                            text: $otpDigits[index],
                            isFocused: focusedField == index,
                            onTextChange: { newText in
                                handleTextChange(at: index, newText: newText)
                            },
                            onDelete: {
                                handleDelete(at: index)
                            }
                        )
                        .focused($focusedField, equals: index)
                    }
                }

                // Resend timer
                Text(authManager.canResendOTP ? "Resend code" : "Send again in \(authManager.otpTimer)s")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(authManager.canResendOTP ? .blue : Color(red: 0.878, green: 0.878, blue: 0.878))
                    .onTapGesture {
                        if authManager.canResendOTP {
                            // Resend OTP
                            authManager.submitPhoneNumber()
                            otpDigits = Array(repeating: "", count: 6)
                            focusedField = 0
                        }
                    }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func handleTextChange(at index: Int, newText: String) {
        // Only allow single digits
        let filtered = newText.filter { $0.isNumber }

        if filtered.count > 1 {
            // Handle paste of multiple digits
            let digits = Array(filtered.prefix(6 - index))
            for (i, digit) in digits.enumerated() {
                if index + i < 6 {
                    otpDigits[index + i] = String(digit)
                }
            }
            // Focus on next empty field or last field
            let nextIndex = min(index + digits.count, 5)
            focusedField = nextIndex
        } else if filtered.count == 1 {
            // Single digit input
            otpDigits[index] = filtered
            // Move to next field
            if index < 5 {
                focusedField = index + 1
            }
        }
    }

    private func handleDelete(at index: Int) {
        // Clear current field
        otpDigits[index] = ""
        // Move to previous field
        if index > 0 {
            focusedField = index - 1
        }
    }
}

struct OTPDigitField: View {
    @Binding var text: String
    let isFocused: Bool
    let onTextChange: (String) -> Void
    let onDelete: () -> Void
    @State private var previousText = ""

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 80)

            TextField("", text: $text)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .onChange(of: text) { _, newValue in
                    if newValue.isEmpty && !previousText.isEmpty {
                        // This is a delete operation
                        onDelete()
                    } else {
                        onTextChange(newValue)
                    }
                    previousText = newValue
                }
                .opacity(0.01) // Nearly invisible but still functional

            // Display the digit
            Text(text)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? .blue : .clear, lineWidth: 2)
        )
        .onAppear {
            previousText = text
        }
    }
}

#Preview {
    OTPVerificationView()
        .environmentObject(AuthenticationManager())
}
