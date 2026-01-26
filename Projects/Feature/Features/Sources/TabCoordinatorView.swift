//
//  TabCoordinatorView.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

struct TabCoordinatorView: View {
    @ObservedObject var coordinator: TabCoordinator

    var body: some View {
        Group {
            if !coordinator.isSplashCompleted {
                coordinator.makeSplash()
            } else {
                MainTabView(coordinator: coordinator)
            }
        }
    }
}
