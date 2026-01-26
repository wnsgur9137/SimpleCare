//
//  SplashView.swift
//  SplashPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI

public struct SplashView: View {
    private let minimumDuration: TimeInterval
    private let onComplete: () -> Void

    @State private var isAnimating = false

    public init(
        minimumDuration: TimeInterval = 1.5,
        onComplete: @escaping () -> Void
    ) {
        self.minimumDuration = minimumDuration
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 140, height: 140)

                    Image(systemName: "heart.text.clipboard")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                }

                // App name
                Text("SimpleCare")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)

                // Tagline
                Text("건강한 하루를 기록하세요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + minimumDuration) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashView {
        print("Splash completed")
    }
}
