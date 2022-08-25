//
//  OAuthToken.swift
//  Roku
//
//  Created by Ivan Kim on 8/30/21.
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation


public enum TokenType: String {
    case OAUTH
    case PARTNERACCESS = "PARTNER-ACCESS"
}


@objc public class OAuthToken: NSObject, NSCoding, Codable {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.expiration, forKey: "expiration")
        aCoder.encode(self.refreshToken, forKey: "refreshToken")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let token = aDecoder.decodeObject(forKey: "token") as? String {
            self.token = token
        }
        
        if let token = aDecoder.decodeObject(forKey: "refreshToken") as? String {
            self.refreshToken = token
        }
        
        if let date = aDecoder.decodeObject(forKey: "expiration") as? Date {
            self.expiration = date
        }
    }
    
    @objc public var token: String?
    public var expiration: Date?
    public var refreshToken: String?
    
    func isExpired() -> Bool {
        let currentTime = Date()
        return currentTime >= expiration ?? currentTime
    }
    
    override public init() {}
    
    init(accessToken: String, expiration: Int, refreshToken: String) {
        self.token = accessToken
        self.refreshToken = refreshToken
        self.expiration = Date(timeIntervalSince1970: TimeInterval(expiration))
    }
}


@objc public class PartnerAccessToken: NSObject, Codable {
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "token")
        aCoder.encode(self.expiry, forKey: "expiry")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        if let token = aDecoder.decodeObject(forKey: "token") as? String {
            self.token = token
        }
        
        if let date = aDecoder.decodeObject(forKey: "expiry") as? Date {
            self.expiry = date
        }
    }
    
    @objc public var token: String?
    var expiry: Date?
    
    func isExpired() -> Bool {
        let currentTime = Date()
        return currentTime >= expiry ?? currentTime
    }
    
    override public init() {}
    
    init(accessToken: String, expiry: Int) {
        self.token = accessToken
        self.expiry = Date(timeIntervalSince1970: TimeInterval(expiry))
    }
}


public class TokenService: Resolving {

    public func getToken(token : String, refreshToken: String? = nil, tokenType: TokenType) -> RokuTask<NSObject>? {
        let completionSource = RokuTaskCompletionSource<NSObject>()
        guard let configResource = tokenResource(token : token, refreshToken: refreshToken, tokenType: tokenType) else {
            print("Error: Cannot create userResource ")
            return nil
        }
        let urlService : URLService = resolver.resolve()
        urlService.load(configResource).continueWith { (task) in
            if let error = task.error {
                completionSource.set(error: FeynmanError(reason: error.localizedDescription))
            }
            else if let result = (task.result?.object as? URLResultResponse<NSObject?>)?.data {
                completionSource.set(result: result)
            }
            else {
                completionSource.set(error: FeynmanError(reason: "virtual id result was not found or of expected type"))
            }
        }
        return completionSource.task
    }
    
    fileprivate func tokenResource(token : String, refreshToken: String? = nil, tokenType: TokenType) -> URLResource<NSObject?>? {

        let url = URL(string: "\(User.rokuEnvironment.iotBackendUrls)/user/token")!
        
        var body = ""
        if tokenType == .PARTNERACCESS {
            body = "{\n  \"tokenType\": [\n    \"PARTNER-ACCESS\"\n  ]\n}"
        }
        if tokenType == .OAUTH {
            body = "{\n  \"tokenType\": [\n    \"OAUTH\"\n  ]\n}"
        }
        
        var headerFields = AWSHeaderService(url: url, method: .post(body), body: body).awsHeaders()
        
        headerFields["access-token"] = token
        if tokenType == .OAUTH, let r = refreshToken {
            headerFields["refresh-token"] = r
        }
        headerFields["app"] = "harold"
        if User.rokuEnvironment.tier == .qa {
            headerFields["apiweb-env"] = "staging"
        }

        return try? URLResource<NSObject?>(url: url, method: .post(body), headerFields: headerFields, parseJson: { (json) -> NSObject? in
            
            guard let dictionary = json as? JSONDictionary else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            
            if tokenType == .PARTNERACCESS {
                guard let partnerAccess = data["partnerAccess"] as? [String: Any], let partnerToken = partnerAccess["token"] as? String, let partnerAccessTokenExpiry = partnerAccess["expiry"] as? Int else {
                    return nil
                }
                
                return PartnerAccessToken(accessToken: partnerToken, expiry: partnerAccessTokenExpiry)
            }
            
            if tokenType == .OAUTH {
                guard let oauth = data["oauth"] as? [String: Any], let accessToken = oauth["accessToken"] as? String, let accessTokenExpiry = oauth["accessTokenExpiry"] as? Int, let refreshToken = oauth["refreshToken"] as? String else {
                    return nil
                }
                
                return  OAuthToken(accessToken: accessToken, expiration: accessTokenExpiry, refreshToken: refreshToken)
            }
            
            return nil
        })
    }

}
