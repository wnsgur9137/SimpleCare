//
//  Project.swift
//  Weight
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Weight",
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
    ]
)
