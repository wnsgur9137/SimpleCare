//
//  Project.swift
//  Profile
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Profile",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Infrastructure.Storage,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
    ],
    hasDomainResources: true
)
