//
//  CallSettingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCallMethod: CallMethod = .internet
    @State private var showCallMethodSelection = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
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
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showCallMethodSelection) {
            CallMethodSelectionView(selectedMethod: $selectedCallMethod)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
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

            Text("Call settings")
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

    private var settingsMenu: some View {
        VStack(spacing: 0) {
            SettingsMenuItemView(title: "Call method", value: selectedCallMethod.displayName) {
                showCallMethodSelection = true
            }

            Rectangle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                .frame(height: 1)

            NavigationLink(destination: CallerIdSettingsView()) {
                SettingsMenuItemView(title: "Caller ID") {}
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        CallSettingsView()
    }
}
