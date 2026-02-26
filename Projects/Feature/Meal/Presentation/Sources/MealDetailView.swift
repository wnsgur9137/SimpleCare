//
//  MealDetailView.swift
//  MealPresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import SwiftUI
import ComposableArchitecture
import MealDomain
import BasePresentation

/// 식사 상세 화면
public struct MealDetailView: View {
    @Bindable var store: StoreOf<MealDetailFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<MealDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                nutritionSummarySection
                foodItemsSection
                if store.isEditing || !(store.meal.notes?.isEmpty ?? true) {
                    notesSection
                }
                deleteButton
            }
            .padding()
        }
        .navigationTitle(store.meal.mealType.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if store.isEditing {
                    Button("common.done".localized) {
                        store.send(.saveChanges)
                    }
                } else {
                    Button("common.edit".localized) {
                        store.send(.editButtonTapped)
                    }
                }
            }
            if store.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel".localized) {
                        store.send(.cancelEdit)
                    }
                }
            }
        }
        .overlay {
            if store.viewState == .loading {
                loadingOverlay
            }
        }
        .alert("common.error".localized, isPresented: .constant(store.viewState.isError)) {
            Button("common.confirm".localized) { store.send(.dismissError) }
        } message: {
            if case .error(let message) = store.viewState {
                Text(message)
            }
        }
        .alert("meal.detail.deleteConfirm.title".localized, isPresented: $store.showDeleteConfirmation) {
            Button("common.cancel".localized, role: .cancel) {
                store.send(.cancelDelete)
            }
            Button("common.delete".localized, role: .destructive) {
                store.send(.confirmDelete)
            }
        } message: {
            Text("meal.detail.deleteConfirm.message".localized)
        }
        .onChange(of: store.viewState) { _, newState in
            if newState == .deleted {
                dismiss()
            }
        }
        .task {
            store.send(.onAppear)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: store.meal.mealType.icon)
                    .font(.title)
                    .foregroundStyle(mealTypeColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(store.meal.mealType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(store.meal.totalCalories)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.scCalories)
                + Text(" kcal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if store.isEditing {
                mealTypePicker
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    private var mealTypePicker: some View {
        Picker("meal.type".localized, selection: $store.meal.mealType) {
            ForEach(MealType.allCases, id: \.self) { type in
                Label(type.displayName, systemImage: type.icon)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Nutrition Summary Section

    private var nutritionSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("meal.detail.nutrition".localized)
                .font(.headline)

            HStack(spacing: 16) {
                NutritionCard(
                    label: "meal.protein".localized,
                    value: String(format: "%.1f", store.meal.totalProtein),
                    unit: "g",
                    color: .scProtein
                )
                NutritionCard(
                    label: "meal.carbs".localized,
                    value: String(format: "%.1f", store.meal.totalCarbs),
                    unit: "g",
                    color: .scCarbs
                )
                NutritionCard(
                    label: "meal.fat".localized,
                    value: String(format: "%.1f", store.meal.totalFat),
                    unit: "g",
                    color: .scFat
                )
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Food Items Section

    private var foodItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("meal.detail.foods".localized)
                    .font(.headline)
                Spacer()
                Text("\(store.meal.foodItems.count)" + "meal.detail.foodCount".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(store.meal.foodItems) { food in
                FoodItemDetailRow(food: food)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("meal.memo".localized)
                .font(.headline)

            if store.isEditing {
                TextField("meal.memoPlaceholder".localized, text: Binding(
                    get: { store.meal.notes ?? "" },
                    set: { store.meal.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
            } else if let notes = store.meal.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(role: .destructive) {
            store.send(.deleteButtonTapped)
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("meal.detail.delete".localized)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            }
        }
        .foregroundStyle(.red)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                }
        }
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (E) HH:mm"
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: store.meal.date)
    }

    private var mealTypeColor: Color {
        switch store.meal.mealType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}

// MARK: - Nutrition Card

private struct NutritionCard: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)

            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        }
    }
}

// MARK: - Food Item Detail Row

private struct FoodItemDetailRow: View {
    let food: FoodItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Text("\(Int(food.servingSize))\(food.servingUnit)")
                    if food.quantity > 1 {
                        Text("× \(Int(food.quantity))")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(food.calories)")
                    .font(.headline)
                    .foregroundStyle(.scCalories)
                + Text(" kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    NutrientLabel(label: "P", value: food.proteinGrams, color: .scProtein)
                    NutrientLabel(label: "C", value: food.carbsGrams, color: .scCarbs)
                    NutrientLabel(label: "F", value: food.fatGrams, color: .scFat)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Nutrient Label

private struct NutrientLabel: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(String(format: "%.0f", value))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        MealDetailView(
            store: Store(
                initialState: MealDetailFeature.State(
                    meal: MealRecord(
                        userProfileId: UUID(),
                        mealType: .lunch,
                        foodItems: [
                            FoodItem(
                                name: "김치찌개",
                                caloriesPerServing: 150,
                                proteinPerServing: 10,
                                carbsPerServing: 8,
                                fatPerServing: 7
                            ),
                            FoodItem(
                                name: "밥",
                                caloriesPerServing: 300,
                                proteinPerServing: 5,
                                carbsPerServing: 65,
                                fatPerServing: 1
                            )
                        ],
                        notes: "맛있는 점심"
                    )
                )
            ) {
                MealDetailFeature()
            }
        )
    }
}
