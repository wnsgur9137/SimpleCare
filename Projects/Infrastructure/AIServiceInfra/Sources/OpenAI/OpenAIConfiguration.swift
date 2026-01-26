//
//  OpenAIConfiguration.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// OpenAI API 설정
public struct OpenAIConfiguration {
    /// API Key (Info.plist 또는 환경변수에서 로드)
    public let apiKey: String

    /// 기본 모델
    public let model: OpenAIModel

    /// API 엔드포인트
    public let baseURL: URL

    /// 요청 타임아웃 (초)
    public let timeoutInterval: TimeInterval

    public init(
        apiKey: String? = nil,
        model: OpenAIModel = .gpt4o,
        baseURL: URL = URL(string: "https://api.openai.com/v1")!,
        timeoutInterval: TimeInterval = 60
    ) {
        // API Key 로드 순서: 직접 전달 > Info.plist > 환경변수
        if let key = apiKey, !key.isEmpty {
            self.apiKey = key
        } else if let plistKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String, !plistKey.isEmpty {
            self.apiKey = plistKey
        } else if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            self.apiKey = envKey
        } else {
            self.apiKey = ""
        }

        self.model = model
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
    }

    /// API Key 유효성 검사
    public var isValid: Bool {
        !apiKey.isEmpty && apiKey.hasPrefix("sk-")
    }
}

/// OpenAI 모델
public enum OpenAIModel: String, Codable {
    case gpt4o = "gpt-4o"
    case gpt4oMini = "gpt-4o-mini"
    case gpt4Turbo = "gpt-4-turbo"
    case gpt35Turbo = "gpt-3.5-turbo"

    public var displayName: String {
        switch self {
        case .gpt4o: return "GPT-4o"
        case .gpt4oMini: return "GPT-4o Mini"
        case .gpt4Turbo: return "GPT-4 Turbo"
        case .gpt35Turbo: return "GPT-3.5 Turbo"
        }
    }

    /// Vision (이미지 분석) 지원 여부
    public var supportsVision: Bool {
        switch self {
        case .gpt4o, .gpt4oMini, .gpt4Turbo:
            return true
        case .gpt35Turbo:
            return false
        }
    }
}
