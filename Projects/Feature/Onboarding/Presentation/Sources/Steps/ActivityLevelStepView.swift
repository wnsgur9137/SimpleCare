//
//  ActivityLevelStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import ProfileDomain
import BasePresentation

// MARK: - ActivityLevelStepView

struct ActivityLevelStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "onboarding.step.activity".localized,
                    subtitle: "onboarding.step.activity.subtitle".localized
                )

                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelRow(
                            level: level,
                            isSelected: store.activityLevel == level
                        ) {
                            store.activityLevel = level
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - ActivityLevelRow

struct ActivityLevelRow: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            .contentShape(Rectangle())
            .glassCard(tint: isSelected ? .scPrimary : nil, cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }
}
