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
    name: "Tab",
    product: .framework,
    dependencies: [
        .Project.Feature.Splash,
        .Project.Feature.Onboarding,
        .Project.Feature.Home,
        .Project.Feature.Settings,
        // Healthcare Features
        .Project.Feature.Meal,
        .Project.Feature.Weight,
        .Project.Feature.Exercise,
        .Project.Feature.Profile,
    ]
)
