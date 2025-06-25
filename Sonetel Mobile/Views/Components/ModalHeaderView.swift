//
//  ModalHeaderView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct ModalHeaderView: View {
    let title: String
    let hasBackButton: Bool
    let useSettingsStyle: Bool
    let onDismiss: () -> Void

    init(title: String, hasBackButton: Bool = false, useSettingsStyle: Bool = false, onDismiss: @escaping () -> Void) {
        self.title = title
        self.hasBackButton = hasBackButton
        self.useSettingsStyle = useSettingsStyle
        self.onDismiss = onDismiss
    }

    var body: some View {
        if useSettingsStyle {
            // Settings style header without status bar spacer
            HStack {
                if hasBackButton {
                    Button(action: onDismiss) {
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
                } else {
                    Spacer()
                }

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .tracking(-0.4)

                Spacer()

                if !hasBackButton {
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                .frame(width: 32, height: 32)

                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                } else {
                    // Invisible spacer for balance
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
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
        } else {
            // Modal style header with status bar spacer
            VStack(spacing: 0) {
                // Status bar spacer
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 50)

                // Header content
                HStack {
                    if hasBackButton {
                        Button(action: onDismiss) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.953, green: 0.953, blue: 0.953))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }

                        Spacer()
                    } else {
                        Spacer()
                    }

                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .tracking(-0.4)

                    Spacer()

                    if !hasBackButton {
                        Button(action: onDismiss) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                    .frame(width: 32, height: 32)

                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }
                    } else {
                        // Invisible spacer for balance
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 75)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(height: 1),
                    alignment: .bottom
                )
            }
        }
    }
}

#Preview {
    VStack {
        ModalHeaderView(title: "Call mode", hasBackButton: false) {
            print("Close tapped")
        }

        Spacer()

        ModalHeaderView(title: "Caller ID", hasBackButton: true) {
            print("Back tapped")
        }

        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}
