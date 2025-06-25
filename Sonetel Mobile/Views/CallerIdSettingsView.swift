//
//  CallerIdSettingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showOutgoingSelection = false
    @State private var showIncomingSelection = false
    @State private var outgoingCallerId = "Automatic"
    @State private var incomingCallerId = "Caller's number"

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ModalHeaderView(title: "Caller ID", hasBackButton: true) {
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
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
        .navigationBarHidden(true)
        .sheet(isPresented: $showOutgoingSelection) {
            CallerIdSelectionView(selectedCallerId: $outgoingCallerId)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showIncomingSelection) {
            CallerIdSelectionView(selectedCallerId: $incomingCallerId)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
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
                value: outgoingCallerId
            ) {
                showOutgoingSelection = true
            }

            Rectangle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // Incoming calls
            CallerIdSettingRowView(
                title: "Incoming calls",
                value: incomingCallerId
            ) {
                showIncomingSelection = true
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
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
        CallerIdSettingsView()
    }
}
