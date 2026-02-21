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
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 4)
                    Capsule()
                        .fill(Color.scPrimary)
                        .frame(width: geometry.size.width * store.currentStep.progress, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.3), value: store.currentStep)

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
            HStack(spacing: 12) {
                if !store.currentStep.isFirst {
                    Button {
                        store.send(.previousStep)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .frame(width: 48, height: 48)
                            .glassCard(cornerRadius: 12)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    store.send(.nextStep)
                } label: {
                    Text(store.currentStep.isLast ? "onboarding.startUsing".localized : "common.next".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.scPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(!store.canProceed)
                .opacity(store.canProceed ? 1.0 : 0.5)
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
