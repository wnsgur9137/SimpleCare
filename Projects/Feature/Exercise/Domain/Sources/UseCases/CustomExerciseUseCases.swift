//
//  CustomExerciseUseCases.swift
//  ExerciseDomain
//
//  Created by SimpleCare on 2/18/26.
//

import Foundation

/// 커스텀 운동 저장소 프로토콜
public protocol CustomExerciseDomainRepositoryProtocol: Sendable {
    func getAll(userProfileId: UUID) async throws -> [CustomExercise]
    func save(_ exercise: CustomExercise) async throws
    func delete(_ exercise: CustomExercise) async throws
}

/// 커스텀 운동 목록 조회 UseCase
public protocol GetCustomExercisesUseCaseProtocol: Sendable {
    func execute(userProfileId: UUID) async throws -> [CustomExercise]
}

public struct GetCustomExercisesUseCase: GetCustomExercisesUseCaseProtocol {
    private let repository: CustomExerciseDomainRepositoryProtocol

    public init(repository: CustomExerciseDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(userProfileId: UUID) async throws -> [CustomExercise] {
        try await repository.getAll(userProfileId: userProfileId)
    }
}

/// 커스텀 운동 저장 UseCase
public protocol SaveCustomExerciseUseCaseProtocol: Sendable {
    func execute(_ exercise: CustomExercise) async throws
}

public struct SaveCustomExerciseUseCase: SaveCustomExerciseUseCaseProtocol {
    private let repository: CustomExerciseDomainRepositoryProtocol

    public init(repository: CustomExerciseDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ exercise: CustomExercise) async throws {
        try await repository.save(exercise)
    }
}

/// 커스텀 운동 삭제 UseCase
public protocol DeleteCustomExerciseUseCaseProtocol: Sendable {
    func execute(_ exercise: CustomExercise) async throws
}

public struct DeleteCustomExerciseUseCase: DeleteCustomExerciseUseCaseProtocol {
    private let repository: CustomExerciseDomainRepositoryProtocol

    public init(repository: CustomExerciseDomainRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ exercise: CustomExercise) async throws {
        try await repository.delete(exercise)
    }
}
