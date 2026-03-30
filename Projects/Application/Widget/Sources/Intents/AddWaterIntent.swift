import AppIntents
import BaseDomain
import WidgetKit

struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "물 1잔 추가"
    static var description: IntentDescription = "수분 섭취량에 물 1잔(250mL)을 추가합니다."

    func perform() async throws -> some IntentResult {
        WidgetDataStore.addWaterCup()

        // Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "WaterIntakeWidget")

        return .result()
    }
}
