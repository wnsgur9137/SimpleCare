//
//  AppCoordinatorView.swift
//  SimpleCare
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        coordinator.start()
    }
}
