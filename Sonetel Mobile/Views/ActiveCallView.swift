//
//  ActiveCallView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct ActiveCallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var callDuration: TimeInterval = 1
    @State private var timer: Timer?
    @State private var isSpeakerOn = false
    @State private var isMuted = false
    
    let phoneNumber: String
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status bar area
                statusBarView
                
                // Top controls
                topControlsView
                
                Spacer()
                
                // Call information
                callInfoView
                
                Spacer()
                
                // Bottom controls
                bottomControlsView
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var statusBarView: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 7) {
                // Signal strength
                HStack(spacing: 2) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(.white)
                            .frame(width: 3, height: CGFloat(4 + index * 2))
                            .opacity(index < 3 ? 1.0 : 0.4)
                    }
                }
                
                // WiFi icon
                Image(systemName: "wifi")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                // Battery
                ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .stroke(.white, lineWidth: 1)
                        .frame(width: 24, height: 12)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white)
                        .frame(width: 20, height: 8)
                    
                    // Battery tip
                    RoundedRectangle(cornerRadius: 1)
                        .fill(.white.opacity(0.4))
                        .frame(width: 1, height: 4)
                        .offset(x: 14)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 21)
        .frame(height: 50)
    }
    
    private var topControlsView: some View {
        HStack {
            Spacer()
            
            Button(action: {
                // Menu action
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .frame(width: 36, height: 36)
                    
                    HStack(spacing: 3) {
                        ForEach(0..<3) { _ in
                            Circle()
                                .fill(.white)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 9)
        .frame(height: 54)
    }
    
    private var callInfoView: some View {
        VStack(spacing: 8) {
            Text(phoneNumber)
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.white)
                .tracking(-0.8)
            
            Text(formatCallDuration(callDuration))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .tracking(-0.32)
        }
        .padding(.horizontal, 60)
        .frame(height: 94)
    }
    
    private var bottomControlsView: some View {
        HStack(spacing: 28) {
            // Speaker button
            Button(action: {
                isSpeakerOn.toggle()
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "speaker.wave.3")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            // Mute button
            Button(action: {
                isMuted.toggle()
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: isMuted ? "mic.slash" : "mic")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            // End call button
            Button(action: {
                dismiss()
            }) {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding(.horizontal, 62)
        .padding(.bottom, 64)
        .frame(height: 136)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            callDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func formatCallDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ActiveCallView(phoneNumber: "+46737431132")
}
