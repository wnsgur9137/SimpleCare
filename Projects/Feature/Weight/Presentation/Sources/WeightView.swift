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
                    // 현재 체중 입력
                    weightInputSection

                    // 추세 차트
                    if let trend = store.weightTrend, !trend.records.isEmpty {
                        trendChartSection(trend: trend)
                        statisticsSection(trend: trend)
                    }
                }
                .padding()
            }
            .navigationTitle("체중 관리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
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

    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("오늘의 체중")
                .font(.headline)

            HStack {
                Text(String(format: "%.1f", store.newWeightKg))
                    .font(.system(size: 48, weight: .bold))
                Text("kg")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Slider(value: $store.newWeightKg, in: 30...200, step: 0.1)

            TextField("메모 (선택)", text: $store.notes)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func trendChartSection(trend: WeightTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("체중 변화")
                .font(.headline)

            Chart(trend.records) { record in
                LineMark(
                    x: .value("날짜", record.date),
                    y: .value("체중", record.weightKg)
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value("날짜", record.date),
                    y: .value("체중", record.weightKg)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }

            // 목표선
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("목표: \(String(format: "%.1f", trend.targetWeight)) kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statisticsSection(trend: WeightTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("통계")
                .font(.headline)

            HStack(spacing: 24) {
                StatBox(
                    title: "목표까지",
                    value: String(format: "%.1f", abs(trend.remainingToGoal)),
                    unit: "kg",
                    color: trend.remainingToGoal > 0 ? .orange : .green
                )

                if let weekly = trend.weeklyChange {
                    StatBox(
                        title: "주간 변화",
                        value: String(format: "%+.1f", weekly),
                        unit: "kg",
                        color: weekly < 0 ? .green : .orange
                    )
                }

                if let monthly = trend.monthlyChange {
                    StatBox(
                        title: "월간 변화",
                        value: String(format: "%+.1f", monthly),
                        unit: "kg",
                        color: monthly < 0 ? .green : .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
