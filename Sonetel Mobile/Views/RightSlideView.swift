//
//  RightSlideView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct RightSlideView<Content: View>: View {
    let content: Content
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: isPresented ? 0 : geometry.size.width)
                .animation(.easeInOut(duration: 0.3), value: isPresented)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    RightSlideView(isPresented: .constant(true)) {
        Color.blue
            .overlay(
                Text("Right Slide Content")
                    .foregroundColor(.white)
            )
    }
}
