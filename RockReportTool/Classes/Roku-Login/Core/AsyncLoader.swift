//
//  AsyncLoader.swift
//  Copyright © 2019 Roku. All rights reserved.
//

import UIKit
import AWSCore
import CocoaLumberjack

public class AsyncLoaderError: Error {
    var reason: String?
    
    init(reason: String) {
        self.reason = reason
    }
    
    public var localizedDescription: String {
        get { return "\(String(describing: reason))" }
    }
}


/*!
 *
 * @typedef AsyncLoader
 * The AsyncLoader class is a thin wrapper around the dispatch_group functionality,
 *    and is intended to make waiting for (and retrying) asynchronous calls a little
 *    easier.
 *
 * To use, call the load() method with a block that does the loading.  In
 *    the block, set loader.value when the call is successful.  Call retry() if
 *    the call was unsuccessful.  (If you want to do something different based
 *    on the number of tries, you can re-call load() as well.
 *    Example:
 *
 * let loader = AsyncLoader<Int>(maxTries: 3)
 *
 * func loadAccountId() {
 *    loader.load { (tryNum) in
 *        aServiceCallForAccountId().continueWith { (task) -> Any? in
 *            if let accountId = task.result, nil == task.error {
 *                self.loader.value = accountId
 *            }
 *            else self.loader.retry()
 *        }
 *     }
 * }
 *
 * When another part of the code wants to access the value you are retrieving,
 *    you can choose to retrieve the value using the valueAsync()/valueBlocking()
 *    methods.
 * If possible, it is safer to use the valueAsync() method, as this will not
 *    block any threads (especially the main thread).  This returns an AWSTask
 *    whose result will be the value.
 * If the load fails after maxTries, the task will have an AsyncLoaderError
 *    set.  Example:
 *
 * func getAccountId() -> AWSTask<Int> {
 *     return loader.valueAsync()
 * }
 *
 * However, if you are trying to retrofit synchronous methods to use AsyncLoader, the
 *    valueBlocking() method may be more convenient.  NB: this will *block* the calling
 *    thread until the value is ready.  However, if it is very likely that the value
 *    will be loaded before it is needed (and you're sure you're not calling
 *    from the main thread), it is more convenient to use this method.
 *
 * valueAsync()/valueBlocking() calls will wait even if they are made before the initial
 *    load() call.
 *
 */


class AsyncLoader<T : AnyObject > : Synchronizable {
    public var value : T? {
        didSet {
            if nil != value {
                DDLogVerbose("\(name) loaded")
                loaded()
            }
        }
    }
    public let name : String
    public let maxTries : Int
    public var numTries = 0
    
    // internal state
    private let group = DispatchGroup()
    private var loading = false
    private var left = false
    private var loadClosure : ((Int) -> ())?
    
    public init(name: String, maxTries : Int) {
        self.name = name
        self.maxTries = maxTries
        self.group.enter()
    }
    
    public var didStart : Bool { return nil != loadClosure}
    public var didFail : Bool { return didStart && numTries >= maxTries }
    public var isLoading : Bool { return loading }

    public func load(loadBlock : @escaping (Int) -> ()) {
        self.loadClosure = loadBlock
        numTries = 1
        loading = true
        loadBlock(numTries)
    }
    
    public func retry() {
        DDLogVerbose("retry \(name) \(numTries)")
        if numTries < maxTries, let loadBlock = loadClosure {
            loading = true
            loadBlock(numTries)
            numTries += 1
        }
        else {
            DDLogWarn("loader \(name) failed \(numTries) times, stopping retries")
            loaded()
        }
    }

    public func reset() {
        synchronized (self) {
            numTries = 0
            loading = false
            loadClosure = nil
            value = nil
            if left {
                group.enter()
            }
            left = false
        }
    }

    public func peek() -> T? {
        return value
    }
    
    public func valueAsync() -> AWSTask<T> {
        let source = AWSTaskCompletionSource<T>()
        notify {
            if let val = self.value {
                source.set(result: val)
            }
            else {
                source.set(error: AsyncLoaderError(reason: "loader \(self.name) failed after \(self.maxTries) tries"))
            }
        }
        return source.task
    }
    
    public func valueBlocking() -> T? {
        if let value = self.value {
            return value
        }
        DDLogVerbose("blocking \(name)")
        let block = DispatchGroup()
        block.enter()
        self.notify {
            DDLogVerbose("unblocking \(self.name)")
            block.leave()
        }
        block.wait()
        return self.value
    }
}

extension AsyncLoader {

    private func notify(completionBlock : @escaping () -> ()) {
        synchronized(self) {
            group.notify(queue: .global()) {
                completionBlock()
            }
        }
    }

    private func loaded() {
        synchronized(self) {
            loading = false
            if !left {
                left = true
                group.leave()
            }
        }
    }
}

