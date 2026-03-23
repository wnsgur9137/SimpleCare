import WidgetKit
import SwiftUI

struct GoalProgressWidget: Widget {
    let kind = "GoalProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            GoalProgressWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("목표 달성률")
        .description("칼로리와 영양소 목표 달성률을 확인합니다.")
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
