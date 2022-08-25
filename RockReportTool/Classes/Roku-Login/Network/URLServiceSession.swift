//
//  URLServiceSession.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation

public protocol SharedURLSessionProvider {
    func sharedURLSession() -> URLSession
    func sharedURLNoRedirectSession() -> URLSession
}

public class CoreSharedURLSessionProvider : SharedURLSessionProvider {
    public func sharedURLSession() -> URLSession {
        return URLSession(configuration: URLServiceSessionConfiguration.shared.configuration, delegate: nil, delegateQueue: nil)
    }
    
    public func sharedURLNoRedirectSession() -> URLSession {
        return URLSession(configuration: URLServiceSessionConfiguration.shared.configuration, delegate: nil, delegateQueue: nil)
    }
}

@objc public class URLServiceSessionConfiguration: NSObject {
    
    @objc public static let shared = URLServiceSessionConfiguration()
    let configuration:URLSessionConfiguration
    
    override private init() {
        self.configuration = URLServiceSessionConfiguration.createConfiguration(timeout: 60)
        let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print("cacheDir: \(cachePaths[0])")
        super.init()
    }
    
    public static func createConfiguration(timeout : TimeInterval) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 500 * 1024 * 1024
        
        config.urlCache = URLCache(memoryCapacity: memoryCapacity,
                                   diskCapacity: diskCapacity,
                                   diskPath: "urlCache")
        config.timeoutIntervalForRequest = timeout
        
        return config
    }
    
    @objc public func removeAllCachedResponses() {
        self.configuration.urlCache?.removeAllCachedResponses()
    }
}

