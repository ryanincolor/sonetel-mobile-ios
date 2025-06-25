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
    
    init(imageURL: String? = nil, initial: String, size: CGFloat = 44, backgroundColor: Color = Color.black.opacity(0.04)) {
        self.imageURL = imageURL
        self.initial = initial
        self.size = size
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Group {
            if let imageURL = imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL + "&format=webp")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    initialsView
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var initialsView: some View {
        ZStack {
            backgroundColor
            Text(initial)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileAvatarView(initial: "J")
        ProfileAvatarView(initial: "E", size: 36)
        ProfileAvatarView(
            imageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/f12f892890cded8790fa9cf224ec8d1f459bb501",
            initial: "J"
        )
    }
    .padding()
}
