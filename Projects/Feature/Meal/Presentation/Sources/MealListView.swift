import SwiftUI
import ComposableArchitecture
import MealDomain
import BasePresentation

public struct MealListView: View {
    @Bindable var store: StoreOf<MealListFeature>
    var onNavigateToDetail: ((MealRecord) -> Void)?
    var onNavigateToRecord: (() -> Void)?

    public init(
        store: StoreOf<MealListFeature>,
        onNavigateToDetail: ((MealRecord) -> Void)? = nil,
        onNavigateToRecord: (() -> Void)? = nil
    ) {
        self.store = store
        self.onNavigateToDetail = onNavigateToDetail
        self.onNavigateToRecord = onNavigateToRecord
    }

    public var body: some View {
        content
            .navigationTitle("meal.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.addMealButtonTapped)
                        onNavigateToRecord?()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch store.viewState {
        case .loading:
            ProgressView()
        case .error(let message):
            errorView(message)
        case .idle, .loaded:
            if store.meals.isEmpty {
                emptyStateView
            } else {
                mealListView
            }
        }
    }

    private var mealListView: some View {
        List {
            ForEach(store.groupedMeals, id: \.date) { group in
                Section {
                    ForEach(group.meals) { meal in
                        MealRowView(meal: meal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.mealTapped(meal))
                                onNavigateToDetail?(meal)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.send(.deleteMeal(meal))
                                } label: {
                                    Label("common.delete".localized, systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(group.date.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("meal.list.empty".localized, systemImage: "fork.knife")
        } description: {
            Text("meal.list.emptyDescription".localized)
        } actions: {
            Button {
                store.send(.addMealButtonTapped)
                onNavigateToRecord?()
            } label: {
                Text("meal.addMeal".localized)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("error.title".localized, systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button {
                store.send(.loadMeals)
            } label: {
                Text("common.retry".localized)
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct MealRowView: View {
    let meal: MealRecord

    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: meal.mealType.icon)
                .font(.title2)
                .foregroundStyle(mealTypeColor)
                .frame(width: 40, height: 40)
                .background(mealTypeColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                // Meal type name
                Text(meal.mealType.displayName)
                    .font(.headline)

                // Food items summary (first 2 items)
                Text(foodSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                // Total calories
                Text("\(meal.totalCalories)")
                    .font(.headline)
                    .foregroundStyle(.scCalories)
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var foodSummary: String {
        let names = meal.foodItems.prefix(2).map { $0.name }
        if meal.foodItems.count > 2 {
            let remaining = meal.foodItems.count - 2
            return names.joined(separator: ", ") + " \("meal.list.and".localized) \(remaining)\("meal.list.items".localized)"
        }
        return names.joined(separator: ", ")
    }

    private var mealTypeColor: Color {
        switch meal.mealType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}
