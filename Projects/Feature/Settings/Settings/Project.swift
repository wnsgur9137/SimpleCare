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
    name: "Settings",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Data.SettingsData,
        .Project.Feature.Domain.SettingsDomain,
        .Project.Feature.Presentation.SettingsPresentation
    ]
)
