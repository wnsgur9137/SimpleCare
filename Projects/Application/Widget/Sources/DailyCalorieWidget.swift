import WidgetKit
import SwiftUI

struct DailyCalorieWidget: Widget {
    let kind = "DailyCalorieWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            DailyCalorieWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.dailyCalorieTitle)
        .description(WidgetStrings.dailyCalorieDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DailyCalorieWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            DailyCalorieSmallView(entry: entry)
        case .systemMedium:
            DailyCalorieMediumView(entry: entry)
        default:
            DailyCalorieSmallView(entry: entry)
        }
    }
}
