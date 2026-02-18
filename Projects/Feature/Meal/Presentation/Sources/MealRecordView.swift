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
import BasePresentation

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

                    // 즐겨찾기
                    favoritesSection

                    // 최근 기록
                    recentMealsSection

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
                            .foregroundStyle(.scSuccess)
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
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
                NutritionBadge(label: "칼로리", value: "\(store.totalCalories)", unit: "kcal", color: .scCalories)
                NutritionBadge(label: "단백질", value: String(format: "%.1f", store.totalProtein), unit: "g", color: .scProtein)
                NutritionBadge(label: "탄수화물", value: String(format: "%.1f", store.totalCarbs), unit: "g", color: .scCarbs)
                NutritionBadge(label: "지방", value: String(format: "%.1f", store.totalFat), unit: "g", color: .scFat)
            }

            // 개별 음식
            ForEach(Array(store.estimatedFoods.enumerated()), id: \.element.name) { index, food in
                EstimatedFoodRow(
                    food: food,
                    onRemove: { store.send(.removeFood(index)) },
                    onFavorite: { store.send(.saveFoodAsFavorite(food)) }
                )
            }

            Text("AI 추정치는 참고용이며 실제와 다를 수 있습니다")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                store.send(.toggleFavorites)
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("즐겨찾기")
                        .font(.headline)
                    Spacer()
                    Image(systemName: store.showFavorites ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if store.showFavorites {
                if store.favorites.isEmpty {
                    Text("저장된 즐겨찾기가 없습니다")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    ForEach(store.favorites) { favorite in
                        FavoriteFoodRow(
                            favorite: favorite,
                            onSelect: { store.send(.selectFavorite(favorite)) },
                            onDelete: { store.send(.deleteFavorite(favorite)) }
                        )
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private var recentMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                store.send(.toggleRecentMeals)
            } label: {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.scPrimary)
                    Text("최근 기록")
                        .font(.headline)
                    Spacer()
                    Image(systemName: store.showRecentMeals ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if store.showRecentMeals {
                if store.recentMeals.isEmpty {
                    Text("최근 7일간 기록이 없습니다")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    ForEach(store.recentMeals) { meal in
                        RecentMealRow(meal: meal) {
                            store.send(.selectRecentMeal(meal))
                        }
                    }
                }
            }
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
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
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
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
    var onFavorite: (() -> Void)?

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
                    .foregroundStyle(.scWarning)
                    .font(.caption)
            }

            if let onFavorite {
                Button(action: onFavorite) {
                    Image(systemName: "star")
                        .foregroundStyle(.yellow)
                }
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct FavoriteFoodRow: View {
    let favorite: FavoriteFood
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text("\(favorite.caloriesPerServing)kcal")
                            .foregroundStyle(.scCalories)
                        Text("P \(String(format: "%.0f", favorite.proteinPerServing))g")
                            .foregroundStyle(.scProtein)
                        if favorite.usageCount > 0 {
                            Text("(\(favorite.usageCount)회)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

struct RecentMealRow: View {
    let meal: MealRecord
    let onSelect: () -> Void

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: meal.date)
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: meal.mealType.icon)
                            .font(.caption)
                            .foregroundStyle(.scPrimary)
                        Text(meal.mealType.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(dateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(meal.foodItems.map(\.name).joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(meal.totalCalories)kcal")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.scCalories)
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 6)
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
