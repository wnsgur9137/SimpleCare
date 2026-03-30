import AppIntents
import WidgetKit

struct SelectWidgetDataTypeIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "표시할 데이터"
    static var description: IntentDescription = "위젯에 표시할 데이터 유형을 선택합니다."

    @Parameter(title: "데이터 유형", default: .calories)
    var dataType: WidgetDataType
}
