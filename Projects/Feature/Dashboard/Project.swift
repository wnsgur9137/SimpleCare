//
//  Project.swift
//  Dashboard
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Dashboard",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Feature.Data.ProfileData,
        .Project.Feature.Data.MealData,
        .Project.Infrastructure.Storage,
        .Project.Infrastructure.AIService,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
        .Project.Feature.Domain.ProfileDomain,
        .Project.Feature.Domain.MealDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
    ]
)
