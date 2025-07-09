//
//  NavigationHeaderView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct NavigationHeaderView: View {
    let title: String
    let showBackButton: Bool
    let showCloseButton: Bool
    let onBackTap: (() -> Void)?

    init(title: String, showBackButton: Bool = true, showCloseButton: Bool = false, onBackTap: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.showCloseButton = showCloseButton
        self.onBackTap = onBackTap
    }

    var body: some View {
        HStack(spacing: 4) {
            // Left side - Back button or spacer
            if showBackButton {
                Button(action: { onBackTap?() }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 44, height: 44)
            } else {
                // Invisible spacer for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Centered title - using design system typography
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .lineLimit(1)
                .multilineTextAlignment(.center)

            Spacer()

            // Right side - Close button or spacer
            if showCloseButton {
                Button(action: { onBackTap?() }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 44, height: 44)
            } else {
                // Invisible spacer for balance
                Circle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 72)
        .background(FigmaColorTokens.surfacePrimary)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        NavigationHeaderView(title: "Phone numbers")

        NavigationHeaderView(title: "Settings", showBackButton: false, showCloseButton: true)

        Spacer()
    }
}
