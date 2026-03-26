//
//  WaterIntakeSection.swift
//  MealPresentation
//

import SwiftUI
import MealDomain
import BasePresentation

struct WaterIntakeSection: View {
    let dailyWaterMl: Int
    let waterGoalMl: Int
    let onAdd: (Int) -> Void

    private var progress: Double {
        guard waterGoalMl > 0 else { return 0 }
        return min(Double(dailyWaterMl) / Double(waterGoalMl), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                Text("meal.water.title".localized)
                    .font(.headline)
                Spacer()
                Text("\(dailyWaterMl)ml / \(waterGoalMl)ml")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(.blue)

            HStack(spacing: 12) {
                WaterQuickAddButton(amount: 200, onAdd: onAdd)
                WaterQuickAddButton(amount: 300, onAdd: onAdd)
                WaterQuickAddButton(amount: 500, onAdd: onAdd)
            }
        }
        .padding()
        .glassCard(cornerRadius: 12)
    }
}

private struct WaterQuickAddButton: View {
    let amount: Int
    let onAdd: (Int) -> Void

    var body: some View {
        Button {
            onAdd(amount)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.caption2)
                Text("\(amount)ml")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
    }
}
