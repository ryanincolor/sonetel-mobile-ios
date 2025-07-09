//
//  MainTabView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab: BottomNavigationView.Tab = .calls
    @State private var isDetailViewPresented = false

    var body: some View {
        VStack(spacing: 0) {
            // Main content
            Group {
                switch selectedTab {
                case .calls:
                    CallsView(isDetailViewPresented: $isDetailViewPresented)
                        .environmentObject(authManager)
                case .chats:
                    ChatsPlaceholderView()
                case .recordings:
                    CallRecordingsView(isDetailViewPresented: $isDetailViewPresented)
                        .environmentObject(authManager)
                case .ai:
                    AIPlaceholderView()
                }
            }

            // Bottom navigation - hidden when detail view is presented
            if !isDetailViewPresented {
                BottomNavigationView(selectedTab: $selectedTab)
            }
        }
        .background(
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
            })
        )
        .task {
            // Preload data when app starts
            if authManager.isAuthenticated {
                await dataManager.preloadAllData()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, authenticated in
            if authenticated {
                // Start preloading immediately when user authenticates
                Task {
                    await dataManager.preloadAllData()
                }
            } else {
                dataManager.clearAllData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh data when app becomes active
            if authManager.isAuthenticated {
                Task {
                    await dataManager.preloadAllData()
                }
            }
        }
    }
}

// MARK: - Placeholder Views

struct ChatsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 48))
                .foregroundColor(FigmaColorTokens.textSecondary)

            Text("Chats")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)

            Text("Chat functionality coming soon")
                .font(.system(size: 16))
                .foregroundColor(FigmaColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
            })
        )
    }
}

struct AIPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkle")
                .font(.system(size: 48))
                .foregroundColor(FigmaColorTokens.textSecondary)

            Text("AI Assistant")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)

            Text("AI features coming soon")
                .font(.system(size: 16))
                .foregroundColor(FigmaColorTokens.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
            })
        )
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
}
