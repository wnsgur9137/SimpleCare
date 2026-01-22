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

    case Base
    case Feature
    case Data
    case Domain
    case Presentation

    case LibraryManager
}

// MARK: - Domain
public enum ProjectDomain: String {
    case Splash
    case Onboarding
    case Home
    case Settings
}

// MARK: - Project
public extension TargetDependency {
    enum Project {
        public struct InjectionManager {}
        public struct Infrastructure {}
        public struct Base {}
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
}

// MARK: - Base
public extension TargetDependency.Project.Base {
    static let Data: TargetDependency = .project(
        layer: .Base,
        name: "BaseData"
    )

    static let Domain: TargetDependency = .project(
        layer: .Base,
        name: "BaseDomain"
    )

    static let Presentation: TargetDependency = .project(
        layer: .Base,
        name: "BasePresentation"
    )
}

// MARK: - Feature
public extension TargetDependency.Project.Feature {
    static let Features: TargetDependency = .project(
        layer: .Feature,
        name: "Features"
    )

    static let Splash: TargetDependency = .project(
        layer: .Feature,
        domain: .Splash,
        name: "Splash"
    )

    static let Onboarding: TargetDependency = .project(
        layer: .Feature,
        domain: .Onboarding,
        name: "Onboarding"
    )

    static let Home: TargetDependency = .project(
        layer: .Feature,
        domain: .Home,
        name: "Home"
    )

    static let Settings: TargetDependency = .project(
        layer: .Feature,
        domain: .Settings,
        name: "Settings"
    )
}

// MARK: - Data
public extension TargetDependency.Project.Feature.Data {
    static let SplashData: TargetDependency = .project(
        domain: .Splash,
        layer: .Data,
        name: "SplashData"
    )

    static let OnboardingData: TargetDependency = .project(
        domain: .Onboarding,
        layer: .Data,
        name: "OnboardingData"
    )

    static let HomeData: TargetDependency = .project(
        domain: .Home,
        layer: .Data,
        name: "HomeData"
    )

    static let SettingsData: TargetDependency = .project(
        domain: .Settings,
        layer: .Data,
        name: "SettingsData"
    )
}

// MARK: - Domain
public extension TargetDependency.Project.Feature.Domain {
    static let SplashDomain: TargetDependency = .project(
        domain: .Splash,
        layer: .Domain,
        name: "SplashDomain"
    )

    static let OnboardingDomain: TargetDependency = .project(
        domain: .Onboarding,
        layer: .Domain,
        name: "OnboardingDomain"
    )

    static let HomeDomain: TargetDependency = .project(
        domain: .Home,
        layer: .Domain,
        name: "HomeDomain"
    )

    static let SettingsDomain: TargetDependency = .project(
        domain: .Settings,
        layer: .Domain,
        name: "SettingsDomain"
    )
}

// MARK: - Presentation
public extension TargetDependency.Project.Feature.Presentation {
    static let SplashPresentation: TargetDependency = .project(
        domain: .Splash,
        layer: .Presentation,
        name: "SplashPresentation"
    )

    static let OnboardingPresentation: TargetDependency = .project(
        domain: .Onboarding,
        layer: .Presentation,
        name: "OnboardingPresentation"
    )

    static let HomePresentation: TargetDependency = .project(
        domain: .Home,
        layer: .Presentation,
        name: "HomePresentation"
    )

    static let SettingsPresentation: TargetDependency = .project(
        domain: .Settings,
        layer: .Presentation,
        name: "SettingsPresentation"
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
        layer: ProjectLayer,
        domain: ProjectDomain,
        name: String
    ) -> Self {
        return .project(
            target: name,
            path: .relative(
                to: layer,
                domain: domain,
                name: name
            )
        )
    }

    static func project(
        domain: ProjectDomain,
        layer: ProjectLayer,
        name: String
    ) -> Self {
        return .project(
            target: name,
            path: .relative(
                domain: domain,
                layer: layer
            )
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
