//
//  Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Onboarding",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Feature.Data.ProfileData,
        .Project.Infrastructure.Storage,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
        .Project.Feature.Domain.ProfileDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
        .Project.Feature.Presentation.ProfilePresentation,
    ]
)
