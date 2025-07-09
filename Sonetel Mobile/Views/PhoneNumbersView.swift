//
//  PhoneNumbersView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct PhoneNumbersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var dataManager = DataManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Phone numbers", showBackButton: true) {
                dismiss()
            }

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
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .task {
            await dataManager.loadPhoneNumbersIfEmpty()
        }
        .refreshable {
            await dataManager.refreshPhoneNumbers()
        }
    }

    private var personalSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text("Personal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                Spacer()
            }
            .padding(.bottom, 8)

            // Content based on state
            if shouldShowLoading {
                loadingView
            } else if shouldShowError {
                errorView
            } else {
                personalNumbersList
            }
        }
    }

    private var sonetelSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text("Sonetel")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                Spacer()
            }
            .padding(.bottom, 8)

            // Content - show cached data instantly
            VStack(spacing: 0) {
                ForEach(Array(dataManager.sonetelPhoneNumbers.enumerated()), id: \.offset) { index, phoneNumber in
                    NavigationLink(destination: SonetelPhoneNumberDetailView(phoneNumber: phoneNumber)) {
                        MenuItemView(
                            title: phoneNumber.cleanDisplayLabel,
                            value: phoneNumber.number,
                            type: .navigation,
                            isSelected: false,
                            hasDivider: index < dataManager.sonetelPhoneNumbers.count - 1,
                            leftIcon: AnyView(
                                ZStack {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 24, height: 24)

                                    Text(phoneNumber.flagEmoji)
                                        .font(.system(size: 28))
                                        .scaleEffect(1.8)
                                        .clipped()
                                }
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                            ),
                            action: nil
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(FigmaColorTokens.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - State Computed Properties

    private var shouldShowLoading: Bool {
        dataManager.isLoadingPhoneNumbers && dataManager.personalPhoneNumbers.isEmpty
    }

    private var shouldShowError: Bool {
        dataManager.phoneNumbersError != nil && dataManager.personalPhoneNumbers.isEmpty
    }

    private var personalNumbersList: some View {
        VStack(spacing: 0) {
            ForEach(dataManager.personalPhoneNumbers.indices, id: \.self) { index in
                PersonalNumberRowView(
                    phoneNumber: dataManager.personalPhoneNumbers[index],
                    hasDivider: index < dataManager.personalPhoneNumbers.count - 1
                )
            }
        }
        .background(FigmaColorTokens.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading phone numbers...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FigmaColorTokens.textSecondary)
        }
        .padding(.vertical, 20)
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundColor(.orange)

            Text("Failed to load phone numbers")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FigmaColorTokens.textPrimary)

            if let error = dataManager.phoneNumbersError {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(FigmaColorTokens.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button("Retry") {
                Task {
                    await dataManager.refreshPhoneNumbers()
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.blue)
        }
        .padding(.vertical, 20)
    }
}

struct PersonalNumberRowView: View {
    let phoneNumber: SonetelPhoneNumber
    let hasDivider: Bool

    var body: some View {
        NavigationLink(destination: PhoneNumberDetailView(phoneNumber: convertToPhoneNumber(phoneNumber))) {
            MenuItemView(
                title: phoneNumber.cleanDisplayLabel,
                value: phoneNumber.number,
                type: .navigation,
                isSelected: false,
                hasDivider: hasDivider,
                leftIcon: AnyView(
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 24, height: 24)

                        Text(phoneNumber.flagEmoji)
                            .font(.system(size: 28))
                            .scaleEffect(1.8)
                            .clipped()
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                ),
                action: nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func convertToPhoneNumber(_ sonetelNumber: SonetelPhoneNumber) -> PhoneNumber {
        return PhoneNumber(
            label: sonetelNumber.cleanDisplayLabel,
            number: sonetelNumber.number,
            fullNumber: sonetelNumber.number,
            countryCode: sonetelNumber.country ?? "SE",
            flagEmoji: sonetelNumber.flagEmoji,
            category: .personal,
            location: sonetelNumber.location ?? "",
            isVerified: true
        )
    }
}



#Preview {
    PhoneNumbersView()
        .environmentObject(AuthenticationManager())
}
