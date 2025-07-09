//
//  CallListItemView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct CallListItemView: View {
    let callRecord: CallRecord
    @Binding var isDetailViewPresented: Bool
    @State private var showCallOptions = false

    var body: some View {
        Button(action: {
            showCallOptions = true
        }) {
            HStack(spacing: 12) {
                ProfileAvatarView(
                    imageURL: callRecord.avatarImageURL,
                    initial: callRecord.contactInitial,
                    flagEmoji: callRecord.flagEmoji
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(callRecord.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(callRecord.isMissed ? .red : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(callRecord.timestamp)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                NavigationLink(destination:
                    CallDetailView(callRecord: callRecord)
                        .onAppear { isDetailViewPresented = true }
                        .onDisappear { isDetailViewPresented = false }
                ) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.primary.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showCallOptions) {
            CallOptionsView(contact: Contact(
                name: callRecord.contactName,
                phoneNumber: callRecord.phoneNumber,
                avatarImageURL: callRecord.avatarImageURL
            ))
        }

    }
}

#Preview {
    CallListItemView(
        callRecord: CallRecord(
            contactName: "John Doe",
            phoneNumber: "+1234567890",
            timestamp: "2 min ago",
            avatarImageURL: nil,
            isMissed: true
        ),
        isDetailViewPresented: .constant(false)
    )
    .padding()
}
