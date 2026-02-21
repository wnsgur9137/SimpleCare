//
//  SummaryStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation

// MARK: - SummaryStepView

struct SummaryStepView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(
                    title: "onboarding.step.summary".localized,
                    subtitle: "onboarding.step.summary.subtitle".localized
                )

                VStack(spacing: 16) {
                    SummaryRow(label: "profile.name".localized, value: store.name)
                    SummaryRow(label: "profile.age".localized, value: "\(store.age)\("onboarding.field.age.unit".localized)")
                    SummaryRow(label: "profile.gender".localized, value: store.biologicalSex.displayName)
                    SummaryRow(label: "profile.height".localized, value: String(format: "%.1f \("unit.cm".localized)", store.heightCm))
                    SummaryRow(
                        label: "onboarding.field.currentWeight".localized,
                        value: String(format: "%.1f \("unit.kg".localized)", store.currentWeightKg)
                    )
                    SummaryRow(
                        label: "onboarding.field.targetWeight".localized,
                        value: String(format: "%.1f \("unit.kg".localized)", store.targetWeightKg)
                    )
                    SummaryRow(label: "profile.goal".localized, value: store.goalType.displayName)
                    SummaryRow(label: "profile.activityLevel".localized, value: store.activityLevel.displayName)
                }
                .padding()
                .glassCard(cornerRadius: 16)

                VStack(spacing: 8) {
                    Text("onboarding.summary.dailyCalories".localized)
                        .font(.headline)
                    Text("\(store.calculatedCalories) \("unit.kcal".localized)")
                        .font(.system(size: 48, weight: .bold))
                    Text("onboarding.summary.bmr".localized + " \(Int(store.calculatedBMR)) \("unit.kcal".localized)")
                        .font(.caption)
                        .opacity(0.8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .glassCard(tint: .scPrimary, cornerRadius: 16)

                Text("onboarding.summary.disclaimer".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - SummaryRow

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
