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
    name: "Splash",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Data.SplashData,
        .Project.Feature.Domain.SplashDomain,
        .Project.Feature.Presentation.SplashPresentation
    ]
)

