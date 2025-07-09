//
//  CallerIdSettingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdSettingsView: View {
    @Binding var callSettings: CallSettings
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiService = SonetelAPIService.shared

    @State private var showOutgoingSelection = false
    @State private var showIncomingSelection = false
    @State private var showError = false
    @State private var errorMessage = ""

    init(callSettings: Binding<CallSettings>) {
        self._callSettings = callSettings
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Caller ID") {
                dismiss()
            }

            // Content
            VStack(spacing: 0) {
                contentView
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .frame(maxHeight: .infinity)
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showOutgoingSelection) {
            CallerIdSelectionView(
                selectedCallerId: Binding(
                    get: { callSettings.callerIdSettings.outgoing },
                    set: { newValue in
                        Task {
                            await updateCallerIdSetting(type: .outgoing, value: newValue)
                        }
                    }
                ),
                selectionType: .outgoing
            )
        }
        .navigationDestination(isPresented: $showIncomingSelection) {
            CallerIdSelectionView(
                selectedCallerId: Binding(
                    get: { callSettings.callerIdSettings.incoming },
                    set: { newValue in
                        Task {
                            await updateCallerIdSetting(type: .incoming, value: newValue)
                        }
                    }
                ),
                selectionType: .incoming
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    private var contentView: some View {
        VStack(spacing: 24) {
            // Settings section
            settingsSection
        }
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            // Outgoing calls
            CallerIdSettingRowView(
                title: "Outgoing calls",
                value: displayValueForCallerIdType(callSettings.callerIdSettings.outgoing)
            ) {
                showOutgoingSelection = true
            }

            Rectangle()
                .fill(FigmaColorTokens.adaptiveT1)
                .frame(height: 1)
                .padding(.horizontal, 16)

            // Incoming calls
            CallerIdSettingRowView(
                title: "Incoming calls",
                value: displayValueForCallerIdType(callSettings.callerIdSettings.incoming)
            ) {
                showIncomingSelection = true
            }
        }
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }

    // MARK: - Helper Methods

    private func displayValueForCallerIdType(_ type: String) -> String {
        if let callerIdType = CallerIdType(rawValue: type) {
            return callerIdType.displayName
        }
        // If it's a specific phone number or unknown type
        return type.capitalized
    }

    private func updateCallerIdSetting(type: CallerIdSelectionType, value: String) async {
        print("🔧 CallerIdSettings: Updating \(type) caller ID to: \(value)")

        do {
            let updatedSettings: CallSettings

            switch type {
            case .outgoing:
                print("🔧 CallerIdSettings: Updating outgoing caller ID to: \(value)")
                updatedSettings = try await apiService.updateOutgoingCallerIdOnly(show: value)
            case .incoming:
                print("🔧 CallerIdSettings: Updating incoming caller ID to: \(value)")
                updatedSettings = try await apiService.updateIncomingCallerIdOnly(show: value)
            }

            await MainActor.run {
                self.callSettings = updatedSettings
                print("✅ CallerIdSettings: Successfully updated \(type) to \(value)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update caller ID settings: \(error.localizedDescription)"
                self.showError = true
                print("❌ CallerIdSettings: Update failed: \(error)")
            }
        }
    }
}

struct CallerIdSettingRowView: View {
    let title: String
    let value: String
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .tracking(-0.36)

                Spacer()

                HStack(spacing: 12) {
                    Text(value)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                        .tracking(-0.36)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(minHeight: 56)
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
    NavigationStack {
        CallerIdSettingsView(callSettings: .constant(CallSettings.defaultSettings))
    }
}
