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

                    // Call list
                    callListView
                        .padding(.bottom, 20) // Add bottom padding for better scrolling
                }
            }
            .clipped()

            // Bottom navigation
            BottomNavigationView()
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
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
                .fill(Color.white)
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
                    Button(action: {
                        selectedFilter = "All"
                    }) {
                        Text("All")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .frame(minWidth: 64)
                            .background(selectedFilter == "All" ? Color.black.opacity(0.04) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        selectedFilter = "Missed"
                    }) {
                        Text("Missed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .frame(minWidth: 64)
                            .background(selectedFilter == "Missed" ? Color.black.opacity(0.04) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer()

                // New call button
                Button(action: {
                    showNewCall = true
                }) {
                    Image(systemName: "phone.badge.plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.black)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }

    private var callsTitleView: some View {
        HStack {
            Text("Calls")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(.primary)
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
                    .foregroundColor(.primary.opacity(0.6))
                    .padding(.leading, 16)
                Spacer()
            }
            .frame(height: 44)
            .background(Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var callListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(filteredCalls) { call in
                CallListItemView(callRecord: call)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 4)
    }

    private var filteredCalls: [CallRecord] {
        let calls = CallRecord.sampleData
        if selectedFilter == "Missed" {
            return calls.filter { $0.isMissed }
        }
        return calls
    }
}

#Preview {
    CallsView()
        .environmentObject(AuthenticationManager())
}
