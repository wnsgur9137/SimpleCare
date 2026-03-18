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

        public init(userProfileId: UUID? = nil) {
            self.userProfileId = userProfileId
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
        .shared
    }

    @MainActor
    public var localizationManager: LocalizationManager {
        .shared
    }

    @MainActor
    public var notificationManager: NotificationManager {
        .shared
    }

    @MainActor
    public var dataExportManager: DataExportManager {
        .shared
    }
}
