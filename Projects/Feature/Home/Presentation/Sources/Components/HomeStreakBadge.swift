//
//  HomeStreakBadge.swift
//  HomePresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI
import BasePresentation

/// 연속 기록 배지
struct HomeStreakBadge: View {
    let days: Int

    var body: some View {
        if days > 0 {
            HStack(spacing: 4) {
                Text("\u{1F525}") // 🔥

                Text("\(days)일 연속")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.scWarning)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.scWarning.opacity(0.15))
            .clipShape(Capsule())
            .accessibilityLabel("\(days)일 연속 기록 중")
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HomeStreakBadge(days: 7)
        HomeStreakBadge(days: 30)
        HomeStreakBadge(days: 0)
    }
    .padding()
}
