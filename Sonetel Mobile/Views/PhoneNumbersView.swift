//
//  PhoneNumbersView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct PhoneNumbersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var personalNumbers = PhoneNumber.sampleData.filter { $0.category == .personal }
    @State private var sonetelNumbers = PhoneNumber.sampleData.filter { $0.category == .sonetel }
    @State private var selectedPhoneNumber: PhoneNumber?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            ScrollView {
                VStack(spacing: 40) {
                    // Personal section
                    personalSection

                    // Sonetel section
                    sonetelSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(item: $selectedPhoneNumber) { phoneNumber in
            PhoneNumberDetailView(phoneNumber: phoneNumber)
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
            }

            Spacer()

            Text("Phone numbers")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                .tracking(-0.4)

            Spacer()

            // Invisible spacer for balance
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var personalSection: some View {
        VStack(spacing: 12) {
            // Section header
            HStack {
                Text("Personal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }

            // Personal numbers
            VStack(spacing: 0) {
                ForEach(personalNumbers) { phoneNumber in
                    PhoneNumberRowView(
                        phoneNumber: phoneNumber,
                        showFlag: false
                    ) {
                        selectedPhoneNumber = phoneNumber
                    }

                    if phoneNumber.id != personalNumbers.last?.id {
                        Rectangle()
                            .fill(Color(red: 0.878, green: 0.878, blue: 0.878))
                            .frame(height: 1)
                    }
                }
            }
            .background(Color(red: 0.953, green: 0.953, blue: 0.953))
            .cornerRadius(20)
        }
    }

    private var sonetelSection: some View {
        VStack(spacing: 12) {
            // Section header
            HStack {
                Text("Sonetel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }

            // Sonetel numbers
            VStack(spacing: 0) {
                ForEach(sonetelNumbers) { phoneNumber in
                    PhoneNumberRowView(
                        phoneNumber: phoneNumber,
                        showFlag: true
                    ) {
                        selectedPhoneNumber = phoneNumber
                    }

                    if phoneNumber.id != sonetelNumbers.last?.id {
                        Rectangle()
                            .fill(Color(red: 0.878, green: 0.878, blue: 0.878))
                            .frame(height: 1)
                    }
                }
            }
            .background(Color(red: 0.953, green: 0.953, blue: 0.953))
            .cornerRadius(20)
        }
    }
}

struct PhoneNumberRowView: View {
    let phoneNumber: PhoneNumber
    let showFlag: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Flag (if applicable)
                if showFlag {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)

                        Text(phoneNumber.flagEmoji)
                            .font(.system(size: 14))
                    }
                }

                // Label
                Text(phoneNumber.label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                Spacer()

                // Phone number
                Text(phoneNumber.number)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 56)
            .frame(maxWidth: .infinity) // Fill width
            .contentShape(Rectangle()) // Make entire area tappable
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    NavigationStack {
        PhoneNumbersView()
    }
}
