//
//  Project.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .project(
    name: "AIServiceInfra",
    product: .framework,
    dependencies: [
        .Project.LibraryManager.NetworkLibraries,
        .Project.LibraryManager.ReactiveLibraries,
    ]
)
