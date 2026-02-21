//
//  BodyInfoStepView.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import ComposableArchitecture
import BasePresentation

struct BodyInfoStepView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    // MARK: - Bindings

    private var heightWhole: Binding<Int> { wholePartBinding(for: $store.heightCm) }
    private var heightDecimal: Binding<Int> { decimalPartBinding(for: $store.heightCm) }

    private var currentWeightWhole: Binding<Int> { wholePartBinding(for: $store.currentWeightKg) }
    private var currentWeightDecimal: Binding<Int> { decimalPartBinding(for: $store.currentWeightKg) }

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

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                StepHeader(
                    title: "onboarding.step.bodyInfo".localized,
                    subtitle: "onboarding.step.bodyInfo.subtitle".localized
                )

                decimalPickerSection(
                    title: "profile.height".localized,
                    wholeBinding: heightWhole,
                    decimalBinding: heightDecimal,
                    wholeRange: 100...220,
                    unit: "unit.cm".localized
                )

                decimalPickerSection(
                    title: "onboarding.field.currentWeight".localized,
                    wholeBinding: currentWeightWhole,
                    decimalBinding: currentWeightDecimal,
                    wholeRange: 30...150,
                    unit: "unit.kg".localized,
                    tint: .scPrimary
                )

                decimalPickerSection(
                    title: "onboarding.field.targetWeight".localized,
                    wholeBinding: targetWeightWhole,
                    decimalBinding: targetWeightDecimal,
                    wholeRange: 30...150,
                    unit: "unit.kg".localized,
                    tint: .scSecondary
                )

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Components

    @ViewBuilder
    private func decimalPickerSection(
        title: String,
        wholeBinding: Binding<Int>,
        decimalBinding: Binding<Int>,
        wholeRange: ClosedRange<Int>,
        unit: String,
        tint: Color? = nil
    ) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Picker(title, selection: wholeBinding) {
                    ForEach(wholeRange, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()

                Text(".")
                    .font(.title2)
                    .fontWeight(.medium)

                Picker(title, selection: decimalBinding) {
                    ForEach(0...9, id: \.self) { decimal in
                        Text("\(decimal)").tag(decimal)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 60)
                .clipped()

                Text(unit)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .glassCard(tint: tint, cornerRadius: 16)
        }
    }
}
