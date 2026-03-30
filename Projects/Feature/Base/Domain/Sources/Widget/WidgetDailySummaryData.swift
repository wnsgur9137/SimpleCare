import Foundation

/// Widget Extension과 메인 앱 간 공유 데이터 모델
public struct WidgetDailySummaryData: Codable, Sendable {
    // MARK: - CodingKeys

    private enum CodingKeys: String, CodingKey {
        case date
        case totalCalories
        case goalCalories
        case remainingCalories
        case calorieProgress
        case exerciseCalories
        case totalProtein
        case totalCarbs
        case totalFat
        case proteinGoal
        case carbsGoal
        case fatGoal
        case streakDays
        case lastUpdated
        case exerciseSessions
        case exerciseDuration
        case weeklyExerciseDays
        case weeklyExerciseGoal
        case recentExercises
        case currentWeight
        case targetWeight
        case weightChange7d
        case bmi
        case recentWeights
        case waterIntakeCups
        case waterGoalCups
        case waterIntakeML
    }

    // MARK: - Calorie
    public let date: Date
    public let totalCalories: Int
    public let goalCalories: Int
    public let remainingCalories: Int
    public let calorieProgress: Double
    public let exerciseCalories: Int

    // MARK: - Macros
    public let totalProtein: Double
    public let totalCarbs: Double
    public let totalFat: Double
    public let proteinGoal: Double
    public let carbsGoal: Double
    public let fatGoal: Double

    // MARK: - Streak
    public let streakDays: Int
    public let lastUpdated: Date

    // MARK: - Exercise (W-A1)
    public let exerciseSessions: Int
    public let exerciseDuration: Int
    public let weeklyExerciseDays: Int
    public let weeklyExerciseGoal: Int
    public let recentExercises: [WidgetExerciseItem]

    // MARK: - Weight (W-A2)
    public let currentWeight: Double?
    public let targetWeight: Double?
    public let weightChange7d: Double?
    public let bmi: Double?
    public let recentWeights: [WidgetWeightPoint]

    // MARK: - Water (W-A3)
    public let waterIntakeCups: Int
    public let waterGoalCups: Int
    public let waterIntakeML: Int

    public init(
        date: Date,
        totalCalories: Int,
        goalCalories: Int,
        remainingCalories: Int,
        calorieProgress: Double,
        exerciseCalories: Int,
        totalProtein: Double,
        totalCarbs: Double,
        totalFat: Double,
        proteinGoal: Double,
        carbsGoal: Double,
        fatGoal: Double,
        streakDays: Int,
        lastUpdated: Date = Date(),
        exerciseSessions: Int = 0,
        exerciseDuration: Int = 0,
        weeklyExerciseDays: Int = 0,
        weeklyExerciseGoal: Int = 5,
        recentExercises: [WidgetExerciseItem] = [],
        currentWeight: Double? = nil,
        targetWeight: Double? = nil,
        weightChange7d: Double? = nil,
        bmi: Double? = nil,
        recentWeights: [WidgetWeightPoint] = [],
        waterIntakeCups: Int = 0,
        waterGoalCups: Int = 8,
        waterIntakeML: Int = 0
    ) {
        self.date = date
        self.totalCalories = totalCalories
        self.goalCalories = goalCalories
        self.remainingCalories = remainingCalories
        self.calorieProgress = calorieProgress
        self.exerciseCalories = exerciseCalories
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.proteinGoal = proteinGoal
        self.carbsGoal = carbsGoal
        self.fatGoal = fatGoal
        self.streakDays = streakDays
        self.lastUpdated = lastUpdated
        self.exerciseSessions = exerciseSessions
        self.exerciseDuration = exerciseDuration
        self.weeklyExerciseDays = weeklyExerciseDays
        self.weeklyExerciseGoal = weeklyExerciseGoal
        self.recentExercises = recentExercises
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.weightChange7d = weightChange7d
        self.bmi = bmi
        self.recentWeights = recentWeights
        self.waterIntakeCups = waterIntakeCups
        self.waterGoalCups = waterGoalCups
        self.waterIntakeML = waterIntakeML
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        totalCalories = try container.decode(Int.self, forKey: .totalCalories)
        goalCalories = try container.decode(Int.self, forKey: .goalCalories)
        remainingCalories = try container.decode(Int.self, forKey: .remainingCalories)
        calorieProgress = try container.decode(Double.self, forKey: .calorieProgress)
        exerciseCalories = try container.decode(Int.self, forKey: .exerciseCalories)
        totalProtein = try container.decode(Double.self, forKey: .totalProtein)
        totalCarbs = try container.decode(Double.self, forKey: .totalCarbs)
        totalFat = try container.decode(Double.self, forKey: .totalFat)
        proteinGoal = try container.decode(Double.self, forKey: .proteinGoal)
        carbsGoal = try container.decode(Double.self, forKey: .carbsGoal)
        fatGoal = try container.decode(Double.self, forKey: .fatGoal)
        streakDays = try container.decode(Int.self, forKey: .streakDays)
        lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
        // New fields with defaults for backward compatibility
        exerciseSessions = try container.decodeIfPresent(Int.self, forKey: .exerciseSessions) ?? 0
        exerciseDuration = try container.decodeIfPresent(Int.self, forKey: .exerciseDuration) ?? 0
        weeklyExerciseDays = try container.decodeIfPresent(Int.self, forKey: .weeklyExerciseDays) ?? 0
        weeklyExerciseGoal = try container.decodeIfPresent(Int.self, forKey: .weeklyExerciseGoal) ?? 5
        recentExercises = try container.decodeIfPresent([WidgetExerciseItem].self, forKey: .recentExercises) ?? []
        currentWeight = try container.decodeIfPresent(Double.self, forKey: .currentWeight)
        targetWeight = try container.decodeIfPresent(Double.self, forKey: .targetWeight)
        weightChange7d = try container.decodeIfPresent(Double.self, forKey: .weightChange7d)
        bmi = try container.decodeIfPresent(Double.self, forKey: .bmi)
        recentWeights = try container.decodeIfPresent([WidgetWeightPoint].self, forKey: .recentWeights) ?? []
        waterIntakeCups = try container.decodeIfPresent(Int.self, forKey: .waterIntakeCups) ?? 0
        waterGoalCups = try container.decodeIfPresent(Int.self, forKey: .waterGoalCups) ?? 8
        waterIntakeML = try container.decodeIfPresent(Int.self, forKey: .waterIntakeML) ?? 0
    }
}

// MARK: - Exercise Widget Item

public struct WidgetExerciseItem: Codable, Sendable {
    public let name: String
    public let calories: Int

    public init(name: String, calories: Int) {
        self.name = name
        self.calories = calories
    }
}

// MARK: - Weight Widget Point

public struct WidgetWeightPoint: Codable, Sendable {
    public let date: Date
    public let weight: Double

    public init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}
