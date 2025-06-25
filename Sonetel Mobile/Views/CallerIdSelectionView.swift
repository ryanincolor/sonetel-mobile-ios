//
//  CallerIdSelectionView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdSelectionView: View {
    @Binding var selectedCallerId: String
    @Environment(\.dismiss) private var dismiss

    private let availableNumbers = PhoneNumber.sampleData

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ModalHeaderView(title: "Caller ID", hasBackButton: true, useSettingsStyle: true) {
                dismiss()
            }

            // Content
            VStack(spacing: 0) {
                contentView
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            // Menu
            menuView

            // Descriptive text
            Text("Choose what number to show the person you are calling.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .frame(maxHeight: .infinity)
    }

    private var menuView: some View {
        VStack(spacing: 0) {
            ForEach(availableNumbers.indices, id: \.self) { index in
                let number = availableNumbers[index]

                CallerIdRowView(
                    phoneNumber: number,
                    isSelected: selectedCallerId == number.label
                ) {
                    selectedCallerId = number.label
                    dismiss()
                }

                if index < availableNumbers.count - 1 {
                    Rectangle()
                        .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
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
                        .foregroundColor(.black)
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
    CallerIdSelectionView(selectedCallerId: .constant("Personal"))
}
