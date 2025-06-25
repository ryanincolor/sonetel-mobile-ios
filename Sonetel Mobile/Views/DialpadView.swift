//
//  DialpadView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct DialpadView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enteredNumber = "+46737431132"
    @State private var showCallerIdSelection = false
    @State private var showActiveCall = false
    @State private var selectedCallerId = "Personal"

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Main content
            VStack(spacing: 0) {
                // Number display section
                numberDisplaySection

                // Dialpad
                dialpadSection
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCallerIdSelection) {
            CallerIdSelectionView(selectedCallerId: $selectedCallerId)
        }
        .fullScreenCover(isPresented: $showActiveCall) {
            ActiveCallView(phoneNumber: enteredNumber)
        }
    }

    private var headerView: some View {
        HStack {
            // Back button
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 36, height: 36)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
            }

            // Title
            Spacer()
            Text("New Call")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            Spacer()

            // Caller ID selector
            Button(action: {
                showCallerIdSelection = true
            }) {
                HStack(spacing: 8) {
                    // Swedish flag
                    Text("🇸🇪")
                        .font(.system(size: 14))

                    Text("+46723319393")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(red: 0.961, green: 0.961, blue: 0.961))
                .cornerRadius(18)
            }

            // Globe button
            Button(action: {
                // Globe action
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 36, height: 36)

                    Image(systemName: "globe")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 73)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var numberDisplaySection: some View {
        VStack(spacing: 8) {
            Text(enteredNumber)
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            HStack {
                Text("$0.027 / min")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.961, green: 0.961, blue: 0.961))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 48)
    }

    private var dialpadSection: some View {
        VStack(spacing: 0) {
            // Dialpad grid
            VStack(spacing: 16) {
                // Row 1: 1, 2, 3
                HStack(spacing: 24) {
                    dialpadButton("1", action: { appendNumber("1") })
                    dialpadButton("2", action: { appendNumber("2") })
                    dialpadButton("3", action: { appendNumber("3") })
                }

                // Row 2: 4, 5, 6
                HStack(spacing: 24) {
                    dialpadButton("4", action: { appendNumber("4") })
                    dialpadButton("5", action: { appendNumber("5") })
                    dialpadButton("6", action: { appendNumber("6") })
                }

                // Row 3: 7, 8, 9
                HStack(spacing: 24) {
                    dialpadButton("7", action: { appendNumber("7") })
                    dialpadButton("8", action: { appendNumber("8") })
                    dialpadButton("9", action: { appendNumber("9") })
                }

                // Row 4: *, 0, #
                HStack(spacing: 24) {
                    dialpadButton("*", action: { appendNumber("*") })
                    dialpadButton("0", action: { appendNumber("0") })
                    dialpadButton("#", action: { appendNumber("#") })
                }

                // Row 5: Empty, Call, Delete
                HStack(spacing: 24) {
                    // Empty space
                    Color.clear
                        .frame(width: 72, height: 72)

                    // Call button
                    Button(action: {
                        showActiveCall = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 72, height: 72)

                            Image(systemName: "phone.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }

                    // Delete button
                    Button(action: deleteLastDigit) {
                        ZStack {
                            // Custom delete button shape
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                .frame(width: 48, height: 36)

                            Image(systemName: "delete.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                        }
                    }
                    .frame(width: 72, height: 72)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .padding(.top, 20)
    }

    private func dialpadButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                    .frame(width: 72, height: 72)

                Text(text)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func appendNumber(_ digit: String) {
        enteredNumber += digit
    }

    private func deleteLastDigit() {
        if !enteredNumber.isEmpty {
            enteredNumber.removeLast()
        }
    }
}

#Preview {
    DialpadView()
}
