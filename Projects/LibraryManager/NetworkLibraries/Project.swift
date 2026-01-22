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
    name: "NetworkLibraries",
    product: .framework,
    dependencies: [
        .SPM.Network.Alamofire,
        .SPM.Network.Moya
    ]
)
