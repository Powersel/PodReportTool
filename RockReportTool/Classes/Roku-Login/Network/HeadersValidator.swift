//
//  HeadersValidator.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import AWSCore

public protocol HeadersValidator {
    func evaluateHeaders<T>(resource : URLResource<T>) -> AWSTask<AnyObject>
    func registerTask() -> (String, AWSTaskCompletionSource<NSDictionary>)?
    func getTask(taskId : String) -> AWSTaskCompletionSource<NSDictionary>?
    func clearTask(taskId : String)
    func updateHeaders(original : [String:String], new dict : NSDictionary) -> [String: String]
}

public class BaseHeadersValidator : HeadersValidator {
    var taskIdDictionary = [String:AWSTaskCompletionSource<NSDictionary>]()
    let taskDictQueue = DispatchQueue(label: "taskDictionary")

    public func evaluateHeaders<T>(resource : URLResource<T>) -> AWSTask<AnyObject> {
        // BaseHeadersValidator does not validate anything, but serves as a useful
        //    superclass on which HeadersValidators can be built (see AWSHeadersValidator)
        let taskSource = AWSTaskCompletionSource<AnyObject>()
        taskSource.set(result: NSNumber(booleanLiteral: true))
        return taskSource.task
    }

    public func registerTask() -> (String, AWSTaskCompletionSource<NSDictionary>)? {
        let taskId = UUID().uuidString
        let taskSource = AWSTaskCompletionSource<NSDictionary>()
        taskDictQueue.sync {
            taskIdDictionary[taskId] = taskSource
        }
        return (taskId, taskSource)
    }
    
    public func getTask(taskId : String) -> AWSTaskCompletionSource<NSDictionary>? {
        var originalSource : AWSTaskCompletionSource<NSDictionary>?
        taskDictQueue.sync {
            originalSource = taskIdDictionary[taskId]
        }
        return originalSource
    }

    public func clearTask(taskId : String) {
        _ = taskDictQueue.sync {
            taskIdDictionary.removeValue(forKey: taskId)
        }
    }

    public func updateHeaders(original : [String:String], new dict : NSDictionary) -> [String: String] {
        var headers = original
        for (key, value) in dict {
            if let k = key as? String, let v = value as? String {
                headers[k] = v
            }
        }
        return headers
    }
}
