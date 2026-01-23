//
//  Coordinator.swift
//  BasePresentation
//
//  Created by JunHyeok Lee on 1/23/26.
//  Copyright © 2026 com.junhyeok.SimpleCare. All rights reserved.
//

import SwiftUI

public protocol Coordinator: ObservableObject {
    associatedtype Body: View

    @ViewBuilder
    func start() -> Body
}
