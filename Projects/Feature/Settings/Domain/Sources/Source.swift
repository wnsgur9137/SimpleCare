//
//  Source.swift
//  SettingsDomain
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation

// MARK: - Settings Domain Layer
//
// Settings 모듈의 Domain 레이어는 현재 최소 구성입니다.
//
// 이유:
// - Settings의 핵심 타입(AppTheme, AppLanguage, NotificationCategory 등)은
//   BasePresentation에 정의되어 있으며, SettingsDomain은 BaseDomain만 참조 가능
// - Settings에 고유한 비즈니스 로직이 없고, Base 매니저에 위임
//
// 확장 시나리오:
// - 원격 설정 동기화 (Feature Flags, Remote Config)
// - 사용자 설정 마이그레이션 로직
// - 설정 유효성 검증 규칙
