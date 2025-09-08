//
//  SplashView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0.0
    @State private var subtitleOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var progressOpacity: Double = 0.0

    let onSplashComplete: () -> Void

    var body: some View {
        ZStack {
            // Clean gradient background
            LinearGradient(
                colors: [
                    SilkaDesign.Colors.accent.opacity(0.9),
                    SilkaDesign.Colors.accent.opacity(0.7),
                    SilkaDesign.Colors.accentSecondary.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(backgroundOpacity)
            .ignoresSafeArea()

            VStack(spacing: SilkaDesign.Spacing.xxxl) {
                Spacer()

                // Modern Logo
                VStack(spacing: SilkaDesign.Spacing.lg) {
                    ZStack {
                        // Subtle backdrop
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)

                        // Icon
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // App Title
                    VStack(spacing: SilkaDesign.Spacing.sm) {
                        Text("SILKA")
                            .font(SilkaDesign.Typography.displayLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .tracking(2)
                            .offset(y: titleOffset)
                            .opacity(titleOpacity)

                        Text("Personal Training Companion")
                            .font(SilkaDesign.Typography.bodyLarge)
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(subtitleOpacity)
                    }
                }

                Spacer()

                // Minimal loading indicator
                VStack(spacing: SilkaDesign.Spacing.md) {
                    // Custom progress indicator
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 8, height: 8)
                                .scaleEffect(logoOpacity)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: logoOpacity
                                )
                        }
                    }

                    Text("Loading your workouts...")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(progressOpacity)
                .padding(.bottom, SilkaDesign.Spacing.xxxl)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Background
        withAnimation(.easeIn(duration: 0.4)) {
            backgroundOpacity = 1.0
        }

        // Logo animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Title animation
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            titleOffset = 0
            titleOpacity = 1.0
        }

        // Subtitle animation
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            subtitleOpacity = 1.0
        }

        // Progress animation
        withAnimation(.easeOut(duration: 0.3).delay(0.7)) {
            progressOpacity = 1.0
        }

        // Complete splash
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onSplashComplete()
        }
    }
}

#Preview {
    SplashView {
        print("Splash completed")
    }
}
