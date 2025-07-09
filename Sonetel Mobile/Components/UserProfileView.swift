//
//  UserProfileView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct UserProfileView: View {
    let userProfile: UserProfile

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(figmaHex: userProfile.backgroundColor))
                    .frame(width: 48, height: 48)

                Text(userProfile.initial)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)
            }

            // User info
            VStack(alignment: .leading, spacing: 2) {
                Text(userProfile.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.textPrimary)

                Text(userProfile.email)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textSecondary)
            }

            Spacer()
        }
        .padding(20)
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }
}



#Preview {
    UserProfileView(userProfile: UserProfile.current)
        .padding()
}
