import AppIntents
import BaseDomain
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
        let baseWeight: Double

        if let pendingWeight = WidgetDataStore.loadPendingWeight() {
            baseWeight = pendingWeight
        } else if let summary = WidgetDataStore.load(), let current = summary.currentWeight {
            baseWeight = current
        } else {
            baseWeight = 70.0
        }

        let newWeight = max(baseWeight + delta, 20.0) // minimum 20kg safety
        WidgetDataStore.savePendingWeight(newWeight)

        WidgetCenter.shared.reloadTimelines(ofKind: "WeightQuickInputWidget")
        return .result()
    }
}
