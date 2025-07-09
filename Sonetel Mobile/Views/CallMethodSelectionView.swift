//
//  CallMethodSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallMethodSelectionView: View {
    @Binding var selectedMethod: CallMethodType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Call mode") {
                dismiss()
            }

            // Content
            ScrollView {
                VStack(spacing: 24) {
                    contentView
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // Menu
            menuView

            // Descriptive text
            Text("Make calls over the internet or through your mobile service provider.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(FigmaColorTokens.textSecondary)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(CallMethodType.allCases, id: \.self) { method in
                CallMethodRowView(
                    method: method,
                    isSelected: selectedMethod == method
                ) {
                    selectedMethod = method
                    dismiss()
                }

                if method != CallMethodType.allCases.last {
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
}

struct CallMethodRowView: View {
    let method: CallMethodType
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Icon
                Image(systemName: method.iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .frame(width: 24, height: 24)

                // Label
                Text(method.displayName)
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
    CallMethodSelectionView(selectedMethod: .constant(.internet))
}
