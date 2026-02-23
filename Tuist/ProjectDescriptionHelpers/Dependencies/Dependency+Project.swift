//
//  Dependency+Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

// MARK: - Layer
public enum ProjectLayer: String {
    case Application

    case InjectionManager
    case Infrastructure

    case Feature

    case LibraryManager
}

// MARK: - Domain
public enum ProjectDomain: String {
    case Base
    case Splash
    case Onboarding
    case Home
    case Settings

    // Healthcare Features
    case Meal
    case Weight
    case Exercise
    case AI
    case Profile
    case Notification
    case Calendar
}

// MARK: - Project
public extension TargetDependency {
    enum Project {
        public struct InjectionManager {}
        public struct Infrastructure {}
        public enum Feature {
            public struct Data {}
            public struct Domain {}
            public struct Presentation {}
        }

        public struct LibraryManager {}
    }
}

// MARK: - InjectionManager
public extension TargetDependency.Project.InjectionManager {
    static let InjectionManager: TargetDependency = .project(name: "InjectionManager")
}

public extension TargetDependency.Project.Infrastructure {
    static let Network: TargetDependency = .project(
        layer: .Infrastructure,
        name: "NetworkInfra"
    )

    static let Storage: TargetDependency = .project(
        layer: .Infrastructure,
        name: "StorageInfra"
    )

    static let AIService: TargetDependency = .project(
        layer: .Infrastructure,
        name: "AIServiceInfra"
    )

    static let HealthKit: TargetDependency = .project(
        layer: .Infrastructure,
        name: "HealthKitInfra"
    )

    static let ImageProcessing: TargetDependency = .project(
        layer: .Infrastructure,
        name: "ImageProcessingInfra"
    )
}

// MARK: - Feature
public extension TargetDependency.Project.Feature {
    static let Tab: TargetDependency = .project(
        layer: .Feature,
        name: "Tab"
    )

    static let Splash: TargetDependency = .project(
        domain: .Splash,
        name: "Splash"
    )

    static let Onboarding: TargetDependency = .project(
        domain: .Onboarding,
        name: "Onboarding"
    )

    static let Home: TargetDependency = .project(
        domain: .Home,
        name: "Home"
    )

    static let Settings: TargetDependency = .project(
        domain: .Settings,
        name: "Settings"
    )

    // Healthcare Features
    static let Meal: TargetDependency = .project(
        domain: .Meal,
        name: "Meal"
    )

    static let Weight: TargetDependency = .project(
        domain: .Weight,
        name: "Weight"
    )

    static let Exercise: TargetDependency = .project(
        domain: .Exercise,
        name: "Exercise"
    )

    static let AI: TargetDependency = .project(
        domain: .AI,
        name: "AI"
    )

    static let Profile: TargetDependency = .project(
        domain: .Profile,
        name: "Profile"
    )

    static let Notification: TargetDependency = .project(
        domain: .Notification,
        name: "Notification"
    )

    static let Calendar: TargetDependency = .project(
        domain: .Calendar,
        name: "Calendar"
    )
}

// MARK: - Data
public extension TargetDependency.Project.Feature.Data {
    static let BaseData: TargetDependency = .project(
        domain: .Base,
        name: "BaseData"
    )

    static let SplashData: TargetDependency = .project(
        domain: .Splash,
        name: "SplashData"
    )

    static let OnboardingData: TargetDependency = .project(
        domain: .Onboarding,
        name: "OnboardingData"
    )

    static let HomeData: TargetDependency = .project(
        domain: .Home,
        name: "HomeData"
    )

    static let SettingsData: TargetDependency = .project(
        domain: .Settings,
        name: "SettingsData"
    )

    // Healthcare Features Data
    static let MealData: TargetDependency = .project(
        domain: .Meal,
        name: "MealData"
    )

    static let WeightData: TargetDependency = .project(
        domain: .Weight,
        name: "WeightData"
    )

    static let ExerciseData: TargetDependency = .project(
        domain: .Exercise,
        name: "ExerciseData"
    )

    static let AIData: TargetDependency = .project(
        domain: .AI,
        name: "AIData"
    )

    static let ProfileData: TargetDependency = .project(
        domain: .Profile,
        name: "ProfileData"
    )

    static let NotificationData: TargetDependency = .project(
        domain: .Notification,
        name: "NotificationData"
    )

    static let CalendarData: TargetDependency = .project(
        domain: .Calendar,
        name: "CalendarData"
    )
}

// MARK: - Domain
public extension TargetDependency.Project.Feature.Domain {
    static let BaseDomain: TargetDependency = .project(
        domain: .Base,
        name: "BaseDomain"
    )

    static let SplashDomain: TargetDependency = .project(
        domain: .Splash,
        name: "SplashDomain"
    )

    static let OnboardingDomain: TargetDependency = .project(
        domain: .Onboarding,
        name: "OnboardingDomain"
    )

    static let HomeDomain: TargetDependency = .project(
        domain: .Home,
        name: "HomeDomain"
    )

    static let SettingsDomain: TargetDependency = .project(
        domain: .Settings,
        name: "SettingsDomain"
    )

    // Healthcare Features Domain
    static let MealDomain: TargetDependency = .project(
        domain: .Meal,
        name: "MealDomain"
    )

    static let WeightDomain: TargetDependency = .project(
        domain: .Weight,
        name: "WeightDomain"
    )

    static let ExerciseDomain: TargetDependency = .project(
        domain: .Exercise,
        name: "ExerciseDomain"
    )

    static let AIDomain: TargetDependency = .project(
        domain: .AI,
        name: "AIDomain"
    )

    static let ProfileDomain: TargetDependency = .project(
        domain: .Profile,
        name: "ProfileDomain"
    )

    static let NotificationDomain: TargetDependency = .project(
        domain: .Notification,
        name: "NotificationDomain"
    )

    static let CalendarDomain: TargetDependency = .project(
        domain: .Calendar,
        name: "CalendarDomain"
    )
}

// MARK: - Presentation
public extension TargetDependency.Project.Feature.Presentation {
    static let BasePresentation: TargetDependency = .project(
        domain: .Base,
        name: "BasePresentation"
    )

    static let SplashPresentation: TargetDependency = .project(
        domain: .Splash,
        name: "SplashPresentation"
    )

    static let OnboardingPresentation: TargetDependency = .project(
        domain: .Onboarding,
        name: "OnboardingPresentation"
    )

    static let HomePresentation: TargetDependency = .project(
        domain: .Home,
        name: "HomePresentation"
    )

    static let SettingsPresentation: TargetDependency = .project(
        domain: .Settings,
        name: "SettingsPresentation"
    )

    // Healthcare Features Presentation
    static let MealPresentation: TargetDependency = .project(
        domain: .Meal,
        name: "MealPresentation"
    )

    static let WeightPresentation: TargetDependency = .project(
        domain: .Weight,
        name: "WeightPresentation"
    )

    static let ExercisePresentation: TargetDependency = .project(
        domain: .Exercise,
        name: "ExercisePresentation"
    )

    static let AIPresentation: TargetDependency = .project(
        domain: .AI,
        name: "AIPresentation"
    )

    static let ProfilePresentation: TargetDependency = .project(
        domain: .Profile,
        name: "ProfilePresentation"
    )

    static let NotificationPresentation: TargetDependency = .project(
        domain: .Notification,
        name: "NotificationPresentation"
    )

    static let CalendarPresentation: TargetDependency = .project(
        domain: .Calendar,
        name: "CalendarPresentation"
    )
}

public extension TargetDependency.Project.LibraryManager {
    static let NetworkLibraries: TargetDependency = .project(
        layer: .LibraryManager,
        name: "NetworkLibraries"
    )

    static let ReactiveLibraries: TargetDependency = .project(
        layer: .LibraryManager,
        name: "ReactiveLibraries"
    )

    static let LayoutLibraries: TargetDependency = .project(
        layer: .LibraryManager,
        name: "LayoutLibraries"
    )

    static let UILibraries: TargetDependency = .project(
        layer: .LibraryManager,
        name: "UILibraries"
    )
}

// MARK: - TargetDependency
public extension TargetDependency {
    static func project(
        layer: ProjectLayer
    ) -> Self {
        return .project(
            target: layer.rawValue,
            path: .relative(to: layer)
        )
    }

    static func project(
        layer: ProjectLayer,
        name: String
    ) -> Self {
        return .project(
            target: name,
            path: .relative(
                to: layer,
                name: name
            )
        )
    }

    static func project(
        domain: ProjectDomain,
        name: String
    ) -> Self {
        return .project(
            target: name,
            path: .relativeFeature(domain: domain)
        )
    }

    static func project(
        name: String
    ) -> Self {
        return .project(
            target: name,
            path: .relativeToProject(name: name)
        )
    }
}
