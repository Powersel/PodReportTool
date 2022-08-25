//
//  Synchronizable.swift
//  Copyright © 2017 Roku. All rights reserved.
//

import Foundation

public protocol Synchronizable {
    func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T
    static func staticSynchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T
}

public extension Synchronizable {
    func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        return try body()
    }
    
    static func staticSynchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
        objc_sync_enter(lock)
        defer { objc_sync_exit(lock) }
        return try body()
    }
}
