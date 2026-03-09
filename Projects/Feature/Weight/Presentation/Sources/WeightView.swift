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
