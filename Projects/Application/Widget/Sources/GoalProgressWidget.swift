import WidgetKit
import SwiftUI

struct GoalProgressWidget: Widget {
    let kind = "GoalProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            GoalProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(WidgetStrings.goalProgressTitle)
        .description(WidgetStrings.goalProgressDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct GoalProgressWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            GoalProgressSmallView(entry: entry)
        case .systemMedium:
            GoalProgressMediumView(entry: entry)
        default:
            GoalProgressSmallView(entry: entry)
        }
    }
}
