//
//  API.swift
//  LWBNetwork
//
//  Created by 이원빈 on 2023/04/23.
//

import Foundation

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
