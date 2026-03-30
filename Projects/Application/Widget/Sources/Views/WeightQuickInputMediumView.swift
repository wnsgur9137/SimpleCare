import SwiftUI
import WidgetKit

struct WeightQuickInputMediumView: View {
    let entry: WeightQuickInputEntry

    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Label("체중 기록", systemImage: "scalemass.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }

            // Weight adjuster row
            HStack(spacing: 16) {
                // Decrease button
                Button(intent: AdjustWeightIntent(delta: -0.1)) {
                    Text("-0.1")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 52, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemFill))
                        )
                }
                .buttonStyle(.plain)
                .if(entry.isPlaceholder) { $0.redacted(reason: .placeholder) }

                Spacer()

                // Display weight
                VStack(spacing: 2) {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(String(format: "%.1f", entry.displayWeight))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("kg")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .if(entry.isPlaceholder) { $0.redacted(reason: .placeholder) }

                Spacer()

                // Increase button
                Button(intent: AdjustWeightIntent(delta: 0.1)) {
                    Text("+0.1")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 52, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemFill))
                        )
                }
                .buttonStyle(.plain)
                .if(entry.isPlaceholder) { $0.redacted(reason: .placeholder) }
            }

            // Save button
            Button(intent: SaveWeightIntent()) {
                Text("저장")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(entry.isPendingSave ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(entry.isPendingSave ? Color.green : Color(.systemFill))
                    )
            }
            .buttonStyle(.plain)
            .if(entry.isPlaceholder) { $0.redacted(reason: .placeholder) }

            // Footer: last recorded & target
            HStack {
                if let last = entry.lastRecordedWeight {
                    Label(String(format: "어제: %.1f kg", last), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if entry.lastRecordedWeight != nil && entry.targetWeight != nil {
                    Text("|")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let target = entry.targetWeight {
                    Label(String(format: "목표: %.1f kg", target), systemImage: "flag.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .if(entry.isPlaceholder) { $0.redacted(reason: .placeholder) }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}

// MARK: - Previews

#Preview("기본 상태", as: .systemMedium) {
    WeightQuickInputWidget()
} timeline: {
    WeightQuickInputEntry(
        date: .now,
        displayWeight: 72.5,
        targetWeight: 70.0,
        lastRecordedWeight: 72.8,
        isPendingSave: false,
        isPlaceholder: false
    )
}

#Preview("저장 대기 상태", as: .systemMedium) {
    WeightQuickInputWidget()
} timeline: {
    WeightQuickInputEntry(
        date: .now,
        displayWeight: 72.3,
        targetWeight: 70.0,
        lastRecordedWeight: 72.5,
        isPendingSave: true,
        isPlaceholder: false
    )
}
