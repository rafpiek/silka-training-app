//
//  SplashView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOpacity: Double = 0.0
    @State private var backgroundGradientOpacity: Double = 0.0
    
    let onSplashComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6),
                    Color.orange.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(backgroundGradientOpacity)
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Logo/Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // App Title
                VStack(spacing: 8) {
                    Text("SILKA")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                    
                    Text("Your Personal Training Companion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Preparing your workout...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(subtitleOpacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Background gradient
        withAnimation(.easeIn(duration: 0.5)) {
            backgroundGradientOpacity = 1.0
        }
        
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            titleOffset = 0
            titleOpacity = 1.0
        }
        
        // Subtitle and loading animation
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            subtitleOpacity = 1.0
        }
        
        // Complete splash after all animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onSplashComplete()
        }
    }
}

#Preview {
    SplashView {
        print("Splash completed")
    }
}