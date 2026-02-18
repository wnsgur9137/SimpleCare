//
//  StorageContainer.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData

/// SwiftData 컨테이너 설정
public final class StorageContainer {
    /// 싱글톤 인스턴스
    public static let shared = StorageContainer()

    /// SwiftData ModelContainer
    public let container: ModelContainer

    /// 모델 스키마
    public static var schema: Schema {
        Schema([
            UserProfileModel.self,
            MealRecordModel.self,
            FoodItemModel.self,
            WeightRecordModel.self,
            ExerciseRecordModel.self,
            FavoriteFoodModel.self,
            CustomExerciseModel.self,
        ])
    }

    /// ModelConfiguration
    public static var modelConfiguration: ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
    }

    private init() {
        do {
            container = try ModelContainer(
                for: Self.schema,
                configurations: [Self.modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// 테스트용 인메모리 컨테이너 생성
    public static func createInMemoryContainer() -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }

    /// 메인 컨텍스트
    @MainActor
    public var mainContext: ModelContext {
        container.mainContext
    }
}
