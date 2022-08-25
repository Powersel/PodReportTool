//
//  JSONWebToken.swift
//  Roku
//
//  Created by Ivan Kim on 8/20/21.
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation

@objc public class JSONWebToken: NSObject, NSCoding, Codable {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.expiration, forKey: "expiration")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let token = aDecoder.decodeObject(forKey: "token") as? String {
            self.token = token
        }
        
        if let date = aDecoder.decodeObject(forKey: "expiration") as? Date {
            self.expiration = date
        }
    }
    
    @objc public var token: String?
    var expiration: Date?
    
    func isExpired() -> Bool {
        let currentTime = Date()
        return currentTime >= expiration ?? currentTime
    }
    
    override public init() {}
}

extension JSONWebToken {
    convenience init?(dictionary: JSONDictionary) {
        guard let token = dictionary["token"] as? String else {
            return nil
        }
        
        guard let expire = dictionary["exp"] as? Double else {
            return nil
        }
        self.init()
        self.token = token
        self.expiration = Date(timeIntervalSince1970: expire)
    }
    
    convenience init?(token: String, expiration: Double) {
        self.init()
        self.token = token
        self.expiration = Date(timeIntervalSince1970: expiration)
    }
}

