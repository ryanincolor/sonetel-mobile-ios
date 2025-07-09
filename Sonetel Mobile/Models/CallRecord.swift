//
//  CallRecord.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import Foundation

struct CallRecord: Identifiable {
    let id = UUID()
    let contactName: String
    let phoneNumber: String?
    let timestamp: String
    let avatarImageURL: String?
    let isMissed: Bool
    let email: String?
    let callDate: String?
    let callTime: String?
    let callDuration: String?
    let callType: CallType

    var displayName: String {
        // If contact name looks like a generic description (contains "number"), use phone number instead
        if contactName.lowercased().contains("number") ||
           contactName.hasPrefix("+") ||
           (contactName.allSatisfy { $0.isNumber || $0 == " " || $0 == "(" || $0 == ")" || $0 == "-" || $0 == "+" }) {
            return phoneNumber ?? contactName
        }
        return contactName
    }

    var contactInitial: String {
        return String(displayName.prefix(1)).uppercased()
    }

    var countryCode: String? {
        guard let phoneNumber = phoneNumber else { return nil }

        // Extract country code from phone number
        if phoneNumber.hasPrefix("+46") { return "SE" }
        if phoneNumber.hasPrefix("+1") { return "US" }
        if phoneNumber.hasPrefix("+44") { return "GB" }
        if phoneNumber.hasPrefix("+49") { return "DE" }
        if phoneNumber.hasPrefix("+33") { return "FR" }
        if phoneNumber.hasPrefix("+47") { return "NO" }
        if phoneNumber.hasPrefix("+45") { return "DK" }
        if phoneNumber.hasPrefix("+358") { return "FI" }
        if phoneNumber.hasPrefix("+31") { return "NL" }
        if phoneNumber.hasPrefix("+41") { return "CH" }
        if phoneNumber.hasPrefix("+43") { return "AT" }
        if phoneNumber.hasPrefix("+32") { return "BE" }
        if phoneNumber.hasPrefix("+39") { return "IT" }
        if phoneNumber.hasPrefix("+34") { return "ES" }

        return nil
    }

    var flagEmoji: String? {
        guard let country = countryCode else { return nil }

        switch country.uppercased() {
        case "SE": return "🇸🇪"
        case "US": return "🇺🇸"
        case "GB": return "🇬🇧"
        case "DE": return "🇩🇪"
        case "FR": return "🇫🇷"
        case "NO": return "🇳🇴"
        case "DK": return "🇩🇰"
        case "FI": return "🇫🇮"
        case "NL": return "🇳🇱"
        case "CH": return "🇨🇭"
        case "AT": return "🇦🇹"
        case "BE": return "🇧🇪"
        case "IT": return "🇮🇹"
        case "ES": return "🇪🇸"
        default: return nil
        }
    }

    enum CallType {
        case incoming
        case outgoing
        case missed

        var displayText: String {
            switch self {
            case .incoming: return "Incoming call"
            case .outgoing: return "Outgoing call"
            case .missed: return "Missed call"
            }
        }
    }

    init(contactName: String, phoneNumber: String? = nil, timestamp: String, avatarImageURL: String? = nil, isMissed: Bool = false, email: String? = nil, callDate: String? = nil, callTime: String? = nil, callDuration: String? = nil, callType: CallType? = nil) {
        self.contactName = contactName
        self.phoneNumber = phoneNumber
        self.timestamp = timestamp
        self.avatarImageURL = avatarImageURL
        self.isMissed = isMissed

        self.email = email
        self.callDate = callDate
        self.callTime = callTime
        self.callDuration = callDuration

        if let callType = callType {
            self.callType = callType
        } else if isMissed {
            self.callType = .missed
        } else {
            self.callType = .incoming
        }
    }
}

// Sample data for the call log
extension CallRecord {
    static let sampleData: [CallRecord] = [
        CallRecord(
            contactName: "James",
            phoneNumber: "+46738123456",
            timestamp: "08:15",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/f12f892890cded8790fa9cf224ec8d1f459bb501&format=webp"
        ),
        CallRecord(
            contactName: "Emma Carter",
            phoneNumber: "+46724489239",
            timestamp: "Fri",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/58be4eb2f720af60234e7469c5712b94aafb1f60",
            email: "emma@tailored.com",
            callDate: "1 October 2025",
            callTime: "11:09",
            callDuration: "2min 59s",
            callType: .incoming
        ),
        CallRecord(
            contactName: "Emma Carter",
            phoneNumber: "+46724489239",
            timestamp: "3 May",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/58be4eb2f720af60234e7469c5712b94aafb1f60",
            isMissed: true,
            email: "emma@tailored.com",
            callDate: "1 October 2025",
            callTime: "11:09",
            callDuration: "2min 59s",
            callType: .missed
        ),
        CallRecord(
            contactName: "Benjamin",
            timestamp: "2 May",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/c4d34a51b075b81bb345a67bc3d6da3e65a94aa7&format=webp"
        ),
        CallRecord(
            contactName: "Shopify Support",
            timestamp: "30 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Isabella",
            timestamp: "27 Apr",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/aba045e43971ad03ee78a09f27d18a5b607d13cb&format=webp"
        ),
        CallRecord(
            contactName: "Emma Carter",
            timestamp: "28 Apr",
            avatarImageURL: "https://cdn.builder.io/api/v1/image/assets/80d2fd810faf4fca8f7a3507a4aa66a7/58be4eb2f720af60234e7469c5712b94aafb1f60&format=webp"
        ),
        CallRecord(
            contactName: "Joshua Mathers",
            timestamp: "28 Apr",
            avatarImageURL: nil,
            isMissed: true
        ),
        CallRecord(
            contactName: "Sarah Wilson",
            timestamp: "26 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Michael Brown",
            timestamp: "25 Apr",
            avatarImageURL: nil,
            isMissed: true
        ),
        CallRecord(
            contactName: "Lisa Johnson",
            timestamp: "24 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "David Miller",
            timestamp: "23 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Jennifer Davis",
            timestamp: "22 Apr",
            avatarImageURL: nil,
            isMissed: true
        ),
        CallRecord(
            contactName: "Robert Garcia",
            timestamp: "21 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Amanda Martinez",
            timestamp: "20 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Christopher Lee",
            timestamp: "19 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Michelle White",
            timestamp: "18 Apr",
            avatarImageURL: nil,
            isMissed: true
        ),
        CallRecord(
            contactName: "Daniel Thompson",
            timestamp: "17 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Ashley Anderson",
            timestamp: "16 Apr",
            avatarImageURL: nil
        ),
        CallRecord(
            contactName: "Kevin Taylor",
            timestamp: "15 Apr",
            avatarImageURL: nil
        )
    ]
}
