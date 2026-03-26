//
//  WeightFeature.swift
//  WeightPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import ComposableArchitecture
import WeightDomain
import BaseDomain

@Reducer
public struct WeightFeature {
    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var weightTrend: WeightTrend?
        public var newWeightKg: Double
        public var bodyFatPercentage: Double?
        /// 골격근량 (kg), 선택 입력
        public var skeletalMuscleMass: Double?
        /// 목표 달성률 계산용 시작 체중 (가장 오래된 기록에서 자동 설정)
        public var startWeight: Double?
        public var notes: String = ""
        public var error: String?
        public var selectedPeriod: TrendPeriod = .month

        public var userProfileId: UUID
        public var currentWeight: Double
        public var targetWeight: Double
        public var heightCm: Double

        public enum TrendPeriod: Int, CaseIterable, Equatable {
            case week = 7
            case month = 30
            case threeMonths = 90

            public var displayName: String {
                switch self {
                case .week: return "period.7days".localized
                case .month: return "period.30days".localized
                case .threeMonths: return "period.90days".localized
                }
            }
        }

        /// 현재 체중 기반 BMI
        public var currentBMI: Double {
            guard heightCm > 0 else { return 0 }
            let heightM = heightCm / 100.0
            return newWeightKg / (heightM * heightM)
        }

        public init(userProfileId: UUID, currentWeight: Double, targetWeight: Double, heightCm: Double = 170.0) {
            self.userProfileId = userProfileId
            self.currentWeight = currentWeight
            self.targetWeight = targetWeight
            self.heightCm = heightCm
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
        case selectPeriod(State.TrendPeriod)
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
            case (.selectPeriod(let l), .selectPeriod(let r)):
                return l == r
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
                let days = state.selectedPeriod.rawValue

                return .run { send in
                    do {
                        let trend = try await weightClient.getWeightTrend(userProfileId, targetWeight, days)
                        await send(.loadTrendResponse(.success(trend)))
                    } catch {
                        await send(.loadTrendResponse(.failure(error)))
                    }
                }

            case .selectPeriod(let period):
                state.selectedPeriod = period
                return .send(.loadTrend)

            case .loadTrendResponse(.success(let trend)):
                state.isLoading = false
                state.weightTrend = trend
                if state.startWeight == nil, let oldest = trend.records.last {
                    state.startWeight = oldest.weightKg
                }
                return .none

            case .loadTrendResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.userMessage
                return .none

            case .saveWeight:
                state.isLoading = true
                state.error = nil

                let record = WeightRecord(
                    userProfileId: state.userProfileId,
                    weightKg: state.newWeightKg,
                    bodyFatPercentage: state.bodyFatPercentage,
                    skeletalMuscleMassKg: state.skeletalMuscleMass,
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
                state.error = error.userMessage
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
    public var syncWeightToHealthKit: @Sendable (Double, Date) async -> Void
    public var isHealthKitAvailable: @Sendable () -> Bool

    public init(
        recordWeight: @escaping @Sendable (WeightRecord) async throws -> Void,
        getWeightTrend: @escaping @Sendable (UUID, Double, Int) async throws -> WeightTrend,
        syncWeightToHealthKit: @escaping @Sendable (Double, Date) async -> Void = { _, _ in },
        isHealthKitAvailable: @escaping @Sendable () -> Bool = { false }
    ) {
        self.recordWeight = recordWeight
        self.getWeightTrend = getWeightTrend
        self.syncWeightToHealthKit = syncWeightToHealthKit
        self.isHealthKitAvailable = isHealthKitAvailable
    }
}

extension WeightClient: DependencyKey {
    public static var liveValue: WeightClient {
        WeightClient(
            recordWeight: unimplemented("WeightClient.recordWeight"),
            getWeightTrend: { _, targetWeight, _ in
                WeightTrend(
                    currentWeight: targetWeight,
                    targetWeight: targetWeight,
                    records: []
                )
            },
            syncWeightToHealthKit: unimplemented("WeightClient.syncWeightToHealthKit"),
            isHealthKitAvailable: unimplemented("WeightClient.isHealthKitAvailable")
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
            },
            syncWeightToHealthKit: { _, _ in },
            isHealthKitAvailable: { true }
        )
    }
}

extension DependencyValues {
    public var weightClient: WeightClient {
        get { self[WeightClient.self] }
        set { self[WeightClient.self] = newValue }
    }
}
