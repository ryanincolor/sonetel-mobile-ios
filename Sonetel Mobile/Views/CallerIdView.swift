//
//  CallerIdView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Settings menu
                    callerIdMenu
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .navigationTitle("Caller ID")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private var callerIdMenu: some View {
        VStack(spacing: 0) {
            SettingsMenuItemView(title: "Outgoing calls", value: "Automatic") {
                // Outgoing calls action
            }
            
            Rectangle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
                .frame(height: 1)
            
            SettingsMenuItemView(title: "Incoming calls", value: "Caller's number") {
                // Incoming calls action
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.04))
        .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        CallerIdView()
    }
}
