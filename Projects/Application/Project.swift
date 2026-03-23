//
//  Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Scripts
private let scripts: [TargetScript] = [
    .swiftLint
]

// MARK: - Targets
private let targets: [Target] = [
    .target(
        name: TuistConstants.projectName,
        destinations: .iOS,
        product: .app,
        productName: TuistConstants.projectName,
        bundleId: TuistConstants.organizationName,
        deploymentTargets: TuistConstants.deploymentTarget,
        infoPlist: .extendingDefault(with: defaultInfoPlist),
        sources: ["Sources/**"],
        resources: ["Resources/**"],
        entitlements: "SimpleCare.entitlements",
        scripts: scripts,
        dependencies: [
            .Project.Feature.Tab,
            .Project.InjectionManager.InjectionManager,
            .target(name: "\(TuistConstants.projectName)Widget")
        ],
        settings: .settings(
            base: [
                "TARGETED_DEVICE_FAMILY": "1,2",
                "SUPPORTS_MACCATALYST": "NO",
                "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO"
            ],
            configurations: [
                .debug(
                    name: .DEV,
                    settings: [
                        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconDev",
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName)-Dev",
                        "PRODUCT_NAME": "\(TuistConstants.projectName)-Dev"
                    ],
                    xcconfig: .xcconfig(.DEV)
                ),
                .release(
                    name: .PROD,
                    settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "RELEASE",
                        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName)",
                        "PRODUCT_NAME": "\(TuistConstants.projectName)"
                    ],
                    xcconfig: .xcconfig(.PROD)
                )
            ]
        ),
        launchArguments: [
            .launchArgument(
                name: "IDEPreferLogStreaming",
                isEnabled: true
            )
        ]
    ),
    .target(
        name: "\(TuistConstants.projectName)Widget",
        destinations: .iOS,
        product: .appExtension,
        productName: "\(TuistConstants.projectName)Widget",
        bundleId: "\(TuistConstants.organizationName).Widget",
        deploymentTargets: TuistConstants.deploymentTarget,
        infoPlist: .extendingDefault(with: [
            "NSExtension": .dictionary([
                "NSExtensionPointIdentifier": .string("com.apple.widgetkit-extension")
            ])
        ]),
        sources: ["Widget/Sources/**"],
        resources: ["Widget/Resources/**"],
        entitlements: "SimpleCareWidget.entitlements",
        dependencies: [
            .Project.Feature.Domain.BaseDomain
        ],
        settings: .settings(
            base: [:],
            configurations: [
                .debug(
                    name: .DEV,
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName)-Dev.Widget"
                    ],
                    xcconfig: .xcconfig(.DEV)
                ),
                .release(
                    name: .PROD,
                    settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName).Widget"
                    ],
                    xcconfig: .xcconfig(.PROD)
                )
            ]
        )
    ),
    .target(
        name: "\(TuistConstants.projectName)Tests",
        destinations: .iOS,
        product: .unitTests,
        productName: "\(TuistConstants.projectName)Tests",
        bundleId: "\(TuistConstants.organizationName)Tests",
        deploymentTargets: TuistConstants.deploymentTarget,
        infoPlist: .default,
        sources: ["Tests/**"],
        entitlements: nil,
        dependencies: [
            .target(name: TuistConstants.projectName)
        ],
        settings: .settings(
            base: [:],
            configurations: [
                .debug(
                    name: .DEV,
                    settings: [
                        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconDev",
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName)Tests-Dev",
                        "PRODUCT_NAME": "\(TuistConstants.projectName)Tests-Dev"
                    ],
                    xcconfig: .xcconfig(.DEV)
                ),
                .debug(
                    name: .PROD,
                    settings: [
                        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconDev",
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(TuistConstants.organizationName)Tests",
                        "PRODUCT_NAME": "\(TuistConstants.projectName)Tests"
                    ],
                    xcconfig: .xcconfig(.PROD)
                )
            ]
        ),
        launchArguments: [
            .launchArgument(
                name: "IDEPreferLogStreaming",
                isEnabled: true
            )
        ]
    )
]

// MARK: - Schemes
private let schemes: [Scheme] = []

// MARK: - Project
let project: Project = .init(
    name: "Application",
    organizationName: TuistConstants.organizationName,
    options: .options(
        defaultKnownRegions: TuistConstants.defaultKnownRegions,
        developmentRegion: TuistConstants.developmentRegion
    ),
    settings: defaultSettings,
    targets: targets,
    schemes: schemes,
    additionalFiles: []
)
