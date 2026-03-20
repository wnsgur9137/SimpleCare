//
//  SettingsDIContainer.swift
//  Settings
//
//  Created by SimpleCare on 2026-03-18.
//

import Foundation
import BasePresentation
import SettingsPresentation

/// Settings 모듈 의존성 주입 컨테이너
public final class SettingsDIContainer: DIContainer, SettingsCoordinatorDependency {

    // MARK: - Dependencies

    public struct Dependencies {
        public let userProfileId: UUID?
        public let themeManager: ThemeManager
        public let localizationManager: LocalizationManager
        public let notificationManager: NotificationManager
        public let dataExportManager: DataExportManager

        @MainActor
        public init(
            userProfileId: UUID? = nil,
            themeManager: ThemeManager = .shared,
            localizationManager: LocalizationManager = .shared,
            notificationManager: NotificationManager = .shared,
            dataExportManager: DataExportManager = .shared
        ) {
            self.userProfileId = userProfileId
            self.themeManager = themeManager
            self.localizationManager = localizationManager
            self.notificationManager = notificationManager
            self.dataExportManager = dataExportManager
        }
    }

    public let dependencies: Dependencies

    // MARK: - Initialization

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - SettingsCoordinatorDependency

    public var userProfileId: UUID? {
        dependencies.userProfileId
    }

    @MainActor
    public var themeManager: ThemeManager {
        dependencies.themeManager
    }

    @MainActor
    public var localizationManager: LocalizationManager {
        dependencies.localizationManager
    }

    @MainActor
    public var notificationManager: NotificationManager {
        dependencies.notificationManager
    }

    @MainActor
    public var dataExportManager: DataExportManager {
        dependencies.dataExportManager
    }
}
