//
//  Project.swift
//  Meal
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Meal",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Feature.Data.ProfileData,
        .Project.Infrastructure.Storage,
        .Project.Infrastructure.AIService,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
        .Project.Feature.Domain.ProfileDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
    ],
    hasDomainResources: true
)
