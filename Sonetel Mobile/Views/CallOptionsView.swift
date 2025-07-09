//
//  CallOptionsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallOptionsView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCallerId = "Personal"
    @State private var selectedCallMethod: CallMethodType = .internet
    @State private var showCallerIdSelection = false
    @State private var showCallMethodSelection = false
    @State private var showActiveCall = false
    @State private var isCallerIdPressed = false
    @State private var isCallMethodPressed = false

    private var selectedPhoneNumber: PhoneNumber? {
        PhoneNumber.sampleData.first { $0.label == selectedCallerId }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            VStack(spacing: 0) {
                contentView
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .navigationDestination(isPresented: $showCallerIdSelection) {
            CallerIdSelectionView(selectedCallerId: $selectedCallerId, selectionType: .outgoing)
        }
        .navigationDestination(isPresented: $showCallMethodSelection) {
            CallMethodSelectionView(selectedMethod: $selectedCallMethod)
        }
        .navigationDestination(isPresented: $showActiveCall) {
            ActiveCallView(phoneNumber: contact.phoneNumber ?? "")
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()

            Text("Call options")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)
                .tracking(-0.4)

            Spacer()

            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 32, height: 32)

                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(FigmaColorTokens.surfacePrimary)
    }

    private var contentView: some View {
        VStack(spacing: 20) {
            // Options menu
            optionsMenuView

            // Call button
            callButtonView

            // Pricing info
            Text("$0.01 per minute")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FigmaColorTokens.textSecondary)
                .tracking(-0.32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 40)
    }

    private var optionsMenuView: some View {
        VStack(spacing: 0) {
            // Show caller ID option
            Button(action: {
                showCallerIdSelection = true
            }) {
                HStack {
                    Text("Show")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .tracking(-0.36)

                    Spacer()

                    HStack(spacing: 8) {
                        // Flag
                        if let phoneNumber = selectedPhoneNumber {
                            AsyncImage(url: URL(string: phoneNumber.flagImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))

                                    Text(phoneNumber.flagEmoji)
                                        .font(.system(size: 12))
                                }
                            }
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                        } else {
                            // Fallback flag
                            Circle()
                                .fill(Color.blue)
                                .overlay(
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.yellow)
                                            .frame(width: 4, height: 20)
                                        Rectangle()
                                            .fill(Color.yellow)
                                            .frame(width: 20, height: 4)
                                    }
                                )
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        }

                        Text(selectedPhoneNumber?.fullNumber ?? selectedCallerId)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                            .tracking(-0.36)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .frame(height: 56)
                .frame(maxWidth: .infinity) // Fill width
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                Rectangle()
                    .fill(isCallerIdPressed ? Color.black.opacity(0.05) : Color.clear)
            )
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isCallerIdPressed = pressing
            }, perform: {})
            .background(FigmaColorTokens.adaptiveT1)
            .overlay(
                Rectangle()
                    .fill(FigmaColorTokens.adaptiveT1)
                    .frame(height: 1),
                alignment: .bottom
            )

            // Call method option
            Button(action: {
                showCallMethodSelection = true
            }) {
                HStack {
                    Text("Call method")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .tracking(-0.36)

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: selectedCallMethod.iconName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)

                        Text(selectedCallMethod.displayName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                            .tracking(-0.36)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .frame(height: 56)
                .frame(maxWidth: .infinity) // Fill width
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                Rectangle()
                    .fill(isCallMethodPressed ? Color.black.opacity(0.05) : Color.clear)
            )
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isCallMethodPressed = pressing
            }, perform: {})
            .background(FigmaColorTokens.adaptiveT1)
        }
        .cornerRadius(20)
    }

    private var callButtonView: some View {
        Button(action: {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showActiveCall = true
            }
        }) {
            Text("Call")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .tracking(-0.36)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(FigmaColorTokens.textPrimary)
                .cornerRadius(36)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CallOptionsView(contact: Contact(
        name: "Emma Carter",
        phoneNumber: "+46724489239",
        email: "emma@tailored.com"
    ))
}
