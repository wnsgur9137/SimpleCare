import Foundation

/// App Group UserDefaults를 통한 Widget 데이터 공유
public enum WidgetDataStore {
    public static let appGroupID = "group.com.junhyeok.SimpleCare"
    public static let dailySummaryKey = "widget.dailySummary"

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    public static func save(_ data: WidgetDailySummaryData) {
        guard let defaults = sharedDefaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: dailySummaryKey)
    }

    public static func load() -> WidgetDailySummaryData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: dailySummaryKey),
              let decoded = try? JSONDecoder().decode(WidgetDailySummaryData.self, from: data) else { return nil }
        return decoded
    }
}
