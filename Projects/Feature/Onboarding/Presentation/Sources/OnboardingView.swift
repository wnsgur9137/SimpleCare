//
//  OnboardingView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import OnboardingDomain
import ProfileDomain

/// 온보딩 메인 뷰
public struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: viewModel.currentStep.progress)
                .tint(.blue)
                .padding(.horizontal)

            // Step content
            TabView(selection: Binding(
                get: { viewModel.currentStep },
                set: { viewModel.goToStep($0) }
            )) {
                WelcomeStepView()
                    .tag(OnboardingStep.welcome)

                BasicInfoStepView(viewModel: viewModel)
                    .tag(OnboardingStep.basicInfo)

                BodyInfoStepView(viewModel: viewModel)
                    .tag(OnboardingStep.bodyInfo)

                GoalSettingStepView(viewModel: viewModel)
                    .tag(OnboardingStep.goalSetting)

                ActivityLevelStepView(viewModel: viewModel)
                    .tag(OnboardingStep.activityLevel)

                SummaryStepView(viewModel: viewModel)
                    .tag(OnboardingStep.summary)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)

            // Navigation buttons
            HStack(spacing: 16) {
                if !viewModel.currentStep.isFirst {
                    Button("이전") {
                        viewModel.previousStep()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button(viewModel.currentStep.isLast ? "시작하기" : "다음") {
                    viewModel.nextStep()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canProceed)
            }
            .padding()
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        .alert("오류", isPresented: .constant(viewModel.error != nil)) {
            Button("확인") {
                // Clear error
            }
        } message: {
            if let error = viewModel.error {
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
                .foregroundStyle(.blue)

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
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

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
                .foregroundStyle(.blue)
                .frame(width: 40)

            Text(text)
                .font(.body)

            Spacer()
        }
    }
}

struct BasicInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "기본 정보",
                    subtitle: "이름과 나이, 성별을 알려주세요"
                )

                VStack(alignment: .leading, spacing: 16) {
                    Text("이름")
                        .font(.headline)
                    TextField("이름을 입력하세요", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("나이: \(viewModel.age)세")
                        .font(.headline)
                    Stepper("", value: $viewModel.age, in: 10...120)
                        .labelsHidden()
                    Slider(value: Binding(
                        get: { Double(viewModel.age) },
                        set: { viewModel.age = Int($0) }
                    ), in: 10...120, step: 1)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("성별")
                        .font(.headline)
                    Picker("성별", selection: $viewModel.biologicalSex) {
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
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                StepHeader(
                    title: "신체 정보",
                    subtitle: "키와 체중을 입력해주세요"
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("키")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f cm", viewModel.heightCm))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $viewModel.heightCm, in: 100...250, step: 0.5)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("현재 체중")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f kg", viewModel.currentWeightKg))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $viewModel.currentWeightKg, in: 30...200, step: 0.1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("목표 체중")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f kg", viewModel.targetWeightKg))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                    Slider(value: $viewModel.targetWeightKg, in: 30...200, step: 0.1)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct GoalSettingStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

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
                            isSelected: viewModel.goalType == goal
                        ) {
                            viewModel.goalType = goal
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
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
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
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
    @ObservedObject var viewModel: OnboardingViewModel

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
                            isSelected: viewModel.activityLevel == level
                        ) {
                            viewModel.activityLevel = level
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
                        .foregroundStyle(isSelected ? .blue : .primary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct SummaryStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(
                    title: "설정 완료",
                    subtitle: "입력하신 정보를 확인해주세요"
                )

                VStack(spacing: 16) {
                    SummaryRow(label: "이름", value: viewModel.name)
                    SummaryRow(label: "나이", value: "\(viewModel.age)세")
                    SummaryRow(label: "성별", value: viewModel.biologicalSex.displayName)
                    SummaryRow(label: "키", value: String(format: "%.1f cm", viewModel.heightCm))
                    SummaryRow(label: "현재 체중", value: String(format: "%.1f kg", viewModel.currentWeightKg))
                    SummaryRow(label: "목표 체중", value: String(format: "%.1f kg", viewModel.targetWeightKg))
                    SummaryRow(label: "목표", value: viewModel.goalType.displayName)
                    SummaryRow(label: "활동 수준", value: viewModel.activityLevel.displayName)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(spacing: 8) {
                    Text("일일 목표 칼로리")
                        .font(.headline)
                    Text("\(viewModel.calculatedCalories) kcal")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("기초대사량 \(Int(viewModel.calculatedBMR)) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))

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
