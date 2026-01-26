//
//  OnboardingStep.swift
//  OnboardingDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// 온보딩 단계
public enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case basicInfo
    case bodyInfo
    case goalSetting
    case activityLevel
    case summary

    public var title: String {
        switch self {
        case .welcome: return "환영합니다"
        case .basicInfo: return "기본 정보"
        case .bodyInfo: return "신체 정보"
        case .goalSetting: return "목표 설정"
        case .activityLevel: return "활동 수준"
        case .summary: return "요약"
        }
    }

    public var subtitle: String {
        switch self {
        case .welcome: return "건강한 식습관을 위한 첫 걸음"
        case .basicInfo: return "이름과 나이를 알려주세요"
        case .bodyInfo: return "키와 체중을 입력해주세요"
        case .goalSetting: return "어떤 목표를 가지고 계신가요?"
        case .activityLevel: return "평소 활동량을 선택해주세요"
        case .summary: return "설정을 확인해주세요"
        }
    }

    public var progress: Double {
        Double(rawValue + 1) / Double(OnboardingStep.allCases.count)
    }

    public var next: OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }

    public var previous: OnboardingStep? {
        OnboardingStep(rawValue: rawValue - 1)
    }

    public var isFirst: Bool {
        self == .welcome
    }

    public var isLast: Bool {
        self == .summary
    }
}
