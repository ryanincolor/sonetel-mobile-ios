//
//  CallsView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct CallsView: View {
    @Binding var isDetailViewPresented: Bool
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var dataManager = DataManager.shared
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
        .sheet(isPresented: $showNewCall) {
            NewCallView()
        }
        .task {
            await dataManager.loadCallsIfEmpty()
        }
        .refreshable {
            await dataManager.refreshCalls()
        }
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
                            .background(selectedFilter == "All" ?
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ?
                                        UIColor(FigmaColorTokens.Dark.T1) : UIColor(FigmaColorTokens.Light.T1)
                                }) : Color.clear)
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
                            .background(selectedFilter == "Missed" ?
                                Color(UIColor { traitCollection in
                                    return traitCollection.userInterfaceStyle == .dark ?
                                        UIColor(FigmaColorTokens.Dark.T1) : UIColor(FigmaColorTokens.Light.T1)
                                }) : Color.clear)
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
            .background(
                Color(UIColor { traitCollection in
                    return traitCollection.userInterfaceStyle == .dark ?
                        UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
                })
            )
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

    private var callListView: some View {
        LazyVStack(spacing: 0) {
            // Debug toggle (only visible in debug builds)


            // Loading state
            if dataManager.isLoadingCalls {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading calls...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textSecondary)
                }
                .padding(.vertical, 20)
            }

            // Error state
            else if let error = dataManager.callsError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)

                    Text("Failed to load calls")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(FigmaColorTokens.textPrimary)

                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(FigmaColorTokens.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        Task {
                            await dataManager.refreshCalls()
                        }
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }

            // Call list
            else {
                ForEach(filteredCalls) { call in
                    CallListItemView(callRecord: call, isDetailViewPresented: $isDetailViewPresented)
                        .padding(.horizontal, 20)
                }

                // Empty state
                if filteredCalls.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "phone")
                            .font(.system(size: 32))
                            .foregroundColor(FigmaColorTokens.textSecondary)

                        Text("No calls found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textPrimary)

                        if selectedFilter == "Missed" {
                            Text("No missed calls")
                                .font(.system(size: 14))
                                .foregroundColor(FigmaColorTokens.textSecondary)
                        } else {
                            Text("Your call history will appear here")
                                .font(.system(size: 14))
                                .foregroundColor(FigmaColorTokens.textSecondary)
                        }
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .padding(.top, 4)
    }

    private var filteredCalls: [CallRecord] {
        if selectedFilter == "Missed" {
            return dataManager.callRecords.filter { $0.isMissed }
        }
        return dataManager.callRecords
    }


}

#Preview {
    CallsView(isDetailViewPresented: .constant(false))
        .environmentObject(AuthenticationManager())
}
