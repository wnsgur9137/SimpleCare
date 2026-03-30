import WidgetKit
import SwiftUI

struct WeightQuickInputWidget: Widget {
    let kind = "WeightQuickInputWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeightQuickInputProvider()) { entry in
            WeightQuickInputMediumView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.weightQuickInputTitle)
        .description(WidgetStrings.weightQuickInputDescription)
        .supportedFamilies([.systemMedium])
    }
}
