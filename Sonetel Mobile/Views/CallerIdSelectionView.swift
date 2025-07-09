//
//  CallerIdSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdOption: Identifiable {
    let id = UUID()
    let value: String
    let displayName: String
    let description: String?
    let phoneNumber: String?
    let category: Category

    enum Category {
        case system
        case phoneNumber
    }
}

enum CallerIdSelectionType {
    case outgoing
    case incoming

    var headerTitle: String {
        switch self {
        case .outgoing: return "Outgoing calls"
        case .incoming: return "Incoming calls"
        }
    }

    var description: String {
        switch self {
        case .outgoing: return "Choose what number to show the person you are calling."
        case .incoming: return "Choose how to display incoming caller information."
        }
    }
}

struct CallerIdSelectionView: View {
    @Binding var selectedCallerId: String
    let selectionType: CallerIdSelectionType
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = SonetelAPIService.shared

    @State private var availableNumbers: [PhoneNumber] = []
    @State private var callerIdOptions: [CallerIdOption] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: selectionType.headerTitle) {
                dismiss()
            }

            // Content
            if isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        contentView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadCallerIdOptions()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // Menu
            menuView

            // Descriptive text
            Text(selectionType.description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(FigmaColorTokens.textSecondary)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(callerIdOptions.indices, id: \.self) { index in
                let option = callerIdOptions[index]

                CallerIdOptionRowView(
                    option: option,
                    isSelected: selectedCallerId == option.value
                ) {
                    selectedCallerId = option.value
                    dismiss()
                }

                if index < callerIdOptions.count - 1 {
                    Rectangle()
                        .fill(FigmaColorTokens.adaptiveT1)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading options...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FigmaColorTokens.textSecondary)
                .padding(.top, 16)
            Spacer()
        }
    }

    // MARK: - API Methods

    private func loadCallerIdOptions() async {
        isLoading = true

        do {
            // Load phone numbers from API
            let personalNumbers = try await apiService.getPersonalPhoneNumbers()
            let sonetelNumbers = try await apiService.getSonetelPhoneNumbers()

            await MainActor.run {
                // Convert to PhoneNumber format
                self.availableNumbers = convertToPhoneNumbers(personalNumbers: personalNumbers, sonetelNumbers: sonetelNumbers)

                // Create caller ID options
                self.callerIdOptions = createCallerIdOptions()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load phone numbers: \(error.localizedDescription)"
                self.showError = true
                self.isLoading = false

                // Fallback to basic options
                self.callerIdOptions = createBasicCallerIdOptions()
            }
        }
    }

    private func convertToPhoneNumbers(personalNumbers: [SonetelPhoneNumber], sonetelNumbers: [SonetelPhoneNumber]) -> [PhoneNumber] {
        var phoneNumbers: [PhoneNumber] = []

        // Add personal numbers
        for number in personalNumbers {
            let phoneNumber = PhoneNumber(
                label: number.label ?? "Personal",
                number: number.number,
                fullNumber: number.number,
                countryCode: extractCountryCode(from: number.number),
                flagEmoji: getFlagEmoji(for: number.country ?? ""),
                category: .personal,
                location: number.location ?? "Personal Number",
                isVerified: true
            )
            phoneNumbers.append(phoneNumber)
        }

        // Add Sonetel numbers
        for number in sonetelNumbers {
            let phoneNumber = PhoneNumber(
                label: number.label ?? "Sonetel",
                number: number.number,
                fullNumber: number.number,
                countryCode: extractCountryCode(from: number.number),
                flagEmoji: getFlagEmoji(for: number.country ?? ""),
                category: .sonetel,
                location: number.location ?? "Sonetel Number"
            )
            phoneNumbers.append(phoneNumber)
        }

        return phoneNumbers
    }

    private func createCallerIdOptions() -> [CallerIdOption] {
        var options: [CallerIdOption] = []

        // Add system options
        options.append(CallerIdOption(
            value: "automatic",
            displayName: "Automatic",
            description: "Best number selected automatically",
            phoneNumber: nil,
            category: .system
        ))

        options.append(CallerIdOption(
            value: "hidden",
            displayName: "Hidden",
            description: "Hide caller ID",
            phoneNumber: nil,
            category: .system
        ))

        // Add phone number options
        for phoneNumber in availableNumbers {
            options.append(CallerIdOption(
                value: phoneNumber.fullNumber,
                displayName: phoneNumber.fullNumber,
                description: phoneNumber.label,
                phoneNumber: phoneNumber.fullNumber,
                category: .phoneNumber
            ))
        }

        return options
    }

    private func createBasicCallerIdOptions() -> [CallerIdOption] {
        return [
            CallerIdOption(
                value: "automatic",
                displayName: "Automatic",
                description: "Best number selected automatically",
                phoneNumber: nil,
                category: .system
            ),
            CallerIdOption(
                value: "hidden",
                displayName: "Hidden",
                description: "Hide caller ID",
                phoneNumber: nil,
                category: .system
            )
        ]
    }

    private func extractCountryCode(from number: String) -> String {
        // Simple extraction - take first 1-3 digits after +
        let cleanNumber = number.replacingOccurrences(of: "+", with: "")
        if cleanNumber.count >= 2 {
            return String(cleanNumber.prefix(2))
        }
        return "1"
    }

    private func getFlagEmoji(for country: String) -> String {
        switch country.uppercased() {
        case "SE", "SWE": return "🇸🇪"
        case "US", "USA": return "🇺🇸"
        case "GB", "UK": return "🇬🇧"
        case "DE", "DEU": return "🇩🇪"
        case "FR", "FRA": return "🇫🇷"
        case "NO", "NOR": return "🇳🇴"
        case "DK", "DNK": return "🇩🇰"
        case "FI", "FIN": return "🇫🇮"
        case "NL", "NET": return "🇳🇱"
        default: return "🌍"
        }
    }
}

struct CallerIdOptionRowView: View {
    let option: CallerIdOption
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                if option.category == .system {
                    Image(systemName: option.value == "automatic" ? "gear" : "eye.slash")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .frame(width: 24, height: 24)
                } else {
                    // Flag for phone numbers
                    Text("📞")
                        .font(.system(size: 20))
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .tracking(-0.36)

                    if let description = option.description {
                        Text(description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(FigmaColorTokens.textSecondary)
                    }
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 72)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
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

struct CallerIdRowView: View {
    let phoneNumber: PhoneNumber
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Flag or icon
                if phoneNumber.category == .personal {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                        .frame(width: 20, height: 20)
                } else {
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
                }

                // Phone number only
                Text(phoneNumber.fullNumber)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.36)

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(minHeight: 72)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
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
    CallerIdSelectionView(selectedCallerId: .constant("Personal"), selectionType: .outgoing)
}
