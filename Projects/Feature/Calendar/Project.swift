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
    ],
    domainDependencies: [
        .Project.Feature.Domain.BaseDomain,
    ],
    presentationDependencies: [
        .Project.Feature.Presentation.BasePresentation,
    ]
)
