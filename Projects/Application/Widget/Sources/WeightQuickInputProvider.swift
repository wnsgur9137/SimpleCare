import BaseDomain
import Foundation
import WidgetKit

struct WeightQuickInputEntry: TimelineEntry {
    let date: Date
    let displayWeight: Double
    let targetWeight: Double?
    let lastRecordedWeight: Double?
    let isPendingSave: Bool
    let isPlaceholder: Bool
}

struct WeightQuickInputProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeightQuickInputEntry {
        WeightQuickInputEntry(
            date: .now,
            displayWeight: 72.5,
            targetWeight: 70.0,
            lastRecordedWeight: 72.8,
            isPendingSave: false,
            isPlaceholder: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WeightQuickInputEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeightQuickInputEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> WeightQuickInputEntry {
        let hasPending = WidgetDataStore.loadPendingWeight() != nil
        let pendingWeight = WidgetDataStore.loadPendingWeight() ?? 0

        let summary = WidgetDataStore.load()
        let currentWeight = summary?.currentWeight
        let targetWeight = summary?.targetWeight

        let displayWeight = hasPending ? pendingWeight : (currentWeight ?? 70.0)

        return WeightQuickInputEntry(
            date: .now,
            displayWeight: displayWeight,
            targetWeight: targetWeight,
            lastRecordedWeight: currentWeight,
            isPendingSave: hasPending,
            isPlaceholder: false
        )
    }
}
