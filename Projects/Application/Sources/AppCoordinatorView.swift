//
//  AppCoordinatorView.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

import BasePresentation

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        Group {
            if !coordinator.isSplashCompleted {
                coordinator.makeSplash()
            } else if !coordinator.isOnboardingCompleted {
                coordinator.makeOnboarding()
            } else {
                coordinator.makeTabCoordinator()
            }
        }
        .animation(.easeInOut, value: coordinator.isSplashCompleted)
        .animation(.easeInOut, value: coordinator.isOnboardingCompleted)
        #if DEBUG
        .debugOverlay()
        #endif
    }
}
