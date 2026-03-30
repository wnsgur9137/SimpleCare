import AppIntents
import WidgetKit

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "물 1잔 추가"
    static var description: IntentDescription = "수분 섭취량에 물 1잔(250mL)을 추가합니다."

    func perform() async throws -> some IntentResult {
        // Read current data from App Group UserDefaults
        let defaults = UserDefaults(suiteName: "group.com.junhyeok.SimpleCare")

        // Increment pending water cups
        let currentCups = defaults?.integer(forKey: "widget.water.pendingCups") ?? 0
        defaults?.set(currentCups + 1, forKey: "widget.water.pendingCups")

        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "WaterIntakeWidget")

        return .result()
    }
}
