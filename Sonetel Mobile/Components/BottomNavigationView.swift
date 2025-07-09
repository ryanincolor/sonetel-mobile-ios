//
//  BottomNavigationView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct BottomNavigationView: View {
    @Binding var selectedTab: Tab
    
    enum Tab: Int, CaseIterable {
        case calls = 0
        case chats = 1
        case recordings = 2
        case ai = 3
        
        var icon: String {
            switch self {
            case .calls: return "phone"
            case .chats: return "message"
            case .recordings: return "mic"
            case .ai: return "sparkle"
            }
        }
        
        var title: String {
            switch self {
            case .calls: return "Calls"
            case .chats: return "Chats"
            case .recordings: return "Recordings"
            case .ai: return "AI"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: iconName(for: tab))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(foregroundColor(for: tab))
                    }
                    .frame(maxWidth: 96)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(backgroundColor(for: tab))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                }
                .buttonStyle(.plain)
                
                if tab != Tab.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
        .background(
            Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(FigmaColorTokens.Dark.Z0) : UIColor(FigmaColorTokens.Light.Z0)
            })
        )
    }
    
    private func iconName(for tab: Tab) -> String {
        switch tab {
        case .calls:
            return "phone"
        case .chats:
            return "message"
        case .recordings:
            return "mic.fill"
        case .ai:
            return "sparkle"
        }
    }
    
    private func foregroundColor(for tab: Tab) -> Color {
        if tab == selectedTab {
            return FigmaColorTokens.textPrimary
        } else {
            return FigmaColorTokens.textPrimary.opacity(0.6)
        }
    }
    
    private func backgroundColor(for tab: Tab) -> Color {
        if tab == selectedTab {
            return Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ?
                    UIColor(FigmaColorTokens.Dark.T1) : UIColor(FigmaColorTokens.Light.T1)
            })
        } else {
            return Color.clear
        }
    }
}

#Preview {
    BottomNavigationView(selectedTab: .constant(.recordings))
}
