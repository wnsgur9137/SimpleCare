//
//  AppConfiguration.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

public enum AppConfiguration: String {
    case DEV
    case PROD

    public var configurationName: ConfigurationName {
        .configuration(rawValue)
    }
}

public extension String {
    static var DEV: String { AppConfiguration.DEV.rawValue }
    static var PROD: String { AppConfiguration.PROD.rawValue }
}

public extension ConfigurationName {
    static var DEV: ConfigurationName { AppConfiguration.DEV.configurationName }
    static var PROD: ConfigurationName { AppConfiguration.PROD.configurationName }
}
