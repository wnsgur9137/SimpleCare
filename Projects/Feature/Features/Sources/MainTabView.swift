//
//  MainTabView.swift
//  Features
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

public struct MainTabView: View {
    @ObservedObject var coordinator: TabCoordinator

    public init(coordinator: TabCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            EmptyView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)
        }
    }
}
