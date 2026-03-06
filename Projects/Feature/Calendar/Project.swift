//
//  Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 2/21/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
    name: "Calendar",
    dataDependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Feature.Data.HomeData,
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
        .Project.Feature.Domain.HomeDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
        .Project.Feature.Presentation.HomePresentation,
    ],
    aggregatorDependencies: [
        .Project.Feature.Presentation.HomePresentation,
    ],
    hasDomainResources: true
)
