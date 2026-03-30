import WidgetKit
import SwiftUI

struct ExerciseWidget: Widget {
    let kind = "ExerciseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            ExerciseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("운동 요약")
        .description("오늘의 운동 세션과 칼로리 소모를 확인합니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ExerciseWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            ExerciseSmallView(entry: entry)
        case .systemMedium:
            ExerciseMediumView(entry: entry)
        default:
            ExerciseSmallView(entry: entry)
        }
    }
}
