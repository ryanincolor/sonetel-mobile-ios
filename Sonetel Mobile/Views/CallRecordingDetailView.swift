//
//  CallRecordingDetailView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallRecordingDetailView: View {
    let recording: CallRecording
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .summary
    @State private var summary: String = ""
    @State private var transcript: String = ""
    @State private var actionItems: [ActionItem] = []
    @State private var isLoading = false
    @State private var playbackState: PlaybackState = .paused
    @State private var playbackPosition: Double = 0.0
    @State private var playbackDuration: Double = 0.0
    @State private var tabTransition: AnyTransition = .opacity
    @State private var recordingTitle: String = "Discussion about upcoming launch"
    @State private var isPlayerExpanded = false

    enum DetailTab: Int, CaseIterable {
        case summary = 0, transcript = 1, actions = 2

        var title: String {
            switch self {
            case .summary: return "Summary"
            case .transcript: return "Transcript"
            case .actions: return "Actions"
            }
        }
    }

    enum PlaybackState {
        case playing, paused
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed top header
            topHeaderView

            ScrollView {
                VStack(spacing: 0) {
                    // Title
                    titleView

                    // Tabs
                    tabsView

                    // Content
                    contentView
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 120) // Extra bottom padding for floating button
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .overlay(
            // Floating AI button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // AI action - could open AI assistant or processing
                    }) {
                        ZStack {
                            Circle()
                                .fill(.black)
                                .frame(width: 64, height: 64)

                            // AI/Star icon
                            Image(systemName: "sparkles")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                }
            }
        )
        .onAppear {
            loadRecordingDetails()
        }

    }

    private var topHeaderView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(Color.white)
                .frame(height: 50)

            // Header content
            HStack {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                            .frame(width: 36, height: 36)

                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                // Menu button
                Button(action: {
                    // Menu action
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                            .frame(width: 36, height: 36)

                        HStack(spacing: 3) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(.black)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }

    private var titleView: some View {
        HStack {
            Text(recordingTitle)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
                .tracking(-0.68)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var tabsView: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                        // Determine slide direction
                        let currentIndex = selectedTab.rawValue
                        let newIndex = tab.rawValue

                        if newIndex > currentIndex {
                            tabTransition = .asymmetric(
                                insertion: .push(from: .trailing),
                                removal: .push(from: .leading)
                            )
                        } else {
                            tabTransition = .asymmetric(
                                insertion: .push(from: .leading),
                                removal: .push(from: .trailing)
                            )
                        }

                        selectedTab = tab
                    }
                }) {
                    Text(tab.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .tracking(-0.32)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == tab ?
                            Color.black.opacity(0.04) :
                            Color.clear
                        )
                        .cornerRadius(28)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var contentView: some View {
        Group {
            switch selectedTab {
            case .summary:
                summaryView
                    .id("summary")
            case .transcript:
                transcriptView
                    .id("transcript")
            case .actions:
                actionsView
                    .id("actions")
            }
        }
        .transition(tabTransition)
    }

    private var summaryView: some View {
        VStack(spacing: 4) {
            // Summary card
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    // Header with speakers and share button
                    HStack {
                        HStack(spacing: 8) {
                            // Extract participant names from recording
                            ForEach(getParticipantNames(), id: \.self) { name in
                                Text(name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.04))
                                    .cornerRadius(28)
                            }
                        }

                        Spacer()

                        // Share button
                        Button(action: {
                            shareSummary()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.04))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Summary text
                    HStack {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading summary...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text(summary.isEmpty ? "No summary available" : summary)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }

                    // Meta information
                    HStack {
                        HStack(spacing: 4) {
                            Text(formatDate(recording.created_date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)

                            Text(formatTime(recording.created_date))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }

                        Spacer()

                        Text("Call")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(red: 1.0, green: 0.937, blue: 0.384))
            .cornerRadius(20)
        }
    }

    private var transcriptView: some View {
        VStack(spacing: 4) {
            // Audio player
            audioPlayerView

            // Transcript card
            VStack(spacing: 0) {
                VStack(spacing: 28) {
                    // Header with speakers and share button
                    HStack {
                        HStack(spacing: 8) {
                            // Extract participant names from recording
                            ForEach(getParticipantNames(), id: \.self) { name in
                                Text(name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.04))
                                    .cornerRadius(28)
                            }
                        }

                        Spacer()

                        // Share button
                        Button(action: {
                            shareTranscript()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.04))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Transcript text
                    VStack(alignment: .leading, spacing: 16) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Loading transcript...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            transcriptContent
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .background(Color(red: 0.996, green: 0.890, blue: 0.976))
            .cornerRadius(20)
        }
    }

    private var audioPlayerView: some View {
        ZStack {
            if isPlayerExpanded {
                // Expanded player content
                expandedPlayerContent
            } else {
                // Compact player content
                compactPlayerView
            }
        }
        .frame(
            width: isPlayerExpanded ? UIScreen.main.bounds.width : nil,
            height: isPlayerExpanded ? UIScreen.main.bounds.height : 56
        )
        .background(.black)
        .cornerRadius(isPlayerExpanded ? 0 : 28)
        .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isPlayerExpanded)
        .zIndex(isPlayerExpanded ? 1000 : 0)
        .ignoresSafeArea(isPlayerExpanded ? .all : [])
    }

    private var compactPlayerView: some View {
        HStack(spacing: 0) {
            // Play/pause button
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
                    isPlayerExpanded = true
                }
            }) {
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: playbackState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .offset(x: playbackState == .playing ? 0 : 1)
                    )
            }
            .padding(.leading, 16)

            // Waveform and progress
            VStack(spacing: 2) {
                // Waveform visualization
                HStack(spacing: 1) {
                    ForEach(0..<60) { index in
                        Rectangle()
                            .fill(Color(red: 0.722, green: 0.722, blue: 0.722))
                            .frame(width: 1.5, height: CGFloat.random(in: 4...20))
                    }
                }
                .frame(height: 32)
                .overlay(
                    // Progress overlay
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 32)
                        .offset(x: -100 + (200 * playbackPosition / max(playbackDuration, 1)))
                        .opacity(playbackDuration > 0 ? 1 : 0)
                )
                .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .padding(.horizontal, 16)
            .onTapGesture { location in
                // Handle scrubbing
                let progress = location.x / 248 // approximate width
                playbackPosition = progress * playbackDuration
            }

            // Duration
            Text(formatPlaybackTime(playbackDuration))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.trailing, 16)

            Spacer()
        }
        .frame(height: 56)
    }

    private var expandedPlayerContent: some View {
        VStack {
            // Status bar spacer
            Rectangle()
                .fill(.clear)
                .frame(height: 50)

            // Header with close button
            HStack {
                Spacer()

                Text("Now Playing")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 400, damping: 25)) {
                        isPlayerExpanded = false
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.161, green: 0.161, blue: 0.161))
                            .frame(width: 36, height: 36)

                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            Spacer()

            // Placeholder for future content
            Text("Expanded Player Content")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
    }

    @ViewBuilder
    private var transcriptContent: some View {
        if transcript.isEmpty {
            // Default transcript content if not loaded or no transcript available
            VStack(alignment: .leading, spacing: 16) {
                // Anna 0:01
                HStack(alignment: .top, spacing: 8) {
                    Text("Anna")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Text("0:01")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))

                    Spacer()
                }

                Text("Hi Mark, how's everything going on your end?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(nil)

                // Mark 0:23
                HStack(alignment: .top, spacing: 8) {
                    Text("Mark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Text("0:23")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))

                    Spacer()
                }

                Text("Hey Anna, it's going well, thanks. We're just wrapping up some final tests for the new product line. I wanted to discuss the next steps for our upcoming launch.")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(nil)

                // Anna 0:38
                HStack(alignment: .top, spacing: 8) {
                    Text("Anna")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Text("0:38")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))

                    Spacer()
                }

                Text("Great to hear! So, I was thinking we could start by reviewing the user testing results you mentioned last week. Have you had a chance to look at them?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(nil)

                // Mark 0:57
                HStack(alignment: .top, spacing: 8) {
                    Text("Mark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Text("0:57")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))

                    Spacer()
                }

                Text("Yes, I've reviewed the results, and there are a few key areas where we're getting stuck. Mainly in the checkout process; users seem to drop off when they reach the payment page.")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(nil)

                // Anna 1:27
                HStack(alignment: .top, spacing: 8) {
                    Text("Anna")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)

                    Text("1:27")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))

                    Spacer()
                }

                Text("Hmm, interesting. I think we can implement a few improvements to streamline that. Maybe simplify the payment options or offer an additional payment gateway? What do you think?")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(nil)
            }
        } else {
            // Real transcript content parsed from API
            Text(transcript)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.black)
                .lineLimit(nil)
        }
    }

    private var actionsView: some View {
        VStack(spacing: 4) {
            // Actions card
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Text("Action items")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                            .tracking(-0.4)

                        Spacer()

                        // Share button
                        Button(action: {
                            shareActionItems()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.04))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Action items list
                    VStack(spacing: 12) {
                        ForEach(actionItems.indices, id: \.self) { index in
                            ActionItemRow(item: actionItems[index]) { checkedItem in
                                toggleActionItem(checkedItem)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color(red: 0.749, green: 0.984, blue: 0.776))
            .cornerRadius(20)
        }
    }

    // MARK: - Helper Functions

    private func loadRecordingDetails() {
        // Set default duration from recording
        playbackDuration = Double(recording.voice_call_details.call_length)
        isLoading = true

        Task {
            await loadRealRecordingData()
        }
    }

    @MainActor
    private func loadRealRecordingData() async {
        do {
            // For dummy data mode, use local data
            if SonetelAPIService.shared.isDummyDataMode {
                summary = "During this call, Anna and Mark discussed the next steps for the upcoming product launch. Mark highlighted an issue with the checkout process where users are dropping off at the payment page."
                transcript = "" // Will use default formatted transcript
                actionItems = getDefaultActionItems()
                recordingTitle = extractTitle(from: summary)
                isLoading = false
                return
            }

            // For real API, fetch the recording details
            if let recordingDetails = try await SonetelAPIService.shared.getCallRecordingDetails(recordingId: recording.call_recording_id) {
                // Extract summary from recording details if available
                summary = recordingDetails.summary ?? "No summary available for this recording."

                // Extract transcript if available
                transcript = recordingDetails.transcript ?? ""

                // Generate action items from summary if available
                actionItems = generateActionItemsFromSummary(summary)

                // Update title from summary
                recordingTitle = extractTitle(from: summary)
            } else {
                summary = "Unable to load recording details."
                transcript = ""
                actionItems = []
                recordingTitle = "Call Recording"
            }
        } catch {
            print("❌ Failed to load recording details: \(error)")
            summary = "Failed to load recording summary."
            transcript = ""
            actionItems = []
        }

        isLoading = false
    }

    private func extractTitle(from summaryText: String) -> String {
        // Try to extract meaningful title from summary
        if !summaryText.isEmpty {
            // Use first sentence of summary as title
            let sentences = summaryText.components(separatedBy: ".")
            if let firstSentence = sentences.first, !firstSentence.isEmpty {
                let cleanedTitle = firstSentence.trimmingCharacters(in: .whitespacesAndNewlines)
                // Limit title length
                if cleanedTitle.count > 60 {
                    return String(cleanedTitle.prefix(57)) + "..."
                }
                return cleanedTitle
            }
        }

        // Fallback to default title
        return "Discussion about upcoming launch"
    }

    private func getParticipantNames() -> [String] {
        // Extract participant names from recording
        var participants: [String] = []

        let fromName = recording.voice_call_details.from_name
        let toName = recording.voice_call_details.to_name

        if !fromName.isEmpty && !fromName.hasPrefix("+") {
            participants.append(fromName.components(separatedBy: " ").first ?? fromName)
        }

        if !toName.isEmpty && !toName.hasPrefix("+") {
            participants.append(toName.components(separatedBy: " ").first ?? toName)
        }

        // Default names if no real names found
        if participants.isEmpty {
            participants = ["Anna", "Mark"]
        }

        return Array(Set(participants)) // Remove duplicates
    }

    private func generateActionItemsFromSummary(_ summaryText: String) -> [ActionItem] {
        // In a real implementation, this would use AI to extract action items
        // For now, return default action items
        return getDefaultActionItems()
    }

    private func togglePlayback() {
        playbackState = playbackState == .playing ? .paused : .playing

        // In real implementation, this would control actual audio playback
        if playbackState == .playing {
            // Start audio playback
        } else {
            // Pause audio playback
        }
    }

    private func formatDate(_ dateString: String) -> String {
        guard let date = parseDate(dateString) else { return "1 October 2024" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
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

    private func formatPlaybackTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }

    private func shareSummary() {
        let summaryText = "Call Summary - \(formatDate(recording.created_date))\n\n\(summary)"
        shareContent(summaryText)
    }

    private func shareTranscript() {
        let transcriptText = "Call Transcript - \(formatDate(recording.created_date))\n\n\(transcript.isEmpty ? getFormattedDefaultTranscript() : transcript)"
        shareContent(transcriptText)
    }

    private func shareActionItems() {
        let actionsText = "Action Items - \(formatDate(recording.created_date))\n\n" +
            actionItems.map { "• \($0.text)" }.joined(separator: "\n")
        shareContent(actionsText)
    }

    private func getFormattedDefaultTranscript() -> String {
        return """
Anna 0:01
Hi Mark, how's everything going on your end?

Mark 0:23
Hey Anna, it's going well, thanks. We're just wrapping up some final tests for the new product line. I wanted to discuss the next steps for our upcoming launch.

Anna 0:38
Great to hear! So, I was thinking we could start by reviewing the user testing results you mentioned last week. Have you had a chance to look at them?

Mark 0:57
Yes, I've reviewed the results, and there are a few key areas where we're getting stuck. Mainly in the checkout process; users seem to drop off when they reach the payment page.

Anna 1:27
Hmm, interesting. I think we can implement a few improvements to streamline that. Maybe simplify the payment options or offer an additional payment gateway? What do you think?
"""
    }

    private func shareContent(_ content: String) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("❌ Cannot find window to present share sheet")
                return
            }

            let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)

            // For iPad
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }

            // Find the topmost presented view controller
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            topViewController.present(activityVC, animated: true)
        }
    }

    private func toggleActionItem(_ item: ActionItem) {
        if let index = actionItems.firstIndex(where: { $0.id == item.id }) {
            actionItems[index].isCompleted.toggle()
        }
    }

    private func getDefaultActionItems() -> [ActionItem] {
        return [
            ActionItem(
                id: UUID(),
                text: "Implement guest checkout feature to improve conversion rates.",
                isCompleted: false
            ),
            ActionItem(
                id: UUID(),
                text: "Simplify the payment process and explore additional payment gateway options.",
                isCompleted: false
            ),
            ActionItem(
                id: UUID(),
                text: "Design and finalize mobile-first experience for the upcoming launch.",
                isCompleted: false
            ),
            ActionItem(
                id: UUID(),
                text: "Prepare and send updated wireframes by Friday for approval.",
                isCompleted: false
            ),
            ActionItem(
                id: UUID(),
                text: "Follow up with a timeline for final deliverables by next Monday.",
                isCompleted: false
            )
        ]
    }
}

// MARK: - Supporting Views and Models

struct ActionItem: Identifiable {
    let id: UUID
    let text: String
    var isCompleted: Bool
}

struct ActionItemRow: View {
    let item: ActionItem
    let onToggle: (ActionItem) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button(action: {
                onToggle(item)
            }) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.black, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        item.isCompleted ?
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black) :
                        nil
                    )
            }
            .padding(.top, 4)

            // Text
            Text(item.text)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .opacity(item.isCompleted ? 0.6 : 1.0)

            Spacer()
        }
    }
}

#Preview {
    CallRecordingDetailView(
        recording: CallRecording(
            call_recording_id: "1",
            call_id: "call1",
            type: "voice_call",
            account_id: 208875534,
            user_id: "user1",
            created_date: "20250104T11:09:00Z",
            expiry_date: nil,
            voice_call_details: VoiceCallDetails(
                from: "user1",
                to: "+46856485160",
                codec: "PCMU",
                direction: "outbound",
                usage_record_id: 1,
                start_time: "20250104T11:09:00Z",
                end_time: "20250104T11:10:32Z",
                call_length: 92,
                from_type: "user",
                from_name: "Anna Johnson",
                caller_id: "19177958340",
                to_type: "phonenumber",
                to_name: "Mark Wilson",
                to_orig: "+46856485160"
            ),
            is_transcribed: true
        )
    )
}
