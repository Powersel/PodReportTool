//
//  URLResult.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation

public typealias URLResultResponse<T> = (headers: [String:Any]?, data: T)

public enum URLResult<T> {
    case success(URLResultResponse<T>)
    case failure(Error)
}

public enum ServiceErrorType: Int {
    case not200 = 0
    case parsing
}

@objc public class FeynmanObject: NSObject {
    init(result: Any?) {
        self.object = result
    }
    @objc public var object: Any?
}

public class FeynmanError: Error {
    var id: String?
    var reason: String?
    
    init(reason: String) {
        self.reason = reason
    }
}

public class URLServiceError: LocalizedError {
    public var reason: ServiceErrorType
    public var statusCode: Int?
    public var responseHeaders: [String:Any]
    
    init(reason: ServiceErrorType, statusCode: Int?, responseHeaders: [String:Any]) {
        self.reason = reason
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
    }
    
    public var localizedDescription: String {
        get { return "\(reason)" }
    }
    
    public var errorDescription: String {
        get {
            if let code = statusCode {
                return "\(code)"
            }
            return ""
        }
    }
}
