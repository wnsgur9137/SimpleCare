//
//  GeminiConfiguration.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 3/16/26.
//

import Foundation

/// Google Gemini API Configuration
public struct GeminiConfiguration: Sendable {
    private static let invalidAPIKeyPlaceholder = "123"

    /// API Key (Info.plist or environment variable)
    public let apiKey: String

    /// Default model
    public let model: GeminiModel

    /// API base URL
    public let baseURL: URL

    /// Request timeout (seconds)
    public let timeoutInterval: TimeInterval

    public init(
        apiKey: String? = nil,
        model: GeminiModel = .flash,
        baseURL: URL? = nil,
        timeoutInterval: TimeInterval = 60
    ) {
        // API Key load order: direct injection > Info.plist > environment variable
        if let key = apiKey, !key.isEmpty {
            self.apiKey = key
        } else if let plistKey = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String, !plistKey.isEmpty {
            self.apiKey = plistKey
        } else if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !envKey.isEmpty {
            self.apiKey = envKey
        } else {
            self.apiKey = ""
        }

        self.model = model
        if let baseURL {
            self.baseURL = baseURL
        } else {
            guard let defaultURL = URL(string: "https://generativelanguage.googleapis.com/v1beta") else {
                preconditionFailure("Default Gemini base URL is invalid.")
            }
            self.baseURL = defaultURL
        }
        self.timeoutInterval = timeoutInterval
    }

    /// API Key validation
    public var isValid: Bool {
        !apiKey.isEmpty && apiKey != Self.invalidAPIKeyPlaceholder
    }
}

/// Google Gemini Models
public enum GeminiModel: String, Codable, Sendable {
    case flash = "gemini-2.5-flash"
    case flashLite = "gemini-2.5-flash-lite"

    public var displayName: String {
        switch self {
        case .flash: return "Gemini 2.5 Flash"
        case .flashLite: return "Gemini 2.5 Flash Lite"
        }
    }

    /// Vision (image analysis) support
    public var supportsVision: Bool {
        switch self {
        case .flash: return true
        case .flashLite: return false
        }
    }
}
