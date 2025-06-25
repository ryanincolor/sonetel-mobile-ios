//
//  NewCallView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct NewCallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private let groupedContacts = Contact.groupedContacts

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Search bar
                        searchBarView

                        // Call a number option
                        callNumberOption

                        // Contacts list
                        contactsListView
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()

            Text("New Call")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Spacer()

            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(width: 32, height: 32)

                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.039, green: 0.039, blue: 0.039))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(height: 75)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var searchBarView: some View {
        HStack {
            Text("Search contacts")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.28))
                .padding(.leading, 16)
            Spacer()
        }
        .frame(height: 44)
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(12)
    }

    private var callNumberOption: some View {
        NavigationLink(destination: DialpadView()) {
            SettingsMenuItemView(
                title: "Call a number",
                hasChevron: false,
                icon: "square.grid.3x3"
            ) {}
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(red: 0.961, green: 0.961, blue: 0.961))
        .cornerRadius(12)
    }

    private var contactsListView: some View {
        LazyVStack(spacing: 20) {
            ForEach(groupedContacts.keys.sorted(), id: \.self) { letter in
                contactSectionView(letter: letter, contacts: groupedContacts[letter] ?? [])
            }
        }
    }

    private func contactSectionView(letter: String, contacts: [Contact]) -> some View {
        VStack(spacing: 4) {
            // Section header
            HStack {
                Text(letter)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                Spacer()
            }
            .padding(.horizontal, 16)

            // Contacts in this section
            VStack(spacing: 0) {
                ForEach(contacts.indices, id: \.self) { index in
                    ContactRowView(contact: contacts[index])

                    if index < contacts.count - 1 {
                        Rectangle()
                            .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                            .frame(height: 1)
                    }
                }
            }
            .background(Color(red: 0.961, green: 0.961, blue: 0.961))
            .cornerRadius(12)
        }
    }
}

struct ContactRowView: View {
    let contact: Contact
    @State private var showContactDetail = false
    @State private var showCallOptions = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            showCallOptions = true
        }) {
            HStack(spacing: 12) {
                // Avatar
                AsyncImage(url: URL(string: contact.avatarImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))

                        Text(contact.initial)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())

                // Contact name
                Text(contact.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.067, green: 0.067, blue: 0.067))

                Spacer()

                // Info button
                Button(action: {
                    showContactDetail = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0, opacity: 0.6))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity) // Fill width
            .contentShape(Rectangle()) // Make entire area tappable
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(isPressed ? Color.black.opacity(0.05) : Color.clear)
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .sheet(isPresented: $showContactDetail) {
            ContactDetailView(contact: contact)
        }
        .sheet(isPresented: $showCallOptions) {
            CallOptionsView(contact: contact)
                .presentationDetents([.height(338)])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    NewCallView()
}
