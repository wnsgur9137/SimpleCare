//
//  GoalSettingStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import ProfileDomain
import BasePresentation

// MARK: - GoalSettingStepView

struct GoalSettingStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "onboarding.step.goal".localized,
                    subtitle: "onboarding.step.goal.subtitle".localized
                )

                VStack(spacing: 16) {
                    ForEach(GoalType.allCases, id: \.self) { goal in
                        GoalOptionCard(
                            goal: goal,
                            isSelected: store.goalType == goal
                        ) {
                            store.goalType = goal
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - GoalOptionCard

struct GoalOptionCard: View {
    let goal: GoalType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.title)
                    .foregroundStyle(isSelected ? .white : .scPrimary)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.scPrimary : Color.scPrimary.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)

                    Text(goalDescription(for: goal))
                        .font(.caption)
                        .opacity(isSelected ? 0.8 : 1.0)
                        .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            .contentShape(Rectangle())
            .glassCard(tint: isSelected ? .scPrimary : nil, cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func goalDescription(for goal: GoalType) -> String {
        switch goal {
        case .weightLoss: return "onboarding.goal.lose.description".localized
        case .weightGain: return "onboarding.goal.gain.description".localized
        case .maintenance: return "onboarding.goal.maintain.description".localized
        }
    }
}
