//
//  CallDetailView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct CallDetailView: View {
    let callRecord: CallRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom top bar
            topBarView
            
            // Scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Main content
                    contentView
                }
            }
            .clipped()
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    private var topBarView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(Color.white)
                .frame(height: 50)
            
            // Top navigation bar
            HStack {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.04))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 56)
            .background(Color.white)
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 4) {
            // Header with avatar and name
            headerView
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            // Call details section
            callDetailsSection
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            // Contact info section
            contactInfoSection
                .padding(.horizontal, 20)
                .padding(.top, 8)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 9) {
            // Avatar
            ProfileAvatarView(
                imageURL: callRecord.avatarImageURL,
                initial: callRecord.contactInitial,
                size: 64
            )
            
            // Name
            Text(callRecord.contactName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var callDetailsSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                // Date
                HStack {
                    Text(callRecord.callDate ?? callRecord.timestamp)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Time, duration, and call type
                HStack(spacing: 4) {
                    if let callTime = callRecord.callTime {
                        Text(callTime)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    if callRecord.callTime != nil && callRecord.callDuration != nil {
                        Text("·")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    if let callDuration = callRecord.callDuration {
                        Text(callDuration)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    if (callRecord.callTime != nil || callRecord.callDuration != nil) {
                        Text("·")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Text(callRecord.callType.displayText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private var contactInfoSection: some View {
        VStack(spacing: 0) {
            // Mobile number row
            if let phoneNumber = callRecord.phoneNumber {
                contactInfoRow(
                    title: "Mobile",
                    value: phoneNumber,
                    isFirst: true,
                    isLast: callRecord.email == nil
                )
            }
            
            // Email row
            if let email = callRecord.email {
                contactInfoRow(
                    title: "Email",
                    value: email,
                    isFirst: callRecord.phoneNumber == nil,
                    isLast: true
                )
            }
        }
        .background(Color.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func contactInfoRow(title: String, value: String, isFirst: Bool, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                // Left content
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Right content
                Text(value)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(height: 56)
            
            // Divider (only if not last)
            if !isLast {
                Rectangle()
                    .fill(Color.black.opacity(0.04))
                    .frame(height: 1)
                    .padding(.leading, 16)
            }
        }
    }
}

#Preview {
    NavigationView {
        CallDetailView(callRecord: CallRecord.sampleData[1])
    }
}
