//
//  CalendarCoordinator.swift
//  CalendarPresentation
//
//  Created by JunHyeok Lee on 2/21/26.
//

import SwiftUI
import BasePresentation

/// Calendar 화면 Coordinator
public final class CalendarCoordinator: ObservableObject, Coordinator {
    public typealias Content = AnyView

    public init() {}

    @MainActor @ViewBuilder
    public func start() -> some View {
        NavigationStack {
            CalendarContentView()
        }
    }
}
