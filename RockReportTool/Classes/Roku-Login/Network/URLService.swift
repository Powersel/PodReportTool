//
//  URLService.swift
//  Copyright © 2018 Roku Inc. All rights reserved.
//

import Foundation
//import BoltsSwift

public typealias JSONDictionary = [String: Any]


public class URLObject {
    init(result: Any?) {
        self.object = result
    }
    public var object: Any?
}

public class URLError: Error {
    var id: String?
    var reason: String?
    
    init(reason: String) {
        self.reason = reason
    }
}

@objc open class URLService: NSObject {

    // Classes conforming to HeadersValidator include AWSHeadersValidator
    var headersValidator : HeadersValidator = BaseHeadersValidator()
    
    // SharedURLSessionProvider was added to avoid pulling in the URLCredential and certificate stuff
    // Conforming classes include CoreSharedURLSessionProvider and MututalAuthSharedURLSessionProvider
    static var sharedURLSessionProvider : SharedURLSessionProvider = CoreSharedURLSessionProvider()
    
    public static var rokuURLSession : URLSession {
        return URLService.sharedURLSessionProvider.sharedURLSession()
    }
    public static var rokuNoRedirectURLSession : URLSession {
        return URLService.sharedURLSessionProvider.sharedURLNoRedirectSession()
    }
    
    public func loadWithSpan<T>(_ resource: URLResource<T>, operation: String, completion: @escaping (URLResult<T>) -> Void) {
        
        let method = resource.method.method
        let url = resource.url.absoluteString
        var headers = resource.headerFields
        
        headers.removeValue(forKey: "X-Amz-Security-Token")
        headers.removeValue(forKey: "Authorization")
        
        let traceService : TraceService = Resolver.resolve()
        let clientSpan = traceService.createClientSpan(operation: operation, url: url, method: method, spanTags: headers)
        if let span = clientSpan {
            traceService.addClientSpan(clientSpan: span)
            resource.headerFields["X-B3-TraceId"] = traceService.traceId ?? ""
            resource.headerFields["X-B3-SpanId"] = span.spanId
            resource.headerFields["X-B3-Sampled"] = "1"
        }
        
        self.load(resource) { result in
            switch result {
            case .success(_):
                if let span = clientSpan {
                    traceService.closeClientSpan(clientSpan: span, status: 200)
                }
            case let.failure(error):
                if let span = clientSpan, let urlServiceError = error as? URLServiceError, let statusCode = urlServiceError.statusCode {
                    traceService.closeClientSpan(clientSpan: span, status: statusCode)
                }
            }
            
            completion(result)
        }
    }

    public func loadWithSpan<T>(_ resource: URLResource<T>, operation: String) -> Task<URLObject> {
        
        let completionSource = TaskCompletionSource<URLObject>()
        let task = completionSource.task
        
        self.loadWithSpan(resource, operation: operation)  { (result) in
            switch result {
            case let .success(data):
                let result = URLObject(result: data)
                completionSource.set(result: result)
            case let.failure(error):
                completionSource.set(error: error)
            }
        }
        
        return task
    }


    public func loadSync<T>(_ resource: URLResource<T>) -> URLResult<T>? {
        
        if let memCachedObject: T = resource.retrieve() {
            print("MemCache Hit")
            return URLResult.success((headers: nil, data: memCachedObject))
        }
        
        let session = resource.disableRedirects ? URLService.rokuNoRedirectURLSession : URLService.rokuURLSession
        
        let request = URLRequest(resource: resource)
        let response: (Data?, URLResponse?, Error?) = session.synchronousDataTask(with: request)
        var result: URLResult<T>?
        var headerFields = [String:Any]()
        var headerFieldsAsData: Data?
        
        if let httpResponse = response.1 as? HTTPURLResponse, let responseHeaderFields = httpResponse.allHeaderFields as? [String: Any] {
            headerFields = responseHeaderFields
            headerFieldsAsData = try? PropertyListSerialization.data(fromPropertyList: headerFields, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
        }
        
        if let error = response.2 {
            result = URLResult.failure(error)
            print(error)
        } else if let httpResponse = response.1 as? HTTPURLResponse , httpResponse.statusCode / 100 != 2 {
            result = URLResult.failure(URLServiceError(reason: .not200, statusCode: httpResponse.statusCode, responseHeaders : headerFields))
        } else {
            if let parsed = response.0.flatMap(resource.parse) {
                resource.store(object: parsed)
                result = URLResult.success((headers: headerFields, data: parsed))
            } else if let parsed = headerFieldsAsData.flatMap(resource.parse) {
                resource.store(object: parsed)
                result = URLResult.success((headers: headerFields, data: parsed))
            } else {
                result = URLResult.failure(URLServiceError(reason: .parsing, statusCode: nil, responseHeaders : headerFields))
            }
        }
        return result
    }

    public func load<T>(_ resource: URLResource<T>,  completion: @escaping (URLResult<T>) -> Void) {
        //Check if memCache is enabled.
        
        if let memCachedObject: T = resource.retrieve() {
            print("MemCache Hit")
            let result = URLResult.success((headers: nil, data: memCachedObject))
            DispatchQueue.main.async { completion(result) }
            return
        }
        
        headersValidator.evaluateHeaders(resource: resource).continueWith { (task) -> Any? in

            // Step 1.  Create session object
            let session = resource.disableRedirects ? URLService.rokuNoRedirectURLSession : URLService.rokuURLSession
            
            // Step 2.  Create request object
            var request = URLRequest(resource: resource)
            request.timeoutInterval = resource.timeout
            //print("\(request.httpMethod!) \(request.url?.absoluteString!)\n\(request.allHTTPHeaderFields!)")
            
            // Step 3.  Create a dataTask that retrieves the contents of a URL based on
            // the specified URL request object, and calls a handler upon completion.
            // This is the only part of the code that is  asynchrounous
            //        debugPrint("Calling Data Task: \(request) \(Date())")
            session.dataTask(with: request) { (data, response, error) in
                debugPrint("Finished Data Task: \(request) \(Date())")
                
                var headerFields = [String:Any]()
                var headerFieldsAsData: Data?
                
                if let httpResponse = response as? HTTPURLResponse, let responseHeaderFields = httpResponse.allHeaderFields as? [String: Any] {
                    headerFields = responseHeaderFields
                    headerFieldsAsData = try? PropertyListSerialization.data(fromPropertyList: headerFields, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
                }
                
                if let error = error {
                    let result : URLResult<T> = URLResult.failure(error)
                    print(error)
                    completion(result)
                } else if let httpResponse = response as? HTTPURLResponse , httpResponse.statusCode / 100 != 2 {
                    
                    // debugging
                    if (httpResponse.statusCode == 403 || httpResponse.statusCode == 401) {
                        print("403 received for \(resource.url)")
                    }
                    debugPrint("headers:\(httpResponse)")
                    if let data = data, let bodyString = String(data: data, encoding: String.Encoding.utf8) {
                        debugPrint("Body: \(bodyString)")
                    }
                    
                    // signal failure
                    let result : URLResult<T> = URLResult.failure(URLServiceError(reason: .not200, statusCode: httpResponse.statusCode, responseHeaders : headerFields))
                    completion(result)
                } else {
                    
                    //                debugPrint("Calling Parsing: \(request) \(Date())")
                    //                if let datareturn = data {
                    //                    print(String(data: datareturn, encoding: String.Encoding.utf8) ?? "Empty Data")
                    //                }
                    DispatchQueue.global(qos: .userInteractive).async {
                        var result : URLResult<T> = URLResult.failure(URLServiceError(reason: .parsing, statusCode: nil, responseHeaders : headerFields))
                        if let parsed = data.flatMap(resource.parse) {
                            resource.store(object: parsed)
                            result = URLResult.success((headers: headerFields, data: parsed))
                        } else if let parsed = headerFieldsAsData.flatMap(resource.parse) {
                            resource.store(object: parsed)
                            result = URLResult.success((headers: headerFields, data: parsed))
                        }
                        completion(result)
                    }
                }
            }.resume()
            
            return nil
        }
    }
    
    public func load<T>(_ resource: URLResource<T>) -> Task<URLObject> {
        
        let completionSource = TaskCompletionSource<URLObject>()
        let task = completionSource.task
        
        self.load(resource)  { (result) in
            switch result {
            case let .success(data):
                let result = URLObject(result: data)
                completionSource.set(result: result)
            case let.failure(error):
                completionSource.set(error: error)
            }
        }
        
        return task
    }
    
}


