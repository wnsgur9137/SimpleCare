//
//  TabDIContainer.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import Foundation

import Splash
import Onboarding
import Home
import Settings
import BasePresentation

public final class TabDIContainer: DIContainer {
    public struct Dependencies {
        public init() {}
    }

    public let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

//    public func makeHomeDIContainer() -> HomeDIContainer {
//        return HomeDIContainer(dependencies: ())
//    }
}
