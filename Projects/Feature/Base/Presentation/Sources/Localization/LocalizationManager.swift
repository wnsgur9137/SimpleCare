//
//  LocalizationManager.swift
//  BasePresentation
//
//  Created by SimpleCare on 2026-02-19.
//

import Foundation
import SwiftUI
import BaseDomain

// MARK: - Supported Languages

/// Supported languages in SimpleCare
public enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case korean = "ko"
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system:
            return String(localized: "settings.language.system")
        case .korean:
            return "한국어"
        case .english:
            return "English"
        }
    }

    public var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .korean:
            return "ko"
        case .english:
            return "en"
        }
    }
}

// MARK: - Localization Manager

/// Manages app localization and runtime language switching
@MainActor
public final class LocalizationManager: ObservableObject {

    // MARK: - Singleton

    public static let shared = LocalizationManager()

    // MARK: - Published Properties

    /// Current selected language
    @Published public private(set) var currentLanguage: AppLanguage {
        didSet {
            saveLanguagePreference()
            updateBundle()
        }
    }

    /// Current locale for formatting
    @Published public private(set) var currentLocale: Locale

    // MARK: - Private Properties

    private let userDefaultsKey = "SimpleCare.AppLanguage"
    private var bundle: Bundle = .main

    // MARK: - Initialization

    private init() {
        // Load saved language preference or use system
        let initialLanguage: AppLanguage
        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            initialLanguage = language
        } else {
            initialLanguage = .system
        }

        // Initialize all stored properties first
        self.currentLanguage = initialLanguage
        self.currentLocale = Self.resolveLocale(for: initialLanguage)

        // Update bundle for initial language
        updateBundle()
    }

    // MARK: - Public Methods

    /// Change the app language
    /// - Parameter language: The new language to use
    public func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        currentLocale = Self.resolveLocale(for: language)

        // Post notification for views that need to update
        NotificationCenter.default.post(
            name: .languageDidChange,
            object: nil,
            userInfo: ["language": language]
        )
    }

    /// Get the effective language code (resolves system to actual language)
    public var effectiveLanguageCode: String {
        switch currentLanguage {
        case .system:
            return Locale.current.language.languageCode?.identifier ?? "ko"
        case .korean:
            return "ko"
        case .english:
            return "en"
        }
    }

    /// Localized string for the given key
    /// - Parameters:
    ///   - key: The localization key
    ///   - defaultValue: Default value if key not found
    /// - Returns: Localized string
    public func localizedString(for key: String, defaultValue: String? = nil) -> String {
        let value = bundle.localizedString(forKey: key, value: defaultValue, table: nil)
        return value
    }

    // MARK: - Private Methods

    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: userDefaultsKey)
    }

    private func updateBundle() {
        let languageCode = effectiveLanguageCode

        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }

    private static func resolveLocale(for language: AppLanguage) -> Locale {
        switch language {
        case .system:
            return .current
        case .korean:
            return Locale(identifier: "ko_KR")
        case .english:
            return Locale(identifier: "en_US")
        }
    }
}

// MARK: - Notification Extension

public extension Notification.Name {
    static let languageDidChange = Notification.Name("SimpleCare.languageDidChange")
}

// MARK: - View Extension for Localization

public extension View {
    /// Observes language changes and triggers view updates
    func observeLanguageChanges() -> some View {
        self.modifier(LanguageChangeModifier())
    }
}

// MARK: - Language Change Modifier

struct LanguageChangeModifier: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var languageChangeCount = 0

    func body(content: Content) -> some View {
        content
            .id(languageChangeCount)
            .onReceive(NotificationCenter.default.publisher(for: .languageDidChange)) { _ in
                languageChangeCount += 1
            }
            .environment(\.locale, localizationManager.currentLocale)
    }
}

// MARK: - LocalizedStringKey Extension

public extension LocalizedStringKey {
    /// Creates a LocalizedStringKey from a string key
    static func key(_ key: String) -> LocalizedStringKey {
        LocalizedStringKey(key)
    }
}
