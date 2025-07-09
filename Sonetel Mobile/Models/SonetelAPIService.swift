//
//  SonetelAPIService.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import Foundation

@MainActor
class SonetelAPIService: ObservableObject {
    static let shared = SonetelAPIService()

    private let baseURL = "https://public-api.sonetel.com"
    private let authBaseURL = "https://api.sonetel.com/SonetelAuth"
    private var cachedAccountInfoFromToken: AccountInfo?
    private var cachedUserProfile: SonetelUserProfile?

    private var accessToken: String? {
        didSet {
            if let token = accessToken {
                UserDefaults.standard.set(token, forKey: "sonetel_access_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "sonetel_access_token")
            }
        }
    }

    /// Parse recording date for sorting
    private func parseRecordingDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }

    /// Convert Call Recording to CallRecord
    private func convertCallRecordingToCallRecord(_ recording: CallRecording) -> CallRecord? {
        let details = recording.voice_call_details

        // Determine contact name and phone number based on direction
        let (contactName, phoneNumber): (String, String) = {
            if details.direction.lowercased() == "outbound" {
                // For outbound calls, the contact is who we called
                let name = details.to_name.hasPrefix("+") ? generateContactName(from: details.to) : details.to_name
                return (name, details.to)
            } else {
                // For inbound calls, the contact is who called us
                let name = details.from_name.isEmpty ? generateContactName(from: details.from) : details.from_name
                return (name, details.caller_id.isEmpty ? details.from : details.caller_id)
            }
        }()

        // Determine call type
        let callType: CallRecord.CallType = {
            if details.direction.lowercased() == "outbound" {
                return .outgoing
            } else {
                // For inbound calls, check if call was completed
                return details.end_time.isEmpty ? .missed : .incoming
            }
        }()

        // Format timestamp for list display
        let timestamp = formatCallRecordingTimestamp(recording.created_date)

        // Format duration
        let duration = details.call_length > 0 ? formatDuration(details.call_length) : nil

        // Format date and time for detail view
        let callDate = formatCallRecordingDate(recording.created_date)
        let callTime = formatCallRecordingTime(recording.created_date)

        return CallRecord(
            contactName: contactName,
            phoneNumber: phoneNumber,
            timestamp: timestamp,
            avatarImageURL: nil,
            isMissed: callType == .missed,
            email: nil,
            callDate: callDate,
            callTime: callTime,
            callDuration: duration,
            callType: callType
        )
    }

    /// Parse call recording date for sorting
    private func parseCallRecordingDate(_ timestamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: timestamp)
    }

    /// Format call recording timestamp for display
    private func formatCallRecordingTimestamp(_ dateString: String) -> String {
        guard let date = parseCallRecordingDate(dateString) else { return "Unknown" }

        let now = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            return dayFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: date)
        }
    }



    /// Format call recording date for detail view
    private func formatCallRecordingDate(_ dateString: String) -> String? {
        guard let date = parseCallRecordingDate(dateString) else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }

    /// Format call recording time for detail view
    private func formatCallRecordingTime(_ dateString: String) -> String? {
        guard let date = parseCallRecordingDate(dateString) else { return nil }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }





    /// Convert actual Usage Record to CallRecord
    private func convertUsageRecordToCallRecord(_ record: UsageRecord) -> CallRecord? {
        // Only process call records
        guard record.service == "outbound_call" || record.service == "inbound_call",
              let callDetails = record.usage_details.call else {
            return nil
        }

        // Determine contact name and phone number based on service type
        let (contactName, phoneNumber): (String, String) = {
            if record.service == "outbound_call" {
                // For outbound calls, the contact is who we called
                let name = generateContactName(from: callDetails.to)
                return (name, callDetails.to)
            } else {
                // For inbound calls, the contact is who called us
                let name = generateContactName(from: callDetails.from)
                return (name, callDetails.from)
            }
        }()

        // Determine call type
        let callType: CallRecord.CallType = {
            if record.service == "outbound_call" {
                return .outgoing
            } else {
                // For inbound calls, check if call was completed (has end_time)
                return callDetails.end_time.isEmpty ? .missed : .incoming
            }
        }()

        // Format timestamp for list display
        let timestamp = formatUsageRecordTimestamp(record.timestamp)

        // Format duration from call_length
        let duration: String? = {
            if let callLengthInt = Int(callDetails.call_length), callLengthInt > 0 {
                return formatDuration(callLengthInt)
            }
            return nil
        }()

        // Format date and time for detail view
        let callDate = formatUsageRecordDate(record.timestamp)
        let callTime = formatUsageRecordTime(record.timestamp)

        return CallRecord(
            contactName: contactName,
            phoneNumber: phoneNumber,
            timestamp: timestamp,
            avatarImageURL: nil,
            isMissed: callType == .missed,
            email: nil,
            callDate: callDate,
            callTime: callTime,
            callDuration: duration,
            callType: callType
        )
    }

    /// Parse usage record timestamp (format: "2025/06/22T06:00:35Z")
    private func parseUsageRecordTimestamp(_ timestamp: String) -> Date? {
        let formatters = [
            "yyyy/MM/dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy/MM/dd HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            if let date = formatter.date(from: timestamp) {
                return date
            }
        }

        return nil
    }

    /// Format usage record timestamp for display
    private func formatUsageRecordTimestamp(_ timestamp: String) -> String {
        guard let date = parseUsageRecordTimestamp(timestamp) else { return "Unknown" }

        let now = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            return dayFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: date)
        }
    }

    /// Format usage record date for detail view
    private func formatUsageRecordDate(_ timestamp: String) -> String? {
        guard let date = parseUsageRecordTimestamp(timestamp) else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: date)
    }

    /// Format usage record time for detail view
    private func formatUsageRecordTime(_ timestamp: String) -> String? {
        guard let date = parseUsageRecordTimestamp(timestamp) else { return nil }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }

    private var refreshToken: String? {
        didSet {
            if let token = refreshToken {
                UserDefaults.standard.set(token, forKey: "sonetel_refresh_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "sonetel_refresh_token")
            }
        }
    }

    private var tokenExpiryDate: Date? {
        didSet {
            if let date = tokenExpiryDate {
                UserDefaults.standard.set(date, forKey: "sonetel_token_expiry")
            } else {
                UserDefaults.standard.removeObject(forKey: "sonetel_token_expiry")
            }
        }
    }

    /// Check if user is authenticated with valid tokens
    var isAuthenticated: Bool {
        guard let accessToken = accessToken, !accessToken.isEmpty else {
            return false
        }

        // Check if token is expired
        if let expiryDate = tokenExpiryDate, Date() >= expiryDate {
            print("⚠️ Access token has expired")
            return false
        }

        return true
    }

    private init() {
        // Restore tokens from UserDefaults
        self.accessToken = UserDefaults.standard.string(forKey: "sonetel_access_token")
        self.refreshToken = UserDefaults.standard.string(forKey: "sonetel_refresh_token")
        self.tokenExpiryDate = UserDefaults.standard.object(forKey: "sonetel_token_expiry") as? Date
    }

    // MARK: - Testing Methods

    /// Test if our access token is valid
    func testTokenValidity() async throws -> Bool {
        guard let token = accessToken else {
            print("❌ SonetelAPI: No access token available")
            return false
        }

        // Test token with a simple API call using the working domain
        let testUrl = URL(string: "\(baseURL)/account")!
        var request = URLRequest(url: testUrl)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 SonetelAPI: Token test returned status: \(httpResponse.statusCode)")
                return httpResponse.statusCode != 401 && httpResponse.statusCode != 403
            }
            return false
        } catch {
            print("❌ SonetelAPI: Token test failed: \(error)")
            return false
        }
    }

    /// Test basic connectivity to Sonetel API
    func testConnectivity() async throws -> Bool {
        print("🌐 SonetelAPI: Testing connectivity to \(authBaseURL)")

        let url = URL(string: "\(authBaseURL)/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "OPTIONS" // Use OPTIONS to test without making actual request
        request.timeoutInterval = 10.0

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 SonetelAPI: Auth endpoint responded with status: \(httpResponse.statusCode)")
                // Any response (even 405 Method Not Allowed) means we can reach the server
                return httpResponse.statusCode < 500
            }
            return false
        } catch {
            print("❌ SonetelAPI: Connectivity test failed: \(error)")
            return false
        }
    }

    // MARK: - Authentication

    /// Create access token using email and password
    func createToken(email: String, password: String) async throws -> TokenResponse {
        print("🔐 SonetelAPI: Attempting to create token for email: \(email)")

        let url = URL(string: "\(authBaseURL)/oauth/token")!
        print("🌐 SonetelAPI: Using URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0 // Add 30 second timeout

        // Basic Auth with client credentials
        let clientCredentials = "sonetel-api:sonetel-api"
        let credentialsData = clientCredentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        // Form-encoded body
        let bodyParams = [
            "grant_type": "password",
            "username": email,
            "password": password,
            "refresh": "yes"
        ]

        var components = URLComponents()
        components.queryItems = bodyParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        print("📤 SonetelAPI: Sending request with form data...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print("📥 SonetelAPI: Received response")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ SonetelAPI: Invalid response type")
                throw SonetelAPIError.invalidResponse
            }

            print("📊 SonetelAPI: HTTP Status Code: \(httpResponse.statusCode)")

            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 SonetelAPI: Response body: \(responseString)")
            }

            if httpResponse.statusCode == 200 {
                do {
                    // First, try to decode as our expected TokenResponse
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    print("✅ SonetelAPI: Successfully decoded token response")

                    // Verify token content
                    print("🔐 SonetelAPI: Token details:")
                    print("   - Access token length: \(tokenResponse.access_token.count)")
                    print("   - Token type: \(tokenResponse.token_type ?? "unknown")")
                    print("   - Expires in: \(tokenResponse.expires_in ?? 0) seconds")
                    print("   - Refresh token: \(tokenResponse.refresh_token != nil ? "yes" : "no")")
                    print("   - Scope: \(tokenResponse.scope ?? "none")")

                    // Store tokens
                    self.accessToken = tokenResponse.access_token
                    self.refreshToken = tokenResponse.refresh_token

                    // Calculate expiry date
                    let expirySeconds = tokenResponse.expires_in ?? 86400 // Default 24 hours
                    self.tokenExpiryDate = Date().addingTimeInterval(TimeInterval(expirySeconds))

                    print("✅ SonetelAPI: Tokens stored successfully")
                    print("🔐 SonetelAPI: Access token: \(tokenResponse.access_token.prefix(20))...")
                    print("🔄 SonetelAPI: Refresh token: \(tokenResponse.refresh_token?.prefix(20) ?? "none")...")
                    print("�� SonetelAPI: Token expires at: \(self.tokenExpiryDate?.description ?? "unknown")")

                    // Extract account info from JWT token
                    print("🔍 SonetelAPI: Extracting account info from JWT token...")
                    if let accountInfoFromToken = extractAccountInfoFromJWT(tokenResponse.access_token) {
                        print("✅ SonetelAPI: Successfully extracted account info from JWT token")
                        self.cachedAccountInfoFromToken = accountInfoFromToken
                    } else {
                        print("❌ SonetelAPI: Failed to extract account info from JWT token")
                    }

                    return tokenResponse
                } catch {
                    print("❌ SonetelAPI: Failed to decode token response: \(error)")

                    // Try to decode as a generic JSON object to see what we got
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("📄 SonetelAPI: Raw auth response JSON: \(jsonObject)")

                        // Check if account info might be included in auth response
                        if let dict = jsonObject as? [String: Any] {
                            let possibleAccountFields = ["user", "account", "profile", "company_name", "name", "email"]
                            for field in possibleAccountFields {
                                if dict[field] != nil {
                                    print("🔍 SonetelAPI: Found potential account field '\(field)' in auth response: \(dict[field] ?? "nil")")
                                }
                            }
                        }

                        // Try to extract token manually if it's a different format
                        if let dict = jsonObject as? [String: Any],
                           let accessToken = dict["access_token"] as? String ?? dict["accessToken"] as? String {

                            print("🔧 SonetelAPI: Manually extracting token from response")

                            let refreshToken = dict["refresh_token"] as? String ?? dict["refreshToken"] as? String
                            let expiresIn = dict["expires_in"] as? Int ?? dict["expiresIn"] as? Int ?? 86400

                            // Store tokens manually
                            self.accessToken = accessToken
                            self.refreshToken = refreshToken
                            self.tokenExpiryDate = Date().addingTimeInterval(TimeInterval(expiresIn))

                            // Extract account info from JWT token
                            if let accountInfoFromToken = extractAccountInfoFromJWT(accessToken) {
                                print("🔍 SonetelAPI: Extracted account info from JWT token")
                                // Store the account info extracted from token for later use
                                self.cachedAccountInfoFromToken = accountInfoFromToken
                            }

                            // Create a TokenResponse object manually
                            let manualTokenResponse = TokenResponse(
                                access_token: accessToken,
                                token_type: dict["token_type"] as? String ?? "Bearer",
                                expires_in: expiresIn,
                                refresh_token: refreshToken,
                                scope: dict["scope"] as? String
                            )

                            print("✅ SonetelAPI: Successfully extracted tokens manually")
                            return manualTokenResponse
                        }
                    }

                    throw SonetelAPIError.networkError("Failed to decode authentication response: \(error.localizedDescription)")
                }
            } else {
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(SonetelErrorResponse.self, from: data) {
                    print("❌ SonetelAPI: Authentication failed: \(errorResponse.error)")
                    throw SonetelAPIError.authenticationFailed(errorResponse.error_description ?? errorResponse.error)
                } else {
                    print("❌ SonetelAPI: Authentication failed with status \(httpResponse.statusCode)")
                    throw SonetelAPIError.authenticationFailed("Authentication failed with status \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("❌ SonetelAPI: Network request failed: \(error)")
            if error is SonetelAPIError {
                throw error
            } else {
                throw SonetelAPIError.networkError("Network request failed: \(error.localizedDescription)")
            }
        }
    }

    /// Refresh the access token using refresh token
    func refreshAccessToken() async throws -> TokenResponse {
        guard let refreshToken = self.refreshToken else {
            throw SonetelAPIError.noRefreshToken
        }

        print("��� SonetelAPI: Refreshing access token...")

        let url = URL(string: "\(authBaseURL)/oauth/token")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0

        // Basic Auth with client credentials
        let clientCredentials = "sonetel-api:sonetel-api"
        let credentialsData = clientCredentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        // Form-encoded body
        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        var components = URLComponents()
        components.queryItems = bodyParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SonetelAPIError.invalidResponse
            }

            print("📊 SonetelAPI: Refresh token status: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)

                // Update stored tokens
                self.accessToken = tokenResponse.access_token
                if let newRefreshToken = tokenResponse.refresh_token {
                    self.refreshToken = newRefreshToken
                }

                // Update expiry date
                let expirySeconds = tokenResponse.expires_in ?? 86400 // Default 24 hours
                self.tokenExpiryDate = Date().addingTimeInterval(TimeInterval(expirySeconds))

                print("✅ SonetelAPI: Access token refreshed successfully")
                return tokenResponse
            } else {
                print("❌ SonetelAPI: Token refresh failed with status \(httpResponse.statusCode)")
                throw SonetelAPIError.tokenRefreshFailed
            }
        } catch {
            print("❌ SonetelAPI: Token refresh request failed: \(error)")
            throw SonetelAPIError.tokenRefreshFailed
        }
    }

    // MARK: - Phone Numbers

    /// Get user's personal phone numbers (mobile, etc.)
    func getPersonalPhoneNumbers() async throws -> [SonetelPhoneNumber] {
        let token = try await getValidToken()
        let userId = getStoredUserId()

        print("🔍 SonetelAPI: Getting personal phone numbers for user: \(userId)")

        let url = URL(string: "\(baseURL)/user/\(userId)/phones")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SonetelAPIError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                   let dict = jsonObject as? [String: Any],
                   let status = dict["status"] as? String,
                   status == "success",
                   let response = dict["response"] as? [[String: Any]] {

                    let phoneNumbers = response.compactMap { numberDict -> SonetelPhoneNumber? in
                        guard let number = numberDict["phnum"] as? String else { return nil }

                        let label = numberDict["phone_name"] as? String ?? "Phone"
                        let shortLabel = label == "Mobile number" ? "Mobile" : label

                        return SonetelPhoneNumber(
                            number: number,
                            label: shortLabel,
                            country: nil, // No country for personal numbers
                            location: nil,
                            status: numberDict["verified"] as? String == "yes" ? "active" : "inactive",
                            type: "personal"
                        )
                    }

                    print("✅ SonetelAPI: Found \(phoneNumbers.count) personal phone numbers")
                    return phoneNumbers
                }
            }
        } catch {
            print("❌ SonetelAPI: Failed to get personal phone numbers: \(error)")
        }

        return []
    }

    /// Get user's Sonetel subscribed phone numbers
    func getSonetelPhoneNumbers() async throws -> [SonetelPhoneNumber] {
        let token = try await getValidToken()
        let accountId = extractAccountId()

        print("🔍 SonetelAPI: Getting Sonetel phone numbers for account: \(accountId)")

        // Try the documented endpoint for phone number subscriptions
        let possibleEndpoints = [
            "\(baseURL)/account/\(accountId)/phonenumbersubscription",  // From documentation
            "https://public-api.sonetel.com/account/\(accountId)/phonenumbersubscription", // Full URL from docs
            "\(baseURL)/account/\(accountId)/phone_number_subscription",
            "\(baseURL)/account/\(accountId)/subscribed_numbers",
            "\(baseURL)/phonenumbersubscription",
            "\(baseURL)/phone_number_subscription"
        ]

        for (index, endpoint) in possibleEndpoints.enumerated() {
            let url = URL(string: endpoint)!
            print("���� SonetelAPI: [\(index + 1)/\(possibleEndpoints.count)] Trying Sonetel numbers from: \(url)")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10.0

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    continue
                }

                print("📊 SonetelAPI: Sonetel numbers status from \(endpoint): \(httpResponse.statusCode)")

                if let responseString = String(data: data, encoding: .utf8) {
                    print("��� SonetelAPI: Sonetel numbers response body (\(data.count) bytes):")
                    print(responseString)
                }

                if httpResponse.statusCode == 200 {
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                       let dict = jsonObject as? [String: Any],
                       let status = dict["status"] as? String,
                       status == "success" {

                        var numbersArray: [[String: Any]] = []

                        if let response = dict["response"] as? [[String: Any]] {
                            numbersArray = response
                        } else if let response = dict["response"] as? [String: Any],
                                  let numbers = response["phone_numbers"] as? [[String: Any]] {
                            numbersArray = numbers
                        }

                        if !numbersArray.isEmpty {
                            let phoneNumbers = numbersArray.compactMap { numberDict -> SonetelPhoneNumber? in
                                guard let number = numberDict["phone_number"] as? String ??
                                                  numberDict["number"] as? String ??
                                                  numberDict["phnum"] as? String else {
                                    return nil
                                }

                                // Extract country code from phone number if not provided
                                let extractedCountry = numberDict["country"] as? String ??
                                                      numberDict["country_code"] as? String ??
                                                      extractCountryCodeFromNumber(number)

                                return SonetelPhoneNumber(
                                    number: number,
                                    label: numberDict["label"] as? String ??
                                           numberDict["name"] as? String ??
                                           numberDict["city"] as? String,
                                    country: extractedCountry,
                                    location: numberDict["location"] as? String ??
                                             numberDict["city"] as? String,
                                    status: numberDict["status"] as? String ?? "active",
                                    type: "sonetel"
                                )
                            }

                            print("✅ SonetelAPI: Found \(phoneNumbers.count) Sonetel phone numbers")
                            return phoneNumbers
                        }
                    }
                }
            } catch {
                print("❌ SonetelAPI: Error fetching Sonetel numbers from \(endpoint): \(error)")
                continue
            }
        }

        print("⚠️ SonetelAPI: No Sonetel phone numbers found")
        return []
    }

    /// Get user's phone numbers (legacy method for backward compatibility)
    func getPhoneNumbers() async throws -> [SonetelPhoneNumber] {
        let token = try await getValidToken()

        print("🌐 SonetelAPI: Getting phone numbers")
        print("🔐 SonetelAPI: Using token: \(token.prefix(20))...")
        print("🔐 SonetelAPI: Token expires: \(tokenExpiryDate?.description ?? "unknown")")

        // Extract IDs for targeted endpoints
        let userId = getStoredUserId()
        let accountId = extractAccountId()

        print("��� SonetelAPI: Using User ID: \(userId), Account ID: \(accountId)")

        // Use the correct endpoints revealed by the API error message:
        // "Unknown partial selection. supported only phones/numbers/call"
        let possibleEndpoints = [
            // User endpoints with correct paths (from API error message)
            "\(baseURL)/user/\(userId)/phones",          // API said "phones" is supported
            "\(baseURL)/user/\(userId)/numbers",         // API said "numbers" is supported

            // Account endpoints with correct paths
            "\(baseURL)/account/\(accountId)/phones",
            "\(baseURL)/account/\(accountId)/numbers",

            // Direct resource endpoints
            "\(baseURL)/phones",
            "\(baseURL)/numbers",

            // Alternative formats
            "\(baseURL)/phone_numbers",
            "\(baseURL)/phonenumbers"
        ]

        for (index, endpoint) in possibleEndpoints.enumerated() {
            let url = URL(string: endpoint)!
            print("🌐 SonetelAPI: [\(index + 1)/\(possibleEndpoints.count)] Trying phone numbers from: \(url)")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10.0

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ SonetelAPI: Invalid response type for phone numbers from \(endpoint)")
                    continue
                }

                print("📊 SonetelAPI: Phone numbers status from \(endpoint): \(httpResponse.statusCode)")

                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 SonetelAPI: Phone numbers response body (\(data.count) bytes):")
                    print(responseString)
                }

                if httpResponse.statusCode == 200 {
                    do {
                        // Try to decode as array of phone numbers
                        let phoneNumbers = try JSONDecoder().decode([SonetelPhoneNumber].self, from: data)
                        print("✅ SonetelAPI: Successfully got \(phoneNumbers.count) phone numbers from \(endpoint)")
                        return phoneNumbers
                    } catch {
                        print("❌ SonetelAPI: Failed to decode phone numbers from \(endpoint): \(error)")

                        // Try to extract from wrapped response
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                           let dict = jsonObject as? [String: Any] {

                            print("🔧 SonetelAPI: Trying to manually extract phone numbers from \(endpoint)")

                            // Handle Sonetel's nested response format (like account API)
                            var numbersArray: [[String: Any]] = []

                            // Check for Sonetel's standard format: {"resource":"...","response":{...},"status":"success"}
                            if let resource = dict["resource"] as? String,
                               let status = dict["status"] as? String,
                               status == "success" {
                                print("🔍 SonetelAPI: Found Sonetel format response for resource: \(resource)")

                                // Handle the actual response format from /user/{id}/phones
                                if let response = dict["response"] as? [[String: Any]] {
                                    // Response is directly an array of phone numbers (this is our case!)
                                    numbersArray = response
                                    print("🔍 SonetelAPI: Found direct array with \(response.count) phone objects")
                                } else if let response = dict["response"] as? [String: Any] {
                                    // Response is an object containing phone numbers
                                    if let phoneNumbers = response["phone_numbers"] as? [[String: Any]] {
                                        numbersArray = phoneNumbers
                                    } else if let numbers = response["numbers"] as? [[String: Any]] {
                                        numbersArray = numbers
                                    } else if let phonenumbers = response["phonenumbers"] as? [[String: Any]] {
                                        numbersArray = phonenumbers
                                    }
                                }
                            } else {
                                // Try other common formats
                                if let numbers = dict["numbers"] as? [[String: Any]] {
                                    numbersArray = numbers
                                } else if let response = dict["response"] as? [[String: Any]] {
                                    numbersArray = response
                                } else if let data = dict["data"] as? [[String: Any]] {
                                    numbersArray = data
                                } else if let results = dict["results"] as? [[String: Any]] {
                                    numbersArray = results
                                }
                            }

                            if !numbersArray.isEmpty {
                                print("🔍 SonetelAPI: Processing \(numbersArray.count) phone number objects")
                                let phoneNumbers = numbersArray.compactMap { numberDict -> SonetelPhoneNumber? in
                                    print("🔍 SonetelAPI: Processing phone object: \(numberDict)")

                                    // Handle the actual API response format:
                                    // {"phone_id":"2204404376","phnum":"+46708956010","phone_type":"regular","phone_name":"Mobile number","receive_calls":"yes","verified":"yes","is_primary":true,"sip_details":null}
                                    guard let number = numberDict["phnum"] as? String ??
                                                      numberDict["number"] as? String ??
                                                      numberDict["phone_number"] as? String else {
                                        print("❌ SonetelAPI: No phone number found in object: \(numberDict)")
                                        return nil
                                    }

                                    let phoneNumber = SonetelPhoneNumber(
                                        number: number,
                                        label: numberDict["phone_name"] as? String ??
                                               numberDict["label"] as? String ??
                                               numberDict["name"] as? String,
                                        country: numberDict["country"] as? String ??
                                                numberDict["country_code"] as? String,
                                        location: numberDict["location"] as? String ??
                                                 numberDict["city"] as? String,
                                        status: numberDict["verified"] as? String == "yes" ? "active" :
                                               numberDict["status"] as? String ?? "active",
                                        type: numberDict["phone_type"] as? String ??
                                             numberDict["type"] as? String ?? "voice",
                                        created_at: numberDict["created_at"] as? String,
                                        updated_at: numberDict["updated_at"] as? String
                                    )

                                    print("✅ SonetelAPI: Successfully created phone number: \(phoneNumber.number)")
                                    return phoneNumber
                                }

                                print("✅ SonetelAPI: Successfully extracted \(phoneNumbers.count) phone numbers manually from \(endpoint)")
                                return phoneNumbers
                            }
                        }
                    }
                } else if httpResponse.statusCode == 404 {
                    print("⚠️ SonetelAPI: Phone numbers endpoint \(endpoint) not found (404), trying next...")
                    continue
                } else if httpResponse.statusCode == 401 {
                    print("❌ SonetelAPI: Unauthorized (401) for phone numbers - token might be invalid")
                    throw SonetelAPIError.unauthorizedAccess
                } else if httpResponse.statusCode == 403 {
                    print("❌ SonetelAPI: Forbidden (403) for phone numbers - insufficient permissions")
                    continue
                } else if httpResponse.statusCode == 200 {
                    // Handle 200 responses that might contain error messages
                    if let responseString = String(data: data, encoding: .utf8),
                       responseString.contains("not authorized") || responseString.contains("failed") {
                        print("⚠️ SonetelAPI: Authorization error in 200 response from \(endpoint): \(responseString)")
                        continue
                    }
                } else {
                    print("⚠️ SonetelAPI: Phone numbers endpoint \(endpoint) returned \(httpResponse.statusCode)")
                    continue
                }
            } catch {
                print("❌ SonetelAPI: Request to phone numbers \(endpoint) failed with error: \(error)")
                continue
            }
        }

        // If all endpoints fail, return demo data for development/testing
        print("��️ SonetelAPI: All phone number endpoints failed, returning demo data for testing")

        // Create demo Sonetel numbers for development/testing
        let demoNumbers = [
            SonetelPhoneNumber(
                number: "+13103219379",
                label: "Los Angeles",
                country: "US",
                location: "Los Angeles, CA USA",
                status: "active",
                type: "voice"
            ),
            SonetelPhoneNumber(
                number: "+16463848632",
                label: "New York",
                country: "US",
                location: "New York, NY USA",
                status: "active",
                type: "voice"
            ),
            SonetelPhoneNumber(
                number: "+46723319847",
                label: "Stockholm",
                country: "SE",
                location: "Stockholm, Sweden",
                status: "active",
                type: "voice"
            ),
            SonetelPhoneNumber(
                number: "+442074567890",
                label: "London",
                country: "GB",
                location: "London, UK",
                status: "active",
                type: "voice"
            )
        ]

        print("✅ SonetelAPI: Returning \(demoNumbers.count) demo phone numbers")
        return demoNumbers
    }

    // MARK: - Account Information

    /// Get account information
    func getAccountInfo(userEmail: String? = nil) async throws -> AccountInfo {
        // Verify we have authentication
        guard isAuthenticated else {
            print("❌ SonetelAPI: No authentication available for account info")
            throw SonetelAPIError.noValidToken
        }

        let token = try await getValidToken()
        print("🔐 SonetelAPI: Using access token: \(token.prefix(20))...")
        print("🔐 SonetelAPI: Token expires: \(tokenExpiryDate?.description ?? "unknown")")

        // Test token validity first
        print("🔍 SonetelAPI: Testing token validity...")
        let isTokenValid = try await testTokenValidity()
        print("🔍 SonetelAPI: Token validity test result: \(isTokenValid)")

        // Continue even if token test fails, as the endpoint might be different
        if !isTokenValid {
            print("⚠️ SonetelAPI: Token test failed, but continuing to try account endpoints...")
        } else {
            print("✅ SonetelAPI: Token is valid, proceeding with account info...")
        }

        // Try different possible account endpoints on the working domain
        let possibleEndpoints = [
            "\(baseURL)/account",                      // api.sonetel.com/account
            "\(baseURL)/me",                          // api.sonetel.com/me
            "\(baseURL)/user",                        // api.sonetel.com/user
            "\(baseURL)/user/profile",                // api.sonetel.com/user/profile
            "\(baseURL)/v1/account",                  // api.sonetel.com/v1/account
            "\(baseURL)/v1/me",                       // api.sonetel.com/v1/me
            "\(baseURL)/api/account",                 // api.sonetel.com/api/account
            "\(baseURL)/api/me"                       // api.sonetel.com/api/me
        ]

        for (index, endpoint) in possibleEndpoints.enumerated() {
            let url = URL(string: endpoint)!
            print("🌐 SonetelAPI: [\(index + 1)/\(possibleEndpoints.count)] Trying account info from: \(url)")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 10.0  // Faster timeout to try more endpoints quickly

            print("��� SonetelAPI: Request headers: Authorization: Bearer \(token.prefix(20))..., Accept: application/json")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ SonetelAPI: Invalid response type for account info from \(endpoint)")
                    continue
                }

                print("📊 SonetelAPI: Account info status from \(endpoint): \(httpResponse.statusCode)")
                print("📋 SonetelAPI: Response headers: \(httpResponse.allHeaderFields)")

                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 SonetelAPI: Response body (\(data.count) bytes):")
                    print(responseString)
                } else {
                    print("📄 SonetelAPI: Response body is not valid UTF-8 or empty (\(data.count) bytes)")
                }

                if httpResponse.statusCode == 200 {
                    // Try to decode the response
                    do {
                        let accountInfo = try JSONDecoder().decode(AccountInfo.self, from: data)
                        print("✅ SonetelAPI: Successfully got account info from \(endpoint)")
                        return accountInfo
                    } catch {
                        print("❌ SonetelAPI: Failed to decode account info from \(endpoint): \(error)")

                        // Try to extract basic info manually if structure is different
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                           let dict = jsonObject as? [String: Any] {

                            print("🔧 SonetelAPI: Trying to manually extract account info from \(endpoint)")
                            print("🔍 SonetelAPI: Response structure: \(dict)")

                            // Handle Sonetel's response format: {"resource":"user","response":{...},"status":"..."}
                            var extractedData: [String: Any] = dict

                            // Check if this is a Sonetel-style response
                            if let resource = dict["resource"] as? String,
                               let status = dict["status"] as? String {
                                print("�� SonetelAPI: Detected Sonetel response format - resource: \(resource), status: \(status)")

                                if status == "success" || status == "ok" {
                                    // Extract data from successful response
                                    if let responseData = dict["response"] as? [String: Any] {
                                        extractedData = responseData
                                        print("✅ SonetelAPI: Using response data from successful Sonetel response")
                                    }
                                } else {
                                    // Use token data as fallback for failed API responses
                                    print("⚠️ SonetelAPI: API response failed (\(status)), using token data as fallback")
                                    if let tokenAccountInfo = self.cachedAccountInfoFromToken {
                                        print("✅ SonetelAPI: Using account info from JWT token")
                                        return tokenAccountInfo
                                    }
                                }
                            }

                            // Create a basic AccountInfo with available data
                            let manualAccountInfo = AccountInfo(
                                account_id: extractedData["account_id"] as? String ?? extractedData["id"] as? String ?? self.cachedAccountInfoFromToken?.account_id ?? "unknown",
                                currency: extractedData["currency"] as? String ?? "USD",
                                prepaid_balance: extractedData["prepaid_balance"] as? Double ?? extractedData["balance"] as? Double,
                                country: extractedData["country"] as? String,
                                email: extractedData["email"] as? String ?? self.cachedAccountInfoFromToken?.email,
                                name: extractedData["name"] as? String ?? extractedData["full_name"] as? String,
                                company_name: extractedData["company_name"] as? String ?? extractedData["company"] as? String,
                                phone_number: extractedData["phone_number"] as? String ?? extractedData["phone"] as? String,
                                verified: extractedData["verified"] as? Bool ?? true,
                                created_at: extractedData["created_at"] as? String,
                                updated_at: extractedData["updated_at"] as? String
                            )

                            print("✅ SonetelAPI: Successfully extracted account info manually from \(endpoint)")
                            return manualAccountInfo
                        }
                    }
                } else if httpResponse.statusCode == 404 {
                    print("⚠️ SonetelAPI: Endpoint \(endpoint) not found (404), trying next...")
                    continue
                } else if httpResponse.statusCode == 401 {
                    print("❌ SonetelAPI: Unauthorized (401) - token might be invalid")
                    throw SonetelAPIError.unauthorizedAccess
                } else if httpResponse.statusCode == 403 {
                    print("❌ SonetelAPI: Forbidden (403) - insufficient permissions for \(endpoint)")
                    continue
                } else {
                    print("⚠️ SonetelAPI: Endpoint \(endpoint) returned \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                    continue
                }
            } catch {
                print("❌ SonetelAPI: Request to \(endpoint) failed with error: \(error)")
                print("❌ SonetelAPI: Error type: \(type(of: error))")
                if let urlError = error as? URLError {
                    print("�� SonetelAPI: URLError code: \(urlError.code), description: \(urlError.localizedDescription)")
                }
                continue
            }
        }

        // If all endpoints fail, use account info from JWT token or create basic fallback
        print("⚠️ SonetelAPI: All account endpoints failed")

        if let tokenAccountInfo = self.cachedAccountInfoFromToken {
            print("✅ SonetelAPI: Using account info extracted from JWT token as fallback")
            return tokenAccountInfo
        } else {
            print("⚠️ SonetelAPI: No token data available, creating basic account info from auth data")
            print("📧 SonetelAPI: Using email from authentication: \(userEmail ?? "unknown")")

            // We know authentication worked, so create minimal account info with actual user data
            let basicAccountInfo = AccountInfo(
                account_id: "authenticated-user", // At least we know they're authenticated
                currency: "USD", // Default
                prepaid_balance: nil,
                country: nil,
                email: userEmail, // Use the email from authentication
                name: nil,
                company_name: "API Data Not Available", // Show that we couldn't fetch this
                phone_number: nil,
                verified: true, // Must be true since authentication succeeded
                created_at: nil,
                updated_at: nil
            )

            print("✅ SonetelAPI: Created basic account info as fallback with email: \(userEmail ?? "none")")
            return basicAccountInfo
        }
    }

    /// Get user profile information
    func getUserProfile(userId: String? = nil) async throws -> SonetelUserProfile {
        let token = try await getValidToken()

        // Use user ID from JWT token if not provided
        let targetUserId = userId ?? getStoredUserId()

        guard !targetUserId.isEmpty else {
            throw SonetelAPIError.networkError("No user ID available for profile fetch")
        }

        print("🌐 SonetelAPI: Getting user profile for user ID: \(targetUserId)")

        // Try a simple user profile endpoint first
        let url = URL(string: "\(baseURL)/users/\(targetUserId)/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10.0

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let userProfile = try? JSONDecoder().decode(SonetelUserProfile.self, from: data) {
                    print("��� SonetelAPI: Successfully got user profile")
                    self.cachedUserProfile = userProfile
                    return userProfile
                }
            }
        } catch {
            print("❌ SonetelAPI: User profile request failed: \(error)")
        }

        // If API call fails, create a basic user profile from JWT token data
        print("⚠️ SonetelAPI: Creating basic user profile from JWT token data")

        if let tokenAccountInfo = self.cachedAccountInfoFromToken {
            let basicUserProfile = SonetelUserProfile(
                user_id: targetUserId,
                email: tokenAccountInfo.email,
                full_name: tokenAccountInfo.name,
                company: tokenAccountInfo.company_name,
                phone: tokenAccountInfo.phone_number,
                status: "active"
            )

            print("✅ SonetelAPI: Created basic user profile from JWT token data")
            self.cachedUserProfile = basicUserProfile
            return basicUserProfile
        } else {
            throw SonetelAPIError.networkError("No user profile data available")
        }
    }

    // MARK: - Call History / Usage Records

    /// Get call history using Usage Records API (proper call history/CDR)
    func getCallHistory(
        dateFrom: Date? = nil,
        dateTo: Date? = nil,
        callType: String = "all" // "all", "outbound", "inbound"
    ) async throws -> [CallRecord] {
        if isDummyDataMode {
            print("🎭 SonetelAPIService: Returning dummy call history")
            let dummyUsageRecords = getDummyUsageRecords()
            let callRecords = dummyUsageRecords.compactMap { record -> CallRecord? in
                return self.convertUsageRecordToCallRecord(record)
            }
            let filteredRecords = filterCallRecords(callRecords, by: callType)
            return filteredRecords.sorted {
                let date1 = self.parseUsageRecordTimestamp($0.timestamp) ?? Date.distantPast
                let date2 = self.parseUsageRecordTimestamp($1.timestamp) ?? Date.distantPast
                return date1 > date2
            }
        }

        let token = try await getValidToken()
        let accountId = extractAccountId()

        guard !accountId.isEmpty else {
            throw SonetelAPIError.networkError("No account ID available")
        }

        // Get usage records and filter for calls
        print("📞 API: Attempting to get usage records...")
        let usageRecords = try await getUsageRecords(
            token: token,
            accountId: accountId,
            dateFrom: dateFrom,
            dateTo: dateTo
        )

        print("✅ API: Retrieved \(usageRecords.count) usage records")

        // Filter for call records and convert to CallRecord objects
        let callRecords = usageRecords.compactMap { record -> CallRecord? in
            return self.convertUsageRecordToCallRecord(record)
        }

        // Filter by call type if specified
        let filteredRecords = filterCallRecords(callRecords, by: callType)

        print("✅ API: Returning \(filteredRecords.count) call history records from Usage Records")
        return filteredRecords.sorted {
            let date1 = self.parseUsageRecordTimestamp($0.timestamp) ?? Date.distantPast
            let date2 = self.parseUsageRecordTimestamp($1.timestamp) ?? Date.distantPast
            return date1 > date2
        }
    }




    /// Get usage records from the API
    private func getUsageRecords(
        token: String,
        accountId: String,
        dateFrom: Date? = nil,
        dateTo: Date? = nil
    ) async throws -> [UsageRecord] {

        // Try the specific endpoint provided by user first
        let endpoints = [
            // The exact endpoint provided - note "usagerecord" singular, not plural
            "https://public-api.sonetel.com/usage/account/\(accountId)/usagerecord",

            // Then try similar variations
            "https://public-api.sonetel.com/usage/account/\(accountId)/usagerecords",
            "https://public-api.sonetel.com/usage/account/\(accountId)/record",
            "https://public-api.sonetel.com/usage/account/\(accountId)/records",

            // Other patterns
            "https://public-api.sonetel.com/call-log",
            "https://public-api.sonetel.com/call-logs",
            "https://public-api.sonetel.com/calls",
            "https://public-api.sonetel.com/cdr"
        ]

        for endpoint in endpoints {
            do {
                let result = try await trySimpleUsageEndpoint(endpoint: endpoint, token: token, accountId: accountId)
                return result
            } catch {
                print("❌ Endpoint \(endpoint) failed: \(error)")
                continue
            }
        }

        throw SonetelAPIError.networkError("No endpoints worked - usage records API may not exist")
    }

    private func trySimpleUsageEndpoint(
        endpoint: String,
        token: String,
        accountId: String
    ) async throws -> [UsageRecord] {

        var urlComponents = URLComponents(string: endpoint)!
        var queryItems: [URLQueryItem] = []

        // Only add account_id if not already in URL
        if !endpoint.contains(accountId) {
            queryItems.append(URLQueryItem(name: "account_id", value: accountId))
        }

        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = urlComponents.url else {
            throw SonetelAPIError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("📞 Trying Usage Endpoint: \(url)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SonetelAPIError.invalidResponse
        }

        print("📞 Response Status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            let responseString = String(data: data, encoding: .utf8) ?? "No response"
            print("✅ SUCCESS! Raw Response from \(endpoint):")
            print("📄 Response: \(responseString.prefix(500))...")

            // Parse the actual usage records response
            let usageResponse = try JSONDecoder().decode(UsageRecordsResponse.self, from: data)
            print("✅ Parsed \(usageResponse.response.count) usage records")

            return usageResponse.response

        } else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Failed \(httpResponse.statusCode): \(errorString.prefix(200))")
            throw SonetelAPIError.networkError("API error \(httpResponse.statusCode)")
        }
    }

    /// Filter call records by type
    private func filterCallRecords(_ records: [CallRecord], by type: String) -> [CallRecord] {
        switch type.lowercased() {
        case "inbound", "incoming":
            return records.filter { $0.callType == .incoming || $0.callType == .missed }
        case "outbound", "outgoing":
            return records.filter { $0.callType == .outgoing }
        case "all":
            return records
        default:
            return records
        }
    }

    /// Get call recordings (for the recordings view)
    func getCallRecordings(
        dateFrom: Date? = nil,
        dateTo: Date? = nil
    ) async throws -> [CallRecording] {
        if isDummyDataMode {
            print("🎭 SonetelAPIService: Returning dummy call recordings")
            return getDummyCallRecordings()
        }

        let token = try await getValidToken()
        let accountId = extractAccountId()

        guard !accountId.isEmpty else {
            throw SonetelAPIError.networkError("No account ID available")
        }

        return try await getCallRecordingsFromAPI(token: token, accountId: accountId, dateFrom: dateFrom, dateTo: dateTo)
    }

    /// Get detailed information for a specific call recording
    func getCallRecordingDetails(recordingId: String) async throws -> CallRecordingDetails? {
        if isDummyDataMode {
            print("🎭 SonetelAPIService: Returning dummy recording details")
            return CallRecordingDetails(
                call_recording_id: recordingId,
                summary: "During this call, the participants discussed the next steps for the upcoming product launch. Key issues with the checkout process were identified where users are dropping off at the payment page.",
                transcript: "Participant A (0:01): Hi there, how's everything going on your end?\n\nParticipant B (0:23): Hey, it's going well, thanks. We're just wrapping up some final tests for the new product line. I wanted to discuss the next steps for our upcoming launch.\n\nParticipant A (0:38): Great to hear! So, I was thinking we could start by reviewing the user testing results you mentioned last week. Have you had a chance to look at them?\n\nParticipant B (0:57): Yes, I've reviewed the results, and there are a few key areas where we're getting stuck. Mainly in the checkout process; users seem to drop off when they reach the payment page.",
                analysis: "The call focused on product launch planning and identified critical UX issues in the checkout flow that need immediate attention."
            )
        }

        let token = try await getValidToken()
        let accountId = extractAccountId()

        guard !accountId.isEmpty else {
            throw SonetelAPIError.networkError("No account ID available")
        }

        return try await getCallRecordingDetailsFromAPI(token: token, accountId: accountId, recordingId: recordingId)
    }

    /// Get call recording details from the API
    private func getCallRecordingDetailsFromAPI(
        token: String,
        accountId: String,
        recordingId: String
    ) async throws -> CallRecordingDetails? {
        // Try to get call summary first
        if let summary = try await getCallSummary(token: token, accountId: accountId, recordingId: recordingId) {
            return summary
        }

        // Fallback to individual recording details
        let url = URL(string: "\(baseURL)/call-recording/\(recordingId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🎙️ API: Getting call recording details for ID: \(recordingId)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SonetelAPIError.networkError("Invalid response type")
        }

        print("🎙️ API: Call recording details response status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 404 {
            print("🎙️ API: Recording not found")
            return nil
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API: Call recording details error: \(errorMessage)")
            throw SonetelAPIError.networkError("Failed to get recording details: \(httpResponse.statusCode)")
        }

        do {
            let recordingDetails = try JSONDecoder().decode(CallRecordingDetails.self, from: data)
            print("✅ API: Successfully decoded call recording details")
            return recordingDetails
        } catch {
            print("❌ API: Failed to decode call recording details: \(error)")
            // Return nil if decoding fails - the recording exists but doesn't have additional details
            return nil
        }
    }

    /// Get call summary from the call_summary endpoint
    private func getCallSummary(
        token: String,
        accountId: String,
        recordingId: String
    ) async throws -> CallRecordingDetails? {
        let url = URL(string: "\(baseURL)/call_summary/\(recordingId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🎙️ API: Getting call summary for recording ID: \(recordingId)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SonetelAPIError.networkError("Invalid response type")
        }

        print("🎙️ API: Call summary response status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 404 {
            print("🎙️ API: Call summary not found for recording")
            return nil
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API: Call summary error: \(errorMessage)")
            return nil // Don't throw error, just return nil to try other methods
        }

        do {
            // Parse the call summary response
            let summaryResponse = try JSONDecoder().decode(CallSummaryResponse.self, from: data)
            print("✅ API: Successfully decoded call summary")

            return CallRecordingDetails(
                call_recording_id: recordingId,
                summary: summaryResponse.summary,
                transcript: summaryResponse.transcript,
                analysis: summaryResponse.analysis
            )
        } catch {
            print("❌ API: Failed to decode call summary: \(error)")
            return nil
        }
    }



    /// Get call recordings from the Call Recording API
    private func getCallRecordingsFromAPI(
        token: String,
        accountId: String,
        dateFrom: Date?,
        dateTo: Date?
    ) async throws -> [CallRecording] {
        var components = URLComponents(string: "\(baseURL)/call-recording")!

        var queryItems = [
            URLQueryItem(name: "account_id", value: accountId),
            URLQueryItem(name: "type", value: "voice_call"),
            URLQueryItem(name: "fields", value: "voice_call_details")
        ]

        // Add date range filters
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let dateFrom = dateFrom {
            queryItems.append(URLQueryItem(name: "created_date_min", value: dateFormatter.string(from: dateFrom)))
        }

        if let dateTo = dateTo {
            queryItems.append(URLQueryItem(name: "created_date_max", value: dateFormatter.string(from: dateTo)))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw SonetelAPIError.networkError("Invalid URL for call recordings")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🔍 SonetelAPI: Fallback - Fetching call recordings from: \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw SonetelAPIError.invalidResponse
            }

            print("📞 SonetelAPI: Call recordings response status: \(httpResponse.statusCode)")

            // Log response body for debugging
            let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("📝 SonetelAPI: Call recordings response: \(responseBody)")

            if httpResponse.statusCode == 401 {
                throw SonetelAPIError.unauthorizedAccess
            }

            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw SonetelAPIError.networkError("Call recordings request failed: \(errorMessage)")
            }

            // Parse the Call Recording response
            let callRecordingResponse = try JSONDecoder().decode(CallRecordingResponse.self, from: data)

            print("✅ SonetelAPI: Successfully fetched \(callRecordingResponse.response.count) call recordings")

            // Return the raw recordings
            return callRecordingResponse.response.sorted { recording1, recording2 in
                let date1 = self.parseRecordingDate(recording1.created_date) ?? Date.distantPast
                let date2 = self.parseRecordingDate(recording2.created_date) ?? Date.distantPast
                return date1 > date2
            }

        } catch let error as SonetelAPIError {
            throw error
        } catch {
            print("❌ SonetelAPI: Call recordings fetch error: \(error)")
            throw SonetelAPIError.networkError("Failed to fetch call recordings: \(error.localizedDescription)")
        }
    }





    /// Format call duration
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60

        if minutes > 0 {
            return "\(minutes)min \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }

    /// Generate contact name from phone number
    private func generateContactName(from phoneNumber: String) -> String {
        // This is a simple implementation - in a real app you might:
        // 1. Look up the number in the user's contacts
        // 2. Use a reverse phone lookup service
        // 3. Check if it's a known business number

        // For now, return the phone number formatted nicely
        // Check for known patterns
        if phoneNumber.hasPrefix("+46") {
            return "Swedish Number"
        } else if phoneNumber.hasPrefix("+1") {
            return "US/Canada Number"
        } else {
            return phoneNumber
        }
    }

    // MARK: - Helper Methods

    /// Get stored user ID from JWT token
    private func getStoredUserId() -> String {
        guard let token = accessToken else {
            return ""
        }

        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            return ""
        }

        let payload = parts[1]
        var paddedPayload = payload
        let paddingLength = 4 - (payload.count % 4)
        if paddingLength != 4 {
            paddedPayload += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: paddedPayload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userId = json["user_id"] as? String else {
            return ""
        }

        return userId
    }

    /// Get stored account ID from cached account info or JWT token
    private func extractAccountId() -> String {
        // First try from cached account info
        if let cachedAccountInfo = cachedAccountInfoFromToken {
            return cachedAccountInfo.account_id
        }

        // Fallback to extracting from JWT token
        guard let token = accessToken else {
            return ""
        }

        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            return ""
        }

        let payload = parts[1]
        var paddedPayload = payload
        let paddingLength = 4 - (payload.count % 4)
        if paddingLength != 4 {
            paddedPayload += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: paddedPayload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accId = json["acc_id"] as? Int else {
            return ""
        }

        return String(accId)
    }

    // MARK: - Token Management

    /// Get call settings for the current user
    func getCallSettings() async throws -> CallSettings {
        let token = try await getValidToken()
        let accountId = extractAccountId()
        let userId = getStoredUserId()

        let url = URL(string: "\(baseURL)/account/\(accountId)/user/\(userId)/call")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🔧 SonetelAPI: Fetching call settings from \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 SonetelAPI: Call settings response status: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 200 {
                    // Try to decode the real Sonetel API response
                    do {
                        let sonetelResponse = try JSONDecoder().decode(SonetelCallSettingsResponse.self, from: data)

                        if sonetelResponse.status == "success" {
                            let callSettings = CallSettings.from(sonetelData: sonetelResponse.response)
                            print("✅ SonetelAPI: Successfully fetched call settings from Sonetel API")
                            return callSettings
                        } else {
                            print("⚠️ SonetelAPI: Sonetel API returned status: \(sonetelResponse.status)")
                            return CallSettings.defaultSettings
                        }
                    } catch {
                        print("❌ SonetelAPI: Failed to decode Sonetel response: \(error)")
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("🔍 SonetelAPI: Raw response: \(responseString)")
                        }
                        return CallSettings.defaultSettings
                    }
                } else if httpResponse.statusCode == 404 {
                    // User might not have settings configured yet, return defaults
                    print("⚠️ SonetelAPI: No call settings found, returning defaults")
                    return CallSettings.defaultSettings
                } else {
                    print("❌ SonetelAPI: Failed to get call settings with status: \(httpResponse.statusCode)")
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("Error response: \(errorData)")
                    }
                    throw SonetelAPIError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }

            throw SonetelAPIError.invalidResponse
        } catch {
            print("❌ SonetelAPI: Error fetching call settings: \(error)")
            // Return default settings if API fails
            return CallSettings.defaultSettings
        }
    }

    /// Try updating outgoing caller ID with different approaches
    func updateOutgoingCallerIdOnly(show: String) async throws -> CallSettings {
        let token = try await getValidToken()
        let accountId = extractAccountId()
        let userId = getStoredUserId()

        // Try multiple approaches
        let approaches = [
            ("PUT with full structure", "PUT", [
                "outgoing": [
                    "show": show,
                    "call_method": "internet",
                    "select_method_per_call": false
                ]
            ]),
            ("PATCH with show only", "PATCH", [
                "outgoing": ["show": show]
            ]),
            ("PUT with show only", "PUT", [
                "show": show
            ]),
            ("POST with show parameter", "POST", [
                "outgoing_show": show
            ])
        ]

        for (description, method, requestBody) in approaches {
            print("🔧 SonetelAPI: Trying \(description)")

            let url = URL(string: "\(baseURL)/account/\(accountId)/user/\(userId)/call")!
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData

            if let requestString = String(data: jsonData, encoding: .utf8) {
                print("🔧 SonetelAPI: \(method) request: \(requestString)")
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 SonetelAPI: \(description) response status: \(httpResponse.statusCode)")

                    if let responseString = String(data: data, encoding: .utf8) {
                        print("🔍 SonetelAPI: \(description) response: \(responseString)")

                        // Check for success/failed in response
                        if responseString.contains("\"status\":\"success\"") {
                            print("✅ SonetelAPI: \(description) succeeded!")
                            return try await getCallSettings()
                        } else if responseString.contains("\"status\":\"failed\"") {
                            print("❌ SonetelAPI: \(description) failed, trying next approach...")
                            continue // Try next approach
                        }
                    }

                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        print("✅ SonetelAPI: \(description) got success status code")
                        return try await getCallSettings()
                    } else {
                        print("❌ SonetelAPI: \(description) failed with HTTP \(httpResponse.statusCode)")
                        continue // Try next approach
                    }
                }
            } catch {
                print("❌ SonetelAPI: \(description) error: \(error)")
                continue // Try next approach
            }
        }

        // If all approaches failed
        print("❌ SonetelAPI: All update approaches failed")
        throw SonetelAPIError.authenticationFailed("All update methods failed")
    }

    /// Try updating incoming caller ID with different approaches
    func updateIncomingCallerIdOnly(show: String) async throws -> CallSettings {
        let token = try await getValidToken()
        let accountId = extractAccountId()
        let userId = getStoredUserId()

        // Try multiple approaches for incoming
        let approaches = [
            ("PATCH with nested structure", "PATCH", [
                "incoming": ["first_action": ["show": show]]
            ]),
            ("PUT with incoming show", "PUT", [
                "incoming": ["show": show]
            ]),
            ("POST with simple parameter", "POST", [
                "incoming_show": show
            ]),
            ("PATCH with direct show", "PATCH", [
                "show": show
            ])
        ]

        for (description, method, requestBody) in approaches {
            print("🔧 SonetelAPI: Trying incoming \(description)")

            let url = URL(string: "\(baseURL)/account/\(accountId)/user/\(userId)/call")!
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData

            if let requestString = String(data: jsonData, encoding: .utf8) {
                print("🔧 SonetelAPI: Incoming \(method) request: \(requestString)")
            }

            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 SonetelAPI: Incoming \(description) response status: \(httpResponse.statusCode)")

                    if let responseString = String(data: data, encoding: .utf8) {
                        print("🔍 SonetelAPI: Incoming \(description) response: \(responseString)")

                        if responseString.contains("\"status\":\"success\"") {
                            print("✅ SonetelAPI: Incoming \(description) succeeded!")
                            return try await getCallSettings()
                        } else if responseString.contains("\"status\":\"failed\"") {
                            print("❌ SonetelAPI: Incoming \(description) failed, trying next...")
                            continue
                        }
                    }

                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        print("✅ SonetelAPI: Incoming \(description) got success status")
                        return try await getCallSettings()
                    } else {
                        continue
                    }
                }
            } catch {
                print("❌ SonetelAPI: Incoming \(description) error: \(error)")
                continue
            }
        }

        print("❌ SonetelAPI: All incoming update approaches failed")
        throw SonetelAPIError.authenticationFailed("All incoming update methods failed")
    }

    /// Update call settings for the current user (alternative method)
    func updateCallerIdSettings(outgoingCli: String?, incomingCli: String?) async throws -> CallSettings {
        let token = try await getValidToken()
        let accountId = extractAccountId()
        let userId = getStoredUserId()

        let url = URL(string: "\(baseURL)/account/\(accountId)/user/\(userId)/call")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH" // Try PATCH method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create a simple dictionary for the request
        var requestBody: [String: Any] = [:]
        if let outgoingCli = outgoingCli {
            requestBody["outgoing_cli"] = outgoingCli
        }
        if let incomingCli = incomingCli {
            requestBody["incoming_cli"] = incomingCli
        }

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = jsonData

        // Debug: Print the request body
        if let requestString = String(data: jsonData, encoding: .utf8) {
            print("🔧 SonetelAPI: PATCH request body: \(requestString)")
        }

        print("🔧 SonetelAPI: Updating call settings with PATCH at \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 SonetelAPI: PATCH update response status: \(httpResponse.statusCode)")

                // Debug: Print response body
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 SonetelAPI: PATCH response body: \(responseString)")
                }

                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    // Check if the response indicates success or failure
                    if let responseString = String(data: data, encoding: .utf8) {
                        if responseString.contains("\"status\":\"failed\"") {
                            print("❌ SonetelAPI: Update failed - API returned status: failed")
                            throw SonetelAPIError.authenticationFailed("API returned failed status")
                        }
                    }

                    print("�� SonetelAPI: Successfully updated call settings with PATCH")
                    // Fetch the updated settings to verify
                    return try await getCallSettings()
                } else {
                    print("❌ SonetelAPI: PATCH failed with status: \(httpResponse.statusCode)")
                    throw SonetelAPIError.networkError("PATCH HTTP \(httpResponse.statusCode)")
                }
            }

            throw SonetelAPIError.invalidResponse
        } catch {
            print("❌ SonetelAPI: PATCH Error: \(error)")
            throw error
        }
    }

    /// Update call settings for the current user
    func updateCallSettings(_ settings: UpdateCallSettingsRequest) async throws -> CallSettings {
        let token = try await getValidToken()
        let accountId = extractAccountId()
        let userId = getStoredUserId()

        let url = URL(string: "\(baseURL)/account/\(accountId)/user/\(userId)/call")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Try POST instead of PUT
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(settings)

        // Debug: Print the request body
        if let requestBody = request.httpBody,
           let requestString = String(data: requestBody, encoding: .utf8) {
            print("🔧 SonetelAPI: Update request body: \(requestString)")
        }

        print("🔧 SonetelAPI: Updating call settings at \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📊 SonetelAPI: Update call settings response status: \(httpResponse.statusCode)")

                // Debug: Print response body for any status
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔍 SonetelAPI: Update response body: \(responseString)")
                }

                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    // Some APIs return 204 No Content on successful update
                    if httpResponse.statusCode == 204 {
                        print("✅ SonetelAPI: Successfully updated call settings (no content)")
                        // Return the updated settings by fetching them again
                        return try await getCallSettings()
                    }

                    // Try to decode response
                    if let settings = try? JSONDecoder().decode(CallSettings.self, from: data) {
                        print("✅ SonetelAPI: Successfully updated call settings (direct)")
                        return settings
                    } else if let settingsResponse = try? JSONDecoder().decode(CallSettingsResponse.self, from: data) {
                        print("✅ SonetelAPI: Successfully updated call settings (wrapped)")
                        return settingsResponse.response.settings
                    } else {
                        print("✅ SonetelAPI: Update successful, fetching current settings")
                        return try await getCallSettings()
                    }
                } else {
                    print("❌ SonetelAPI: Failed to update call settings with status: \(httpResponse.statusCode)")
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("❌ SonetelAPI: Error response body: \(errorData)")
                    }

                    // Try to parse error response
                    if let errorResponse = try? JSONDecoder().decode(SonetelErrorResponse.self, from: data) {
                        print("❌ SonetelAPI: Error details: \(errorResponse.error)")
                        throw SonetelAPIError.authenticationFailed(errorResponse.error_description ?? errorResponse.error)
                    }

                    throw SonetelAPIError.networkError("HTTP \(httpResponse.statusCode): Update failed")
                }
            }

            throw SonetelAPIError.invalidResponse
        } catch {
            print("❌ SonetelAPI: Error updating call settings: \(error)")
            throw error
        }
    }

    /// Get a valid access token, refreshing if necessary
    private func getValidToken() async throws -> String {
        // Check if we have a token and it's not expired
        if let token = accessToken {
            // Simple check - in production you'd want to validate token expiry
            return token
        }

        // Try to get from UserDefaults
        if let storedToken = UserDefaults.standard.string(forKey: "sonetel_access_token") {
            accessToken = storedToken
            return storedToken
        }

        throw SonetelAPIError.noValidToken
    }

    /// Clear stored tokens and all authentication data
    func clearTokens() {
        print("🗑��� Clearing all stored authentication tokens")
        accessToken = nil
        refreshToken = nil
        tokenExpiryDate = nil

        // Also clear from UserDefaults explicitly
        UserDefaults.standard.removeObject(forKey: "sonetel_access_token")
        UserDefaults.standard.removeObject(forKey: "sonetel_refresh_token")
        UserDefaults.standard.removeObject(forKey: "sonetel_token_expiry")
        UserDefaults.standard.synchronize()
    }

    /// Extract account information from JWT token
    private func extractAccountInfoFromJWT(_ token: String) -> AccountInfo? {
        print("🔍 SonetelAPI: Starting JWT token extraction...")
        print("🔍 SonetelAPI: Token length: \(token.count)")

        // JWT tokens have 3 parts separated by dots: header.payload.signature
        let parts = token.components(separatedBy: ".")
        print("🔍 SonetelAPI: JWT parts count: \(parts.count)")

        guard parts.count == 3 else {
            print("❌ SonetelAPI: Invalid JWT token format - expected 3 parts, got \(parts.count)")
            return nil
        }

        // Decode the payload (second part)
        let payload = parts[1]
        print("🔍 SonetelAPI: JWT payload part length: \(payload.count)")
        print("🔍 SonetelAPI: JWT payload (first 50 chars): \(payload.prefix(50))...")

        // Add padding if needed for base64 decoding
        var paddedPayload = payload
        let paddingLength = 4 - (payload.count % 4)
        if paddingLength != 4 {
            paddedPayload += String(repeating: "=", count: paddingLength)
            print("🔍 SonetelAPI: Added \(paddingLength) padding characters for base64 decoding")
        }

        // Decode base64
        guard let data = Data(base64Encoded: paddedPayload) else {
            print("❌ SonetelAPI: Failed to decode base64 payload")
            return nil
        }

        print("✅ SonetelAPI: Successfully decoded base64 payload, data size: \(data.count) bytes")

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ SonetelAPI: Failed to parse JSON from decoded payload")
            return nil
        }

        print("✅ SonetelAPI: Successfully parsed JWT JSON")
        print("🔍 SonetelAPI: JWT payload keys: \(Array(json.keys))")
        print("�� SonetelAPI: JWT payload: \(json)")

        // Extract account info from JWT payload
        let userId = json["user_id"] as? String ?? ""
        let userName = json["user_name"] as? String ?? ""
        let accId = json["acc_id"] as? Int
        let scope = json["scope"] as? [String] ?? []

        print("🔍 SonetelAPI: Extracted values:")
        print("   - user_id: \(userId)")
        print("   - user_name: \(userName)")
        print("   - acc_id: \(accId ?? -1)")
        print("   - scope: \(scope)")

        let accountInfo = AccountInfo(
            account_id: accId != nil ? String(accId!) : "unknown",
            currency: "USD", // Default, will be updated from API if available
            prepaid_balance: nil,
            country: nil,
            email: userName.isEmpty ? nil : userName,
            name: nil, // Will try to get from API
            company_name: nil, // Will try to get from API
            phone_number: nil,
            verified: true, // JWT token implies verification
            created_at: nil,
            updated_at: nil
        )

        print("✅ SonetelAPI: Created account info from JWT:")
        print("   - Account ID: \(accountInfo.account_id)")
        print("   - Email: \(accountInfo.email ?? "none")")
        print("   - Currency: \(accountInfo.currency)")
        print("   - Verified: \(accountInfo.verified ?? false)")

        return accountInfo
    }

    // MARK: - Dummy Data Mode

    private var _isDummyDataMode: Bool = false

    var isDummyDataMode: Bool {
        return _isDummyDataMode
    }

    func enableDummyDataMode() {
        _isDummyDataMode = true
        print("🎭 SonetelAPIService: Dummy data mode enabled")
    }

    func disableDummyDataMode() {
        _isDummyDataMode = false
        print("🔧 SonetelAPIService: Dummy data mode disabled")
    }

    private func getDummyCallRecordings() -> [CallRecording] {
        return [
            CallRecording(
                call_recording_id: "rec_001",
                call_id: "call_001",
                type: "voice_call",
                account_id: 999999999,
                user_id: "user_demo",
                created_date: "20250104T110900Z",
                expiry_date: "20250204T110900Z",
                voice_call_details: VoiceCallDetails(
                    from: "anna@company.com",
                    to: "mark@company.com",
                    codec: "PCMU",
                    direction: "outbound",
                    usage_record_id: 1001,
                    start_time: "20250104T110900Z",
                    end_time: "20250104T111032Z",
                    call_length: 92,
                    from_type: "user",
                    from_name: "Anna Johnson",
                    caller_id: "+1234567890",
                    to_type: "user",
                    to_name: "Mark Wilson",
                    to_orig: "mark@company.com"
                ),
                is_transcribed: true
            ),
            CallRecording(
                call_recording_id: "rec_002",
                call_id: "call_002",
                type: "voice_call",
                account_id: 999999999,
                user_id: "user_demo",
                created_date: "20250103T143000Z",
                expiry_date: "20250203T143000Z",
                voice_call_details: VoiceCallDetails(
                    from: "demo@sonetel.com",
                    to: "+46856485160",
                    codec: "PCMU",
                    direction: "outbound",
                    usage_record_id: 1002,
                    start_time: "20250103T143000Z",
                    end_time: "20250103T143245Z",
                    call_length: 165,
                    from_type: "user",
                    from_name: "Demo User",
                    caller_id: "+1234567890",
                    to_type: "phonenumber",
                    to_name: "+46856485160",
                    to_orig: "+46856485160"
                ),
                is_transcribed: true
            ),
            CallRecording(
                call_recording_id: "rec_003",
                call_id: "call_003",
                type: "voice_call",
                account_id: 999999999,
                user_id: "user_demo",
                created_date: "20250102T095500Z",
                expiry_date: "20250202T095500Z",
                voice_call_details: VoiceCallDetails(
                    from: "+14155552345",
                    to: "demo@sonetel.com",
                    codec: "PCMU",
                    direction: "inbound",
                    usage_record_id: 1003,
                    start_time: "20250102T095500Z",
                    end_time: "20250102T100120Z",
                    call_length: 380,
                    from_type: "phonenumber",
                    from_name: "+14155552345",
                    caller_id: "+14155552345",
                    to_type: "user",
                    to_name: "Demo User",
                    to_orig: "demo@sonetel.com"
                ),
                is_transcribed: true
            )
        ]
    }

    private func getDummyUsageRecords() -> [UsageRecord] {
        return [
            UsageRecord(
                record_id: "usage_001",
                timestamp: "2025/01/04T11:09:00Z",
                service: "outbound_call",
                account_id: "999999999",
                usage_details: UsageDetails(
                    call: CallUsageDetails(
                        start_time: "2025/01/04T11:09:00Z",
                        end_time: "2025/01/04T11:10:32Z",
                        call_length: "92",
                        from_type: "user",
                        from: "demo@sonetel.com",
                        caller_id: "+1234567890",
                        to_type: "user",
                        to: "anna@company.com",
                        to_orig: "anna@company.com",
                        app_type: "app"
                    ),
                    ai_credits: nil,
                    phnumsubscription: nil,
                    priceplan: nil
                ),
                charges: UsageCharges(
                    priceplan: "basic",
                    currency: "USD",
                    count: "1",
                    usage_fixed: "0.00",
                    usage_time: "0.05",
                    subscription_setup: "0.00",
                    subscription_recurring: "0.00",
                    usage_vat: "0.01",
                    renew_mode: "auto",
                    ai_credits_usage: nil,
                    charge_category: "call"
                )
            ),
            UsageRecord(
                record_id: "usage_002",
                timestamp: "2025/01/03T14:30:00Z",
                service: "outbound_call",
                account_id: "999999999",
                usage_details: UsageDetails(
                    call: CallUsageDetails(
                        start_time: "2025/01/03T14:30:00Z",
                        end_time: "2025/01/03T14:32:45Z",
                        call_length: "165",
                        from_type: "user",
                        from: "demo@sonetel.com",
                        caller_id: "+1234567890",
                        to_type: "phonenumber",
                        to: "+46856485160",
                        to_orig: "+46856485160",
                        app_type: "app"
                    ),
                    ai_credits: nil,
                    phnumsubscription: nil,
                    priceplan: nil
                ),
                charges: UsageCharges(
                    priceplan: "basic",
                    currency: "USD",
                    count: "1",
                    usage_fixed: "0.00",
                    usage_time: "0.08",
                    subscription_setup: "0.00",
                    subscription_recurring: "0.00",
                    usage_vat: "0.02",
                    renew_mode: "auto",
                    ai_credits_usage: nil,
                    charge_category: "call"
                )
            ),
            UsageRecord(
                record_id: "usage_003",
                timestamp: "2025/01/02T09:55:00Z",
                service: "inbound_call",
                account_id: "999999999",
                usage_details: UsageDetails(
                    call: CallUsageDetails(
                        start_time: "2025/01/02T09:55:00Z",
                        end_time: "2025/01/02T10:01:20Z",
                        call_length: "380",
                        from_type: "phonenumber",
                        from: "+14155552345",
                        caller_id: "+14155552345",
                        to_type: "user",
                        to: "demo@sonetel.com",
                        to_orig: "demo@sonetel.com",
                        app_type: "app"
                    ),
                    ai_credits: nil,
                    phnumsubscription: nil,
                    priceplan: nil
                ),
                charges: UsageCharges(
                    priceplan: "basic",
                    currency: "USD",
                    count: "1",
                    usage_fixed: "0.00",
                    usage_time: "0.00",
                    subscription_setup: "0.00",
                    subscription_recurring: "0.00",
                    usage_vat: "0.00",
                    renew_mode: "auto",
                    ai_credits_usage: nil,
                    charge_category: "call"
                )
            )
        ]
    }
}

// MARK: - Data Models

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String?
    let expires_in: Int?
    let refresh_token: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case access_token
        case token_type
        case expires_in
        case refresh_token
        case scope
        // Alternative names
        case accessToken
        case tokenType
        case expiresIn
        case refreshToken
    }

    init(access_token: String, token_type: String? = "Bearer", expires_in: Int? = 86400, refresh_token: String? = nil, scope: String? = nil) {
        self.access_token = access_token
        self.token_type = token_type
        self.expires_in = expires_in
        self.refresh_token = refresh_token
        self.scope = scope
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(access_token, forKey: .access_token)
        try container.encodeIfPresent(token_type, forKey: .token_type)
        try container.encodeIfPresent(expires_in, forKey: .expires_in)
        try container.encodeIfPresent(refresh_token, forKey: .refresh_token)
        try container.encodeIfPresent(scope, forKey: .scope)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try different possible property names for access_token
        if let accessToken = try container.decodeIfPresent(String.self, forKey: .access_token) {
            self.access_token = accessToken
        } else if let accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) {
            self.access_token = accessToken
        } else {
            throw DecodingError.keyNotFound(CodingKeys.access_token,
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Missing access_token in response"))
        }

        // Try different possible property names for other fields
        self.token_type = try container.decodeIfPresent(String.self, forKey: .token_type) ??
                         (try container.decodeIfPresent(String.self, forKey: .tokenType))

        self.expires_in = try container.decodeIfPresent(Int.self, forKey: .expires_in) ??
                         (try container.decodeIfPresent(Int.self, forKey: .expiresIn)) ?? 86400 // Default 24 hours

        self.refresh_token = try container.decodeIfPresent(String.self, forKey: .refresh_token) ??
                            (try container.decodeIfPresent(String.self, forKey: .refreshToken))

        self.scope = try container.decodeIfPresent(String.self, forKey: .scope)
    }
}

struct AccountInfo: Codable {
    let account_id: String
    let currency: String
    let prepaid_balance: Double?
    let country: String?
    let email: String?
    let name: String?
    let company_name: String?
    let phone_number: String?
    let verified: Bool?
    let created_at: String?
    let updated_at: String?

    init(account_id: String, currency: String, prepaid_balance: Double? = nil, country: String? = nil, email: String? = nil, name: String? = nil, company_name: String? = nil, phone_number: String? = nil, verified: Bool? = nil, created_at: String? = nil, updated_at: String? = nil) {
        self.account_id = account_id
        self.currency = currency
        self.prepaid_balance = prepaid_balance
        self.country = country
        self.email = email
        self.name = name
        self.company_name = company_name
        self.phone_number = phone_number
        self.verified = verified
        self.created_at = created_at
        self.updated_at = updated_at
    }
}

struct SonetelUserProfile: Codable {
    let user_id: String
    let email: String?
    let first_name: String?
    let last_name: String?
    let full_name: String?
    let company: String?
    let title: String?
    let phone: String?
    let mobile: String?
    let department: String?
    let role: String?
    let status: String?
    let timezone: String?
    let language: String?
    let avatar_url: String?
    let last_login: String?
    let created_at: String?
    let updated_at: String?

    // Custom initializer with default values
    init(user_id: String, email: String? = nil, first_name: String? = nil, last_name: String? = nil, full_name: String? = nil, company: String? = nil, title: String? = nil, phone: String? = nil, mobile: String? = nil, department: String? = nil, role: String? = nil, status: String? = nil, timezone: String? = nil, language: String? = nil, avatar_url: String? = nil, last_login: String? = nil, created_at: String? = nil, updated_at: String? = nil) {
        self.user_id = user_id
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.full_name = full_name
        self.company = company
        self.title = title
        self.phone = phone
        self.mobile = mobile
        self.department = department
        self.role = role
        self.status = status
        self.timezone = timezone
        self.language = language
        self.avatar_url = avatar_url
        self.last_login = last_login
        self.created_at = created_at
        self.updated_at = updated_at
    }
}

struct SonetelPhoneNumber: Codable, Identifiable {
    let id = UUID()
    let number: String
    let label: String?
    let country: String?
    let location: String?
    let status: String?
    let type: String?
    let created_at: String?
    let updated_at: String?

    enum CodingKeys: String, CodingKey {
        case number
        case label
        case country
        case location
        case status
        case type
        case created_at
        case updated_at
        // Alternative names
        case phone_number
        case name
        case country_code
        case city
    }

    init(number: String, label: String? = nil, country: String? = nil, location: String? = nil, status: String? = nil, type: String? = nil, created_at: String? = nil, updated_at: String? = nil) {
        self.number = number
        self.label = label
        self.country = country
        self.location = location
        self.status = status
        self.type = type
        self.created_at = created_at
        self.updated_at = updated_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Try different possible property names for number
        if let number = try container.decodeIfPresent(String.self, forKey: .number) {
            self.number = number
        } else if let phoneNumber = try container.decodeIfPresent(String.self, forKey: .phone_number) {
            self.number = phoneNumber
        } else {
            throw DecodingError.keyNotFound(CodingKeys.number,
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Missing number field in phone number response"))
        }

        // Try different possible property names for other fields
        self.label = try container.decodeIfPresent(String.self, forKey: .label) ??
                    (try container.decodeIfPresent(String.self, forKey: .name))

        self.country = try container.decodeIfPresent(String.self, forKey: .country) ??
                      (try container.decodeIfPresent(String.self, forKey: .country_code))

        self.location = try container.decodeIfPresent(String.self, forKey: .location) ??
                       (try container.decodeIfPresent(String.self, forKey: .city))

        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        self.updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(created_at, forKey: .created_at)
        try container.encodeIfPresent(updated_at, forKey: .updated_at)
    }

    // Helper methods for UI
    var displayLabel: String {
        if let label = label, !label.isEmpty {
            return label
        }

        if let location = location, !location.isEmpty {
            return location
        }

        return number
    }

    var cleanDisplayLabel: String {
        if let label = label, !label.isEmpty, !label.hasPrefix("+") {
            // Remove area code patterns from label as well
            var cleanLabel = label.replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            cleanLabel = cleanLabel.replacingOccurrences(of: #",\s*$"#, with: "", options: .regularExpression)
            return cleanLabel.trimmingCharacters(in: .whitespaces)
        }

        if let location = location, !location.isEmpty {
            // Remove area code patterns like "(917)", "(Stockholm)", etc.
            var cleanLocation = location.replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            // Also remove any trailing commas and whitespace
            cleanLocation = cleanLocation.replacingOccurrences(of: #",\s*$"#, with: "", options: .regularExpression)
            return cleanLocation.trimmingCharacters(in: .whitespaces)
        }

        return number
    }

    var flagEmoji: String {
        guard let country = country else { return "🌍" }

        switch country.uppercased() {
        case "SE", "SWE": return "🇸🇪"
        case "US", "USA": return "🇺🇸"
        case "GB", "UK": return "🇬🇧"
        case "DE", "DEU": return "🇩🇪"
        case "FR", "FRA": return "🇫🇷"
        case "NO", "NOR": return "🇳🇴"
        case "DK", "DNK": return "🇩🇰"
        case "FI", "FIN": return "🇫🇮"
        case "NL", "NET": return "🇳🇱"
        case "CH", "CHE": return "🇨🇭"
        case "AT", "AUT": return "🇦🇹"
        case "BE", "BEL": return "🇧🇪"
        case "IT", "ITA": return "🇮🇹"
        case "ES", "ESP": return "🇪🇸"
        default: return "🌍"
        }
    }

    var isActive: Bool {
        return status?.lowercased() == "active"
    }

    var flagImageURL: String {
        guard let country = country else { return "" }
        return "https://flagcdn.com/w80/\(country.lowercased()).png"
    }
}

struct SonetelErrorResponse: Codable {
    let error: String
    let error_description: String?
}

// MARK: - Error Types

enum SonetelAPIError: LocalizedError {
    case invalidResponse
    case authenticationFailed(String)
    case noRefreshToken
    case tokenRefreshFailed
    case unauthorizedAccess
    case networkError(String)
    case noValidToken

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationFailed(let message):
            return message
        case .noRefreshToken:
            return "No refresh token available"
        case .tokenRefreshFailed:
            return "Failed to refresh access token"
        case .unauthorizedAccess:
            return "Unauthorized access - please log in again"
        case .networkError(let message):
            return message
        case .noValidToken:
            return "No valid authentication token"
        }
    }
    }

    // MARK: - Helper Methods

    /// Extract country code from phone number
    private func extractCountryCodeFromNumber(_ number: String) -> String? {
        let cleanNumber = number.replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: "-", with: "")
                                .replacingOccurrences(of: "(", with: "")
                                .replacingOccurrences(of: ")", with: "")

        // Common country codes and their patterns
        if cleanNumber.hasPrefix("+1") { return "US" }
        if cleanNumber.hasPrefix("+46") { return "SE" }
        if cleanNumber.hasPrefix("+44") { return "GB" }
        if cleanNumber.hasPrefix("+49") { return "DE" }
        if cleanNumber.hasPrefix("+33") { return "FR" }
        if cleanNumber.hasPrefix("+47") { return "NO" }
        if cleanNumber.hasPrefix("+45") { return "DK" }
        if cleanNumber.hasPrefix("+358") { return "FI" }
        if cleanNumber.hasPrefix("+31") { return "NL" }
        if cleanNumber.hasPrefix("+41") { return "CH" }
        if cleanNumber.hasPrefix("+43") { return "AT" }
        if cleanNumber.hasPrefix("+32") { return "BE" }
        if cleanNumber.hasPrefix("+39") { return "IT" }
        if cleanNumber.hasPrefix("+34") { return "ES" }

        return nil
    }

// MARK: - Call Recording API Models

struct CallRecordingResponse: Codable {
    let resource: String
    let status: String
    let response: [CallRecording]
}

struct CallRecording: Codable {
    let call_recording_id: String
    let call_id: String
    let type: String
    let account_id: Int
    let user_id: String
    let created_date: String
    let expiry_date: String?
    let voice_call_details: VoiceCallDetails
    let is_transcribed: Bool
}

struct VoiceCallDetails: Codable {
    let from: String
    let to: String
    let codec: String
    let direction: String
    let usage_record_id: Int
    let start_time: String
    let end_time: String
    let call_length: Int // in seconds
    let from_type: String
    let from_name: String
    let caller_id: String
    let to_type: String
    let to_name: String
    let to_orig: String
}

struct CallRecordingDetails: Codable {
    let call_recording_id: String
    let summary: String?
    let transcript: String?
    let analysis: String?

    init(call_recording_id: String, summary: String? = nil, transcript: String? = nil, analysis: String? = nil) {
        self.call_recording_id = call_recording_id
        self.summary = summary
        self.transcript = transcript
        self.analysis = analysis
    }
}

struct CallSummaryResponse: Codable {
    let call_recording_id: String?
    let summary: String?
    let transcript: String?
    let analysis: String?
    let status: String?
}

// MARK: - Usage Records API Models

struct UsageRecordsResponse: Codable {
    let resource: String
    let status: String
    let endFlag: String
    let pagination: UsagePagination
    let response: [UsageRecord]
}

struct UsagePagination: Codable {
    let req_id: String
    let max_count: String
    let next: String
    let previous: String
    let before: String
    let count: String
    let refresh: String
    let after: String
}

struct UsageRecord: Codable {
    let record_id: String
    let timestamp: String
    let service: String // "outbound_call", "inbound_call", "call_summary", etc.
    let account_id: String
    let usage_details: UsageDetails
    let charges: UsageCharges
}

struct UsageDetails: Codable {
    let call: CallUsageDetails?
    let ai_credits: AICreditsDetails?
    let phnumsubscription: PhoneSubscriptionDetails?
    let priceplan: PricePlanDetails?
}

struct CallUsageDetails: Codable {
    let start_time: String
    let end_time: String
    let call_length: String // Duration in seconds as string
    let from_type: String
    let from: String
    let caller_id: String
    let to_type: String
    let to: String
    let to_orig: String
    let app_type: String
}

struct AICreditsDetails: Codable {
    let details: String?
    let user: String?
    let from: String?
    let to: String?
}

struct PhoneSubscriptionDetails: Codable {
    let phnum: String
    let country: String
    let area_code: String
    let city: String
    let type: String
    let range: String
    let price_category: String
}

struct PricePlanDetails: Codable {
    let priceplan_package: String
    let priceplan_count: String
}

struct UsageCharges: Codable {
    let priceplan: String
    let currency: String
    let count: String?
    let usage_fixed: String
    let usage_time: String
    let subscription_setup: String
    let subscription_recurring: String
    let usage_vat: String
    let renew_mode: String
    let ai_credits_usage: String?
    let charge_category: String
}

// MARK: - User Profile
