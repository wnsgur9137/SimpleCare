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
    name: "Base",
    dataDependencies: [
        .Project.LibraryManager.ReactiveLibraries,
        .Project.Infrastructure.Network,
    ],
    domainDependencies: [
        .Project.LibraryManager.ReactiveLibraries,
    ],
    presentationDependencies: [
        .Project.LibraryManager.ReactiveLibraries,
        .Project.LibraryManager.LayoutLibraries,
        .Project.LibraryManager.UILibraries,
    ],
    hasDomainResources: true,
    hasPresentationResources: true,
    hasAggregator: false
)
