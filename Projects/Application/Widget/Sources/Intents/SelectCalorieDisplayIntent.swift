import AppIntents
import WidgetKit

struct SelectCalorieDisplayIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "칼로리 표시 방식"
    static var description: IntentDescription = "칼로리 위젯의 표시 방식을 선택합니다."

    @Parameter(title: "표시 방식", default: .intake)
    var displayMode: CalorieDisplayMode
}
