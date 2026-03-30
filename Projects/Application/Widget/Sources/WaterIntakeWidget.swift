import WidgetKit
import SwiftUI

struct WaterIntakeWidget: Widget {
    let kind = "WaterIntakeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            WaterIntakeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("수분 섭취")
        .description("오늘의 수분 섭취량을 확인합니다.")
        .supportedFamilies([.systemSmall])
    }
}

struct WaterIntakeWidgetEntryView: View {
    let entry: WidgetEntry

    var body: some View {
        WaterIntakeSmallView(entry: entry)
    }
}
