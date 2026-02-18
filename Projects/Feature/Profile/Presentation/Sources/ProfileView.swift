//
//  ProfileView.swift
//  ProfilePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import ProfileDomain
import BasePresentation

/// 프로필 화면
public struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                // 기본 정보 섹션
                Section("기본 정보") {
                    TextField("이름", text: $store.name)

                    Stepper(
                        "나이: \(store.age)세",
                        value: $store.age,
                        in: 10...120
                    )

                    Picker("성별", selection: $store.biologicalSex) {
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
                        Text(String(format: "%.1f cm", store.heightCm))
                    }
                    Slider(value: $store.heightCm, in: 100...250, step: 0.5)

                    HStack {
                        Text("현재 체중")
                        Spacer()
                        Text(String(format: "%.1f kg", store.currentWeightKg))
                    }
                    Slider(value: $store.currentWeightKg, in: 30...200, step: 0.1)

                    HStack {
                        Text("목표 체중")
                        Spacer()
                        Text(String(format: "%.1f kg", store.targetWeightKg))
                    }
                    Slider(value: $store.targetWeightKg, in: 30...200, step: 0.1)
                }

                // 활동 및 목표 섹션
                Section("활동 및 목표") {
                    Picker("활동 수준", selection: $store.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }

                    Picker("목표", selection: $store.goalType) {
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
                        Text("\(Int(store.calculatedBMR)) kcal")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("일일 소비량 (TDEE)")
                        Spacer()
                        Text("\(Int(store.calculatedTDEE)) kcal")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("일일 목표 칼로리")
                        Spacer()
                        Text("\(store.recommendedCalories) kcal")
                            .foregroundStyle(.scPrimary)
                            .fontWeight(.semibold)
                    }
                }

                // BMI 섹션
                Section("BMI (체질량 지수)") {
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(String(format: "%.1f", store.calculatedBMI))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(bmiColor)
                    }

                    HStack {
                        Text("범위")
                        Spacer()
                        Text(store.bmiCategory)
                            .foregroundStyle(bmiColor)
                            .fontWeight(.medium)
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
                        store.send(.saveProfile)
                    }
                }
            }
            .task {
                store.send(.onAppear)
            }
        }
    }

    private var bmiColor: Color {
        .bmiColor(for: store.calculatedBMI)
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}
