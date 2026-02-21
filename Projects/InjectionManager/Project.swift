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
    name: "InjectionManager",
    product: .staticFramework,
    dependencies: [
        .Project.Infrastructure.Network,
        .Project.Feature.Tab
    ]
)
