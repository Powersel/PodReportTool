//
//  BaseService.swift
//  Feynman
//
//  Created by Ivan Kim on 3/22/18.
//  Copyright © 2018 Roku. All rights reserved.
//

import Foundation
import CryptoSwift
import CocoaLumberjack

enum WebContentType: String {
    case xml = "text/xml"
    case json = "application/json"
    case plain = "text/plain"
}

public class BaseService : NSObject {
    
    fileprivate let hmacShaTypeString = "AWS4-HMAC-SHA256"
    fileprivate let awsRegion = "us-east-1"
    fileprivate let serviceType = "execute-api"
    fileprivate let aws4Request = "aws4_request"
    fileprivate let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmssXXXXX"
        return formatter
    }()
    
    func putRequest(url: String, body: String? = nil, contentType: WebContentType? = .xml, headers: [String: String]? = [String:String](), parseJson: Bool = true) -> Task<FeynmanObject> {
        
        let taskCompletionSource = TaskCompletionSource<FeynmanObject>()
        guard let putURL = URL(string: url) else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid URL"))
            return taskCompletionSource.task
        }
        
        var headerFields = User.rokuEnvironment.commonHeaders
        headerFields.merge(headers!) { (_, new) in new }
        
        let resource: URLResource<Any>?
        
        if let body = body {
            headerFields["Content-Length"] = "\(body.lengthOfBytes(using: .utf8))"
            headerFields["Content-Type"] = (contentType ?? .xml).rawValue
            if parseJson {
                resource = try? URLResource<Any>(url: putURL, method: .put(body), headerFields: headerFields, parseJson: { (data) -> Any? in
                    return data
                })
            } else {
                resource = URLResource<Any>(url: putURL, method: .put(body), headerFields: headerFields, parseHeaders: { (dict) -> Any? in
                    return dict
                })
            }
        } else {
            if parseJson {
                resource = try? URLResource<Any>(url: putURL, method: .put(""), headerFields: headerFields, parseJson: { (data) -> Any? in
                    return data
                })
            } else {
                resource = URLResource<Any>(url: putURL, method: .put(""), headerFields: headerFields, parseHeaders: { (dict) -> Any? in
                    return dict
                })
            }
        }
        
        guard let resourceSafe = resource else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid Resource"))
            return taskCompletionSource.task
        }
        
        URLService().load(resourceSafe) { (result) in
            switch result {
            case let .success((headers, data)):
                let resultData = FeynmanObject(result: (headers,data))
                taskCompletionSource.set(result: resultData)
            case let.failure(error):
                taskCompletionSource.set(error: error)
            }
        }
        
        return taskCompletionSource.task
    }
    
    func postRequest(url: String, body: Data? = nil, contentType: WebContentType? = .xml, headers: [String: String]? = [String:String]()) -> Task<FeynmanObject> {
        
        let taskCompletionSource = TaskCompletionSource<FeynmanObject>()
        guard let postURL = URL(string: url) else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid URL"))
            return taskCompletionSource.task
        }
        
        var headerFields = User.rokuEnvironment.commonHeaders
        if let headers = headers {
            headerFields.merge(headers) { (_, new) in new }
        }
        
        let resource: URLResource<Any>?
        
        if let body = body {
            headerFields["Content-Length"] = "\(body.count)"
            headerFields["Content-Type"] = "application/octet-stream"
            resource = try? URLResource<Any>(url: postURL, methodData: .post(body), headerFields: headerFields, parseData: { (data) -> Any? in
                return data
            })
        } else {
            resource = try? URLResource<Any>(url: postURL, method: .post(""), headerFields: headerFields, parseJson: { (data) -> Any? in
                return data
            })
        }
        
        guard let resourceSafe = resource else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid Resource"))
            return taskCompletionSource.task
        }
        
        URLService().load(resourceSafe) { (result) in
            switch result {
            case let .success((headers, data)):
                let resultData = FeynmanObject(result: (headers,data))
                taskCompletionSource.set(result: resultData)
            case let.failure(error):
                taskCompletionSource.set(error: error)
            }
        }
        
        return taskCompletionSource.task
    }

    
    func postRequest(url: String, body: String? = nil, contentType: WebContentType? = .xml, headers: [String: String]? = [String:String](), parseJson: Bool = true) -> Task<FeynmanObject> {
        
        let taskCompletionSource = TaskCompletionSource<FeynmanObject>()
        guard let postURL = URL(string: url) else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid URL"))
            return taskCompletionSource.task
        }
        
        var headerFields = User.rokuEnvironment.commonHeaders
        if let headers = headers {
            headerFields.merge(headers) { (_, new) in new }
        }
        
        let resource: URLResource<Any>?
        
        if let body = body {
            headerFields["Content-Length"] = "\(body.lengthOfBytes(using: .utf8))"
            headerFields["Content-Type"] = (contentType ?? .xml).rawValue
            if parseJson {
                resource = try? URLResource<Any>(url: postURL, method: .post(body), headerFields: headerFields, parseJson: { (data) -> Any? in
                    return data
                })
            } else {
                resource = URLResource<Any>(url: postURL, method: .post(body), headerFields: headerFields, parseHeaders: { (dict) -> Any? in
                    return dict
                })
            }
        } else {
            if parseJson {
                resource = try? URLResource<Any>(url: postURL, method: .post(""), headerFields: headerFields, parseJson: { (data) -> Any? in
                    return data
                })
            } else {
                resource = URLResource<Any>(url: postURL, method: .post(""), headerFields: headerFields, parseHeaders: { (dict) -> Any? in
                    return dict
                })
            }
        }
        
        guard let resourceSafe = resource else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid Resource"))
            return taskCompletionSource.task
        }
        
        URLService().load(resourceSafe) { (result) in
            switch result {
            case let .success((headers, data)):
                let resultData = FeynmanObject(result: (headers,data))
                taskCompletionSource.set(result: resultData)
            case let.failure(error):
                taskCompletionSource.set(error: error)
            }
        }
        
        return taskCompletionSource.task
    }
    
    func deleteRequest(url: String, headers: [String: String]? = [String:String]()) -> Task<FeynmanObject> {
        
        let taskCompletionSource = TaskCompletionSource<FeynmanObject>()
        guard let deleteURL = URL(string: url) else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid URL"))
            return taskCompletionSource.task
        }
        
        var headerFields = User.rokuEnvironment.commonHeaders
        if let headers = headers {
            headerFields.merge(headers) { (_, new) in new }
        }
        
        let resource: URLResource<Any>? = try? URLResource<Any>(url: deleteURL, method: .delete(nil), headerFields: headerFields, parseJson: { (data) -> Any? in
            return data
        })
        
        guard let resourceSafe = resource else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid Resource"))
            return taskCompletionSource.task
        }
        
        URLService().load(resourceSafe) { (result) in
            switch result {
            case let .success((headers, data)):
                let resultData = FeynmanObject(result: (headers,data))
                taskCompletionSource.set(result: resultData)
            case let.failure(error):
                taskCompletionSource.set(error: error)
            }
        }
        
        return taskCompletionSource.task
    }
    
    func getRequest(url: String,
                    rokuService: Bool = false,
                    signAWS: Bool = false,
                    timeout: TimeInterval = 60,
                    useCache: Bool = true,
                    headerFields: [String: String] = User.rokuEnvironment.commonHeaders
    ) -> Task<FeynmanObject> {

        let taskCompletionSource = TaskCompletionSource<FeynmanObject>()
        guard let getURL = URL(string: url) else {
            taskCompletionSource.set(error: FeynmanError(reason: "Invalid URL"))
            return taskCompletionSource.task
        }
        
        let resource = URLResource<Data>(url: getURL, headerFields: headerFields) { (data) -> Data? in data }
        resource.timeout = timeout
        resource.useCache = useCache
        
        URLService().load(resource) { (result) in
            switch result {
            case let .success((headers, data)):
                let resultData = FeynmanObject(result: (headers,data))
                taskCompletionSource.set(result: resultData)
            case let .failure(error):
                taskCompletionSource.set(error: error)
            }
        }
        
        return taskCompletionSource.task
    }
}
