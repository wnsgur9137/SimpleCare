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
                    DateSectionHeaderView(date: group.date, meals: group.meals)
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

// MARK: - DateSectionHeaderView

private struct DateSectionHeaderView: View {
    let date: Date
    let meals: [MealRecord]

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("MMMdEEEE")
        return formatter
    }()

    private var calendar: Calendar { Calendar.current }

    private var relativeDateLabel: String? {
        if calendar.isDateInToday(date) {
            return "meal.list.today".localized
        } else if calendar.isDateInYesterday(date) {
            return "meal.list.yesterday".localized
        }
        return nil
    }

    private var formattedDate: String {
        Self.dateFormatter.string(from: date)
    }

    private var dailyTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        meals.reduce((calories: 0, protein: 0.0, carbs: 0.0, fat: 0.0)) { totals, meal in
            (
                calories: totals.calories + meal.totalCalories,
                protein: totals.protein + meal.totalProtein,
                carbs: totals.carbs + meal.totalCarbs,
                fat: totals.fat + meal.totalFat
            )
        }
    }

    var body: some View {
        let totals = dailyTotals
        VStack(alignment: .leading, spacing: 6) {
            // Date label
            HStack(spacing: 6) {
                if let relative = relativeDateLabel {
                    Text(relative)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("·")
                        .foregroundStyle(.secondary)
                }
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(relativeDateLabel != nil ? .secondary : .primary)
                    .fontWeight(relativeDateLabel == nil ? .bold : .regular)
            }

            // Daily calories
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.scCalories)
                Text("\(totals.calories) \("unit.kcal".localized)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.scCalories)
            }

            // Macro summary
            HStack(spacing: 12) {
                MacroDotView(label: "macro.protein.short".localized, value: String(format: "%.0fg", totals.protein), color: .scProtein)
                MacroDotView(label: "macro.carbs.short".localized, value: String(format: "%.0fg", totals.carbs), color: .scCarbs)
                MacroDotView(label: "macro.fat.short".localized, value: String(format: "%.0fg", totals.fat), color: .scFat)
            }
        }
        .padding(.vertical, 4)
        .textCase(nil)
    }
}

// MARK: - MacroDotView

private struct MacroDotView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text("\(label) \(value)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - MealRowView

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
                // Meal type name + time
                HStack(spacing: 6) {
                    Text(meal.mealType.displayName)
                        .font(.headline)
                    Text(meal.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                // Food items summary
                Text(foodSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Individual macro mini display
                HStack(spacing: 8) {
                    MacroDotView(label: "macro.protein.short".localized, value: String(format: "%.0fg", meal.totalProtein), color: .scProtein)
                    MacroDotView(label: "macro.carbs.short".localized, value: String(format: "%.0fg", meal.totalCarbs), color: .scCarbs)
                    MacroDotView(label: "macro.fat.short".localized, value: String(format: "%.0fg", meal.totalFat), color: .scFat)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                // Total calories
                Text("\(meal.totalCalories)")
                    .font(.headline)
                    .foregroundStyle(.scCalories)
                Text("unit.kcal".localized)
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
