//
//  ChatGPTManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

final class ChatGPTManager: Request {
    
    private init() {}
    static let shared = ChatGPTManager()
    
    var baseURL = "https://api.openai.com/v1/responses"
    var headers = [
        "Content-Type" : "application/json",
        "Authorization" : NetworkData.chatgptApiKey
    ]
    var httpMethod: HTTPMethod = .post
    var jsonDecoder = JSONDecoder()
    
    func buildRequest(url: URL, body: [String : Any]) throws -> URLRequest {
        do {
            let httpBody = try JSONSerialization.data(withJSONObject: body)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = httpMethod.rawValue
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.httpBody = httpBody
            return urlRequest
        } catch {
            throw ChatGPTError.buildRequestFailed
        }
    }
    
    func getRequestBody(message: String) -> [String : Any] {
        return [
            "model" : ChatGPTData.Models.gpt4omini.name,
            "input" : PromptBuilder.getPrompt(for: message)
        ]
    }
    
    func isResponseSuccess(urlResponse: URLResponse) throws -> Bool {
        guard let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode else {
            throw ChatGPTError.invalidResponse
        }
        
        guard (200...299).contains(statusCode) else {
            throw ChatGPTError.httpResponseFailed(code: statusCode)
        }
        
        return true
    }
    
    func decodeData<T: Decodable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try jsonDecoder.decode(responseType, from: data)
        } catch {
            throw ChatGPTError.decodeFailed(message: error.localizedDescription)
        }
    }
    
    func requestChatMessage(_ prompt: String) async throws -> ChatMessage {
        guard let baseURL = URL(string: baseURL) else {
            throw ChatGPTError.invalidURL
        }
        
        let requestBody = getRequestBody(message: prompt)
        let urlRequest = try buildRequest(url: baseURL, body: requestBody)
    
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
            guard try isResponseSuccess(urlResponse: urlResponse) else {
                throw ChatGPTError.invalidResponse
            }
            
            return try decodeData(data, responseType: ChatMessage.self)
                
            
        } catch {
            throw ChatGPTError.requestFailed
        }
    }
    
}

extension ChatGPTManager {
    enum ChatGPTError: Error, LocalizedError {
        case invalidURL
        case buildRequestFailed
        case requestFailed
        case fetchRequestFailed
        case invalidResponse
        case decodeFailed(message: String)
        case httpResponseFailed(code: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Request URL is invalid."
            case .buildRequestFailed:
                return "Build Request Failed!"
            case .fetchRequestFailed:
                return "Fetch Request Failed!"
            case .requestFailed:
                return "CHATGPTMANAGER Request Failed!"
            case .invalidResponse:
                return "Invalid Response"
            case .decodeFailed(let message):
                return "Decoding Failed. Error Message: \(message)"
            case .httpResponseFailed(let code):
                return "HTTP Failed. Code: \(code)"
            @unknown default:
                return "Unknown Error Occured, Please try again later."
            }
        }
    }
}

