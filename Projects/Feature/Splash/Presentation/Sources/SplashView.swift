//
//  SplashView.swift
//  SplashPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation

public struct SplashView: View {
    @Bindable var store: StoreOf<SplashFeature>

    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.scPrimary.opacity(0.6), Color.scAccent.opacity(0.4)],
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
                        .scaleEffect(store.isAnimating ? 1.0 : 0.8)
                        .opacity(store.isAnimating ? 1.0 : 0.5)
                }

                // App name
                Text("SimpleCare")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(store.isAnimating ? 1.0 : 0.0)

                // Tagline
                Text("건강한 하루를 기록하세요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .opacity(store.isAnimating ? 1.0 : 0.0)
            }
        }
        .animation(.easeOut(duration: 0.6), value: store.isAnimating)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SplashView(
        store: Store(initialState: SplashFeature.State()) {
            SplashFeature()
        }
    )
}
