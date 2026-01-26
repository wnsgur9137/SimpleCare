//
//  StreakBadge.swift
//  DashboardPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI

/// 연속 기록 배지
public struct StreakBadge: View {
    let days: Int

    public init(days: Int) {
        self.days = days
    }

    public var body: some View {
        if days > 0 {
            HStack(spacing: 4) {
                Text("\u{1F525}") // 🔥

                Text("\(days)일 연속")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
            .accessibilityLabel("\(days)일 연속 기록 중")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(days: 7)
        StreakBadge(days: 30)
        StreakBadge(days: 0)
    }
    .padding()
}
