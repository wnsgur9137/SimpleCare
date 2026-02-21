//
//  ThemeManager.swift
//  BasePresentation
//
//  Created by SimpleCare on 2026-02-20.
//

import Foundation
import SwiftUI
import BaseDomain

// MARK: - App Theme

/// Supported themes in SimpleCare
public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system:
            return "settings.theme.system".localized
        case .light:
            return "settings.theme.light".localized
        case .dark:
            return "settings.theme.dark".localized
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    public var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

// MARK: - Theme Constants

public enum ThemeConstants {
    public static let userDefaultsKey = "SimpleCare.AppTheme"
    public static let defaultTheme = AppTheme.system
}

// MARK: - Theme Manager

/// Manages app theme and runtime theme switching
@MainActor
public final class ThemeManager: ObservableObject {

    // MARK: - Singleton

    public static let shared = ThemeManager()

    // MARK: - Published Properties

    /// Current selected theme
    @Published public private(set) var currentTheme: AppTheme {
        didSet {
            saveThemePreference()
        }
    }

    // MARK: - Initialization

    private init() {
        // Load saved theme preference or use system
        if let savedTheme = UserDefaults.standard.string(forKey: ThemeConstants.userDefaultsKey),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = ThemeConstants.defaultTheme
        }
    }

    // MARK: - Public Methods

    /// Change the app theme
    /// - Parameter theme: The new theme to use
    public func setTheme(_ theme: AppTheme) {
        guard theme != currentTheme else { return }
        currentTheme = theme
    }

    /// Get the effective color scheme (resolves system to actual scheme)
    public var effectiveColorScheme: ColorScheme? {
        currentTheme.colorScheme
    }

    // MARK: - Private Methods

    private func saveThemePreference() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: ThemeConstants.userDefaultsKey)
    }
}
