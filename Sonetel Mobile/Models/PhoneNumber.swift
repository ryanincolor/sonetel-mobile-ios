//
//  PhoneNumber.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation

struct PhoneNumber: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let number: String
    let fullNumber: String // Complete number without truncation
    let countryCode: String
    let flagEmoji: String
    let category: Category
    let location: String // City, State/Province, Country
    let isVerified: Bool // For personal numbers
    var forwardingNumber: String? // Current call forwarding destination

    enum Category {
        case personal
        case sonetel
    }

    init(label: String, number: String, fullNumber: String? = nil, countryCode: String, flagEmoji: String, category: Category, location: String, isVerified: Bool = false, forwardingNumber: String? = nil) {
        self.label = label
        self.number = number
        self.fullNumber = fullNumber ?? number
        self.countryCode = countryCode
        self.flagEmoji = flagEmoji
        self.category = category
        self.location = location
        self.isVerified = isVerified
        self.forwardingNumber = forwardingNumber
    }

    // Helper computed properties
    var displayNumber: String {
        return category == .sonetel ? number : fullNumber
    }

    var flagImageURL: String {
        // Convert country code to flag image URL
        let baseURL = "https://flagcdn.com/w80/"
        return "\(baseURL)\(countryCode.lowercased()).png"
    }
}

extension PhoneNumber {
    static let sampleData: [PhoneNumber] = [
        PhoneNumber(
            label: "Mobile",
            number: "+46738243982",
            fullNumber: "+46738243982",
            countryCode: "SE",
            flagEmoji: "🇸🇪",
            category: .personal,
            location: "Sweden",
            isVerified: true
        ),
        PhoneNumber(
            label: "Los Angeles",
            number: "+1310321937..",
            fullNumber: "+13103219379",
            countryCode: "US",
            flagEmoji: "🇺🇸",
            category: .sonetel,
            location: "Los Angeles, CA USA",
            forwardingNumber: "+46738243982"
        ),
        PhoneNumber(
            label: "New York",
            number: "+1646384863..",
            fullNumber: "+16463848632",
            countryCode: "US",
            flagEmoji: "🇺🇸",
            category: .sonetel,
            location: "New York, NY USA",
            forwardingNumber: "+46738243982"
        ),
        PhoneNumber(
            label: "Stockholm",
            number: "+467233198..",
            fullNumber: "+46723319847",
            countryCode: "SE",
            flagEmoji: "🇸🇪",
            category: .sonetel,
            location: "Stockholm, Sweden",
            forwardingNumber: "+46738243982"
        ),
        PhoneNumber(
            label: "London",
            number: "+442074567..",
            fullNumber: "+442074567890",
            countryCode: "GB",
            flagEmoji: "🇬🇧",
            category: .sonetel,
            location: "London, UK",
            forwardingNumber: "+46738243982"
        )
    ]

    // Get personal numbers for call forwarding selection
    static var personalNumbers: [PhoneNumber] {
        return sampleData.filter { $0.category == .personal }
    }

    // Get verified personal number (default for forwarding)
    static var verifiedPersonalNumber: PhoneNumber? {
        return sampleData.first { $0.category == .personal && $0.isVerified }
    }
}
