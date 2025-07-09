//
//  CallSettings.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation

// MARK: - Call Settings Models

// MARK: - Real Sonetel API Models

struct SonetelCallSettingsResponse: Codable {
    let resource: String
    let status: String
    let response: SonetelCallSettingsData
}

struct SonetelCallSettingsData: Codable {
    let incoming: SonetelIncomingSettings
    let outgoing: SonetelOutgoingSettings
}

struct SonetelIncomingSettings: Codable {
    let firstAction: SonetelCallAction
    let secondAction: SonetelCallAction?
    let standardAction: SonetelCallAction?

    enum CodingKeys: String, CodingKey {
        case firstAction = "first_action"
        case secondAction = "second_action"
        case standardAction = "standard_action"
    }
}

struct SonetelOutgoingSettings: Codable {
    let show: String
    let callMethod: String
    let selectMethodPerCall: Bool

    enum CodingKeys: String, CodingKey {
        case show = "show"
        case callMethod = "call_method"
        case selectMethodPerCall = "select_method_per_call"
    }
}

struct SonetelCallAction: Codable {
    let action: String
    let show: String?
    let ringTime: String?
    let to: String?

    enum CodingKeys: String, CodingKey {
        case action = "action"
        case show = "show"
        case ringTime = "ring_time"
        case to = "to"
    }
}

// MARK: - Converted CallSettings for UI compatibility

struct CallSettings: Codable {
    let outgoingCli: String
    let incomingCli: String
    let callMethod: String
    let callForwarding: CallForwarding?
    let voicemail: VoicemailSettings?

    enum CodingKeys: String, CodingKey {
        case outgoingCli = "outgoing_cli"
        case incomingCli = "incoming_cli"
        case callMethod = "call_method"
        case callForwarding = "call_forwarding"
        case voicemail = "voicemail"
    }

    // Computed property for backward compatibility
    var callerIdSettings: CallerIdSettings {
        return CallerIdSettings(
            outgoing: outgoingCli,
            incoming: incomingCli,
            availableNumbers: []
        )
    }

    // Create from Sonetel API response
    static func from(sonetelData: SonetelCallSettingsData) -> CallSettings {
        return CallSettings(
            outgoingCli: sonetelData.outgoing.show,
            incomingCli: sonetelData.incoming.firstAction.show ?? "auto",
            callMethod: sonetelData.outgoing.callMethod,
            callForwarding: nil,
            voicemail: nil
        )
    }
}

struct CallerIdSettings: Codable {
    let outgoing: String
    let incoming: String
    let availableNumbers: [String]

    enum CodingKeys: String, CodingKey {
        case outgoing = "outgoing"
        case incoming = "incoming"
        case availableNumbers = "available_numbers"
    }
}

struct CallForwarding: Codable {
    let enabled: Bool
    let number: String?
    let delay: Int?

    enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case number = "number"
        case delay = "delay"
    }
}

struct VoicemailSettings: Codable {
    let enabled: Bool
    let greeting: String?

    enum CodingKeys: String, CodingKey {
        case enabled = "enabled"
        case greeting = "greeting"
    }
}

// MARK: - API Response Models

struct CallSettingsResponse: Codable {
    let status: String
    let response: CallSettingsData
}

struct CallSettingsData: Codable {
    let userId: String
    let settings: CallSettings

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case settings = "settings"
    }
}

// MARK: - Update Request Models

struct UpdateCallSettingsRequest: Codable {
    let outgoing: SonetelOutgoingUpdate?
    let incoming: SonetelIncomingUpdate?

    enum CodingKeys: String, CodingKey {
        case outgoing = "outgoing"
        case incoming = "incoming"
    }
}

struct SonetelOutgoingUpdate: Codable {
    let show: String

    enum CodingKeys: String, CodingKey {
        case show = "show"
    }
}

struct SonetelIncomingUpdate: Codable {
    let firstAction: SonetelUpdateAction

    enum CodingKeys: String, CodingKey {
        case firstAction = "first_action"
    }
}

struct SonetelUpdateAction: Codable {
    let show: String

    enum CodingKeys: String, CodingKey {
        case show = "show"
    }
}

// MARK: - Swift Enums for Type Safety

enum CallMethodType: String, CaseIterable, Codable {
    case internet = "internet"
    case mobile = "mobile"
    case automatic = "automatic"

    var displayName: String {
        switch self {
        case .internet:
            return "Internet"
        case .mobile:
            return "Mobile"
        case .automatic:
            return "Automatic"
        }
    }

    var iconName: String {
        switch self {
        case .internet:
            return "globe"
        case .mobile:
            return "cellularbars"
        case .automatic:
            return "gear"
        }
    }
}

enum CallerIdType: String, CaseIterable, Codable {
    case automatic = "automatic"
    case hidden = "hidden"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .hidden:
            return "Hidden"
        case .custom:
            return "Custom"
        }
    }
}

// MARK: - Default Settings

extension CallSettings {
    static let defaultSettings = CallSettings(
        outgoingCli: "auto",
        incomingCli: "auto",
        callMethod: "internet",
        callForwarding: CallForwarding(
            enabled: false,
            number: nil,
            delay: 20
        ),
        voicemail: VoicemailSettings(
            enabled: true,
            greeting: nil
        )
    )
}
