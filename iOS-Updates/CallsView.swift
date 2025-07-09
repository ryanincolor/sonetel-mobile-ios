//
//  CallsView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct CallsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showSettings = false
    @State private var showNewCall = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Top header
            topHeaderView

            // Main content in ScrollView
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Calls title
                    callsTitleView

                    // Search bar
                    searchBarView

                    // Filter toggle
                    filterToggleView

                    // Calls list
                    callsListView
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showNewCall) {
            NewCallView()
        }
        }
    }

    private var topHeaderView: some View {
        VStack(spacing: 0) {
            // Status bar spacer
            Rectangle()
                .fill(Color.clear)
                .frame(height: 50)

            // Header content
            HStack {
                // Profile button
                Button(action: {
                    showSettings = true
                }) {
                    ProfileAvatarView(
                        initial: authManager.currentUser?.initial ?? "?",
                        size: 36,
                        backgroundColor: Color.yellow.opacity(0.8)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // All/Missed toggle
                HStack(spacing: 4) {
                    FilterButton(
                        title: "All",
                        isSelected: selectedFilter == "All"
                    ) {
                        selectedFilter = "All"
                    }

                    FilterButton(
                        title: "Missed",
                        isSelected: selectedFilter == "Missed"
                    ) {
                        selectedFilter = "Missed"
                    }
                }

                Spacer()

                // New call button
                Button(action: {
                    showNewCall = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(FigmaColorTokens.surfacePrimary)
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var callsTitleView: some View {
        HStack {
            Text("Calls")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            TextField("Search", text: $searchText)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(FigmaColorTokens.adaptiveT1)
        .cornerRadius(12)
        .padding(.bottom, 20)
    }

    private var filterToggleView: some View {
        HStack {
            Text(selectedFilter == "All" ? "All calls" : "Missed calls")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.bottom, 16)
    }

    private var callsListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredCallRecords) { callRecord in
                CallListItemView(callRecord: callRecord)
            }
        }
    }

    private var filteredCallRecords: [CallRecord] {
        let records = CallRecord.sampleData
        if selectedFilter == "Missed" {
            return records.filter { $0.type == .missed }
        }
        return records
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.black : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CallsView()
        .environmentObject(AuthenticationManager())
}
