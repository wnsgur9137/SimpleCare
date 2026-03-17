//
//  StorageContainer.swift
//  StorageInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import SwiftData
import os.log

/// StorageContainer가 인메모리 폴백으로 전환되었을 때 발송되는 알림
public extension Notification.Name {
    static let storageContainerFallbackActivated = Notification.Name("StorageContainerFallbackActivated")
}

/// SwiftData 컨테이너 설정
public final class StorageContainer {
    /// 싱글톤 인스턴스
    public static let shared = StorageContainer()

    /// SwiftData ModelContainer
    public let container: ModelContainer

    /// 스토리지가 폴백(인메모리) 모드로 동작 중인지 여부
    public private(set) var isUsingFallbackStorage: Bool = false

    private static let logger = Logger(subsystem: "com.junhyeok.SimpleCare", category: "StorageContainer")

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
        // 1차 시도: 정상 초기화
        do {
            container = try ModelContainer(
                for: Self.schema,
                configurations: [Self.modelConfiguration]
            )
            return
        } catch {
            Self.logger.warning("ModelContainer 초기화 실패, 손상된 스토어 삭제 후 재시도합니다. 오류: \(error.localizedDescription)")
        }

        // 2차 시도: 손상된 스토어 삭제 후 재시도
        Self.deleteCorruptedStore()
        do {
            container = try ModelContainer(
                for: Self.schema,
                configurations: [Self.modelConfiguration]
            )
            Self.logger.warning("손상된 스토어 삭제 후 ModelContainer 재초기화에 성공하였습니다.")
            return
        } catch {
            Self.logger.error("손상된 스토어 삭제 후 재시도도 실패하였습니다. 인메모리 폴백으로 전환합니다. 오류: \(error.localizedDescription)")
        }

        // 3차 시도: 인메모리 폴백
        let inMemoryConfig = ModelConfiguration(
            schema: Self.schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        do {
            container = try ModelContainer(for: Self.schema, configurations: [inMemoryConfig])
            isUsingFallbackStorage = true
            Self.logger.error("인메모리 폴백 스토리지가 활성화되었습니다. 데이터는 앱 종료 시 유지되지 않습니다.")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .storageContainerFallbackActivated, object: nil)
            }
        } catch {
            // 인메모리 컨테이너마저 실패하는 경우는 SwiftData 자체 결함이므로 크래시 허용
            Self.logger.critical("인메모리 ModelContainer 생성도 실패하였습니다. 복구 불가능한 오류입니다: \(error.localizedDescription)")
            fatalError("인메모리 ModelContainer 생성 실패 (복구 불가능): \(error)")
        }
    }

    /// 손상된 기본 스토어 파일을 삭제하는 헬퍼
    private static func deleteCorruptedStore() {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            logger.warning("Application Support 디렉토리를 찾을 수 없어 스토어 파일을 삭제하지 못했습니다.")
            return
        }

        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: appSupportURL, includingPropertiesForKeys: nil)
            let storeFiles = contents.filter { url in
                let name = url.lastPathComponent
                return name.hasSuffix(".store") || name.hasSuffix(".store-shm") || name.hasSuffix(".store-wal")
            }
            for fileURL in storeFiles {
                try fileManager.removeItem(at: fileURL)
                logger.warning("손상된 스토어 파일을 삭제하였습니다: \(fileURL.lastPathComponent)")
            }
        } catch {
            logger.error("스토어 파일 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }

    /// 테스트용 인메모리 컨테이너 생성
    public static func createInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// 메인 컨텍스트
    @MainActor
    public var mainContext: ModelContext {
        container.mainContext
    }
}
