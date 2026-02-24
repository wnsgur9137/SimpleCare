//
//  NotificationManager.swift
//  BasePresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import Foundation
import UserNotifications
import BaseDomain

// MARK: - Notification Category

/// Notification categories supported in SimpleCare
public enum NotificationCategory: String, CaseIterable, Codable, Identifiable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case exercise = "exercise"
    case weight = "weight"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .breakfast:
            return "notification.meal.breakfast".localized
        case .lunch:
            return "notification.meal.lunch".localized
        case .dinner:
            return "notification.meal.dinner".localized
        case .exercise:
            return "notification.exercise".localized
        case .weight:
            return "notification.weight".localized
        }
    }

    public var icon: String {
        switch self {
        case .breakfast, .lunch, .dinner:
            return "fork.knife"
        case .exercise:
            return "figure.run"
        case .weight:
            return "scalemass"
        }
    }

    public var notificationBody: String {
        switch self {
        case .breakfast:
            return "notification.meal.breakfast.body".localized
        case .lunch:
            return "notification.meal.lunch.body".localized
        case .dinner:
            return "notification.meal.dinner.body".localized
        case .exercise:
            return "notification.exercise.body".localized
        case .weight:
            return "notification.weight.body".localized
        }
    }

    public var defaultHour: Int {
        switch self {
        case .breakfast:
            return 8
        case .lunch:
            return 12
        case .dinner:
            return 18
        case .exercise:
            return 19
        case .weight:
            return 7
        }
    }

    public var defaultMinute: Int {
        return 0
    }

    /// Group categories for UI display
    public var group: NotificationGroup {
        switch self {
        case .breakfast, .lunch, .dinner:
            return .meal
        case .exercise:
            return .exercise
        case .weight:
            return .weight
        }
    }
}

// MARK: - Notification Group

public enum NotificationGroup: String, CaseIterable {
    case meal
    case exercise
    case weight

    public var displayName: String {
        switch self {
        case .meal:
            return "notification.meal".localized
        case .exercise:
            return "notification.exercise".localized
        case .weight:
            return "notification.weight".localized
        }
    }

    public var categories: [NotificationCategory] {
        switch self {
        case .meal:
            return [.breakfast, .lunch, .dinner]
        case .exercise:
            return [.exercise]
        case .weight:
            return [.weight]
        }
    }
}

// MARK: - Notification Setting

/// Individual notification setting for a category
public struct NotificationSetting: Codable, Equatable {
    public var isEnabled: Bool
    public var hour: Int
    public var minute: Int

    public init(isEnabled: Bool = false, hour: Int, minute: Int) {
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
    }

    public var timeDate: Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Notification Constants

public enum NotificationConstants {
    public static let userDefaultsKey = "SimpleCare.NotificationSettings"
    public static let authorizationStatusKey = "SimpleCare.NotificationAuthorized"
}

// MARK: - Notification Manager

/// Manages notification settings and scheduling
@MainActor
public final class NotificationManager: ObservableObject {

    // MARK: - Singleton

    public static let shared = NotificationManager()

    // MARK: - Published Properties

    /// Current notification settings per category
    @Published public private(set) var settings: [NotificationCategory: NotificationSetting]

    /// Whether notification authorization is granted
    @Published public private(set) var isAuthorized: Bool = false

    // MARK: - Private Properties

    private let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Initialization

    private init() {
        self.settings = Self.loadSettings()
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Check current authorization status
    public func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Request notification authorization
    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            isAuthorized = false
            return false
        }
    }

    // MARK: - Settings Management

    /// Update notification enabled state for a category
    public func updateSetting(for category: NotificationCategory, isEnabled: Bool) {
        var setting = settings[category] ?? NotificationSetting(
            hour: category.defaultHour,
            minute: category.defaultMinute
        )
        setting.isEnabled = isEnabled
        settings[category] = setting
        saveSettings()

        if isEnabled {
            scheduleNotification(for: category, setting: setting)
        } else {
            cancelNotification(for: category)
        }
    }

    /// Update notification time for a category
    public func updateTime(for category: NotificationCategory, hour: Int, minute: Int) {
        var setting = settings[category] ?? NotificationSetting(
            hour: category.defaultHour,
            minute: category.defaultMinute
        )
        setting.hour = hour
        setting.minute = minute
        settings[category] = setting
        saveSettings()

        if setting.isEnabled {
            scheduleNotification(for: category, setting: setting)
        }
    }

    /// Update notification time using Date
    public func updateTime(for category: NotificationCategory, date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        updateTime(for: category, hour: components.hour ?? category.defaultHour, minute: components.minute ?? category.defaultMinute)
    }

    /// Get setting for a specific category
    public func setting(for category: NotificationCategory) -> NotificationSetting {
        return settings[category] ?? NotificationSetting(
            isEnabled: false,
            hour: category.defaultHour,
            minute: category.defaultMinute
        )
    }

    // MARK: - Notification Scheduling

    private func scheduleNotification(for category: NotificationCategory, setting: NotificationSetting) {
        // Remove existing notification first
        cancelNotification(for: category)

        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "SimpleCare"
        content.body = category.notificationBody
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = setting.hour
        dateComponents.minute = setting.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: category.rawValue,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(category.rawValue): \(error)")
            }
        }
    }

    private func cancelNotification(for category: NotificationCategory) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [category.rawValue])
    }

    /// Reschedule all enabled notifications (useful after language change)
    public func rescheduleAllNotifications() {
        for category in NotificationCategory.allCases {
            let setting = self.setting(for: category)
            if setting.isEnabled {
                scheduleNotification(for: category, setting: setting)
            }
        }
    }

    // MARK: - Persistence

    private static func loadSettings() -> [NotificationCategory: NotificationSetting] {
        guard let data = UserDefaults.standard.data(forKey: NotificationConstants.userDefaultsKey),
              let decoded = try? JSONDecoder().decode([String: NotificationSetting].self, from: data) else {
            // Return default settings
            var defaults: [NotificationCategory: NotificationSetting] = [:]
            for category in NotificationCategory.allCases {
                defaults[category] = NotificationSetting(
                    isEnabled: false,
                    hour: category.defaultHour,
                    minute: category.defaultMinute
                )
            }
            return defaults
        }

        var settings: [NotificationCategory: NotificationSetting] = [:]
        for (key, value) in decoded {
            if let category = NotificationCategory(rawValue: key) {
                settings[category] = value
            }
        }

        // Fill in any missing categories with defaults
        for category in NotificationCategory.allCases {
            if settings[category] == nil {
                settings[category] = NotificationSetting(
                    isEnabled: false,
                    hour: category.defaultHour,
                    minute: category.defaultMinute
                )
            }
        }

        return settings
    }

    private func saveSettings() {
        var encoded: [String: NotificationSetting] = [:]
        for (category, setting) in settings {
            encoded[category.rawValue] = setting
        }

        if let data = try? JSONEncoder().encode(encoded) {
            UserDefaults.standard.set(data, forKey: NotificationConstants.userDefaultsKey)
        }
    }
}
