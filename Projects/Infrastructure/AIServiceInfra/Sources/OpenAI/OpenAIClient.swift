//
//  OpenAIClient.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 1/26/26.
//

import Foundation

/// OpenAI API 클라이언트
public actor OpenAIClient {
    private let configuration: OpenAIConfiguration
    private let session: URLSession

    public init(configuration: OpenAIConfiguration = OpenAIConfiguration()) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        self.session = URLSession(configuration: sessionConfig)
    }

    // MARK: - Chat Completion

    /// Chat Completion API 호출
    public func chatCompletion(
        messages: [ChatMessage],
        model: OpenAIModel? = nil,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> ChatCompletionResponse {
        let request = ChatCompletionRequest(
            model: (model ?? configuration.model).rawValue,
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens
        )

        return try await sendRequest(
            endpoint: "chat/completions",
            body: request
        )
    }

    /// Vision을 포함한 Chat Completion
    public func chatCompletionWithVision(
        textPrompt: String,
        imageData: Data,
        model: OpenAIModel? = nil,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> ChatCompletionResponse {
        let selectedModel = model ?? configuration.model

        guard selectedModel.supportsVision else {
            throw OpenAIError.modelDoesNotSupportVision
        }

        let base64Image = imageData.base64EncodedString()
        let imageContent = MessageContent.imageURL(
            ImageURL(url: "data:image/jpeg;base64,\(base64Image)")
        )
        let textContent = MessageContent.text(textPrompt)

        let message = ChatMessage(
            role: .user,
            content: .multiContent([textContent, imageContent])
        )

        return try await chatCompletion(
            messages: [message],
            model: selectedModel,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }

    // MARK: - Private

    private func sendRequest<T: Encodable, R: Decodable>(
        endpoint: String,
        body: T
    ) async throws -> R {
        guard configuration.isValid else {
            throw OpenAIError.invalidAPIKey
        }

        let url = configuration.baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw OpenAIError.invalidAPIKey
        }

        if httpResponse.statusCode == 429 {
            throw OpenAIError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                throw OpenAIError.apiError(errorResponse.error.message)
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(R.self, from: data)
    }
}

// MARK: - Request/Response Types

public struct ChatCompletionRequest: Encodable {
    public let model: String
    public let messages: [ChatMessage]
    public let temperature: Double?
    public let maxTokens: Int?

    public init(
        model: String,
        messages: [ChatMessage],
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

public struct ChatMessage: Codable {
    public let role: MessageRole
    public let content: MessageContentWrapper

    public init(role: MessageRole, content: MessageContentWrapper) {
        self.role = role
        self.content = content
    }

    public init(role: MessageRole, text: String) {
        self.role = role
        self.content = .text(text)
    }
}

public enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

public enum MessageContentWrapper: Codable {
    case text(String)
    case multiContent([MessageContent])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let contents = try? container.decode([MessageContent].self) {
            self = .multiContent(contents)
        } else {
            throw DecodingError.typeMismatch(
                MessageContentWrapper.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid content type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
            try container.encode(text)
        case .multiContent(let contents):
            try container.encode(contents)
        }
    }
}

public enum MessageContent: Codable {
    case text(String)
    case imageURL(ImageURL)

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        case "image_url":
            let imageUrl = try container.decode(ImageURL.self, forKey: .imageUrl)
            self = .imageURL(imageUrl)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)
        case .imageURL(let imageUrl):
            try container.encode("image_url", forKey: .type)
            try container.encode(imageUrl, forKey: .imageUrl)
        }
    }
}

public struct ImageURL: Codable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}

public struct ChatCompletionResponse: Decodable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [ChatChoice]
    public let usage: UsageInfo?
}

public struct ChatChoice: Decodable {
    public let index: Int
    public let message: ResponseMessage
    public let finishReason: String?
}

public struct ResponseMessage: Decodable {
    public let role: String
    public let content: String?
}

public struct UsageInfo: Decodable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
}

// MARK: - Error Types

public enum OpenAIError: LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case rateLimited
    case modelDoesNotSupportVision
    case httpError(Int)
    case apiError(String)
    case encodingError
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .modelDoesNotSupportVision:
            return "Selected model does not support vision/image analysis"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

public struct OpenAIErrorResponse: Decodable {
    public let error: OpenAIErrorDetail
}

public struct OpenAIErrorDetail: Decodable {
    public let message: String
    public let type: String?
    public let code: String?
}
