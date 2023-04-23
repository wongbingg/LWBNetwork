//
//  LWBNetwork.swift
//  LWBNetwork
//
//  Created by wongbingg on 04/22/2023.
//  Copyright (c) 2023 wongbingg. All rights reserved.
//

import UIKit

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIConfigurationError: LocalizedError {
    case failToMakeURL
    case failToMakeURLRequest
    
    var errorDescription: String? {
        switch self {
        case .failToMakeURL:
            return "APIConfigurationError: URL을 만드는데 실패했습니다."
        case .failToMakeURLRequest:
            return "APIConfigurationError: URLRequest를 만드는데 실패했습니다."
        }
    }
}

enum APIClientError: LocalizedError {
    case unknown
    case statusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "APIClientError: 알 수 없는 에러가 발생했습니다."
        case .statusCode(let code):
            return "APIClientError: statue code = \(code) 에러입니다."
        }
    }
}

// MARK: - APIConfiguration
public struct APIConfiguration {
    let method: HTTPMethod
    let baseURL: String
    let path: String
    let parameters: [String: Any]?
    let headerField: [String: String]?
    
    public init(
        method: HTTPMethod,
        baseURL: String,
        path: String,
        parameters: [String : Any]?,
        headerField: [String : String]?
    ) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.parameters = parameters
        self.headerField = headerField
    }
    
    func makeURLRequest() throws -> URLRequest {
        let url = try makeURL(base: baseURL, path: path, parameters: parameters)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        guard let headerField = headerField else { return urlRequest }
        
        for (index, value) in headerField {
            urlRequest.setValue(value, forHTTPHeaderField: index)
        }
        return urlRequest
    }
    
    private func makeURL(base: String, path: String, parameters: [String: Any]?) throws -> URL {
        guard var urlComponent = URLComponents(string: base + path) else {
            throw APIConfigurationError.failToMakeURL
        }
        urlComponent.queryItems = makeQuery(with: parameters)
        guard let url = urlComponent.url else {
            throw APIConfigurationError.failToMakeURL
        }
        return url
    }
    
    private func makeQuery(with dic: [String: Any]?) -> [URLQueryItem]? {
        guard let dic = dic else {
            return nil
        }
        var list: [URLQueryItem] = []
        for (index, value) in dic {
            if let value = value as? String {
                list.append(URLQueryItem(name: index, value: value))
            } else if let value = value as? Int {
                list.append(URLQueryItem(name: index, value: String(value)))
            } else if let value = value as? Double {
                list.append(URLQueryItem(name: index, value: String(value)))
            }
        }
        return list
    }
}

// MARK: - APIClient

public struct APIClient {
    public static let shared = APIClient(session: URLSession.shared)
    private let session: URLSessionProtocol
    
    func requestData(with urlRequest: URLRequest) async throws -> Data {
        var result: (data: Data, response: URLResponse)?
        result = try await session.data(for: urlRequest)
        
        let successRange = 200..<300
        
        guard let statusCode = (result?.response as? HTTPURLResponse)?.statusCode else {
            throw APIClientError.unknown
        }
        guard 200..<300 ~= statusCode else {
            throw APIClientError.statusCode(statusCode)
        }
        guard let result = result else {
            throw APIClientError.unknown
        }
        return result.data
    }
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum APIError: LocalizedError {
    case emptyConfiguration
    case failToEncode
    case failToDecode
    
    var errorDescription: String? {
        switch self {
        case .emptyConfiguration:
            return "APIError: APIConfiguration이 비었습니다."
        case .failToEncode:
            return "APIError: String Encoding에 실패했습니다."
        case .failToDecode:
            return "APIError: Decoding에 실패했습니다."
        }
    }
}

public protocol API {
    associatedtype ResponseType: Decodable
    var configuration: APIConfiguration? { get }
}

extension API {
    public func execute(using client: APIClient = APIClient.shared) async throws -> ResponseType {
        
        guard let urlRequest = try configuration?.makeURLRequest() else {
            throw APIError.emptyConfiguration
        }
        let data = try await client.requestData(with: urlRequest)
        
        if ResponseType.self == String.self {
            
            guard let result = String(data: data, encoding: .utf8) else {
                throw APIError.failToEncode
            }
            return result as! Self.ResponseType
        }
        
        do {
            let result = try JSONDecoder().decode(ResponseType.self, from: data)
            return result
        } catch {
            throw APIError.failToDecode
        }
    }
}
