//
//  FullscreenTranscriptView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct FullscreenTranscriptView: View {
    let recording: CallRecording
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea(.all)

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
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
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    FullscreenTranscriptView(
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
