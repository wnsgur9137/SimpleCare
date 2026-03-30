import WidgetKit
import SwiftUI

struct WeightTrendWidget: Widget {
    let kind = "WeightTrendWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            WeightTrendWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.weightTitle)
        .description(WidgetStrings.weightDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WeightTrendWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            WeightTrendSmallView(entry: entry)
        case .systemMedium:
            WeightTrendMediumView(entry: entry)
        default:
            WeightTrendSmallView(entry: entry)
        }
    }
}
