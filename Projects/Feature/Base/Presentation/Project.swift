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
    name: "BasePresentation",
    product: .staticFramework,
    dependencies: [
        .Project.Feature.Domain.BaseDomain,
        .Project.LibraryManager.ReactiveLibraries,
        .Project.LibraryManager.LayoutLibraries,
        .Project.LibraryManager.UILibraries,
    ]
)

