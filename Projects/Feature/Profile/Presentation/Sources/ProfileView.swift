//
//  ProfileView.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ProfileDomain

/// 프로필 화면
public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    public init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 기본 정보 섹션
                Section("기본 정보") {
                    TextField("이름", text: $viewModel.name)

                    Stepper(
                        "나이: \(viewModel.age)세",
                        value: $viewModel.age,
                        in: 10...120
                    )

                    Picker("성별", selection: $viewModel.biologicalSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.displayName).tag(sex)
                        }
                    }
                }

                // 신체 정보 섹션
                Section("신체 정보") {
                    HStack {
                        Text("키")
                        Spacer()
                        Text(String(format: "%.1f cm", viewModel.heightCm))
                    }
                    Slider(value: $viewModel.heightCm, in: 100...250, step: 0.5)

                    HStack {
                        Text("현재 체중")
                        Spacer()
                        Text(String(format: "%.1f kg", viewModel.currentWeightKg))
                    }
                    Slider(value: $viewModel.currentWeightKg, in: 30...200, step: 0.1)

                    HStack {
                        Text("목표 체중")
                        Spacer()
                        Text(String(format: "%.1f kg", viewModel.targetWeightKg))
                    }
                    Slider(value: $viewModel.targetWeightKg, in: 30...200, step: 0.1)
                }

                // 활동 및 목표 섹션
                Section("활동 및 목표") {
                    Picker("활동 수준", selection: $viewModel.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }

                    Picker("목표", selection: $viewModel.goalType) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            Label(goal.displayName, systemImage: goal.icon).tag(goal)
                        }
                    }
                }

                // 계산된 정보 섹션
                Section("예상 칼로리") {
                    HStack {
                        Text("기초대사량 (BMR)")
                        Spacer()
                        Text("\(Int(viewModel.calculatedBMR)) kcal")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("일일 소비량 (TDEE)")
                        Spacer()
                        Text("\(Int(viewModel.calculatedTDEE)) kcal")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("일일 목표 칼로리")
                        Spacer()
                        Text("\(viewModel.recommendedCalories) kcal")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }

                // 면책 조항
                Section {
                    Text("이 정보는 추정치이며 실제 값과 다를 수 있습니다. 정확한 건강 조언은 전문가와 상담하세요.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            try? await viewModel.saveProfile()
                        }
                    }
                }
            }
            .task {
                await viewModel.loadProfile()
            }
        }
    }
}

#Preview {
    // Preview를 위한 Mock
    let mockGetUseCase = MockGetUserProfileUseCase()
    let mockSaveUseCase = MockSaveUserProfileUseCase()
    let mockUpdateUseCase = MockUpdateUserProfileUseCase()

    ProfileView(viewModel: ProfileViewModel(
        getProfileUseCase: mockGetUseCase,
        saveProfileUseCase: mockSaveUseCase,
        updateProfileUseCase: mockUpdateUseCase
    ))
}

// MARK: - Preview Mocks

private struct MockGetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    func execute() async throws -> UserProfile? {
        nil
    }
}

private struct MockSaveUserProfileUseCase: SaveUserProfileUseCaseProtocol {
    func execute(profile: UserProfile) async throws {}
}

private struct MockUpdateUserProfileUseCase: UpdateUserProfileUseCaseProtocol {
    func execute(profile: UserProfile) async throws {}
}
