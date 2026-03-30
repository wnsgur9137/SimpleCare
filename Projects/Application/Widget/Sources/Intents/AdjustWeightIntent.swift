import AppIntents
import WidgetKit

struct AdjustWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "체중 조절"
    static var description: IntentDescription = "체중을 0.1kg 단위로 조절합니다."

    @Parameter(title: "변화량")
    var delta: Double

    init() {
        self.delta = 0.1
    }

    init(delta: Double) {
        self.delta = delta
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.junhyeok.SimpleCare")
        let currentPending = defaults?.double(forKey: "widget.weight.pending") ?? 0
        let hasPending = defaults?.bool(forKey: "widget.weight.pendingSaved") ?? false

        let baseWeight: Double
        if hasPending {
            baseWeight = currentPending
        } else {
            // Read from daily summary
            if let data = defaults?.data(forKey: "widget.dailySummary"),
               let summary = try? JSONDecoder().decode(WeightSummaryMinimal.self, from: data),
               let weight = summary.currentWeight {
                baseWeight = weight
            } else {
                baseWeight = 70.0
            }
        }

        let newWeight = max(baseWeight + delta, 20.0) // minimum 20kg safety
        defaults?.set(newWeight, forKey: "widget.weight.pending")
        defaults?.set(true, forKey: "widget.weight.pendingSaved")

        WidgetCenter.shared.reloadTimelines(ofKind: "WeightQuickInputWidget")
        return .result()
    }
}

private struct WeightSummaryMinimal: Codable {
    let currentWeight: Double?
}
