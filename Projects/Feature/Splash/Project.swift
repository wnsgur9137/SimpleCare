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
    name: "Splash",
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
