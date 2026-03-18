//
//  NotificationEnableBanner.swift
//  BasePresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import SwiftUI
import BaseDomain

/// 알림 활성화를 유도하는 배너 컴포넌트
public struct NotificationEnableBanner: View {
    let categories: [NotificationCategory]
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var isDismissed = false

    public init(categories: [NotificationCategory]) {
        self.categories = categories
    }

    /// 단일 카테고리용 convenience initializer
    public init(category: NotificationCategory) {
        self.categories = [category]
    }

    private var shouldShow: Bool {
        guard !isDismissed else { return false }
        guard notificationManager.isAuthorized else { return false }

        // 모든 관련 카테고리가 비활성화되어 있으면 표시
        return categories.allSatisfy { category in
            !notificationManager.setting(for: category).isEnabled
        }
    }

    private var bannerTitle: String {
        if categories.count == 1 {
            return categories[0].displayName
        } else {
            return "notification.meal".localized
        }
    }

    private var bannerIcon: String {
        categories.first?.icon ?? "bell"
    }

    public var body: some View {
        if shouldShow {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .font(.title3)
                    .foregroundStyle(.scWarning)

                VStack(alignment: .leading, spacing: 2) {
                    Text("notification.banner.title".localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("notification.banner.description".localized(with: bannerTitle))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    enableNotifications()
                } label: {
                    Text("notification.banner.enable".localized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.scWarning, in: .capsule)
                }

                Button {
                    withAnimation {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color.scWarning.opacity(0.1), in: .rect(cornerRadius: 12))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func enableNotifications() {
        for category in categories {
            notificationManager.updateSetting(for: category, isEnabled: true)
        }
        withAnimation {
            isDismissed = true
        }
    }
}

#Preview {
    VStack {
        NotificationEnableBanner(category: .exercise)
        NotificationEnableBanner(categories: [.breakfast, .lunch, .dinner])
    }
    .padding()
}
