//
//  SonetelPhoneNumberDetailView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct SonetelPhoneNumberDetailView: View {
    let phoneNumber: SonetelPhoneNumber
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Sonetel Number") {
                dismiss()
            }

            // Content
            ScrollView {
                VStack(spacing: 28) {
                    // Phone number card
                    phoneNumberCard

                    // Settings menu
                    settingsMenu
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 64)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
    }



    // MARK: - Phone Number Card
    private var phoneNumberCard: some View {
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

            VStack(spacing: 2) {
                // Phone number with formatting
                Text(formattedPhoneNumber)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                    .tracking(0.374)

                // Location
                Text(phoneNumber.location ?? "Location not available")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
            }
        }
        .padding(.vertical, 48)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }

    // MARK: - Settings Menu
    private var settingsMenu: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Forward calls to")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                Spacer()

                Text("+46723319393") // This would come from API data
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 56)
        }
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }

    // MARK: - Helper Properties
    private var formattedPhoneNumber: String {
        let number = phoneNumber.number

        // Format different number patterns
        if number.hasPrefix("+1") && number.count >= 12 {
            // US numbers: +1 310 321 9379
            let area = String(number.dropFirst(2).prefix(3))
            let exchange = String(number.dropFirst(5).prefix(3))
            let subscriber = String(number.dropFirst(8).prefix(4))
            return "+1 \(area) \(exchange) \(subscriber)"
        } else if number.hasPrefix("+46") && number.count >= 10 {
            // Swedish numbers: +46 70 123 4567
            let area = String(number.dropFirst(3).prefix(2))
            let part1 = String(number.dropFirst(5).prefix(3))
            let part2 = String(number.dropFirst(8))
            return "+46 \(area) \(part1) \(part2)"
        } else {
            // Default formatting: add spaces every 3-4 digits
            return number
        }
    }
}

#Preview {
    SonetelPhoneNumberDetailView(
        phoneNumber: SonetelPhoneNumber(
            number: "+13103219379",
            label: "Los Angeles",
            country: "US",
            location: "Los Angeles, CA USA",
            status: "active",
            type: "sonetel"
        )
    )
}
