//
//  WelcomeStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

// MARK: - WelcomeStepView

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.scPrimary)

            VStack(spacing: 8) {
                Text("SimpleCare")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("onboarding.subtitle".localized)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                FeatureRow(icon: "fork.knife", text: "onboarding.feature.nutrition".localized)
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "onboarding.feature.weight".localized)
                FeatureRow(icon: "figure.run", text: "onboarding.feature.exercise".localized)
            }
            .padding()
            .glassCard(cornerRadius: 16)

            Spacer()

            Text("onboarding.disclaimer".localized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - FeatureRow

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.scPrimary)
                .frame(width: 40)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}
