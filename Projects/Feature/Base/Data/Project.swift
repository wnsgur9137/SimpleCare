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
    name: "BaseData",
    product: .staticFramework,
    dependencies: [
        .Project.LibraryManager.ReactiveLibraries,
        .Project.Infrastructure.Network,
        .Project.Feature.Domain.BaseDomain
    ]
)
