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
    name: "SettingsPresentation",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Presentation.BasePresentation,
        .Project.Feature.Domain.SettingsDomain,
    ]
)
