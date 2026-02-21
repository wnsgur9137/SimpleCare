//
//  OnboardingView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import OnboardingDomain
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

#Preview {
    OnboardingView(
        store: Store(initialState: OnboardingFeature.State()) {
            OnboardingFeature()
        }
    )
}
