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
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?

    public init(store: StoreOf<MealFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 알림 활성화 배너
                    NotificationEnableBanner(categories: [.breakfast, .lunch, .dinner])

                    // 식사 유형 선택
                    mealTypeSection

                    // 입력 방식 선택
                    inputSection

                    // 수분 섭취
                    WaterIntakeSection(
                        dailyWaterMl: store.dailyWaterMl,
                        waterGoalMl: store.waterGoalMl,
                        onAdd: { amount in store.send(.addWaterIntake(amount)) }
                    )

                    // 즐겨찾기
                    favoritesSection

                    // 최근 기록
                    recentMealsSection

                    // 추정 결과
                    if !store.estimatedFoods.isEmpty {
                        estimatedFoodsSection
                    }

                    // 건강 팁
                    if let healthTip = store.healthTip {
                        healthTipSection(healthTip)
                    }

                    // 메모
                    notesSection
                }
                .padding()
            }
            .navigationTitle("meal.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
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
            .alert("common.error".localized, isPresented: Binding(
                get: { store.viewState.isError },
                set: { if !$0 { store.send(.dismissError) } }
            )) {
                Button("common.confirm".localized) { store.send(.dismissError) }
            } message: {
                if case .error(let message) = store.viewState {
                    Text(message)
                }
            }
            .task {
                store.send(.loadWaterIntakes)
            }
            .onChange(of: store.viewState) { _, newState in
                if newState == .success {
                    dismiss()
                }
            }
            .sheet(isPresented: $store.showManualInput) {
                ManualFoodInputSheet { name, calories, protein, carbs, fat in
                    store.send(.addManualFood(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat))
                }
            }
            .sheet(isPresented: $store.showEditFavorite) {
                if let favorite = store.editingFavorite {
                    EditFavoriteSheet(favorite: favorite) { updated in
                        store.send(.updateFavorite(updated))
                    } onDismiss: {
                        store.send(.dismissEditFavorite)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        store.send(.imageSelected(data))
                    }
                    selectedPhotoItem = nil
                }
            }
        }
    }

    // MARK: - Sections

    private var mealTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("meal.type".localized)
                .font(.headline)

            Picker("meal.type".localized, selection: $store.mealType) {
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
            Text("meal.foodInput".localized)
                .font(.headline)

            // 텍스트 입력
            HStack {
                TextField("meal.inputPlaceholder".localized, text: $store.foodDescription, axis: .vertical)
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

            // 추가 입력 버튼들
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("meal.photoAnalyze".localized, systemImage: "camera.fill")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    store.send(.toggleManualInput)
                } label: {
                    Label("meal.manualInput".localized, systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }

                Button {
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                    store.send(.copyMealsFromDate(yesterday))
                } label: {
                    Label("meal.copyFromYesterday".localized, systemImage: "doc.on.doc")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private var estimatedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("meal.estimateResult".localized)
                    .font(.headline)
                Spacer()
                Text("meal.aiEstimate".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 총합
            HStack(spacing: 16) {
                NutritionBadge(label: "meal.calories".localized, value: "\(store.totalCalories)", unit: "kcal", color: .scCalories)
                NutritionBadge(label: "meal.protein".localized, value: String(format: "%.1f", store.totalProtein), unit: "g", color: .scProtein)
                NutritionBadge(label: "meal.carbs".localized, value: String(format: "%.1f", store.totalCarbs), unit: "g", color: .scCarbs)
                NutritionBadge(label: "meal.fat".localized, value: String(format: "%.1f", store.totalFat), unit: "g", color: .scFat)
            }

            // 개별 음식
            ForEach(Array(store.estimatedFoods.enumerated()), id: \.offset) { index, food in
                EstimatedFoodRow(
                    food: food,
                    onRemove: { store.send(.removeFood(index)) },
                    onFavorite: { store.send(.saveFoodAsFavorite(food)) },
                    onQuantityChanged: { quantity in
                        store.send(.adjustFoodQuantity(index: index, quantity: quantity))
                    }
                )
            }

            Text("meal.estimateDisclaimer".localized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private func healthTipSection(_ tip: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.scWarning)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text("meal.healthTip".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(tip)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                        .foregroundStyle(.scWarning)
                    Text("meal.favorites".localized)
                        .font(.headline)
                    Spacer()
                    Image(systemName: store.showFavorites ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if store.showFavorites {
                if store.favorites.isEmpty {
                    Text("meal.noFavorites".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    ForEach(store.favorites) { favorite in
                        FavoriteFoodRow(
                            favorite: favorite,
                            onSelect: { store.send(.selectFavorite(favorite)) },
                            onDelete: { store.send(.deleteFavorite(favorite)) },
                            onEdit: { store.send(.editFavorite(favorite)) }
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
                    Text("meal.recent".localized)
                        .font(.headline)
                    Spacer()
                    Image(systemName: store.showRecentMeals ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if store.showRecentMeals {
                if store.recentMeals.isEmpty {
                    Text("meal.noRecent".localized)
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
            Text("meal.memo".localized)
                .font(.headline)

            TextField("meal.memoPlaceholder".localized, text: $store.notes, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.scOverlay
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(store.viewState == .estimating ? "meal.analyzing".localized : "meal.saving".localized)
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
    var onQuantityChanged: ((Double) -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.body)
                        .fontWeight(.medium)

                    Text("\(Int(food.servingSize))\(food.servingUnit) \u{00B7} \(food.adjustedCalories)kcal")
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
                            .foregroundStyle(.scWarning)
                    }
                }

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            // Quantity stepper
            if let onQuantityChanged {
                HStack {
                    Text("meal.quantity".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    HStack(spacing: 12) {
                        Button {
                            let newQuantity = max(0.5, food.quantity - 0.5)
                            onQuantityChanged(newQuantity)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.scPrimary)
                        }
                        .disabled(food.quantity <= 0.5)

                        Text(String(format: "%.1f", food.quantity))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(minWidth: 30)

                        Button {
                            let newQuantity = min(10.0, food.quantity + 0.5)
                            onQuantityChanged(newQuantity)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.scPrimary)
                        }
                        .disabled(food.quantity >= 10.0)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct FavoriteFoodRow: View {
    let favorite: FavoriteFood
    let onSelect: () -> Void
    let onDelete: () -> Void
    var onEdit: (() -> Void)?

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
                            Text("meal.usageCount".localized(with: favorite.usageCount))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if let onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(.scPrimary)
                }
            }

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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    private var dateText: String {
        Self.dateFormatter.string(from: meal.date)
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

// MARK: - Manual Food Input Sheet

struct ManualFoodInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var foodName: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatText: String = ""

    let onSave: (String, Int, Double, Double, Double) -> Void

    private var isValid: Bool {
        !foodName.isEmpty && (Int(caloriesText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("meal.manualInput.name".localized, text: $foodName)
                }

                Section {
                    TextField("meal.manualInput.calories".localized, text: $caloriesText)
                        .keyboardType(.numberPad)
                    TextField("meal.manualInput.protein".localized, text: $proteinText)
                        .keyboardType(.decimalPad)
                    TextField("meal.manualInput.carbs".localized, text: $carbsText)
                        .keyboardType(.decimalPad)
                    TextField("meal.manualInput.fat".localized, text: $fatText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("meal.manualInput.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        onSave(
                            foodName,
                            Int(caloriesText) ?? 0,
                            Double(proteinText) ?? 0,
                            Double(carbsText) ?? 0,
                            Double(fatText) ?? 0
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Edit Favorite Sheet

struct EditFavoriteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var servingSizeText: String
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String

    let favorite: FavoriteFood
    let onSave: (FavoriteFood) -> Void
    let onDismiss: () -> Void

    init(favorite: FavoriteFood, onSave: @escaping (FavoriteFood) -> Void, onDismiss: @escaping () -> Void) {
        self.favorite = favorite
        self.onSave = onSave
        self.onDismiss = onDismiss
        _name = State(initialValue: favorite.name)
        _servingSizeText = State(initialValue: String(format: "%.0f", favorite.servingSize))
        _caloriesText = State(initialValue: "\(favorite.caloriesPerServing)")
        _proteinText = State(initialValue: String(format: "%.1f", favorite.proteinPerServing))
        _carbsText = State(initialValue: String(format: "%.1f", favorite.carbsPerServing))
        _fatText = State(initialValue: String(format: "%.1f", favorite.fatPerServing))
    }

    private var isValid: Bool {
        !name.isEmpty && (Int(caloriesText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("meal.manualInput.name".localized, text: $name)
                    TextField("meal.servingSize".localized, text: $servingSizeText)
                        .keyboardType(.decimalPad)
                }

                Section {
                    TextField("meal.manualInput.calories".localized, text: $caloriesText)
                        .keyboardType(.numberPad)
                    TextField("meal.manualInput.protein".localized, text: $proteinText)
                        .keyboardType(.decimalPad)
                    TextField("meal.manualInput.carbs".localized, text: $carbsText)
                        .keyboardType(.decimalPad)
                    TextField("meal.manualInput.fat".localized, text: $fatText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("meal.editFavorite.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) {
                        onDismiss()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save".localized) {
                        let updated = favorite.updated(
                            name: name,
                            servingSize: Double(servingSizeText) ?? favorite.servingSize,
                            caloriesPerServing: Int(caloriesText) ?? favorite.caloriesPerServing,
                            proteinPerServing: Double(proteinText) ?? favorite.proteinPerServing,
                            carbsPerServing: Double(carbsText) ?? favorite.carbsPerServing,
                            fatPerServing: Double(fatText) ?? favorite.fatPerServing
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
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
