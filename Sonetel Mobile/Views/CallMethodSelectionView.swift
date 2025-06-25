//
//  CallMethodSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallMethodSelectionView: View {
    @Binding var selectedMethod: CallMethod
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ModalHeaderView(title: "Call mode", hasBackButton: true, useSettingsStyle: true) {
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
        .navigationBarHidden(true)
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            // Menu
            menuView

            // Descriptive text
            Text("Make calls over the internet or through your mobile service provider.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            // Internet option
            CallMethodRowView(
                method: .internet,
                isSelected: selectedMethod == .internet
            ) {
                selectedMethod = .internet
                dismiss()
            }

            Rectangle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                .frame(height: 1)
                .padding(.horizontal, 16)

            // Mobile option
            CallMethodRowView(
                method: .mobile,
                isSelected: selectedMethod == .mobile
            ) {
                selectedMethod = .mobile
                dismiss()
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
    }
}

struct CallMethodRowView: View {
    let method: CallMethod
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Icon
                Image(systemName: method.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)

                // Label
                Text(method.displayName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .tracking(-0.36)

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
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

enum CallMethod: String, CaseIterable {
    case internet = "internet"
    case mobile = "mobile"

    var displayName: String {
        switch self {
        case .internet:
            return "Internet"
        case .mobile:
            return "Mobile"
        }
    }

    var iconName: String {
        switch self {
        case .internet:
            return "globe"
        case .mobile:
            return "cellularbars"
        }
    }
}



#Preview {
    CallMethodSelectionView(selectedMethod: .constant(.internet))
}
