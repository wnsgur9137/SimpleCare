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

    /// Maximum number of retry attempts for transient errors (429, 5xx)
    public let maxRetries: Int

    /// Base delay between retries in seconds (doubles with each attempt)
    public let retryBaseDelay: TimeInterval

    public init(
        apiKey: String? = nil,
        model: GeminiModel = .flash,
        baseURL: URL? = nil,
        timeoutInterval: TimeInterval = 60,
        maxRetries: Int = 3,
        retryBaseDelay: TimeInterval = 1.0
    ) {
        // API Key load order: direct injection > Keychain > Info.plist > environment variable
        if let key = apiKey, !key.isEmpty {
            self.apiKey = key
        } else {
            self.apiKey = KeychainManager.loadGeminiAPIKey()
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
        self.maxRetries = max(0, maxRetries)
        self.retryBaseDelay = max(0, retryBaseDelay)
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
