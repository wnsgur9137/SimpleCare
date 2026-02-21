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
    @State private var refreshID = UUID()

    public init() {}

    public var body: some View {
        List {
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

            Section("settings.language".localized) {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        localizationManager.setLanguage(language)
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

            Section("settings.appInfo".localized) {
                HStack {
                    Text("settings.version".localized)
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("onboarding.disclaimer".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings.title".localized)
        .id(refreshID)
    }

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
