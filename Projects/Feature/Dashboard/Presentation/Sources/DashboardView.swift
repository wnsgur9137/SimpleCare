//
//  DashboardView.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import Charts
import DashboardDomain

/// 대시보드 메인 화면
public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 날짜 선택
                    dateNavigationSection

                    // AI 인사이트
                    insightSection

                    // 칼로리 요약
                    if let summary = viewModel.dailySummary {
                        calorieSummarySection(summary: summary)

                        // 영양소 차트
                        nutritionChartSection(summary: summary)

                        // 상세 정보
                        detailsSection(summary: summary)
                    }
                }
                .padding()
            }
            .navigationTitle("대시보드")
            .refreshable {
                await viewModel.refreshData()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .overlay {
                if viewModel.state == .loading && viewModel.dailySummary == nil {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Sections

    private var dateNavigationSection: some View {
        HStack {
            Button {
                viewModel.goToPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }

            Spacer()

            VStack {
                Text(viewModel.isToday ? "오늘" : formattedDate)
                    .font(.title2)
                    .fontWeight(.bold)

                if !viewModel.isToday {
                    Text(formattedWeekday)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                viewModel.goToNextDay()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
            .disabled(!viewModel.canGoToNextDay)
        }
        .padding(.horizontal)
    }

    private var insightSection: some View {
        HStack(spacing: 12) {
            Text(viewModel.insight.emoji)
                .font(.largeTitle)

            Text(viewModel.insight.comment)
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func calorieSummarySection(summary: DailySummary) -> some View {
        VStack(spacing: 16) {
            // 원형 프로그레스
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)

                Circle()
                    .trim(from: 0, to: min(summary.calorieProgress, 1.0))
                    .stroke(
                        calorieColor(for: summary.calorieStatus),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: summary.calorieProgress)

                VStack(spacing: 4) {
                    Text("\(summary.totalCalories)")
                        .font(.system(size: 36, weight: .bold))

                    Text("/ \(summary.goalCalories) kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(summary.calorieStatus.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(calorieColor(for: summary.calorieStatus))
                }
            }
            .frame(width: 200, height: 200)

            // 남은 칼로리
            HStack(spacing: 24) {
                VStack {
                    Text("남은 칼로리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(summary.remainingCalories)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(summary.remainingCalories >= 0 ? .green : .red)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if summary.exerciseCalories > 0 {
                    VStack {
                        Text("운동 소모")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(summary.exerciseCalories)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func nutritionChartSection(summary: DailySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("영양소 섭취량")
                .font(.headline)

            Chart {
                BarMark(
                    x: .value("영양소", "단백질"),
                    y: .value("섭취량", summary.totalProtein)
                )
                .foregroundStyle(.red)

                BarMark(
                    x: .value("영양소", "탄수화물"),
                    y: .value("섭취량", summary.totalCarbs)
                )
                .foregroundStyle(.orange)

                BarMark(
                    x: .value("영양소", "지방"),
                    y: .value("섭취량", summary.totalFat)
                )
                .foregroundStyle(.yellow)
            }
            .frame(height: 200)

            HStack(spacing: 16) {
                NutritionLegend(color: .red, label: "단백질", value: String(format: "%.1fg", summary.totalProtein))
                NutritionLegend(color: .orange, label: "탄수화물", value: String(format: "%.1fg", summary.totalCarbs))
                NutritionLegend(color: .yellow, label: "지방", value: String(format: "%.1fg", summary.totalFat))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func detailsSection(summary: DailySummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 기록")
                .font(.headline)

            HStack {
                Label("\(summary.mealCount)회 식사", systemImage: "fork.knife")
                Spacer()
                if summary.exerciseCalories > 0 {
                    Label("\(summary.exerciseCalories)kcal 운동", systemImage: "figure.run")
                }
            }
            .font(.body)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: viewModel.selectedDate)
    }

    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: viewModel.selectedDate)
    }

    private func calorieColor(for status: CalorieStatus) -> Color {
        switch status {
        case .under: return .orange
        case .onTrack: return .green
        case .over: return .red
        }
    }
}

// MARK: - Supporting Views

struct NutritionLegend: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
