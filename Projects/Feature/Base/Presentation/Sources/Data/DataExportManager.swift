//
//  DataExportManager.swift
//  BasePresentation
//
//  Created by SimpleCare on 3/3/26.
//

import Foundation
import SwiftData
import StorageInfra

/// 데이터 내보내기 형식
public enum ExportFormat: String, CaseIterable, Identifiable {
    case csv = "csv"
    case json = "json"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .csv: return "CSV"
        case .json: return "JSON"
        }
    }

    public var fileExtension: String { rawValue }

    public var mimeType: String {
        switch self {
        case .csv: return "text/csv"
        case .json: return "application/json"
        }
    }
}

/// 데이터 내보내기/삭제 관리자
@MainActor
public final class DataExportManager: ObservableObject {
    public static let shared = DataExportManager()

    @Published public var isExporting = false
    @Published public var isDeleting = false
    @Published public var exportError: String?

    // Static DateFormatter for performance
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private init() {}

    // MARK: - Export

    /// 모든 데이터를 지정된 형식으로 내보내기
    public func exportAllData(
        format: ExportFormat,
        userProfileId: UUID
    ) async throws -> URL {
        isExporting = true
        exportError = nil

        defer { isExporting = false }

        // 이전 내보내기 임시 파일 정리
        cleanupExportFiles()

        let context = StorageContainer.shared.mainContext

        // Fetch all records
        let meals = try fetchMeals(context: context, userProfileId: userProfileId)
        let exercises = try fetchExercises(context: context, userProfileId: userProfileId)
        let weights = try fetchWeights(context: context, userProfileId: userProfileId)

        // Create export data
        let exportData = ExportData(
            exportDate: Date(),
            meals: meals.map { MealExportItem(from: $0) },
            exercises: exercises.map { ExerciseExportItem(from: $0) },
            weights: weights.map { WeightExportItem(from: $0) }
        )

        // Generate file
        let fileURL: URL
        switch format {
        case .json:
            fileURL = try exportToJSON(data: exportData)
        case .csv:
            fileURL = try exportToCSV(data: exportData)
        }

        return fileURL
    }

    private func fetchMeals(context: ModelContext, userProfileId: UUID) throws -> [MealRecordModel] {
        let descriptor = FetchDescriptor<MealRecordModel>(
            predicate: #Predicate { $0.userProfileId == userProfileId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func fetchExercises(context: ModelContext, userProfileId: UUID) throws -> [ExerciseRecordModel] {
        let descriptor = FetchDescriptor<ExerciseRecordModel>(
            predicate: #Predicate { $0.userProfileId == userProfileId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func fetchWeights(context: ModelContext, userProfileId: UUID) throws -> [WeightRecordModel] {
        let descriptor = FetchDescriptor<WeightRecordModel>(
            predicate: #Predicate { $0.userProfileId == userProfileId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    /// 이전 내보내기 임시 파일 정리
    public func cleanupExportFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: nil
            )
            for fileURL in contents where fileURL.lastPathComponent.hasPrefix("SimpleCare_Export_") {
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            // 정리 실패는 무시 (다음 기회에 재시도)
        }
    }

    /// 특정 내보내기 파일 삭제
    public func cleanupExportFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    private func exportToJSON(data: ExportData) throws -> URL {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(data)

        let fileName = "SimpleCare_Export_\(formatDate(Date())).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try jsonData.write(to: fileURL)
        // 파일 보호 속성 적용
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUnlessOpen],
            ofItemAtPath: fileURL.path
        )
        return fileURL
    }

    private func exportToCSV(data: ExportData) throws -> URL {
        var csvContent = ""

        // Meals section
        csvContent += "=== MEALS ===\n"
        csvContent += "Date,Type,Foods,Calories,Protein(g),Carbs(g),Fat(g),Notes\n"
        for meal in data.meals {
            let foods = escapeCSVField(meal.foods.map { $0.name }.joined(separator: "; "))
            let notes = escapeCSVField(meal.notes ?? "")
            let protein = String(format: "%.1f", meal.totalProtein)
            let carbs = String(format: "%.1f", meal.totalCarbs)
            let fat = String(format: "%.1f", meal.totalFat)
            csvContent += "\(formatDate(meal.date)),\(meal.mealType),\"\(foods)\","
            csvContent += "\(meal.totalCalories),\(protein),\(carbs),\(fat),\"\(notes)\"\n"
        }

        csvContent += "\n"

        // Exercises section
        csvContent += "=== EXERCISES ===\n"
        csvContent += "Date,Type,Duration(min),Intensity,Calories,Notes\n"
        for exercise in data.exercises {
            let exerciseType = escapeCSVField(exercise.exerciseType)
            let notes = escapeCSVField(exercise.notes ?? "")
            csvContent += "\(formatDate(exercise.date)),\"\(exerciseType)\","
            csvContent += "\(exercise.durationMinutes),\(exercise.intensity),\(exercise.caloriesBurned),\"\(notes)\"\n"
        }

        csvContent += "\n"

        // Weights section
        csvContent += "=== WEIGHTS ===\n"
        csvContent += "Date,Weight(kg),BodyFat(%),Notes\n"
        for weight in data.weights {
            let bodyFat = weight.bodyFatPercentage.map { String(format: "%.1f", $0) } ?? ""
            let notes = escapeCSVField(weight.notes ?? "")
            csvContent += "\(formatDate(weight.date)),\(String(format: "%.1f", weight.weightKg)),\(bodyFat),\"\(notes)\"\n"
        }

        let fileName = "SimpleCare_Export_\(formatDate(Date())).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        // 파일 보호 속성 적용
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUnlessOpen],
            ofItemAtPath: fileURL.path
        )
        return fileURL
    }

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    /// CSV 필드 이스케이프 (CSV Injection 방지)
    private func escapeCSVField(_ value: String) -> String {
        var escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        // Formula injection 방지: 수식 시작 문자 앞에 ' 추가
        if escaped.hasPrefix("=") || escaped.hasPrefix("+") ||
           escaped.hasPrefix("-") || escaped.hasPrefix("@") {
            escaped = "'" + escaped
        }
        return escaped
    }

    // MARK: - Delete All Data

    /// 모든 사용자 데이터 삭제 (배치 삭제로 성능 최적화)
    public func deleteAllData(userProfileId: UUID) async throws {
        isDeleting = true
        defer { isDeleting = false }

        let context = StorageContainer.shared.mainContext

        // Batch delete meals
        try context.delete(
            model: MealRecordModel.self,
            where: #Predicate { $0.userProfileId == userProfileId }
        )

        // Batch delete exercises
        try context.delete(
            model: ExerciseRecordModel.self,
            where: #Predicate { $0.userProfileId == userProfileId }
        )

        // Batch delete weights
        try context.delete(
            model: WeightRecordModel.self,
            where: #Predicate { $0.userProfileId == userProfileId }
        )

        // Batch delete favorites
        try context.delete(
            model: FavoriteFoodModel.self,
            where: #Predicate { $0.userProfileId == userProfileId }
        )

        // Batch delete custom exercises
        try context.delete(
            model: CustomExerciseModel.self,
            where: #Predicate { $0.userProfileId == userProfileId }
        )

        try context.save()
    }
}

// MARK: - Export Data Structures

struct ExportData: Codable {
    let exportDate: Date
    let meals: [MealExportItem]
    let exercises: [ExerciseExportItem]
    let weights: [WeightExportItem]
}

struct MealExportItem: Codable {
    let id: UUID
    let date: Date
    let mealType: String
    let foods: [FoodExportItem]
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let notes: String?

    init(from model: MealRecordModel) {
        self.id = model.id
        self.date = model.date
        self.mealType = model.mealType.rawValue
        self.foods = model.foodItems.map { FoodExportItem(from: $0) }
        self.totalCalories = model.totalCalories
        self.totalProtein = model.totalProtein
        self.totalCarbs = model.totalCarbs
        self.totalFat = model.totalFat
        self.notes = model.notes
    }
}

struct FoodExportItem: Codable {
    let name: String
    let calories: Int
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double
    let servingDescription: String

    init(from model: FoodItemModel) {
        self.name = model.name
        self.calories = model.calories
        self.proteinGrams = model.proteinGrams
        self.carbsGrams = model.carbsGrams
        self.fatGrams = model.fatGrams
        self.servingDescription = model.servingDescription
    }
}

struct ExerciseExportItem: Codable {
    let id: UUID
    let date: Date
    let exerciseType: String
    let intensity: String
    let durationMinutes: Int
    let caloriesBurned: Int
    let notes: String?

    init(from model: ExerciseRecordModel) {
        self.id = model.id
        self.date = model.date
        self.exerciseType = model.customExerciseName ?? model.exerciseType.rawValue
        self.intensity = model.intensity.rawValue
        self.durationMinutes = model.durationMinutes
        self.caloriesBurned = model.caloriesBurned
        self.notes = model.notes
    }
}

struct WeightExportItem: Codable {
    let id: UUID
    let date: Date
    let weightKg: Double
    let bodyFatPercentage: Double?
    let notes: String?

    init(from model: WeightRecordModel) {
        self.id = model.id
        self.date = model.date
        self.weightKg = model.weightKg
        self.bodyFatPercentage = model.bodyFatPercentage
        self.notes = model.notes
    }
}
