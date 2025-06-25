//
//  Contact.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String?
    let email: String?
    let avatarImageURL: String?
    let initial: String

    init(name: String, phoneNumber: String? = nil, email: String? = nil, avatarImageURL: String? = nil) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.avatarImageURL = avatarImageURL
        self.initial = String(name.prefix(1)).uppercased()
    }
}

extension Contact {
    static let sampleData: [Contact] = [
        Contact(name: "Aiden Archer", phoneNumber: "+46738123456", avatarImageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Ivy Irwin", phoneNumber: "+46738234567", avatarImageURL: "https://images.unsplash.com/photo-1494790108755-2616c96b9968?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Emma Carter", phoneNumber: "+46724489239", email: "emma@tailored.com", avatarImageURL: "https://images.unsplash.com/photo-1494790108755-2616c96b9968?w=128&h=128&fit=crop&crop=face"),
        Contact(name: "Evelyn Ellis", phoneNumber: "+46738345678", avatarImageURL: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Hugo Hayes", phoneNumber: "+46738456789", avatarImageURL: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Caleb Carter", phoneNumber: "+46738567890", avatarImageURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Felix Fox", phoneNumber: "+46738678901", avatarImageURL: "https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Giselle Grant", phoneNumber: "+46738789012", avatarImageURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Brianna Blake", phoneNumber: "+46738890123", avatarImageURL: "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=100&h=100&fit=crop&crop=face"),
        Contact(name: "Diana Drake", phoneNumber: "+46738901234", avatarImageURL: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&h=100&fit=crop&crop=face")
    ]

    static var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: sampleData.sorted { $0.name < $1.name }) { contact in
            String(contact.name.prefix(1).uppercased())
        }
    }
}
