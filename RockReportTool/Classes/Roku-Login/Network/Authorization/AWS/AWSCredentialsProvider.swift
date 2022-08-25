//
//  AWSCredentialsProvider.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import CocoaLumberjack
import AWSAuthCore

// AWSCredentialsProvider defines an API around getting AWSCredentials, and
//     getting them in synchronous/asynchronous fashion.
// Conforming classes include DefaultAWSCredentialsProvider.
@objc public protocol AWSCredentialsProvider  {
    func prefetch()
    func awsCredentials() -> AWSTask<AWSCredentials>
    func awsBlocking() -> AWSCredentials?
    func awsNonBlocking() -> AWSCredentials?
}

public class DefaultAWSCredentialsProvider: AWSCredentialsProvider, Synchronizable {
    let awsCognitoCredentialsProvider: AWSCognitoCredentialsProvider
    
    var awsLoader = AsyncLoader<AWSCredentials>(name: "AWS", maxTries: 2)

    public init(with identityPoolId: String) {
        self.awsCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1,
                                                                           identityPoolId: identityPoolId)
    }
    
    public func prefetch() {
        DispatchQueue.global().async {
            if !self.awsLoader.didStart || self.awsLoader.didFail {
                self.fetchAWS()
            }
        }
    }

    public func awsCredentials() -> AWSTask<AWSCredentials> {
        synchronized(self) {
            if awsLoader.didFail {
                fetchAWS()
            }
            else if nil == awsLoader.peek(), !awsLoader.isLoading {
                awsLoader.reset()
                fetchAWS()
            }
            else if let credential = awsLoader.peek(), let expiry = credential.expiration, expiry < Date(), !awsLoader.isLoading {
                DDLogVerbose("AWS expiry check: credential expired \(expiry) < \(Date()), refetching")
                awsLoader.reset()
                fetchAWS()
            }
        }
        return awsLoader.valueAsync()
    }

    public func awsBlocking() -> AWSCredentials? {
        synchronized(self) {
            if awsLoader.didFail {
                fetchAWS()
            }
            else if nil == awsLoader.peek(), !awsLoader.isLoading {
                awsLoader.reset()
                fetchAWS()
            }
            else if let credential = awsLoader.peek(), let expiry = credential.expiration, expiry < Date(), !awsLoader.isLoading {
                awsLoader.reset()
                fetchAWS()
            }
        }
        return awsLoader.valueBlocking()
    }

    public func awsNonBlocking() -> AWSCredentials? {
        return awsLoader.peek()
    }

    private func fetchAWS() {
        weak var weakSelf = self
        awsLoader.load { (n) in
            self.awsCognitoCredentialsProvider.clearCredentials()
            self.awsCognitoCredentialsProvider.credentials().continueWith { (task) -> Any? in
                if let credentials = task.result, nil == task.error {
                    DDLogVerbose("AWS credential fetch successfully, expiry \(String(describing:credentials.expiration))")
                    weakSelf?.awsLoader.value = credentials
                }
                else {
                    DDLogError("failed try \(n) getting AWS credentials: \(String(describing:task.error))")
                    weakSelf?.awsLoader.retry()
                }
                return nil
            }
        }
    }
}

