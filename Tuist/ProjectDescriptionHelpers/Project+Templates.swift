//
//  Project+Templates.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

// MARK: - Constants
public enum TuistConstants {
    public static let projectName: String = "SimpleCare"
    public static let appVersion: Plist.Value = "0.0.1"
    public static let bundleVersion: Plist.Value = "1"
    public static let organizationName: String = "com.junhyeok.\(TuistConstants.projectName)"
    public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
    public static let defaultKnownRegions: [String] = ["en", "ko"]
    public static let developmentRegion: String = "ko"
}

// MARK: - Default InfoPlist
public let defaultInfoPlist: [String: Plist.Value] = [
    "CFBundleShortVersionString": TuistConstants.appVersion,
    "CFBundleVersion": TuistConstants.bundleVersion,
    "UIAppFonts": [],
    "AppConfigurations": [],
    "NSAppTransportSecurity": [
        "NSAllowsArbitraryLoads": true
    ],
    "LSApplicationQueriesSchemes": [],
    "CFBundleURLTypes": [],
    "UIRequiresFullScreen": false,
    "UIUserInterfaceStyle": "Automatic",
    "UILaunchScreen": [:],
    "UISupportedInterfaceOrientations": [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight"
    ],
    "UISupportedInterfaceOrientations~ipad": [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationPortraitUpsideDown",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight"
    ]
]

// MARK: - Default Settings
public let defaultSettings: Settings = .settings(
    base: [
        "DEVELOPMENT_TEAM": "VW2UR5Y845"
    ],
    configurations: [
        .debug(name: .DEV),
        .release(name: .PROD)
    ]
)

// MARK: - Project
public extension Project {
    static func feature(
        name: String,
        destinations: Destinations = .iOS,
        product: Product = .staticFramework,
        organizationName: String = TuistConstants.organizationName,
        deploymentTargets: DeploymentTargets? = TuistConstants.deploymentTarget,
        dataDependencies: [TargetDependency] = [],
        domainDependencies: [TargetDependency] = [],
        presentationDependencies: [TargetDependency] = [],
        hasAggregator: Bool = true,
        hasTest: Bool = false,
        hasDemoApp: Bool = false
    ) -> Project {
        let settings: Settings = defaultSettings

        let domainTarget: Target = .target(
            name: "\(name)Domain",
            destinations: destinations,
            product: product,
            bundleId: "\(organizationName).\(name)Domain",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Domain/Sources/**"],
            dependencies: domainDependencies,
            settings: settings
        )

        let dataTarget: Target = .target(
            name: "\(name)Data",
            destinations: destinations,
            product: product,
            bundleId: "\(organizationName).\(name)Data",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Data/Sources/**"],
            dependencies: [.target(name: "\(name)Domain")] + dataDependencies,
            settings: settings
        )

        let presentationTarget: Target = .target(
            name: "\(name)Presentation",
            destinations: destinations,
            product: product,
            bundleId: "\(organizationName).\(name)Presentation",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Presentation/Sources/**"],
            dependencies: [.target(name: "\(name)Domain")] + presentationDependencies,
            settings: settings
        )

        var targets: [Target] = [dataTarget, domainTarget, presentationTarget]

        if hasAggregator {
            let aggregatorTarget: Target = .target(
                name: name,
                destinations: destinations,
                product: product,
                bundleId: "\(organizationName).\(name)",
                deploymentTargets: deploymentTargets,
                infoPlist: .default,
                sources: ["Sources/**"],
                dependencies: [
                    .target(name: "\(name)Data"),
                    .target(name: "\(name)Domain"),
                    .target(name: "\(name)Presentation")
                ],
                settings: settings
            )
            targets.append(aggregatorTarget)
        }

        let demoAppTarget: Target = .target(
            name: "\(name)DemoApp",
            destinations: destinations,
            product: .app,
            bundleId: "\(organizationName).\(name)DemoApp",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: defaultInfoPlist),
            sources: ["Demo/**"],
            resources: ["Demo/Resources/**"],
            dependencies: hasAggregator
                ? [.target(name: name)]
                : [
                    .target(name: "\(name)Data"),
                    .target(name: "\(name)Domain"),
                    .target(name: "\(name)Presentation")
                ],
            settings: settings
        )

        let testTargetDependencies: [TargetDependency] = hasDemoApp
            ? [.target(name: "\(name)DemoApp")]
            : hasAggregator
            ? [.target(name: name)]
            : [
                .target(name: "\(name)Data"),
                .target(name: "\(name)Domain"),
                .target(name: "\(name)Presentation")
            ]

        let testTarget: Target = .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(organizationName).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: testTargetDependencies
        )

        let schemes: [Scheme] = hasDemoApp
            ? [
                .makeScheme(target: .DEV, name: name),
                .makeDemoScheme(target: .DEV, name: name)
            ]
            : [
                .makeScheme(target: .DEV, name: name)
            ]

        if hasTest {
            targets.append(testTarget)
        }
        if hasDemoApp {
            targets.append(demoAppTarget)
        }

        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(
                defaultKnownRegions: TuistConstants.defaultKnownRegions,
                developmentRegion: TuistConstants.developmentRegion
            ),
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }

    static func project(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        organizationName: String = TuistConstants.organizationName,
        deploymentTargets: DeploymentTargets? = TuistConstants.deploymentTarget,
        settings: [String: SettingValue] = [:],
        packages: [Package] = [],
        dependencies: [TargetDependency] = [],
        infoPlist: [String: Plist.Value] = [:],
        hasTest: Bool = false,
        hasResource: Bool = false,
        hasDemoApp: Bool = false
    ) -> Project {
        let settings: Settings = defaultSettings

        let target: Target = .target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: "\(organizationName).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            resources: hasResource ? ["Resources/**"] : nil,
            dependencies: dependencies,
            settings: settings
        )

        let demoAppTarget: Target = .target(
            name: "\(name)DemoApp",
            destinations: destinations,
            product: .app,
            bundleId: "\(organizationName).\(name)DemoApp",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: defaultInfoPlist),
            sources: ["Demo/**"],
            resources: ["Demo/Resources/**"],
            dependencies: [.target(name: name)],
            settings: settings
        )

        let testTargetDependencies: [TargetDependency] = hasDemoApp
            ? [.target(name: "\(name)DemoApp")]
            : [.target(name: "\(name)")]

        let testTarget: Target = .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(organizationName).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: testTargetDependencies
        )

        let schemes: [Scheme] = hasDemoApp
            ? [
                .makeScheme(target: .DEV, name: name),
                .makeDemoScheme(target: .DEV, name: name)
            ]
            : [
                .makeScheme(target: .DEV, name: name)
            ]

        var targets: [Target] = [target]
        if hasTest {
            targets.append(testTarget)
        }
        if hasDemoApp {
            targets.append(demoAppTarget)
        }

        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(
                defaultKnownRegions: TuistConstants.defaultKnownRegions,
                developmentRegion: TuistConstants.developmentRegion
            ),
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }
}
