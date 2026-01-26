//
//  MealRecordView.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture
import MealDomain

/// 식사 기록 화면
public struct MealRecordView: View {
    @Bindable var store: StoreOf<MealFeature>
    @State private var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<MealFeature>) {
        self.store = store
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
                    if !store.estimatedFoods.isEmpty {
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
                        store.send(.saveMeal)
                    }
                    .disabled(!store.canSave)
                }
            }
            .overlay {
                if store.viewState == .loading || store.viewState == .estimating {
                    loadingOverlay
                }
            }
            .alert("오류", isPresented: .constant(store.viewState.isError)) {
                Button("확인") { store.send(.dismissError) }
            } message: {
                if case .error(let message) = store.viewState {
                    Text(message)
                }
            }
            .onChange(of: store.viewState) { _, newState in
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

            Picker("식사 유형", selection: $store.mealType) {
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
                    TextField("예: 김치찌개 1인분, 공기밥", text: $store.foodDescription, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        store.send(.estimateFromText)
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.title2)
                    }
                    .disabled(store.foodDescription.isEmpty)
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
                                store.selectedImageData = data
                                store.send(.estimateFromImage)
                            }
                        }
                    }

                    if store.selectedImageData != nil {
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
                NutritionBadge(label: "칼로리", value: "\(store.totalCalories)", unit: "kcal", color: .blue)
                NutritionBadge(label: "단백질", value: String(format: "%.1f", store.totalProtein), unit: "g", color: .red)
                NutritionBadge(label: "탄수화물", value: String(format: "%.1f", store.totalCarbs), unit: "g", color: .orange)
                NutritionBadge(label: "지방", value: String(format: "%.1f", store.totalFat), unit: "g", color: .yellow)
            }

            // 개별 음식
            ForEach(Array(store.estimatedFoods.enumerated()), id: \.element.name) { index, food in
                EstimatedFoodRow(food: food) {
                    store.send(.removeFood(index))
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

            TextField("메모를 입력하세요", text: $store.notes, axis: .vertical)
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
                Text(store.viewState == .estimating ? "AI가 분석 중..." : "저장 중...")
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

#Preview {
    MealRecordView(
        store: Store(
            initialState: MealFeature.State(userProfileId: UUID())
        ) {
            MealFeature()
        }
    )
}
