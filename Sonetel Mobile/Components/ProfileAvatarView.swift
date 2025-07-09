//
//  ProfileAvatarView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct ProfileAvatarView: View {
    let imageURL: String?
    let initial: String
    let size: CGFloat
    let backgroundColor: Color
    let flagEmoji: String?

    init(imageURL: String? = nil, initial: String, size: CGFloat = 44, backgroundColor: Color = FigmaColorTokens.adaptiveT1, flagEmoji: String? = nil) {
        self.imageURL = imageURL
        self.initial = initial
        self.size = size
        self.backgroundColor = backgroundColor
        self.flagEmoji = flagEmoji
    }

    var body: some View {
        Group {
            if let imageURL = imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL + "&format=webp")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var placeholderView: some View {
        ZStack {
            if let flagEmoji = flagEmoji, shouldShowFlag {
                // Show flag emoji similar to SonetelPhoneNumberDetailView
                Circle()
                    .fill(Color.clear)

                Text(flagEmoji)
                    .font(.system(size: size * 1.2))
                    .scaleEffect(1.8)
                    .clipped()
            } else {
                // Show initials
                backgroundColor
                Text(initial)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
    }

    private var shouldShowFlag: Bool {
        // Show flag if initial is "+" or looks like a phone number
        return initial == "+" || initial.allSatisfy { $0.isNumber || $0 == "+" }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileAvatarView(initial: "JP")
        ProfileAvatarView(initial: "AB", size: 60)
        ProfileAvatarView(initial: "CD", size: 80, backgroundColor: .blue.opacity(0.2))
    }
    .padding()
}
