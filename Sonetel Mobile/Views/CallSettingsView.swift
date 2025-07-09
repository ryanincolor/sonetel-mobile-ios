//
//  CallSettingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = SonetelAPIService.shared

    @State private var callSettings: CallSettings = CallSettings.defaultSettings
    @State private var isLoading = true
    @State private var showCallMethodSelection = false
    @State private var showError = false
    @State private var errorMessage = ""

    var selectedCallMethod: CallMethodType {
        // For now, default to internet since we don't have call method in the new API
        .internet
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Call settings") {
                dismiss()
            }

            // Content
            if isLoading {
                loadingView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Settings menu
                        settingsMenu
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCallMethodSelection) {
            CallMethodSelectionView(
                selectedMethod: Binding(
                    get: { selectedCallMethod },
                    set: { newMethod in
                        Task {
                            await updateCallMethod(newMethod)
                        }
                    }
                )
            )
        }
        .onAppear {
            Task {
                await loadCallSettings()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }



    private var settingsMenu: some View {
        VStack(spacing: 0) {
            MenuItemView(
                title: "Call method",
                value: selectedCallMethod.displayName,
                type: .navigation
            ) {
                showCallMethodSelection = true
            }

            NavigationLink(destination: CallerIdSettingsView(callSettings: $callSettings)) {
                MenuItemView(
                    title: "Caller ID",
                    type: .navigation,
                    hasDivider: false
                )
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .clipShape(RoundedRectangle(cornerRadius: FigmaBorderRadiusTokens.large))
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading settings...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(FigmaColorTokens.textSecondary)
                .padding(.top, 16)
            Spacer()
        }
    }

    // MARK: - API Methods

    private func loadCallSettings() async {
        isLoading = true

        do {
            let settings = try await apiService.getCallSettings()
            await MainActor.run {
                self.callSettings = settings
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load call settings: \(error.localizedDescription)"
                self.showError = true
                self.isLoading = false
            }
        }
    }

    private func updateCallMethod(_ method: CallMethodType) async {
        // For now, we'll just show a message since call method isn't part of the call settings API
        await MainActor.run {
            self.errorMessage = "Call method setting will be available in a future update"
            self.showError = true
        }
    }
}

#Preview {
    NavigationStack {
        CallSettingsView()
    }
}
