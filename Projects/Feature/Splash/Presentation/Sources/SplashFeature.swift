//
//  SplashFeature.swift
//  SplashPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SplashFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isAnimating: Bool = false
        public var isCompleted: Bool = false
        public var minimumDuration: TimeInterval

        public init(minimumDuration: TimeInterval = 1.5) {
            self.minimumDuration = minimumDuration
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
        case startAnimation
        case timerCompleted
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case splashCompleted
        }
    }

    // MARK: - Dependencies

    @Dependency(\.continuousClock) var clock

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [duration = state.minimumDuration] send in
                    await send(.startAnimation)
                    try await clock.sleep(for: .seconds(duration))
                    await send(.timerCompleted)
                }

            case .startAnimation:
                state.isAnimating = true
                return .none

            case .timerCompleted:
                state.isCompleted = true
                return .send(.delegate(.splashCompleted))

            case .delegate:
                return .none
            }
        }
    }
}
