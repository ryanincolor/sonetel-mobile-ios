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
                    .fill(Color(hex: userProfile.backgroundColor))
                    .frame(width: 48, height: 48)
                
                Text(userProfile.initial)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
            }
            
            // User info
            VStack(alignment: .leading, spacing: 2) {
                Text(userProfile.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                
                Text(userProfile.email)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    UserProfileView(userProfile: UserProfile.current)
        .padding()
}
