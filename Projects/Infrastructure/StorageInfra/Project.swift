//
//  Project.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .project(
    name: "StorageInfra",
    product: .framework,
    dependencies: [
        .Project.LibraryManager.ReactiveLibraries,
    ]
)
