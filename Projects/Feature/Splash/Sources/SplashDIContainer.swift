//
//  SplashDIContainer.swift
//  Splash
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SplashPresentation

public final class SplashDIContainer: SplashCoordinatorDependency {
    public let minimumDuration: TimeInterval

    public init(minimumDuration: TimeInterval = 1.5) {
        self.minimumDuration = minimumDuration
    }
}
