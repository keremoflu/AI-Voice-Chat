//
//  Request.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

protocol Request {
    var baseURL: String { get }
    var headers: [String : String] { get }
    var httpMethod: HTTPMethod { get }
    var jsonDecoder: JSONDecoder { get }
    
    func buildRequest(url: URL, body: [String: Any]) throws -> URLRequest
    func decodeData<T: Decodable>(_ data: Data, responseType: T.Type) throws -> T
}
