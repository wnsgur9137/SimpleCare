//
//  MealRecordView.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import PhotosUI
import MealDomain

/// 식사 기록 화면
public struct MealRecordView: View {
    @StateObject private var viewModel: MealRecordViewModel
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: MealRecordViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 식사 유형 선택
                    mealTypeSection

                    // 입력 방식 선택
                    inputSection

                    // 추정 결과
                    if !viewModel.estimatedFoods.isEmpty {
                        estimatedFoodsSection
                    }

                    // 메모
                    notesSection
                }
                .padding()
            }
            .navigationTitle("식사 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task { await viewModel.saveMeal() }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .overlay {
                if viewModel.state == .loading || viewModel.state == .estimating {
                    loadingOverlay
                }
            }
            .alert("오류", isPresented: .constant(viewModel.state.isError)) {
                Button("확인") { viewModel.dismissError() }
            } message: {
                if case .error(let message) = viewModel.state {
                    Text(message)
                }
            }
            .onChange(of: viewModel.state) { _, newState in
                if newState == .success {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Sections

    private var mealTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("식사 유형")
                .font(.headline)

            Picker("식사 유형", selection: $viewModel.mealType) {
                ForEach(MealType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("음식 입력")
                .font(.headline)

            // 텍스트 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("텍스트로 입력")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("예: 김치찌개 1인분, 공기밥", text: $viewModel.foodDescription, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        Task { await viewModel.estimateFromText() }
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.title2)
                    }
                    .disabled(viewModel.foodDescription.isEmpty)
                }
            }

            Divider()

            // 이미지 입력
            VStack(alignment: .leading, spacing: 8) {
                Text("사진으로 입력")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Label("사진 선택", systemImage: "photo")
                    }
                    .buttonStyle(.bordered)
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                viewModel.selectedImageData = data
                                await viewModel.estimateFromImage()
                            }
                        }
                    }

                    if viewModel.selectedImageData != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var estimatedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("추정 결과")
                    .font(.headline)
                Spacer()
                Text("AI 추정치")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 총합
            HStack(spacing: 16) {
                NutritionBadge(label: "칼로리", value: "\(viewModel.totalCalories)", unit: "kcal", color: .blue)
                NutritionBadge(label: "단백질", value: String(format: "%.1f", viewModel.totalProtein), unit: "g", color: .red)
                NutritionBadge(label: "탄수화물", value: String(format: "%.1f", viewModel.totalCarbs), unit: "g", color: .orange)
                NutritionBadge(label: "지방", value: String(format: "%.1f", viewModel.totalFat), unit: "g", color: .yellow)
            }

            // 개별 음식
            ForEach(Array(viewModel.estimatedFoods.enumerated()), id: \.element.name) { index, food in
                EstimatedFoodRow(food: food) {
                    viewModel.removeFood(at: index)
                }
            }

            Text("AI 추정치는 참고용이며 실제와 다를 수 있습니다")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모 (선택)")
                .font(.headline)

            TextField("메모를 입력하세요", text: $viewModel.notes, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(viewModel.state == .estimating ? "AI가 분석 중..." : "저장 중...")
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Supporting Views

struct NutritionBadge: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EstimatedFoodRow: View {
    let food: EstimatedFoodItem
    let onRemove: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text("\(Int(food.servingSize))\(food.servingUnit) · \(food.calories)kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if food.confidence < 0.7 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - State Extension

extension MealRecordViewState {
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}
