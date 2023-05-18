//
//  APIClient.swift
//  LWBNetwork
//
//  Created by 이원빈 on 2023/04/23.
//

import Foundation

public struct APIClient {
    public static let shared = APIClient(session: URLSession.shared)
    private let session: URLSessionProtocol
    
    // MARK: Async-await
    func requestData(with urlRequest: URLRequest) async throws -> Data {
        var result: (data: Data, response: URLResponse)?
        result = try await session.data(for: urlRequest)
        
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
    
    // MARK: Escaping closure
    func requestData(
        with urlRequest: URLRequest,
        _ completion: @escaping (Result<Data, APIClientError>) -> Void
    ) {
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.localized(error.localizedDescription)))
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.unknown))
                return
            }
            guard 200..<300 ~= statusCode else {
                completion(.failure(.statusCode(statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            completion(.success(data))
        }.resume()
    }
}

enum APIClientError: LocalizedError {
    case unknown
    case localized(String)
    case statusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "APIClientError: 알 수 없는 에러가 발생했습니다."
        case .localized(let log):
            return log
        case .statusCode(let code):
            return "APIClientError: statue code = \(code) 에러입니다."
        }
    }
}
