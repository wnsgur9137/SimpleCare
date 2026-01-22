//
//  NetworkInfra.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .project(
    name: "NetworkInfra",
    product: .framework,
    dependencies: [
        .Project.LibraryManager.ReactiveLibraries,
        .Project.LibraryManager.NetworkLibraries
    ]
)
