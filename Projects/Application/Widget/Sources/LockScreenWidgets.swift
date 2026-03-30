import WidgetKit
import SwiftUI

struct LockScreenWidget: Widget {
    let kind = "LockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetDataProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("잠금 화면")
        .description("잠금 화면에서 건강 요약을 확인합니다.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            LockScreenInlineView(entry: entry)
        default:
            LockScreenCircularView(entry: entry)
        }
    }
}
