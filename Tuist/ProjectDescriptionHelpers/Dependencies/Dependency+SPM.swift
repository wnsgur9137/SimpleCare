//
//  Dependency+SPM.swift
//  SimpleCareManifests
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation
import ProjectDescription

// MARK: - Group
public extension TargetDependency {
    enum SPM {
        public struct Network {}
        public struct Data {}
        public struct Layout {}
        public struct Reactive {}
        public struct UI {}
        public struct Test {}
    }
}

public extension Package {
    struct UI {}
    struct Test {}
}

// MARK: - Network
public extension TargetDependency.SPM.Network {
    static let Alamofire: TargetDependency = .external(name: "Alamofire", condition: .none)
    static let Moya: TargetDependency = .external(name: "Moya", condition: .none)
}

// MARK: - Layout
public extension TargetDependency.SPM.Layout {
    static let SnapKit: TargetDependency = .external(name: "SnapKit", condition: .none)
}

// MARK: - Reactive
public extension TargetDependency.SPM.Reactive {
    static let TCA: TargetDependency = .external(name: "ComposableArchitecture", condition: .none)
    static let CombineCocoa: TargetDependency = .external(name: "CombineCocoa", condition: .none)
}

// MARK: - UI
public extension TargetDependency.SPM.UI {
    static let KingFisher: TargetDependency = .external(name: "Kingfisher", condition: .none)
    static let Lottie: TargetDependency = .external(name: "Lottie", condition: .none)
    static let IQKeyboardManager: TargetDependency = .external(name: "IQKeyboardManagerSwift", condition: .none)
    static let AcknowList: TargetDependency = .external(name: "AcknowList", condition: .none)
}

// MARK: - Test
public extension TargetDependency.SPM.Test {}
