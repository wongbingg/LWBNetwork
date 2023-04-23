//
//  APIConfiguration.swift
//  LWBNetwork
//
//  Created by 이원빈 on 2023/04/23.
//

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
    
    public func makeURLRequest() throws -> URLRequest {
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

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
