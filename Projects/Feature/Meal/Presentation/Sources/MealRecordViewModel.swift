//
//  MealRecordViewModel.swift
//  MealPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import Combine
import MealDomain

/// 식사 기록 화면 상태
public enum MealRecordViewState: Equatable {
    case idle
    case loading
    case estimating
    case success
    case error(String)
}

/// 식사 기록 ViewModel
@MainActor
public final class MealRecordViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published public private(set) var state: MealRecordViewState = .idle
    @Published public var mealType: MealType = .lunch
    @Published public var foodDescription: String = ""
    @Published public var selectedImageData: Data?
    @Published public private(set) var estimatedFoods: [EstimatedFoodItem] = []
    @Published public var notes: String = ""

    // MARK: - Dependencies

    private let estimateNutritionUseCase: EstimateMealNutritionUseCaseProtocol
    private let analyzeMealImageUseCase: AnalyzeMealImageUseCaseProtocol
    private let recordMealUseCase: RecordMealUseCaseProtocol
    private let userProfileId: UUID

    public var onSaveComplete: (() -> Void)?

    // MARK: - Initialization

    public init(
        estimateNutritionUseCase: EstimateMealNutritionUseCaseProtocol,
        analyzeMealImageUseCase: AnalyzeMealImageUseCaseProtocol,
        recordMealUseCase: RecordMealUseCaseProtocol,
        userProfileId: UUID
    ) {
        self.estimateNutritionUseCase = estimateNutritionUseCase
        self.analyzeMealImageUseCase = analyzeMealImageUseCase
        self.recordMealUseCase = recordMealUseCase
        self.userProfileId = userProfileId
    }

    // MARK: - Public Methods

    /// 텍스트로 영양 추정
    public func estimateFromText() async {
        guard !foodDescription.isEmpty else { return }

        state = .estimating
        do {
            let result = try await estimateNutritionUseCase.execute(text: foodDescription)
            if let error = result.error {
                state = .error(error)
            } else {
                estimatedFoods = result.foods
                state = .idle
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// 이미지로 영양 추정
    public func estimateFromImage() async {
        guard let imageData = selectedImageData else { return }

        state = .estimating
        do {
            let result = try await analyzeMealImageUseCase.execute(imageData: imageData)
            if let error = result.error {
                state = .error(error)
            } else {
                estimatedFoods = result.foods
                state = .idle
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// 식사 기록 저장
    public func saveMeal() async {
        guard !estimatedFoods.isEmpty else {
            state = .error("음식을 추가해주세요")
            return
        }

        state = .loading
        do {
            let foodItems = estimatedFoods.map { $0.toFoodItem() }
            let meal = MealRecord(
                userProfileId: userProfileId,
                mealType: mealType,
                foodItems: foodItems,
                notes: notes.isEmpty ? nil : notes
            )
            try await recordMealUseCase.execute(meal: meal)
            state = .success
            onSaveComplete?()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// 추정된 음식 삭제
    public func removeFood(at index: Int) {
        guard index < estimatedFoods.count else { return }
        estimatedFoods.remove(at: index)
    }

    /// 오류 상태 해제
    public func dismissError() {
        state = .idle
    }

    /// 전체 초기화
    public func reset() {
        foodDescription = ""
        selectedImageData = nil
        estimatedFoods = []
        notes = ""
        state = .idle
    }

    // MARK: - Computed

    public var totalCalories: Int {
        estimatedFoods.reduce(0) { $0 + $1.calories }
    }

    public var totalProtein: Double {
        estimatedFoods.reduce(0) { $0 + $1.protein }
    }

    public var totalCarbs: Double {
        estimatedFoods.reduce(0) { $0 + $1.carbs }
    }

    public var totalFat: Double {
        estimatedFoods.reduce(0) { $0 + $1.fat }
    }

    public var canSave: Bool {
        !estimatedFoods.isEmpty && state != .loading && state != .estimating
    }
}
