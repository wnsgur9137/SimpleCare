//
//  OnboardingView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import OnboardingDomain
import ProfileDomain
import BasePresentation

/// 온보딩 메인 뷰
public struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: store.currentStep.progress)
                .tint(.scPrimary)
                .padding(.horizontal)

            // Step content
            TabView(selection: $store.currentStep.sending(\.goToStep)) {
                WelcomeStepView()
                    .tag(OnboardingStep.welcome)

                BasicInfoStepView(store: store)
                    .tag(OnboardingStep.basicInfo)

                BodyInfoStepView(store: store)
                    .tag(OnboardingStep.bodyInfo)

                GoalSettingStepView(store: store)
                    .tag(OnboardingStep.goalSetting)

                ActivityLevelStepView(store: store)
                    .tag(OnboardingStep.activityLevel)

                SummaryStepView(store: store)
                    .tag(OnboardingStep.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: store.currentStep)

            // Navigation buttons
            HStack(spacing: 16) {
                if !store.currentStep.isFirst {
                    Button("common.back".localized) {
                        store.send(.previousStep)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button(store.currentStep.isLast ? "onboarding.startUsing".localized : "common.next".localized) {
                    store.send(.nextStep)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!store.canProceed)
            }
            .padding()
        }
        .overlay {
            if store.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert("common.error".localized, isPresented: .constant(store.error != nil)) {
            Button("common.confirm".localized) {
                // Clear error handled by binding
            }
        } message: {
            if let error = store.error {
                Text(error)
            }
        }
    }
}

// MARK: - Step Views

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

struct BasicInfoStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "onboarding.step.basicInfo".localized,
                    subtitle: "onboarding.step.basicInfo.subtitle".localized
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("profile.name".localized)
                        .font(.headline)
                    TextField("onboarding.field.name.placeholder".localized, text: $store.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                }

                VStack(spacing: 8) {
                    Text("profile.age".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("profile.age".localized, selection: $store.age) {
                            ForEach(10...100, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()

                        Text("onboarding.field.age.unit".localized)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassCard(cornerRadius: 16)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("profile.gender".localized)
                        .font(.headline)
                    Picker("profile.gender".localized, selection: $store.biologicalSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.displayName).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct BodyInfoStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    // 키: 정수부와 소수부 분리
    private var heightWhole: Binding<Int> { wholePartBinding(for: $store.heightCm) }
    private var heightDecimal: Binding<Int> { decimalPartBinding(for: $store.heightCm) }

    // 현재 체중: 정수부와 소수부 분리
    private var currentWeightWhole: Binding<Int> { wholePartBinding(for: $store.currentWeightKg) }
    private var currentWeightDecimal: Binding<Int> { decimalPartBinding(for: $store.currentWeightKg) }

    // 목표 체중: 정수부와 소수부 분리
    private var targetWeightWhole: Binding<Int> { wholePartBinding(for: $store.targetWeightKg) }
    private var targetWeightDecimal: Binding<Int> { decimalPartBinding(for: $store.targetWeightKg) }

    private func wholePartBinding(for binding: Binding<Double>) -> Binding<Int> {
        Binding(
            get: { Int(binding.wrappedValue) },
            set: { binding.wrappedValue = Double($0) + (binding.wrappedValue - Double(Int(binding.wrappedValue))) }
        )
    }

    private func decimalPartBinding(for binding: Binding<Double>) -> Binding<Int> {
        Binding(
            get: { Int((binding.wrappedValue - Double(Int(binding.wrappedValue))) * 10) },
            set: { binding.wrappedValue = Double(Int(binding.wrappedValue)) + Double($0) / 10.0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(
                    title: "onboarding.step.bodyInfo".localized,
                    subtitle: "onboarding.step.bodyInfo.subtitle".localized
                )

                // 키 입력
                VStack(spacing: 8) {
                    Text("profile.height".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("profile.height".localized, selection: heightWhole) {
                            ForEach(100...220, id: \.self) { cm in
                                Text("\(cm)").tag(cm)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text(".")
                            .font(.title2)
                            .fontWeight(.medium)

                        Picker("profile.height".localized, selection: heightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("unit.cm".localized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassCard(cornerRadius: 16)
                }

                // 현재 체중 입력
                VStack(spacing: 8) {
                    Text("onboarding.field.currentWeight".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("profile.weight".localized, selection: currentWeightWhole) {
                            ForEach(30...150, id: \.self) { kg in
                                Text("\(kg)").tag(kg)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text(".")
                            .font(.title2)
                            .fontWeight(.medium)

                        Picker("profile.weight".localized, selection: currentWeightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("unit.kg".localized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassCard(tint: .scPrimary, cornerRadius: 16)
                }

                // 목표 체중 입력
                VStack(spacing: 8) {
                    Text("onboarding.field.targetWeight".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("onboarding.field.targetWeight".localized, selection: targetWeightWhole) {
                            ForEach(30...150, id: \.self) { kg in
                                Text("\(kg)").tag(kg)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        .clipped()

                        Text(".")
                            .font(.title2)
                            .fontWeight(.medium)

                        Picker("onboarding.field.targetWeight".localized, selection: targetWeightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("unit.kg".localized)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassCard(tint: .scSuccess, cornerRadius: 16)
                }

                Spacer()
            }
            .padding()
        }
    }
}

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
                        .foregroundStyle(isSelected ? .white : .primary)

                    Text(goalDescription(for: goal))
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
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
                        .foregroundStyle(isSelected ? .scPrimary : .primary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.scPrimary)
                }
            }
            .padding()
            .contentShape(Rectangle())
            .glassCard(tint: isSelected ? .scPrimary : nil, cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }
}

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
                        .foregroundStyle(.scPrimary)
                    Text("onboarding.summary.bmr".localized + " \(Int(store.calculatedBMR)) \("unit.kcal".localized)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

struct StepHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom)
    }
}

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
