//
//  AWSHeadersValidator.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import CocoaLumberjack
import AWSCore

/// Handle HeaderService requiring asynchronous information
public class AWSHeadersValidator : BaseHeadersValidator {
    var awsCredentialsProvider : AWSCredentialsProvider = DefaultAWSCredentialsProvider(with: "")

    static let AWSHeadersPending = "AWSHeadersPending"

    override public func evaluateHeaders<T>(resource: URLResource<T>) -> AWSTask<AnyObject> {
        let taskSource = AWSTaskCompletionSource<AnyObject>()
        if let awsTaskId = resource.headerFields[AWSHeadersValidator.AWSHeadersPending], let awsTaskSource = getTask(taskId: awsTaskId) {
            clearTask(taskId: awsTaskId)
            DDLogVerbose("URL \(resource.url) task pending AWS credentials")
            awsTaskSource.task.continueWith { [weak self] (task) -> Any? in
                if let dict = task.result {
                    if let newHeaders = self?.updateHeaders(original : resource.headerFields, new: dict) {
                        resource.headerFields = newHeaders
                    }
                    resource.headerFields.removeValue(forKey: AWSHeadersValidator.AWSHeadersPending)
                    DDLogVerbose("URL \(resource.url) pending AWS credentials complete, header count \(resource.headerFields.count)")
                    taskSource.set(result: NSNumber(booleanLiteral: true))
                }
                else {
                    DDLogVerbose("URL \(resource.url) task result was nil")
                    taskSource.set(result: NSNumber(booleanLiteral: false))
                }
                return nil
            }
        }
        else {
            taskSource.set(result: NSNumber(booleanLiteral: true))
        }
        return taskSource.task
    }
    
    public func registerAWSTask(awsHeaderService: AWSHeaderService) -> String? {
        if let (taskId, taskSource) = registerTask() {
        
            awsCredentialsProvider.awsCredentials().continueWith { (task) -> Any? in
                if let error = task.error {
                    DDLogVerbose("AWSHeadersValidator fetch credentials error \(error)")
                    taskSource.set(error: RokuError(reason: "AWS credentials failed to fetch"))
                }
                else if let credentials = task.result {
                    DDLogVerbose("AWSHeadersValidator, credentials returned from task okay, \(String(describing:credentials.expiration))")
                    let headers = awsHeaderService.awsHeaders()
                    let result : NSDictionary = headers as NSDictionary
                    taskSource.set(result: result)
                }
                return nil
            }
            return taskId
        }
        return nil
    }
}
