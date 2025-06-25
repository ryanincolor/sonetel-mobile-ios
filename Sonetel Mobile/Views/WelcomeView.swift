//
//  WelcomeView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Status bar spacer
                statusBarView
                
                // Main content
                VStack(spacing: 4) {
                    // Hero section
                    heroSectionView
                    
                    // Text and button
                    bottomSectionView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    private var statusBarView: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 7) {
                // Signal strength bars
                HStack(spacing: 2) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.black)
                            .frame(width: 3, height: CGFloat(4 + index * 2))
                            .opacity(index < 3 ? 1.0 : 0.4)
                    }
                }
                
                // WiFi icon
                Image(systemName: "wifi")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                
                // Battery
                ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .stroke(.black, lineWidth: 1)
                        .frame(width: 24, height: 12)
                        .opacity(0.35)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black)
                        .frame(width: 20, height: 8)
                    
                    // Battery tip
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.black.opacity(0.4))
                        .frame(width: 1, height: 4)
                        .offset(x: 14)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 21)
        .frame(height: 50)
        .background(Color.white)
    }
    
    private var heroSectionView: some View {
        VStack(spacing: 0) {
            // Sonetel logo section
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.961, green: 0.961, blue: 0.961))
                        .frame(height: 415)
                    
                    // Sonetel logo placeholder - simplified version
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.6, blue: 0.8),
                                    Color(red: 0.2, green: 0.7, blue: 0.8),
                                    Color(red: 1.0, green: 0.8, blue: 0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("S")
                                .font(.system(size: 120, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Text section
            VStack(spacing: 0) {
                Text("Make and recieve calls worldwide at the cost of a local call.")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .tracking(-0.68)
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .padding(.bottom, 96)
            }
        }
    }
    
    private var bottomSectionView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Get started button
            Button(action: {
                authManager.startAuthentication()
            }) {
                Text("Get started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .tracking(-0.36)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.067, green: 0.067, blue: 0.067))
                    .cornerRadius(36)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthenticationManager())
}
