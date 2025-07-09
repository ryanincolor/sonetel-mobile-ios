//
//  ContactDetailView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCallOptions = false

    let contact: Contact

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile section
                        profileSectionView

                        // Contact info section
                        contactInfoSectionView

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .background(FigmaColorTokens.surfacePrimary)
        }
        .sheet(isPresented: $showCallOptions) {
            CallOptionsView(contact: contact)
                .presentationDetents([.height(338)])
                .presentationDragIndicator(.hidden)
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.953, green: 0.953, blue: 0.953))
                        .frame(width: 44, height: 44)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15.5)
        .frame(height: 75)
        .background(FigmaColorTokens.surfacePrimary)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var profileSectionView: some View {
        VStack(spacing: 9) {
            // Avatar
            AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1494790108755-2616c96b9968?w=128&h=128&fit=crop&crop=face")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))

                    Text(contact.initial)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(Circle())

            // Name
            Text("Emma Carter")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)
                .tracking(-0.68)
        }
        .padding(.horizontal, 20)
    }

    private var contactInfoSectionView: some View {
        VStack(spacing: 8) {
            ContactInfoRowView(
                label: "Mobile",
                value: "+46724489239",
                isPhoneNumber: true,
                onTap: {
                    showCallOptions = true
                }
            )

            ContactInfoRowView(
                label: "Email",
                value: "emma@tailored.com",
                isPhoneNumber: false,
                onTap: nil
            )
        }
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(20)
    }
}

struct ContactInfoRowView: View {
    let label: String
    let value: String
    let isPhoneNumber: Bool
    let onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack {
                // Left content
                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.36)

                Spacer()

                // Right content
                Text(value)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(FigmaColorTokens.textPrimary)
                    .tracking(-0.36)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(height: 56)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
        .overlay(
            Rectangle()
                .fill(FigmaColorTokens.adaptiveT1)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

#Preview {
    ContactDetailView(contact: Contact(
        name: "Emma Carter",
        phoneNumber: "+46724489239",
        email: "emma@tailored.com",
        avatarImageURL: "https://images.unsplash.com/photo-1494790108755-2616c96b9968?w=128&h=128&fit=crop&crop=face"
    ))
}
