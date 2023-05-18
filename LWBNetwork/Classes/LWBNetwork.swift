//
//  LWBNetwork.swift
//  LWBNetwork
//
//  Created by wongbingg on 04/22/2023.
//  Copyright (c) 2023 wongbingg. All rights reserved.
//

import UIKit

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
