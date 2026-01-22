//
//  Path+XCConfig.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

public extension ProjectDescription.Path {
    static func xcconfig(_ configuration: AppConfiguration) -> Path {
        return "//XCConfig/\(configuration.rawValue).xcconfig"
    }
}
