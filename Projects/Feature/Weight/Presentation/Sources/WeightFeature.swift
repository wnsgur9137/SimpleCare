//
//  WeightFeature.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import WeightDomain

@Reducer
public struct WeightFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var weightTrend: WeightTrend?
        public var newWeightKg: Double
        public var bodyFatPercentage: Double?
        public var notes: String = ""
        public var error: String?

        public var userProfileId: UUID
        public var currentWeight: Double
        public var targetWeight: Double

        public init(userProfileId: UUID, currentWeight: Double, targetWeight: Double) {
            self.userProfileId = userProfileId
            self.currentWeight = currentWeight
            self.targetWeight = targetWeight
            self.newWeightKg = currentWeight
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case loadTrend
        case loadTrendResponse(Result<WeightTrend, Error>)
        case saveWeight
        case saveWeightResponse(Result<Void, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case saveCompleted
        }

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.binding(let l), .binding(let r)):
                return l == r
            case (.onAppear, .onAppear):
                return true
            case (.loadTrend, .loadTrend):
                return true
            case (.loadTrendResponse(.success(let l)), .loadTrendResponse(.success(let r))):
                return l == r
            case (.loadTrendResponse(.failure), .loadTrendResponse(.failure)):
                return true
            case (.saveWeight, .saveWeight):
                return true
            case (.saveWeightResponse(.success), .saveWeightResponse(.success)):
                return true
            case (.saveWeightResponse(.failure), .saveWeightResponse(.failure)):
                return true
            case (.delegate(let l), .delegate(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    // MARK: - Dependencies

    @Dependency(\.weightClient) var weightClient

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .send(.loadTrend)

            case .loadTrend:
                state.isLoading = true
                let userProfileId = state.userProfileId
                let targetWeight = state.targetWeight

                return .run { send in
                    do {
                        let trend = try await weightClient.getWeightTrend(userProfileId, targetWeight, 30)
                        await send(.loadTrendResponse(.success(trend)))
                    } catch {
                        await send(.loadTrendResponse(.failure(error)))
                    }
                }

            case .loadTrendResponse(.success(let trend)):
                state.isLoading = false
                state.weightTrend = trend
                return .none

            case .loadTrendResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .saveWeight:
                state.isLoading = true
                state.error = nil

                let record = WeightRecord(
                    userProfileId: state.userProfileId,
                    weightKg: state.newWeightKg,
                    bodyFatPercentage: state.bodyFatPercentage,
                    notes: state.notes.isEmpty ? nil : state.notes
                )

                return .run { send in
                    do {
                        try await weightClient.recordWeight(record)
                        await send(.saveWeightResponse(.success(())))
                    } catch {
                        await send(.saveWeightResponse(.failure(error)))
                    }
                }

            case .saveWeightResponse(.success):
                state.isLoading = false
                return .concatenate(
                    .send(.loadTrend),
                    .send(.delegate(.saveCompleted))
                )

            case .saveWeightResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Dependencies

public struct WeightClient {
    public var recordWeight: @Sendable (WeightRecord) async throws -> Void
    public var getWeightTrend: @Sendable (UUID, Double, Int) async throws -> WeightTrend

    public init(
        recordWeight: @escaping @Sendable (WeightRecord) async throws -> Void,
        getWeightTrend: @escaping @Sendable (UUID, Double, Int) async throws -> WeightTrend
    ) {
        self.recordWeight = recordWeight
        self.getWeightTrend = getWeightTrend
    }
}

extension WeightClient: DependencyKey {
    public static var liveValue: WeightClient {
        WeightClient(
            recordWeight: { _ in },
            getWeightTrend: { _, targetWeight, _ in
                WeightTrend(
                    currentWeight: targetWeight,
                    targetWeight: targetWeight,
                    records: []
                )
            }
        )
    }

    public static var testValue: WeightClient {
        WeightClient(
            recordWeight: { _ in },
            getWeightTrend: { _, targetWeight, _ in
                WeightTrend(
                    currentWeight: 70,
                    previousWeight: 71,
                    targetWeight: targetWeight,
                    weeklyChange: -0.5,
                    monthlyChange: -2.0,
                    records: []
                )
            }
        )
    }
}

extension DependencyValues {
    public var weightClient: WeightClient {
        get { self[WeightClient.self] }
        set { self[WeightClient.self] = newValue }
    }
}
