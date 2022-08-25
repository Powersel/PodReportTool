//
//  URLRequest.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation

public enum HttpMethod<Body> {
    case get
    case post(Body)
    case put(Body)
    case delete(Body?)
    case patch(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        case .patch:
            return "PATCH"
        }
    }
}

extension URLRequest {
    
    public init<T>(resource: URLResource<T>) {
        self.init(url: resource.url)
        
        httpMethod = resource.method.method
        //        https://developer.apple.com/documentation/foundation/urlrequest/2011509-timeoutinterval
        //        Use default timeout
        //        timeoutInterval = 10
        
        switch resource.method {
        case .post(let data), .patch(let data), .put(let data):
            httpBody = data
        case .delete(let data):
            if let data = data {
                httpBody = data
            }
        default:
            break
        }
        
        // Set the header fields
        for (key, value) in resource.headerFields {
            self.setValue(value, forHTTPHeaderField: key)
            //            debugPrint("Header: \(key): \(value)")
        }
    }
}
