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
    name: "HomeData",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Data.BaseData,
        .Project.Feature.Domain.HomeDomain
    ]
)
