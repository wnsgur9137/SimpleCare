import AppIntents
import BaseDomain
import WidgetKit

struct SaveWeightIntent: AppIntent {
    static var title: LocalizedStringResource = "체중 저장"
    static var description: IntentDescription = "조절된 체중을 저장합니다."

    func perform() async throws -> some IntentResult {
        // Re-save the pending weight to mark it as confirmed for the app to consume via consumePendingWeight()
        if let pendingWeight = WidgetDataStore.loadPendingWeight() {
            WidgetDataStore.savePendingWeight(pendingWeight)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "WeightQuickInputWidget")
        return .result()
    }
}
