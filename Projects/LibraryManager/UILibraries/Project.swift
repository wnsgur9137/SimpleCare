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
    name: "UILibraries",
    product: .framework,
    dependencies: [
        .SPM.UI.KingFisher,
        .SPM.UI.Lottie,
        .SPM.UI.IQKeyboardManager,
        .SPM.UI.AcknowList
    ]
)
