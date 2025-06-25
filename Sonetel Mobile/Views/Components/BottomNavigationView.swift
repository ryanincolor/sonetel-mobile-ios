//
//  BottomNavigationView.swift
//  Sonetel Mobile
//
//  Created by Ryan Pittman on 2025-06-10.
//

import SwiftUI

struct BottomNavigationView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        HStack(spacing: 100) {
            // Calls tab (active)
            Button(action: {
                selectedTab = 0
            }) {
                VStack {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: 96)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Dialpad tab
            Button(action: {
                selectedTab = 1
            }) {
                VStack {
                    Image(systemName: "grid.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.primary.opacity(0.6))
                }
                .frame(maxWidth: 96)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 48)
        .padding(.top, 8)
        .padding(.bottom, 34)
        .background(Color.white)
    }
}

#Preview {
    BottomNavigationView()
}
