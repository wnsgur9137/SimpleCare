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
    name: "ReactiveLibraries",
    product: .framework,
    dependencies: [
        .SPM.Reactive.TCA,
        .SPM.Reactive.CombineCocoa
    ]
)
