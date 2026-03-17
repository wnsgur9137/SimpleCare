//
//  GeminiClient.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 3/16/26.
//

import Foundation

/// Google Gemini API Client
public actor GeminiClient {
    private let configuration: GeminiConfiguration
    private let session: URLSession

    public init(configuration: GeminiConfiguration = GeminiConfiguration()) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        self.session = URLSession(configuration: sessionConfig)
    }

    // MARK: - Generate Content

    /// Text-based content generation
    public func generateContent(
        systemPrompt: String,
        userMessage: String,
        model: GeminiModel? = nil,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> GeminiResponse {
        let selectedModel = model ?? configuration.model
        let request = GeminiRequest(
            systemInstruction: GeminiContent(parts: [GeminiPart(text: systemPrompt)]),
            contents: [
                GeminiContent(role: "user", parts: [GeminiPart(text: userMessage)])
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: temperature,
                maxOutputTokens: maxTokens,
                responseMimeType: "application/json"
            )
        )

        return try await sendRequest(model: selectedModel, body: request)
    }

    /// Vision-based content generation (image + text)
    public func generateContentWithVision(
        systemPrompt: String,
        userMessage: String,
        imageData: Data,
        model: GeminiModel? = nil,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> GeminiResponse {
        let selectedModel = model ?? configuration.model

        guard selectedModel.supportsVision else {
            throw GeminiError.modelDoesNotSupportVision
        }

        let base64Image = imageData.base64EncodedString()
        let textPart = GeminiPart(text: userMessage)
        let imagePart = GeminiPart(
            inlineData: GeminiInlineData(mimeType: "image/jpeg", data: base64Image)
        )

        let request = GeminiRequest(
            systemInstruction: GeminiContent(parts: [GeminiPart(text: systemPrompt)]),
            contents: [
                GeminiContent(role: "user", parts: [textPart, imagePart])
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: temperature,
                maxOutputTokens: maxTokens,
                responseMimeType: "application/json"
            )
        )

        return try await sendRequest(model: selectedModel, body: request)
    }

    // MARK: - Private

    private func sendRequest(
        model: GeminiModel,
        body: GeminiRequest
    ) async throws -> GeminiResponse {
        guard configuration.isValid else {
            throw GeminiError.invalidAPIKey
        }

        // Build URL: /v1beta/models/{model}:generateContent?key={apiKey}
        var components = URLComponents(
            url: configuration.baseURL.appending(path: "models/\(model.rawValue):generateContent"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: "key", value: configuration.apiKey)]

        guard let url = components?.url else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        if httpResponse.statusCode == 403 {
            throw GeminiError.invalidAPIKey
        }

        if httpResponse.statusCode == 429 {
            throw GeminiError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                throw GeminiError.apiError(errorResponse.error.message)
            } else {
                throw GeminiError.httpError(httpResponse.statusCode)
            }
        }

        return try JSONDecoder().decode(GeminiResponse.self, from: data)
    }
}

// MARK: - Request Types

public struct GeminiRequest: Encodable {
    public let systemInstruction: GeminiContent?
    public let contents: [GeminiContent]
    public let generationConfig: GeminiGenerationConfig?
}

public struct GeminiContent: Codable {
    public let role: String?
    public let parts: [GeminiPart]

    public init(role: String? = nil, parts: [GeminiPart]) {
        self.role = role
        self.parts = parts
    }
}

public struct GeminiPart: Codable {
    public let text: String?
    public let inlineData: GeminiInlineData?

    public init(text: String? = nil, inlineData: GeminiInlineData? = nil) {
        self.text = text
        self.inlineData = inlineData
    }
}

public struct GeminiInlineData: Codable {
    public let mimeType: String
    public let data: String
}

public struct GeminiGenerationConfig: Encodable {
    public let temperature: Double?
    public let maxOutputTokens: Int?
    public let responseMimeType: String?
}

// MARK: - Response Types

public struct GeminiResponse: Decodable {
    public let candidates: [GeminiCandidate]?
    public let usageMetadata: GeminiUsageMetadata?

    /// Extract text content from the first candidate
    public var text: String? {
        candidates?.first?.content.parts.compactMap(\.text).joined()
    }
}

public struct GeminiCandidate: Decodable {
    public let content: GeminiResponseContent
    public let finishReason: String?
}

public struct GeminiResponseContent: Decodable {
    public let parts: [GeminiResponsePart]
    public let role: String?
}

public struct GeminiResponsePart: Decodable {
    public let text: String?
}

public struct GeminiUsageMetadata: Decodable {
    public let promptTokenCount: Int?
    public let candidatesTokenCount: Int?
    public let totalTokenCount: Int?
}

// MARK: - Error Types

public enum GeminiError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case rateLimited
    case modelDoesNotSupportVision
    case httpError(Int)
    case apiError(String)
    case noContent

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return NSLocalizedString("gemini_error_invalid_api_key", comment: "Invalid Gemini API key")
        case .invalidResponse:
            return NSLocalizedString("gemini_error_invalid_response", comment: "Invalid response from server")
        case .rateLimited:
            return NSLocalizedString("gemini_error_rate_limited", comment: "Rate limit exceeded. Please try again later.")
        case .modelDoesNotSupportVision:
            return NSLocalizedString("gemini_error_no_vision_support", comment: "Selected model does not support vision/image analysis")
        case .httpError(let code):
            return String(format: NSLocalizedString("gemini_error_http", comment: "HTTP error: %d"), code)
        case .apiError(let message):
            return String(format: NSLocalizedString("gemini_error_api", comment: "API error: %@"), message)
        case .noContent:
            return NSLocalizedString("gemini_error_no_content", comment: "No content in response")
        }
    }
}

public struct GeminiErrorResponse: Decodable {
    public let error: GeminiErrorDetail
}

public struct GeminiErrorDetail: Decodable {
    public let code: Int
    public let message: String
    public let status: String?
}
