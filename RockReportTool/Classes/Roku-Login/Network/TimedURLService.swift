//
//  TimedURLService.swift
//  Created by Harold Sun on 3/12/20.
//

import UIKit

/**
 *  TimedURLService allows a client to make resource calls in similar fashion to URLService (which it wraps), but additionally
 *   allows for a timeout; default data which is delivered on timeout; and a cacheBlock, a function block that is called when valid
 *   data is returned from the resource.
 *
 *  IMPORTANT: It is expected that using cached data is an important part of app continuity when a resource call can time out.
 *   cacheBlock is called both when the resource response is "on-time" AND also when the response occurs after timeout.
 *   In the former case, cacheBlock is called after delivery of data (via completion handler/Task) so that the original cache
 *   contents can still be compared to the new data, if desired.  In the latter case, default data is delivered first, and the
 *   cacheBlock is called if/when the response is received.
 */
@objc public class TimedURLService: NSObject, Synchronizable {

    let timeout : Double
    var timer : Timer?
    var timerElapsed = false
    
    @objc public init(timeout : Double) {
        self.timeout = timeout
        super.init()
    }


    public func loadWithSpan<T>(_ resource: URLResource<T>, operation: String, completion: @escaping (URLResult<T>) -> Void, defaultData : T, cacheBlock : ((T)->Void)? = nil) {
        
        let defaultCompletion = {
            NSLog("Sending default data from \(resource.url)")
            let tuple : (headers : [String:Any]?, data: T) = (headers: nil, data: defaultData)
            completion(URLResult.success(tuple))
        }
        self.createTimer(withCompletion: defaultCompletion)

        // call this after timer created to avoid race condition
        URLService().loadWithSpan(resource, operation: operation) { (result) in
            self.stopTimer()
            self.synchronized(self) {
                // only call completion handler if timer has not elapsed
                if !self.timerElapsed {
                    switch result {
                    case let .success((_, data)):
                        NSLog("Received data from \(resource.url)")
                        completion(result)
                        if let cb = cacheBlock {
                            cb(data)
                        }
                    case let .failure(error):
                        NSLog("Received \(error) from \(resource.url)")
                        defaultCompletion()
                    }
                }
                else {
                    NSLog("Timer elapsed for \(resource.url)")
                    switch result {
                    case let .success((_, data)):
                        NSLog("Received data from \(resource.url)")
                        if let cb = cacheBlock {
                            cb(data)
                        }
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
    public func load<T>(_ resource: URLResource<T>,  completion: @escaping (URLResult<T>) -> Void, defaultData : T, cacheBlock : ((T)->Void)? = nil) {
        
        let defaultCompletion = {
            NSLog("Sending default data from \(resource.url)")
            let tuple : (headers : [String:Any]?, data: T) = (headers: nil, data: defaultData)
            completion(URLResult.success(tuple))
        }
        self.createTimer(withCompletion: defaultCompletion)

        // call this after timer created to avoid race condition
        URLService().load(resource) { (result) in
            self.stopTimer()
            self.synchronized(self) {
                // only call completion handler if timer has not elapsed
                if !self.timerElapsed {
                    switch result {
                    case let .success((_, data)):
                        NSLog("Received data from \(resource.url)")
                        completion(result)
                        if let cb = cacheBlock {
                            cb(data)
                        }
                    case let .failure(error):
                        NSLog("Received \(error) from \(resource.url)")
                        defaultCompletion()
                    }
                }
                else {
                    NSLog("Timer elapsed for \(resource.url)")
                    switch result {
                    case let .success((_, data)):
                        NSLog("Received data from \(resource.url)")
                        if let cb = cacheBlock {
                            cb(data)
                        }
                    case .failure:
                        break
                    }
                }
            }
        }

    }
    
    public func load<T>(_ resource: URLResource<T>, defaultData : T, cacheBlock : ((T)->Void)? = nil) -> Task<URLObject> {
        let completionSource = TaskCompletionSource<URLObject>()

        let defaultCompletion = {
            NSLog("Sending default data from \(resource.url)")
            let tuple : (headers : [String:Any]?, data: T) = (headers: nil, data: defaultData)
            completionSource.set(result:URLObject(result:tuple))
        }
        self.createTimer(withCompletion: defaultCompletion)

        // call this after timer created to avoid race condition
        URLService().load(resource).continueWith { (task) -> Any? in
            self.stopTimer()
            if let error = task.error {
                NSLog("Received \(error) from \(resource.url)")
                self.synchronized(self) {
                    // only call completion handler if timer has not elapsed
                    if !self.timerElapsed {
                        // send defaultData on error (and timer not elapsed)
                        defaultCompletion()
                    }
                    else {
                        NSLog("Timer elapsed for \(resource.url)")
                    }
                }
                return nil
            }
            
            if let urlObject = task.result, let data = (urlObject.object as? URLResultResponse<T>)?.data {
                NSLog("Received data from \(resource.url)")
                self.synchronized(self) {
                    // only call completion handler if timer has not elapsed
                    if !self.timerElapsed {
                        completionSource.set(result: urlObject)
                    }
                    else {
                        NSLog("Timer elapsed for \(resource.url)")
                    }
                    // call cacheBlock regardless of timeout
                    if let cb = cacheBlock {
                        cb(data)
                    }
                }
            }
            return nil
        }
        
        return completionSource.task
    }

    public func loadWithSpan<T>(_ resource: URLResource<T>, operation: String, defaultData : T, cacheBlock : ((T)->Void)? = nil) -> Task<URLObject> {
        let completionSource = TaskCompletionSource<URLObject>()

        let defaultCompletion = {
            NSLog("Sending default data from \(resource.url)")
            let tuple : (headers : [String:Any]?, data: T) = (headers: nil, data: defaultData)
            completionSource.set(result:URLObject(result:tuple))
        }
        self.createTimer(withCompletion: defaultCompletion)

        // call this after timer created to avoid race condition
        URLService().loadWithSpan(resource, operation: operation).continueWith { (task) -> Any? in
            self.stopTimer()
            if let error = task.error {
                NSLog("Received \(error) from \(resource.url)")
                self.synchronized(self) {
                    // only call completion handler if timer has not elapsed
                    if !self.timerElapsed {
                        // send defaultData on error (and timer not elapsed)
                        defaultCompletion()
                    }
                    else {
                        NSLog("Timer elapsed for \(resource.url)")
                    }
                }
                return nil
            }
            
            if let urlObject = task.result, let data = (urlObject.object as? URLResultResponse<T>)?.data {
                NSLog("Received data from \(resource.url)")
                self.synchronized(self) {
                    // only call completion handler if timer has not elapsed
                    if !self.timerElapsed {
                        completionSource.set(result: urlObject)
                    }
                    else {
                        NSLog("Timer elapsed for \(resource.url)")
                    }
                    // call cacheBlock regardless of timeout
                    if let cb = cacheBlock {
                        cb(data)
                    }
                }
            }
            return nil
        }
        
        return completionSource.task
    }

    fileprivate func createTimer(withCompletion completion: @escaping () -> Void) {
        synchronized(self) {
            timerElapsed = false
            timer = Timer.scheduledTimer(timeInterval: self.timeout, target: self, selector: #selector(TimedURLService.onTimerElapsed), userInfo: completion, repeats: false)
        }
    }

    fileprivate func stopTimer() {
        synchronized(self) {
            timer?.invalidate()
            timer = nil
        }
    }

    @objc public func onTimerElapsed() {
        synchronized(self) {
            timerElapsed = true
            if let t = self.timer, let completion = t.userInfo as? () -> Void {
                NSLog("Timer expired")
                completion()
            }
        }
    }
    

}
