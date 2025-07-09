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
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }

                    Spacer()
                } else {
                    Spacer()
                }

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.4)

                Spacer()

                if !hasBackButton {
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .background(FigmaColorTokens.surfacePrimary)
        } else {
            // Regular modal header
            HStack {
                if hasBackButton {
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                .frame(width: 44, height: 44)

                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }

                    Spacer()
                } else {
                    Spacer()
                }

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.4)

                Spacer()

                if !hasBackButton {
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                                .frame(width: 44, height: 44)

                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            .background(FigmaColorTokens.surfacePrimary)
        }
    }
}

#Preview {
    ModalHeaderView(title: "Settings", onDismiss: {})
}

#Preview("With Back Button") {
    ModalHeaderView(title: "Language", hasBackButton: true, onDismiss: {})
}

#Preview("Settings Style") {
    ModalHeaderView(title: "Settings", useSettingsStyle: true, onDismiss: {})
}
