//
//  PhoneNumberDetailView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct PhoneNumberDetailView: View {
    let phoneNumber: PhoneNumber
    @Environment(\.dismiss) private var dismiss
    @State private var showingCallForwardingSelection = false
    @State private var selectedForwardingNumber: String

    init(phoneNumber: PhoneNumber) {
        self.phoneNumber = phoneNumber
        self._selectedForwardingNumber = State(initialValue: phoneNumber.forwardingNumber ?? PhoneNumber.verifiedPersonalNumber?.fullNumber ?? "")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: phoneNumber.category == .personal ? "Personal Number" : "Sonetel Number") {
                dismiss()
            }

            // Content
            ScrollView {
                VStack(spacing: 28) {
                    // Phone number card
                    phoneNumberCardView

                    // Settings menu - only for Sonetel numbers
                    if phoneNumber.category == .sonetel {
                        settingsMenuView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 64)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCallForwardingSelection) {
            CallForwardingSelectionView(
                selectedNumber: $selectedForwardingNumber,
                availableNumbers: PhoneNumber.personalNumbers
            )
        }
    }



    private var phoneNumberCardView: some View {
        VStack(spacing: 20) {
            // Flag - emoji fills the circle completely
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 64, height: 64)

                Text(phoneNumber.flagEmoji)
                    .font(.system(size: 80))
                    .scaleEffect(2.0)
                    .clipped()
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())

            VStack(spacing: 4) {
                // Phone number
                Text(phoneNumber.fullNumber)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    .tracking(-0.68)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // Location
                Text(phoneNumber.location)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 48)
        .padding(.bottom, 20)
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }

    private var settingsMenuView: some View {
        VStack(spacing: 0) {
            MenuItemView(
                title: "Forward calls to",
                value: formatPhoneNumber(selectedForwardingNumber),
                type: .navigation,
                hasDivider: false
            ) {
                showingCallForwardingSelection = true
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func formatPhoneNumber(_ number: String) -> String {
        // Simple formatting for display
        if number.starts(with: "+46") {
            return number
        } else if number.starts(with: "+1") {
            return number
        }
        return number
    }
}

// MARK: - Call Forwarding Selection View

struct CallForwardingSelectionView: View {
    @Binding var selectedNumber: String
    let availableNumbers: [PhoneNumber]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            VStack(spacing: 0) {
                menuView
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .frame(maxHeight: .infinity)
        }
        .background(FigmaColorTokens.surfacePrimary)
        .ignoresSafeArea(.all, edges: .top)
    }

    private var headerView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(FigmaColorTokens.surfacePrimary)
                .frame(height: 50)

            // Header content
            HStack {
                Spacer()

                Text("Forward calls to")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .tracking(-0.36)

                Spacer()

                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                            .frame(width: 32, height: 32)

                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 75)
            .background(FigmaColorTokens.surfacePrimary)
            .overlay(
                Rectangle()
                    .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(availableNumbers.indices, id: \.self) { index in
                let number = availableNumbers[index]

                Button(action: {
                    selectedNumber = number.fullNumber
                    dismiss()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(number.fullNumber)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                                .tracking(-0.36)

                            Text(number.label)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                .tracking(-0.32)
                        }

                        Spacer()

                        if selectedNumber == number.fullNumber {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(minHeight: 72)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                if index < availableNumbers.count - 1 {
                    Rectangle()
                        .fill(FigmaColorTokens.adaptiveT1)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }
}



#Preview {
    PhoneNumberDetailView(phoneNumber: PhoneNumber.sampleData[1])
}
