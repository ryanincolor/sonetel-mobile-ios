//
//  CallListItemView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct CallListItemView: View {
    let callRecord: CallRecord
    @State private var showCallOptions = false
    @State private var showCallDetail = false

    var body: some View {
        Button(action: {
            showCallOptions = true
        }) {
            HStack(spacing: 12) {
                ProfileAvatarView(
                    imageURL: callRecord.avatarImageURL,
                    initial: callRecord.contactInitial
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(callRecord.contactName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(callRecord.isMissed ? .red : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(callRecord.timestamp)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                Button(action: {
                    showCallDetail = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.primary.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showCallOptions) {
            CallOptionsView(contact: Contact(
                name: callRecord.contactName,
                phoneNumber: callRecord.phoneNumber,
                avatarImageURL: callRecord.avatarImageURL
            ))
            .presentationDetents([.height(338)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showCallDetail) {
            CallDetailView(callRecord: callRecord)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        CallListItemView(callRecord: CallRecord.sampleData[0])
        Divider()
        CallListItemView(callRecord: CallRecord.sampleData[2])
        Divider()
        CallListItemView(callRecord: CallRecord.sampleData[4])
    }
    .padding(.horizontal, 20)
}
