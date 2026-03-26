//
//  WeightView.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import Charts
import ComposableArchitecture
import WeightDomain
import BasePresentation

/// 체중 관리 화면
public struct WeightView: View {
    @Bindable var store: StoreOf<WeightFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<WeightFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 알림 활성화 배너
                    NotificationEnableBanner(category: .weight)

                    // 현재 체중 입력
                    weightInputSection

                    // Empty State 배너
                    emptyStateBanner

                    // 목표 달성 프로그레스
                    if let trend = store.weightTrend, let startWeight = store.startWeight, !trend.records.isEmpty {
                        goalProgressSection(trend: trend, startWeight: startWeight)
                    }

                    // 추세 차트 (항상 표시)
                    if let trend = store.weightTrend {
                        trendChartSection(trend: trend)
                        statisticsSection(trend: trend)
                    }
                }
                .padding()
            }
            .navigationTitle("weight.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        store.send(.saveWeight)
                    }
                    .disabled(store.isLoading)
                }
            }
            .task {
                store.send(.onAppear)
            }
        }
    }

    @ViewBuilder
    private var emptyStateBanner: some View {
        if let trend = store.weightTrend, trend.records.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(.scPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("weight.empty.banner.title".localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("weight.empty.banner.description".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.scPrimary.opacity(0.1), in: .rect(cornerRadius: 12))
        }
    }

    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("weight.todayWeight".localized)
                .font(.headline)

            HStack {
                Text(String(format: "%.1f", store.newWeightKg))
                    .font(.system(size: 48, weight: .bold))
                Text("unit.kg".localized)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $store.newWeightKg, in: 30...200, step: 0.1)
                .accessibilityLabel("accessibility.weight.slider".localized)
                .accessibilityValue(String(format: "%.1f %@", store.newWeightKg, "unit.kg".localized))
                .accessibilityHint("accessibility.weight.sliderHint".localized)

            // 체성분 입력 (선택)
            DisclosureGroup("weight.bodyComposition".localized) {
                VStack(spacing: 12) {
                    HStack {
                        Text("weight.bodyFat".localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(store.bodyFatPercentage.map { String(format: "%.1f%%", $0) } ?? "--")
                            .font(.subheadline)
                            .frame(width: 55)
                    }
                    Slider(
                        value: Binding(
                            get: { store.bodyFatPercentage ?? 20.0 },
                            set: { store.bodyFatPercentage = $0 }
                        ),
                        in: 3...60,
                        step: 0.1
                    )

                    HStack {
                        Text("weight.skeletalMuscle".localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(store.skeletalMuscleMass.map { String(format: "%.1f kg", $0) } ?? "--")
                            .font(.subheadline)
                            .frame(width: 60)
                    }
                    Slider(
                        value: Binding(
                            get: { store.skeletalMuscleMass ?? 30.0 },
                            set: { store.skeletalMuscleMass = $0 }
                        ),
                        in: 10...60,
                        step: 0.1
                    )
                }
            }
            .font(.subheadline)

            TextField("weight.memo".localized, text: $store.notes)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    private func trendChartSection(trend: WeightTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("weight.trend".localized)
                    .font(.headline)

                Spacer()

                Picker("weight.period".localized, selection: Binding(
                    get: { store.selectedPeriod },
                    set: { store.send(.selectPeriod($0)) }
                )) {
                    ForEach(WeightFeature.State.TrendPeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            Chart {
                ForEach(trend.records) { record in
                    LineMark(
                        x: .value("common.date".localized, record.date),
                        y: .value("weight.current".localized, record.weightKg)
                    )
                    .foregroundStyle(.scPrimary)

                    PointMark(
                        x: .value("common.date".localized, record.date),
                        y: .value("weight.current".localized, record.weightKg)
                    )
                    .foregroundStyle(.scPrimary)
                }

                RuleMark(y: .value("weight.goal".localized, trend.targetWeight))
                    .foregroundStyle(.scSuccess)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("\("weight.goal".localized) \(String(format: "%.1f", trend.targetWeight))\("unit.kg".localized)")
                            .font(.caption2)
                            .foregroundStyle(.scSuccess)
                    }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .accessibilityLabel("accessibility.weight.chart".localized(with: trend.records.count))
            .overlay {
                if trend.records.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text("weight.noData".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    private func statisticsSection(trend: WeightTrend) -> some View {
        let isEmpty = trend.records.isEmpty

        func changeStatValue(for change: Double?) -> String {
            guard !isEmpty, let change = change else { return "--" }
            return String(format: "%+.1f", change)
        }

        func changeStatColor(for change: Double?) -> Color {
            guard !isEmpty, let change = change else { return .secondary }
            return change < 0 ? .scSuccess : .scWarning
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text("weight.stats".localized)
                .font(.headline)

            HStack(spacing: 24) {
                StatBox(
                    title: "weight.toGoal".localized,
                    value: isEmpty ? "--" : String(format: "%.1f", abs(trend.remainingToGoal)),
                    unit: "unit.kg".localized,
                    color: isEmpty ? .secondary : (trend.remainingToGoal > 0 ? .scWarning : .scSuccess)
                )

                StatBox(
                    title: "weight.weeklyChange".localized,
                    value: changeStatValue(for: trend.weeklyChange),
                    unit: "unit.kg".localized,
                    color: changeStatColor(for: trend.weeklyChange)
                )

                StatBox(
                    title: "weight.monthlyChange".localized,
                    value: changeStatValue(for: trend.monthlyChange),
                    unit: "unit.kg".localized,
                    color: changeStatColor(for: trend.monthlyChange)
                )

                if store.heightCm > 0 {
                    StatBox(
                        title: "weight.bmi".localized,
                        value: isEmpty ? "--" : String(format: "%.1f", store.currentBMI),
                        unit: isEmpty ? "" : bmiCategoryLabel,
                        color: isEmpty ? .secondary : bmiColor
                    )
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    /// 목표 달성 프로그레스 섹션 — 시작/현재/목표 체중과 달성률을 표시
    /// - Parameters:
    ///   - trend: 현재 체중 트렌드 데이터
    ///   - startWeight: 기록 시작 시점의 체중 (가장 오래된 기록)
    private func goalProgressSection(trend: WeightTrend, startWeight: Double) -> some View {
        let progress = trend.progressToGoal(from: startWeight)

        return VStack(alignment: .leading, spacing: 12) {
            Text("weight.goalProgress".localized)
                .font(.headline)

            ProgressView(value: progress)
                .tint(progress >= 1.0 ? .scSuccess : .scPrimary)

            HStack {
                VStack(alignment: .leading) {
                    Text("weight.start".localized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", startWeight))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                Spacer()
                VStack {
                    Text("weight.current".localized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", trend.currentWeight))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.scPrimary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("weight.goal".localized)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", trend.targetWeight))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

            Text(String(format: "weight.progressPercent".localized, Int(progress * 100)))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    private var bmiCategoryLabel: String {
        Color.bmiCategoryLabel(for: store.currentBMI)
    }

    private var bmiColor: Color {
        .bmiColor(for: store.currentBMI)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title), \(value) \(unit)")
    }
}

#Preview {
    WeightView(
        store: Store(
            initialState: WeightFeature.State(
                userProfileId: UUID(),
                currentWeight: 70,
                targetWeight: 65
            )
        ) {
            WeightFeature()
        }
    )
}
