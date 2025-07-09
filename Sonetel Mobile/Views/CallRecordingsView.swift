//
//  CallRecordingsView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallRecordingsView: View {
    @Binding var isDetailViewPresented: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top header
                topHeaderView

                // Main content in ScrollView
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        // Title
                        titleView

                        // Search bar
                        searchBarView

                        // Recordings content
                        recordingsContentView
                    }
                }
                .clipped()
            }
            .background(
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                        UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
                })
            )
            .ignoresSafeArea(.all, edges: .top)
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
        }
        .task {
            await dataManager.loadRecordingsIfEmpty()
        }
        .refreshable {
            await dataManager.refreshRecordings()
        }
    }

    private var topHeaderView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(
                    Color(UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark ?
                            UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
                    })
                )
                .frame(height: 50)

            // Header content
            HStack {
                // Back button
                Button(action: {
                    // Navigate back - for now just dismiss
                }) {
                    ZStack {
                        Circle()
                            .fill(FigmaColorTokens.Light.Z1)
                            .frame(width: 36, height: 36)

                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: 8) {
                    // Add button
                    Button(action: {
                        // Add recording action
                    }) {
                        ZStack {
                            Circle()
                                .fill(FigmaColorTokens.Light.Z1)
                                .frame(width: 36, height: 36)

                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }
                    }

                    // Menu button
                    Button(action: {
                        showSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(FigmaColorTokens.Light.Z1)
                                .frame(width: 36, height: 36)

                            HStack(spacing: 3) {
                                ForEach(0..<3) { _ in
                                    Circle()
                                        .fill(FigmaColorTokens.textPrimary)
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                        UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
                })
            )
        }
    }

    private var titleView: some View {
        HStack {
            Text("All recordings")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)
                .tracking(-0.68)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var searchBarView: some View {
        VStack {
            HStack {
                Text("Search")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textSecondary.opacity(0.6))
                    .padding(.leading, 16)
                Spacer()
            }
            .frame(height: 44)
            .background(
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                        UIColor(FigmaColorTokens.Dark.T1) : UIColor(FigmaColorTokens.Light.T1)
                })
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var recordingsContentView: some View {
        VStack(spacing: 20) {
            if dataManager.isLoadingRecordings {
                // Loading state
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading recordings...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textSecondary)
                }
                .padding(.vertical, 40)
            } else if let error = dataManager.recordingsError {
                // Error state
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)

                    Text("Failed to load recordings")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)

                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(FigmaColorTokens.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task {
                            await dataManager.refreshRecordings()
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            } else {
                // Recordings grouped by time period
                recordingsGroupedContent
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private var recordingsGroupedContent: some View {
        VStack(spacing: 20) {
            // Group recordings by time periods
            let groupedRecordings = groupRecordingsByTime(dataManager.callRecordings)

            ForEach(Array(groupedRecordings.keys.sorted().reversed()), id: \.self) { period in
                if let recordingsInPeriod = groupedRecordings[period], !recordingsInPeriod.isEmpty {
                    RecordingGroupView(
                        title: period,
                        recordings: recordingsInPeriod,
                        isDetailViewPresented: $isDetailViewPresented
                    )
                }
            }

            // Empty state
            if dataManager.callRecordings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mic.circle")
                        .font(.system(size: 32))
                        .foregroundColor(FigmaColorTokens.textSecondary)

                    Text("No recordings found")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)

                    Text("Your call recordings will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(FigmaColorTokens.textSecondary)
                }
                .padding(.vertical, 40)
            }
        }
    }



    private func groupRecordingsByTime(_ recordings: [CallRecording]) -> [String: [CallRecording]] {
        var grouped: [String: [CallRecording]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for recording in recordings {
            let date = parseRecordingDate(recording.created_date) ?? now

            let period: String
            if calendar.isDateInToday(date) {
                period = "Today"
            } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                period = "Past 7 days"
            } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                period = "Past 30 days"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                period = formatter.string(from: date)
            }

            if grouped[period] == nil {
                grouped[period] = []
            }
            grouped[period]?.append(recording)
        }

        return grouped
    }

    private func parseRecordingDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
}

struct RecordingGroupView: View {
    let title: String
    let recordings: [CallRecording]
    @Binding var isDetailViewPresented: Bool

    var body: some View {
        VStack(spacing: 7) {
            // Section title
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(FigmaColorTokens.Light.Z6)
                    .tracking(-0.32)
                Spacer()
            }

            // Recordings list
            VStack(spacing: 0) {
                ForEach(recordings.indices, id: \.self) { index in
                    RecordingItemView(
                        recording: recordings[index],
                        hasDivider: index < recordings.count - 1,
                        isDetailViewPresented: $isDetailViewPresented
                    )
                }
            }
            .background(FigmaColorTokens.Light.Z1)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct RecordingItemView: View {
    let recording: CallRecording
    let hasDivider: Bool
    @Binding var isDetailViewPresented: Bool

    var body: some View {
        NavigationLink(destination:
            CallRecordingDetailView(recording: recording)
                .onAppear { isDetailViewPresented = true }
                .onDisappear { isDetailViewPresented = false }
        ) {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    // Recording title
                    HStack {
                        Text("Discussion about upcoming launch")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                            .tracking(-0.36)
                        Spacer()
                    }

                    // Details row
                    HStack {
                        // Left details
                        HStack(spacing: 4) {
                            Text(formatDate(recording.created_date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)

                            Text(formatTime(recording.created_date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)

                            Text("·")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)

                            Text(getRecordingType(recording))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(FigmaColorTokens.textPrimary)
                        }

                        Spacer()

                        // Duration
                        Text(formatDuration(recording.voice_call_details.call_length))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

                // Divider
                if hasDivider {
                    Rectangle()
                        .fill(
                            Color(UIColor { traitCollection in
                                return traitCollection.userInterfaceStyle == .dark ?
                                    UIColor(FigmaColorTokens.Dark.T2) : UIColor(FigmaColorTokens.Light.T2)
                            })
                        )
                        .frame(height: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return "1 Oct 2024" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    private func formatTime(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return "11:09" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }

    private func getRecordingType(_ recording: CallRecording) -> String {
        switch recording.type {
        case "voice_call":
            return "Call"
        default:
            return "Recording"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
}

#Preview {
    CallRecordingsView(isDetailViewPresented: .constant(false))
        .environmentObject(AuthenticationManager())
}
