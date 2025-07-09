//
//  PhoneNumberEntryView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct PhoneNumberEntryView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @FocusState private var isPhoneNumberFocused: Bool
    @State private var showCountryPicker = false

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
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(selectedCountry: $authManager.selectedCountry)
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
        VStack(spacing: 0) {
            // Main content - aligned to top
            VStack(spacing: 40) {
                // Title
                Text("Enter your phone number")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.68)
                    .multilineTextAlignment(.center)

                // Form
                VStack(spacing: 8) {
                    // Country selector
                    Button(action: {
                        showCountryPicker = true
                    }) {
                        HStack {
                            Text(authManager.selectedCountry.flag)
                                .font(.system(size: 16))

                            Text("\(authManager.selectedCountry.name) (\(authManager.selectedCountry.code))")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(FigmaColorTokens.textPrimary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(height: 48)
                        .background(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .cornerRadius(12)
                    }

                    // Phone number input
                    ZStack(alignment: .leading) {
                        HStack {
                            if authManager.phoneNumber.isEmpty {
                                Text("Your mobile number")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)

                        HStack {
                            TextField("", text: $authManager.phoneNumber)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                                .focused($isPhoneNumberFocused)
                                .keyboardType(.phonePad)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 15)
                    }
                    .frame(height: 48)
                    .background(Color(red: 0.961, green: 0.961, blue: 0.961))
                    .cornerRadius(12)
                }
                .frame(maxWidth: 353)
            }
            .padding(.top, 40)

            Spacer()

            // Continue button
            Button(action: {
                authManager.submitPhoneNumber()
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }

                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .tracking(-0.36)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 0.067, green: 0.067, blue: 0.067))
                .cornerRadius(36)
            }
            .disabled(authManager.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Auto-focus phone number field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneNumberFocused = true
            }
        }
    }
}

struct CountryPickerView: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(Country.all) { country in
                Button(action: {
                    selectedCountry = country
                    dismiss()
                }) {
                    HStack {
                        Text(country.flag)
                            .font(.system(size: 20))

                        VStack(alignment: .leading) {
                            Text(country.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)

                            Text(country.code)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if selectedCountry.id == country.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

#Preview {
    PhoneNumberEntryView()
        .environmentObject(AuthenticationManager())
}
