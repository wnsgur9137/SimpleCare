import Foundation

/// App Group UserDefaults를 통한 Widget 데이터 공유
public enum WidgetDataStore {
    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: WidgetConstants.appGroupID)
    }

    public static func save(_ data: WidgetDailySummaryData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: WidgetConstants.dailySummaryKey)
    }

    public static func load() -> WidgetDailySummaryData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: WidgetConstants.dailySummaryKey),
              let decoded = try? JSONDecoder().decode(WidgetDailySummaryData.self, from: data) else { return nil }
        return decoded
    }

    // MARK: - Water Quick Add (W-D1)

    /// Widget에서 수분 1잔 추가 (Interactive Widget용)
    public static func addWaterCup() {
        guard let defaults = sharedDefaults else { return }
        let currentCups = defaults.integer(forKey: WidgetConstants.waterPendingCupsKey)
        defaults.set(currentCups + 1, forKey: WidgetConstants.waterPendingCupsKey)
    }

    /// 앱 진입 시 Widget에서 추가된 수분 잔 수 소비
    public static func consumePendingWaterCups() -> Int {
        guard let defaults = sharedDefaults else { return 0 }
        let pending = defaults.integer(forKey: WidgetConstants.waterPendingCupsKey)
        defaults.set(0, forKey: WidgetConstants.waterPendingCupsKey)
        return pending
    }

    // MARK: - Weight Quick Input (W-D2)

    /// Widget에서 임시 체중 저장
    public static func savePendingWeight(_ weight: Double) {
        guard let defaults = sharedDefaults else { return }
        defaults.set(weight, forKey: WidgetConstants.weightPendingKey)
        defaults.set(true, forKey: WidgetConstants.weightPendingSavedKey)
    }

    /// Widget 임시 체중 조회
    public static func loadPendingWeight() -> Double? {
        guard let defaults = sharedDefaults else { return nil }
        guard defaults.bool(forKey: WidgetConstants.weightPendingSavedKey) else { return nil }
        return defaults.double(forKey: WidgetConstants.weightPendingKey)
    }

    /// 앱 진입 시 Widget에서 저장된 체중 소비
    public static func consumePendingWeight() -> Double? {
        guard let defaults = sharedDefaults else { return nil }
        guard defaults.bool(forKey: WidgetConstants.weightPendingSavedKey) else { return nil }
        let weight = defaults.double(forKey: WidgetConstants.weightPendingKey)
        defaults.removeObject(forKey: WidgetConstants.weightPendingKey)
        defaults.set(false, forKey: WidgetConstants.weightPendingSavedKey)
        return weight
    }
}
