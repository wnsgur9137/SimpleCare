import AppIntents
import WidgetKit

struct SaveWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "체중 저장"
    static var description: IntentDescription = "조절된 체중을 저장합니다."

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.junhyeok.SimpleCare")

        // Mark as confirmed (app will pick up on next launch)
        defaults?.set(true, forKey: "widget.weight.pendingConfirmed")

        WidgetCenter.shared.reloadTimelines(ofKind: "WeightQuickInputWidget")
        return .result()
    }
}
