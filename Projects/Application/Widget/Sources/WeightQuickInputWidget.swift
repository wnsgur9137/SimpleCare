import WidgetKit
import SwiftUI

struct WeightQuickInputWidget: Widget {
    let kind = "WeightQuickInputWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeightQuickInputProvider()) { entry in
            WeightQuickInputMediumView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("체중 기록")
        .description("위젯에서 빠르게 체중을 기록합니다.")
        .supportedFamilies([.systemMedium])
    }
}
