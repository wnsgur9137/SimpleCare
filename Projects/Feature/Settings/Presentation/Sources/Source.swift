//
//  SettingsCoordinator.swift
//  Settings
//
//  Created by JunHyeok Lee on 1/22/26.
//

import SwiftUI
import BasePresentation

// MARK: - SettingsCoordinator

public final class SettingsCoordinator: ObservableObject, Coordinator {
    public init() {}

    @ViewBuilder
    public func start() -> some View {
        SettingsView()
    }
}

// MARK: - SettingsView

public struct SettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var refreshID = UUID()
    @State private var mealRemindersExpanded = false

    public init() {}

    public var body: some View {
        List {
            themeSection
            languageSection
            notificationSection
            appInfoSection
            disclaimerSection
        }
        .navigationTitle("settings.title".localized)
        .id(refreshID)
        .task {
            await notificationManager.checkAuthorizationStatus()
        }
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        Section("settings.theme".localized) {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    themeManager.setTheme(theme)
                } label: {
                    HStack {
                        Image(systemName: theme.icon)
                            .foregroundStyle(themeIconColor(for: theme))
                            .frame(width: 24)
                        Text(theme.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        Section("settings.language".localized) {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    localizationManager.setLanguage(language)
                    notificationManager.rescheduleAllNotifications()
                    refreshID = UUID()
                } label: {
                    HStack {
                        Text(language.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if localizationManager.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section("settings.notifications".localized) {
            if !notificationManager.isAuthorized {
                notificationPermissionButton
            }

            mealRemindersGroup
            exerciseReminderRow
            weightReminderRow
        }
    }

    private var notificationPermissionButton: some View {
        Button {
            Task {
                await notificationManager.requestAuthorization()
            }
        } label: {
            HStack {
                Image(systemName: "bell.badge")
                    .foregroundStyle(.orange)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("notification.enablePermission".localized)
                        .foregroundStyle(.primary)
                    Text("notification.permissionDescription".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var mealRemindersGroup: some View {
        DisclosureGroup(
            isExpanded: $mealRemindersExpanded,
            content: {
                NotificationToggleRow(category: .breakfast, manager: notificationManager)
                NotificationToggleRow(category: .lunch, manager: notificationManager)
                NotificationToggleRow(category: .dinner, manager: notificationManager)
            },
            label: {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    Text("notification.meal".localized)
                }
            }
        )
    }

    private var exerciseReminderRow: some View {
        NotificationToggleRow(category: .exercise, manager: notificationManager)
    }

    private var weightReminderRow: some View {
        NotificationToggleRow(category: .weight, manager: notificationManager)
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section("settings.appInfo".localized) {
            HStack {
                Text("settings.version".localized)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        Section {
            Text("onboarding.disclaimer".localized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func themeIconColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system:
            return .primary
        case .light:
            return .orange
        case .dark:
            return .indigo
        }
    }
}

// MARK: - NotificationToggleRow

struct NotificationToggleRow: View {
    let category: NotificationCategory
    @ObservedObject var manager: NotificationManager

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { manager.setting(for: category).isEnabled },
            set: { manager.updateSetting(for: category, isEnabled: $0) }
        )
    }

    private var selectedTime: Binding<Date> {
        Binding(
            get: { manager.setting(for: category).timeDate },
            set: { manager.updateTime(for: category, date: $0) }
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if category.group.categories.count == 1 {
                    Image(systemName: category.icon)
                        .foregroundStyle(iconColor)
                        .frame(width: 24)
                }
                Text(category.displayName)
                Spacer()
                Toggle("", isOn: isEnabled)
                    .labelsHidden()
            }

            if isEnabled.wrappedValue {
                HStack {
                    Text("notification.time".localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .padding(.leading, category.group.categories.count == 1 ? 32 : 0)
            }
        }
    }

    private var iconColor: Color {
        switch category {
        case .breakfast, .lunch, .dinner:
            return .green
        case .exercise:
            return .orange
        case .weight:
            return .blue
        }
    }
}
