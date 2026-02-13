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
                    Button("이전") {
                        store.send(.previousStep)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button(store.currentStep.isLast ? "시작하기" : "다음") {
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
        .alert("오류", isPresented: .constant(store.error != nil)) {
            Button("확인") {
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

                Text("건강한 식습관을 위한\n스마트한 파트너")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                FeatureRow(icon: "fork.knife", text: "AI 기반 영양 분석")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "체중 및 목표 관리")
                FeatureRow(icon: "figure.run", text: "운동 칼로리 추적")
            }
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 16))

            Spacer()

            Text("AI 추정치는 참고용이며 의료적 조언이 아닙니다")
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
                    title: "기본 정보",
                    subtitle: "이름과 나이, 성별을 알려주세요"
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("이름")
                        .font(.headline)
                    TextField("이름을 입력하세요", text: $store.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                }

                VStack(spacing: 8) {
                    Text("나이")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("나이", selection: $store.age) {
                            ForEach(10...100, id: \.self) { age in
                                Text("\(age)").tag(age)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()

                        Text("세")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("성별")
                        .font(.headline)
                    Picker("성별", selection: $store.biologicalSex) {
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
    private var heightWhole: Binding<Int> {
        Binding(
            get: { Int(store.heightCm) },
            set: { store.heightCm = Double($0) + (store.heightCm - Double(Int(store.heightCm))) }
        )
    }

    private var heightDecimal: Binding<Int> {
        Binding(
            get: { Int((store.heightCm - Double(Int(store.heightCm))) * 10) },
            set: { store.heightCm = Double(Int(store.heightCm)) + Double($0) / 10.0 }
        )
    }

    // 현재 체중: 정수부와 소수부 분리
    private var currentWeightWhole: Binding<Int> {
        Binding(
            get: { Int(store.currentWeightKg) },
            set: { store.currentWeightKg = Double($0) + (store.currentWeightKg - Double(Int(store.currentWeightKg))) }
        )
    }

    private var currentWeightDecimal: Binding<Int> {
        Binding(
            get: { Int((store.currentWeightKg - Double(Int(store.currentWeightKg))) * 10) },
            set: { store.currentWeightKg = Double(Int(store.currentWeightKg)) + Double($0) / 10.0 }
        )
    }

    // 목표 체중: 정수부와 소수부 분리
    private var targetWeightWhole: Binding<Int> {
        Binding(
            get: { Int(store.targetWeightKg) },
            set: { store.targetWeightKg = Double($0) + (store.targetWeightKg - Double(Int(store.targetWeightKg))) }
        )
    }

    private var targetWeightDecimal: Binding<Int> {
        Binding(
            get: { Int((store.targetWeightKg - Double(Int(store.targetWeightKg))) * 10) },
            set: { store.targetWeightKg = Double(Int(store.targetWeightKg)) + Double($0) / 10.0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(
                    title: "신체 정보",
                    subtitle: "키와 체중을 입력해주세요"
                )

                // 키 입력
                VStack(spacing: 8) {
                    Text("키")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("키 정수", selection: heightWhole) {
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

                        Picker("키 소수", selection: heightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("cm")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                }

                // 현재 체중 입력
                VStack(spacing: 8) {
                    Text("현재 체중")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("체중 정수", selection: currentWeightWhole) {
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

                        Picker("체중 소수", selection: currentWeightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("kg")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular.tint(.scPrimary), in: .rect(cornerRadius: 16))
                }

                // 목표 체중 입력
                VStack(spacing: 8) {
                    Text("목표 체중")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        Picker("목표 체중 정수", selection: targetWeightWhole) {
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

                        Picker("목표 체중 소수", selection: targetWeightDecimal) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text("\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60)
                        .clipped()

                        Text("kg")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular.tint(.scSuccess), in: .rect(cornerRadius: 16))
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
                    title: "목표 설정",
                    subtitle: "어떤 목표를 달성하고 싶으신가요?"
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
            .glassCard(tint: isSelected ? .scPrimary : .clear, cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func goalDescription(for goal: GoalType) -> String {
        switch goal {
        case .weightLoss: return "일일 칼로리 -500kcal 목표"
        case .weightGain: return "일일 칼로리 +300kcal 목표"
        case .maintenance: return "현재 체중 유지"
        }
    }
}

struct ActivityLevelStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "활동 수준",
                    subtitle: "평소 운동량을 선택해주세요"
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
            .glassCard(tint: isSelected ? .scPrimary : .clear, cornerRadius: 12)
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
                    title: "설정 완료",
                    subtitle: "입력하신 정보를 확인해주세요"
                )

                VStack(spacing: 16) {
                    SummaryRow(label: "이름", value: store.name)
                    SummaryRow(label: "나이", value: "\(store.age)세")
                    SummaryRow(label: "성별", value: store.biologicalSex.displayName)
                    SummaryRow(label: "키", value: String(format: "%.1f cm", store.heightCm))
                    SummaryRow(label: "현재 체중", value: String(format: "%.1f kg", store.currentWeightKg))
                    SummaryRow(label: "목표 체중", value: String(format: "%.1f kg", store.targetWeightKg))
                    SummaryRow(label: "목표", value: store.goalType.displayName)
                    SummaryRow(label: "활동 수준", value: store.activityLevel.displayName)
                }
                .padding()
                .glassEffect(.regular, in: .rect(cornerRadius: 16))

                VStack(spacing: 8) {
                    Text("일일 목표 칼로리")
                        .font(.headline)
                    Text("\(store.calculatedCalories) kcal")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.scPrimary)
                    Text("기초대사량 \(Int(store.calculatedBMR)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(.scPrimary), in: .rect(cornerRadius: 16))

                Text("이 정보는 Mifflin-St Jeor 공식을 기반으로 한 추정치입니다. 정확한 건강 조언은 전문가와 상담하세요.")
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
