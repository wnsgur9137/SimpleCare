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
                Section("profile.section.basic".localized) {
                    TextField("profile.name".localized, text: $store.name)

                    Stepper(
                        String(format: "profile.age.format".localized, store.age),
                        value: $store.age,
                        in: 10...120
                    )

                    Picker("profile.gender".localized, selection: $store.biologicalSex) {
                        ForEach(BiologicalSex.allCases, id: \.self) { sex in
                            Text(sex.displayName).tag(sex)
                        }
                    }
                }

                // 신체 정보 섹션
                Section("profile.section.body".localized) {
                    HStack {
                        Text("profile.height".localized)
                        Spacer()
                        Text(String(format: "%.1f %@", store.heightCm, "unit.cm".localized))
                    }
                    Slider(value: $store.heightCm, in: 100...250, step: 0.5)

                    HStack {
                        Text("profile.currentWeight".localized)
                        Spacer()
                        Text(String(format: "%.1f %@", store.currentWeightKg, "unit.kg".localized))
                    }
                    Slider(value: $store.currentWeightKg, in: 30...200, step: 0.1)

                    HStack {
                        Text("profile.targetWeight".localized)
                        Spacer()
                        Text(String(format: "%.1f %@", store.targetWeightKg, "unit.kg".localized))
                    }
                    Slider(value: $store.targetWeightKg, in: 30...200, step: 0.1)
                }

                // 활동 및 목표 섹션
                Section("profile.section.activityAndGoal".localized) {
                    Picker("profile.activityLevel".localized, selection: $store.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }

                    Picker("profile.goal".localized, selection: $store.goalType) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            Label(goal.displayName, systemImage: goal.icon).tag(goal)
                        }
                    }
                }

                // 계산된 정보 섹션
                Section("profile.section.estimatedCalories".localized) {
                    HStack {
                        Text("profile.bmr".localized)
                        Spacer()
                        Text("\(Int(store.calculatedBMR)) \("unit.kcal".localized)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("profile.tdee".localized)
                        Spacer()
                        Text("\(Int(store.calculatedTDEE)) \("unit.kcal".localized)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("profile.dailyCalorieGoal".localized)
                        Spacer()
                        Text("\(store.recommendedCalories) \("unit.kcal".localized)")
                            .foregroundStyle(.scPrimary)
                            .fontWeight(.semibold)
                    }
                }

                // BMI 섹션
                Section("profile.section.bmi".localized) {
                    HStack {
                        Text("profile.bmi".localized)
                        Spacer()
                        Text(String(format: "%.1f", store.calculatedBMI))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(bmiColor)
                    }

                    HStack {
                        Text("profile.bmiCategory".localized)
                        Spacer()
                        Text(store.bmiCategory)
                            .foregroundStyle(bmiColor)
                            .fontWeight(.medium)
                    }
                }

                // 면책 조항
                Section {
                    Text("onboarding.disclaimer".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("profile.title".localized)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
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
