//
//  CallerIdView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct CallerIdView: View {
    @State private var showOutgoingSelection = false
    @State private var showIncomingSelection = false

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
        .background(FigmaColorTokens.surfacePrimary)
        .navigationTitle("Caller ID")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .navigationDestination(isPresented: $showOutgoingSelection) {
            CallerIdSelectionView(selectedCallerId: .constant("Automatic"), selectionType: .outgoing)
        }
        .navigationDestination(isPresented: $showIncomingSelection) {
            CallerIdSelectionView(selectedCallerId: .constant("Caller's number"), selectionType: .incoming)
        }
    }

    private var callerIdMenu: some View {
        MenuView(items: [
            MenuItemView(
                title: "Outgoing calls",
                value: "Automatic",
                type: .navigation
            ) {
                showOutgoingSelection = true
            },
            MenuItemView(
                title: "Incoming calls",
                value: "Caller's number",
                type: .navigation,
                hasDivider: false
            ) {
                showIncomingSelection = true
            }
        ])
    }
}

#Preview {
    NavigationStack {
        CallerIdView()
    }
}
