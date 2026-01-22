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
    name: "Onboarding",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Data.OnboardingData,
        .Project.Feature.Domain.OnboardingDomain,
        .Project.Feature.Presentation.OnboardingPresentation
    ]
)
