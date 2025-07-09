//
//  DataManager.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()

    // Published data for instant access
    @Published var callRecords: [CallRecord] = []
    @Published var callRecordings: [CallRecording] = []
    @Published var personalPhoneNumbers: [SonetelPhoneNumber] = []
    @Published var sonetelPhoneNumbers: [SonetelPhoneNumber] = []

    // Loading states
    @Published var isLoadingCalls = false
    @Published var isLoadingRecordings = false
    @Published var isLoadingPhoneNumbers = false

    // Error states
    @Published var callsError: String?
    @Published var recordingsError: String?
    @Published var phoneNumbersError: String?

    // Cache timestamps for background refresh logic
    private var lastCallsRefresh: Date?
    private var lastRecordingsRefresh: Date?
    private var lastPhoneNumbersRefresh: Date?

    // Refresh intervals (in seconds)
    private let refreshInterval: TimeInterval = 300 // 5 minutes

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Start background refresh timer
        startBackgroundRefresh()
    }

    // MARK: - Background Data Fetching

    func startBackgroundRefresh() {
        // Refresh every 5 minutes when app is active
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.refreshAllDataIfNeeded()
                }
            }
            .store(in: &cancellables)
    }

    private func refreshAllDataIfNeeded() async {
        // Only refresh if data is stale and user is authenticated
        guard SonetelAPIService.shared.isAuthenticated else { return }

        let now = Date()

        // Refresh calls if stale
        if shouldRefreshCalls(at: now) {
            await refreshCallsInBackground()
        }

        // Refresh recordings if stale
        if shouldRefreshRecordings(at: now) {
            await refreshRecordingsInBackground()
        }

        // Refresh phone numbers if stale
        if shouldRefreshPhoneNumbers(at: now) {
            await refreshPhoneNumbersInBackground()
        }
    }

    // MARK: - Calls Management

    func loadCallsIfEmpty() async {
        // Only load if we don't have data and user is authenticated
        guard callRecords.isEmpty && SonetelAPIService.shared.isAuthenticated else { return }
        await refreshCalls()
    }

    func refreshCalls() async {
        isLoadingCalls = true
        callsError = nil

        do {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let newCalls = try await SonetelAPIService.shared.getCallHistory(
                dateFrom: thirtyDaysAgo,
                dateTo: Date(),
                callType: "all"
            )

            callRecords = newCalls
            lastCallsRefresh = Date()
            print("📞 DataManager: Loaded \(newCalls.count) calls")

        } catch {
            callsError = error.localizedDescription
            print("❌ DataManager: Failed to load calls: \(error)")
        }

        isLoadingCalls = false
    }

    private func refreshCallsInBackground() async {
        // Background refresh without loading state
        do {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let newCalls = try await SonetelAPIService.shared.getCallHistory(
                dateFrom: thirtyDaysAgo,
                dateTo: Date(),
                callType: "all"
            )

            callRecords = newCalls
            lastCallsRefresh = Date()
            print("🔄 DataManager: Background refreshed \(newCalls.count) calls")

        } catch {
            print("⚠️ DataManager: Background call refresh failed: \(error)")
        }
    }

    private func shouldRefreshCalls(at date: Date) -> Bool {
        guard let lastRefresh = lastCallsRefresh else { return !callRecords.isEmpty }
        return date.timeIntervalSince(lastRefresh) > refreshInterval
    }

    // MARK: - Recordings Management

    func loadRecordingsIfEmpty() async {
        guard callRecordings.isEmpty && SonetelAPIService.shared.isAuthenticated else { return }
        await refreshRecordings()
    }

    func refreshRecordings() async {
        isLoadingRecordings = true
        recordingsError = nil

        do {
            let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
            let newRecordings = try await SonetelAPIService.shared.getCallRecordings(
                dateFrom: ninetyDaysAgo,
                dateTo: Date()
            )

            callRecordings = newRecordings
            lastRecordingsRefresh = Date()
            print("🎙️ DataManager: Loaded \(newRecordings.count) recordings")

        } catch {
            recordingsError = error.localizedDescription
            print("❌ DataManager: Failed to load recordings: \(error)")
        }

        isLoadingRecordings = false
    }

    private func refreshRecordingsInBackground() async {
        do {
            let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
            let newRecordings = try await SonetelAPIService.shared.getCallRecordings(
                dateFrom: ninetyDaysAgo,
                dateTo: Date()
            )

            callRecordings = newRecordings
            lastRecordingsRefresh = Date()
            print("🔄 DataManager: Background refreshed \(newRecordings.count) recordings")

        } catch {
            print("⚠️ DataManager: Background recordings refresh failed: \(error)")
        }
    }

    private func shouldRefreshRecordings(at date: Date) -> Bool {
        guard let lastRefresh = lastRecordingsRefresh else { return !callRecordings.isEmpty }
        return date.timeIntervalSince(lastRefresh) > refreshInterval
    }

    // MARK: - Phone Numbers Management

    func loadPhoneNumbersIfEmpty() async {
        guard (personalPhoneNumbers.isEmpty || sonetelPhoneNumbers.isEmpty) && SonetelAPIService.shared.isAuthenticated else { return }
        await refreshPhoneNumbers()
    }

    func refreshPhoneNumbers() async {
        isLoadingPhoneNumbers = true
        phoneNumbersError = nil

        do {
            // Load both types concurrently
            async let personalNumbers = SonetelAPIService.shared.getPersonalPhoneNumbers()
            async let sonetelNumbers = SonetelAPIService.shared.getSonetelPhoneNumbers()

            let (personal, sonetel) = try await (personalNumbers, sonetelNumbers)

            personalPhoneNumbers = personal
            sonetelPhoneNumbers = sonetel
            lastPhoneNumbersRefresh = Date()
            print("📱 DataManager: Loaded \(personal.count) personal + \(sonetel.count) Sonetel numbers")

        } catch {
            phoneNumbersError = error.localizedDescription
            print("❌ DataManager: Failed to load phone numbers: \(error)")
        }

        isLoadingPhoneNumbers = false
    }

    private func refreshPhoneNumbersInBackground() async {
        do {
            async let personalNumbers = SonetelAPIService.shared.getPersonalPhoneNumbers()
            async let sonetelNumbers = SonetelAPIService.shared.getSonetelPhoneNumbers()

            let (personal, sonetel) = try await (personalNumbers, sonetelNumbers)

            personalPhoneNumbers = personal
            sonetelPhoneNumbers = sonetel
            lastPhoneNumbersRefresh = Date()
            print("🔄 DataManager: Background refreshed \(personal.count) personal + \(sonetel.count) Sonetel numbers")

        } catch {
            print("⚠️ DataManager: Background phone numbers refresh failed: \(error)")
        }
    }

    private func shouldRefreshPhoneNumbers(at date: Date) -> Bool {
        guard let lastRefresh = lastPhoneNumbersRefresh else { return !personalPhoneNumbers.isEmpty || !sonetelPhoneNumbers.isEmpty }
        return date.timeIntervalSince(lastRefresh) > refreshInterval
    }

    // MARK: - Utility Methods

    func clearAllData() {
        callRecords = []
        callRecordings = []
        personalPhoneNumbers = []
        sonetelPhoneNumbers = []
        lastCallsRefresh = nil
        lastRecordingsRefresh = nil
        lastPhoneNumbersRefresh = nil
    }

    func preloadAllData() async {
        // Preload all data when app starts or user logs in
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadCallsIfEmpty() }
            group.addTask { await self.loadRecordingsIfEmpty() }
            group.addTask { await self.loadPhoneNumbersIfEmpty() }
        }
    }
}
