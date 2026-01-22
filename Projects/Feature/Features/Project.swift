//
//  Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .project(
    name: "Features",
    product: .framework,
    dependencies: [
        .Project.Feature.Splash,
        .Project.Feature.Onboarding,
        .Project.Feature.Home,
        .Project.Feature.Settings
    ]
)
