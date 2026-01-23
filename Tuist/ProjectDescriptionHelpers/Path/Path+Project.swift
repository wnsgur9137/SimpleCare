//
//  Path+Project.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

public extension ProjectDescription.Path {
    static func relativeToProject(
        name: String
    ) -> Self {
        return .relativeToRoot("Projects/\(name)")
    }

    static func relative(
        to layer: ProjectLayer
    ) -> Self {
        return .relativeToRoot("Projects/\(layer.rawValue)/\(layer.rawValue)")
    }

    static func relative(
        to layer: ProjectLayer,
        name: String
    ) -> Self {
        return .relativeToRoot("Projects/\(layer.rawValue)/\(name)")
    }

    static func relativeFeature(
        domain: ProjectDomain
    ) -> Self {
        return .relativeToRoot("Projects/Feature/\(domain.rawValue)")
    }
}
