//
//  UserProfile.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation

struct UserProfile: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let initial: String
    let avatarImageURL: String?
    let backgroundColor: String
    
    init(name: String, email: String, avatarImageURL: String? = nil, backgroundColor: String = "#FFEF62") {
        self.name = name
        self.email = email
        // Use first letter of name if available, otherwise first letter of email
        if !name.isEmpty {
            self.initial = String(name.prefix(1)).uppercased()
        } else {
            self.initial = String(email.prefix(1)).uppercased()
        }
        self.avatarImageURL = avatarImageURL
        self.backgroundColor = backgroundColor
    }
}

extension UserProfile {
    static let current = UserProfile(
        name: "Jessica Flores",
        email: "jflores@fabricsco.com",
        backgroundColor: "#FFEF62"
    )
}
