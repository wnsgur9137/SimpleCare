//
//  OnboardingStep.swift
//  OnboardingDomain
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation
import BaseDomain

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
        case .welcome: return "onboarding.step.welcome.title".localized
        case .basicInfo: return "onboarding.step.basicInfo".localized
        case .bodyInfo: return "onboarding.step.bodyInfo".localized
        case .goalSetting: return "onboarding.step.goal".localized
        case .activityLevel: return "onboarding.step.activity".localized
        case .summary: return "onboarding.step.summary".localized
        }
    }

    public var subtitle: String {
        switch self {
        case .welcome: return "onboarding.step.welcome.subtitle".localized
        case .basicInfo: return "onboarding.step.basicInfo.subtitle".localized
        case .bodyInfo: return "onboarding.step.bodyInfo.subtitle".localized
        case .goalSetting: return "onboarding.step.goal.subtitle".localized
        case .activityLevel: return "onboarding.step.activity.subtitle".localized
        case .summary: return "onboarding.step.summary.subtitle".localized
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
