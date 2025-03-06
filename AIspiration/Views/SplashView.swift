//
//  SplashView.swift
//  AIspiration
//
//  Created by 牛拙 on 3/5/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            HomeView()
        } else {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("AIspiration")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("每日智慧，激发灵感")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 