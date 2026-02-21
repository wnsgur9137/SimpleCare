//
//  BasicInfoStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import ProfileDomain
import BasePresentation

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
