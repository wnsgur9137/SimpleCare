import WidgetKit
import SwiftUI

struct WaterIntakeWidget: Widget {
    let kind = "WaterIntakeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            WaterIntakeWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.waterTitle)
        .description(WidgetStrings.waterDescription)
        .supportedFamilies([.systemSmall])
    }
}

struct WaterIntakeWidgetEntryView: View {
    let entry: WidgetEntry

    var body: some View {
        if #available(iOS 17.0, *) {
            WaterIntakeInteractiveView(entry: entry)
        } else {
            WaterIntakeSmallView(entry: entry)
        }
    }
}
