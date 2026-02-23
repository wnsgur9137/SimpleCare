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
    name: "Home",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Infrastructure.Storage,
        .Project.Infrastructure.AIService,
        .Project.Infrastructure.HealthKit,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
    ],
    hasDomainResources: true
)
