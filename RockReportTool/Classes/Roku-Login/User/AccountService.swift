//
//  AccountService.swift
//  Feynman
//
//  Created by Ivan Kim on 3/22/18.
//  Copyright © 2018 Roku. All rights reserved.
//

import Foundation
import SWXMLHash
import SwiftyJSON
import CocoaLumberjack

@objc public class AccountService: NSObject, Resolving {
    var virtualIdService = VirtualIdService()

    fileprivate var jwtTokenRetryCount = 0
    static let jwtTokenMaxRetryCount = 4
    
    func createUser(firstName: String, lastName: String, email: String, password: String, newsLetterOptIn: Bool) -> RokuTask<FeynmanObject>? {
        
        return nil
        
//        let createUserCompletionSource = RokuTaskCompletionSource<FeynmanObject>()
//        let createUserTask = createUserCompletionSource.task
//
//        guard let createUserResource = AccountService.createUserResource(firstName: firstName, lastName: lastName, email: email, password: password, newsLetterOptIn: newsLetterOptIn ? "true" : "false") else {
//            print("Error: Cannot create createUserResource ")
//            return nil
//        }
//
//        URLService().load(createUserResource).continueWith(Executor.immediate, continuation: { (task) in
//            if !task.faulted {
//                let loggedInUser = User()
//
//                if let userIds = (task.result?.object as? URLResultResponse<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>)?.data {
//                    loggedInUser.profileId = userIds.profileID
//                    loggedInUser.rokuUserId = userIds.rokuID
//                    loggedInUser.channelStoreCode = userIds.channelStoreCode
//                    loggedInUser.cultureCode = userIds.cultureCode
//                    loggedInUser.firstName = firstName
//                    loggedInUser.lastName = lastName
//                    loggedInUser.email = email
//                    loggedInUser.virtualUserId = userIds.virtualUserId
//                    loggedInUser.userToken = userIds.userToken
//                    loggedInUser.userJWTToken = userIds.jwtToken
//                    loggedInUser.oauthToken = userIds.oauthToken
//                    loggedInUser.partnerToken = userIds.partnerAccessToken
//                    User.currentUser = loggedInUser
//                    createUserCompletionSource.set(result: FeynmanObject(result: loggedInUser))
//                }
//            } else {
//                createUserCompletionSource.set(error: FeynmanError(reason: "Error: createUser failed"))
//            }
//        })
//
//        return createUserTask
    }

    public func login(email: String, password: String) -> RokuTask<FeynmanObject>? {
        
        return nil
        
//        let loginCompletionSource = RokuTaskCompletionSource<FeynmanObject>()
//        let loginTask = loginCompletionSource.task
//
//        guard let loginResource = AccountService.loginResource(email: email, password: password) else {
//            print("Error: Cannot create loginResource ")
//            return nil
//        }
//
//        URLService().load(loginResource).continueWith(Executor.immediate, continuation: { (loginResourceTask) in
//            if !loginResourceTask.faulted {
//                let loggedInUser = User()
//
//                if let userIds = (loginResourceTask.result?.object as? URLResultResponse<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>)?.data {
//                    loggedInUser.profileId = userIds.profileID
//                    loggedInUser.rokuUserId = userIds.rokuID
//                    loggedInUser.channelStoreCode = userIds.channelStoreCode
//                    loggedInUser.cultureCode = userIds.cultureCode
//                    loggedInUser.firstName = userIds.firstName
//                    loggedInUser.lastName = userIds.lastName
//                    loggedInUser.email = email
//                    loggedInUser.virtualUserId = userIds.virtualUserId
//                    loggedInUser.userToken = userIds.userToken
//                    loggedInUser.userJWTToken = userIds.jwtToken
//                    loggedInUser.oauthToken = userIds.oauthToken
//                    loggedInUser.partnerToken = userIds.partnerAccessToken
//                    User.currentUser = loggedInUser
//                    loginCompletionSource.set(result: FeynmanObject(result: loggedInUser))
//                }
//            } else {
//                guard let error = loginResourceTask.error else  {
//                    loginCompletionSource.set(error: FeynmanError(reason: "Error: task faulted"))
//                    return
//                }
//                loginCompletionSource.set(error: error)
//                print("loginResourceTask is faulted: \(error)")
//            }
//        })
//        return loginTask
    }
    
    @objc public func logout() -> RokuTask<FeynmanObject>? {
        
        return nil
        
//        let logoutCompletionSource = RokuTaskCompletionSource<FeynmanObject>()
//        let logoutTask = logoutCompletionSource.task
//
//        if let accessToken = User.currentUser?.oauthToken?.token, let logoutResource = AccountService.logoutResource(accessToken: accessToken) {
//            URLService().load(logoutResource).continueWith(Executor.immediate, continuation: { (logoutResourceTask) in
//                if !logoutResourceTask.faulted {
//                    if let message = (logoutResourceTask.result?.object as? URLResultResponse<String>)?.data {
//                        logoutCompletionSource.set(result: FeynmanObject(result: message))
//                    }
//                } else {
//                    guard let error = logoutResourceTask.error else  {
//                        logoutCompletionSource.set(error: FeynmanError(reason: "Error: task faulted"))
//                        return
//                    }
//                    logoutCompletionSource.set(error: error)
//                    print("logoutResourceTask is faulted: \(error)")
//                }
//            })
//        } else {
//            logoutCompletionSource.set(result: FeynmanObject(result: true))
//        }
//        return logoutTask
    }
    
    public func confirmPassword(email: String, password: String) -> RokuTask<NSNumber>? {
        
        return nil
        
//        let confirmPasswordCompletionSource = RokuTaskCompletionSource<NSNumber>()
//        let confirmPasswordTask = confirmPasswordCompletionSource.task
//
//        guard let confirmPasswordResource = AccountService.confirmPasswordResource(email: email, password: password) else {
//            print("Error: Cannot create confirmPasswordResource")
//            return nil
//        }
//
//        URLService().load(confirmPasswordResource).continueWith(Executor.immediate, continuation: { (confirmPasswordResourceTask) in
//            if !confirmPasswordResourceTask.faulted {
//                confirmPasswordCompletionSource.set(result: NSNumber(booleanLiteral: true))
//            } else {
//                guard let error = confirmPasswordResourceTask.error else  {
//                    confirmPasswordCompletionSource.set(error: FeynmanError(reason: "Error: task faulted"))
//                    return
//                }
//                confirmPasswordCompletionSource.set(error: error)
//                print("confirmPasswordResource is faulted: \(error)")
//            }
//        })
//        return confirmPasswordTask
    }
    
    public func deleteUser() -> RokuTask<FeynmanObject>? {
        
        return nil
        
//        let deleteUserCompletionSource = RokuTaskCompletionSource<FeynmanObject>()
//        let deleteUserTask = deleteUserCompletionSource.task
//
//        guard let deleteUserResource = AccountService.deleteUserResource() else {
//            print("Error: Cannot create deleteUserResource ")
//            return nil
//        }
//
//        URLService().load(deleteUserResource).continueWith(Executor.immediate, continuation: { (deleteUserResourceTask) in
//            if !deleteUserResourceTask.faulted {
//                if let message = (deleteUserResourceTask.result?.object as? URLResultResponse<String>)?.data {
//                    deleteUserCompletionSource.set(result: FeynmanObject(result: message))
//                }
//            } else {
//                guard let error = deleteUserResourceTask.error else  {
//                    deleteUserCompletionSource.set(error: FeynmanError(reason: "Error: task faulted"))
//                    return
//                }
//                deleteUserCompletionSource.set(error: error)
//                print("deleteUserResource is faulted: \(error)")
//            }
//        })
//        return deleteUserTask
    }
    
    public func getjwtToken(tokenResource: URLResource<JSONWebToken>,completionSource: RokuTaskCompletionSource<JSONWebToken>? = nil) -> RokuTask<JSONWebToken>{
        
        self.jwtTokenRetryCount += 1
        let jwtCompletionSource = completionSource ?? RokuTaskCompletionSource<JSONWebToken>()
        
        URLService().load(tokenResource).continueWith(Executor.immediate, continuation: { (task) in
            if !task.faulted {
                if let userJWTToken = (task.result?.object as? URLResultResponse<JSONWebToken>)?.data {
                    jwtCompletionSource.set(result: userJWTToken)
                }
                else {
                    if self.jwtTokenRetryCount >= AccountService.jwtTokenMaxRetryCount {
                      jwtCompletionSource.set(error: FeynmanError(reason: "Error: Invalid userJWTToken"))
                    }
                    else {
                        DispatchQueue.global(qos: .userInitiated).async {
                        let _ = self.getjwtToken(tokenResource: tokenResource, completionSource: jwtCompletionSource)
                        }
                    }
                    
                }
            }
            else {
                if self.jwtTokenRetryCount >= AccountService.jwtTokenMaxRetryCount {
                    jwtCompletionSource.set(error: task.error!)
                }
                else {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let _ = self.getjwtToken(tokenResource: tokenResource, completionSource: jwtCompletionSource)
                    }
                }
            }
        })
        return jwtCompletionSource.task
    }
    
    public func refreshUserOAuth(oauth: OAuthToken, email: String, userToken: String) -> Task<OAuthToken> {
        let refreshCompletionSource = TaskCompletionSource<OAuthToken>()

        guard let refreshResource = refreshOAuthResource(oauth: oauth, email: email, userToken: userToken) else {
            print("Error: Cannot create refreshOAuthResource ")
            refreshCompletionSource.set(error: FeynmanError(reason: "Error: could not create refreshOAuthResource"))
            return refreshCompletionSource.task
        }

        URLService().load(refreshResource).continueWith(Executor.immediate, continuation: { task in
                        if !task.faulted, let oauth = (task.result?.object as? URLResultResponse<OAuthToken>)?.data {
                            refreshCompletionSource.set(result: oauth)
                        } else if let error = task.error {
                            refreshCompletionSource.set(error: error)
                            print("refreshOAuthResource is faulted: \(error)")
                        } else {
                            refreshCompletionSource.set(error: FeynmanError(reason: "Error: refreshOAuth faulted"))
                        }
        })
        return refreshCompletionSource.task
    }
}

extension AccountService {
    private class func loginResource(email: String, password: String) -> URLResource<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>? {
        guard let url = URL(string: "\(User.rokuEnvironment.iotBackendUrls)/user/login") else {
            print("Invalid url")
            return nil
        }
        
        let body = "{ \"email\": \"\(email)\", \"password\": \"\(password)\" }"

        var headerFields = AWSHeaderService(url: url, method: .post(body), body: body).awsHeaders()
        headerFields["app"] = "harold"
        if User.rokuEnvironment.tier == .qa {
            headerFields["apiweb-env"] = "staging"
        }
        
        return try? URLResource<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>(url: url, method: .post(body), headerFields: headerFields, parseJson: {
            (json) -> (profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)? in
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            guard let rokuId = data["id"] as? String else {
                print("Error: roku id not found")
                return nil
            }
            let channelStoreCode = data["channelStoreCode"] as? String 
            
            let cultureCode = data["cultureCode"] as? String
            
            let firstName = data["firstName"] as? String
            
            let lastName = data["lastName"] as? String
            
//            guard let lastName = data["lastName"] as? String else {
//                print("Error: lastName not found")
//                return nil
//            }
            
            
            var virtualId: String? = nil
            if let virtualUserId = data["virtualUserId"] as? String {
                virtualId = virtualUserId
            }
            
            let userToken = data["userToken"] as? String
            
            let profileId = data["notificationToken"] as? String

            guard let oauth = data["oauth"] as? [String: Any], let accessToken = oauth["accessToken"] as? String, let accessTokenExpiry = oauth["accessTokenExpiry"] as? Int, let refreshToken = oauth["refreshToken"] as? String else {
                return nil
            }
            let oauthToken = OAuthToken(accessToken: accessToken, expiration: accessTokenExpiry, refreshToken: refreshToken)
            
            guard let partnerAccess = data["partnerAccess"] as? [String: Any], let partnerToken = partnerAccess["token"] as? String, let partnerAccessTokenExpiry = partnerAccess["expiry"] as? Int else {
                return nil
            }
            
            let partnerAccessToken = PartnerAccessToken(accessToken: partnerToken, expiry: partnerAccessTokenExpiry)
            
//            guard let jwt = data["jwt"] as? [String: Any], let jsonWebToken = jwt["accessToken"] as? String, let jwtTokenExpiry = jwt["accessTokenExpiry"] as? Double, let jwtToken = JSONWebToken(token: jsonWebToken, expiration: jwtTokenExpiry) else {
//                print("Error: JWT Token not found")
//                return nil
//            }
            
            return (profileId, rokuId, channelStoreCode, cultureCode, firstName, lastName, virtualId, userToken, oauthToken, nil, partnerAccessToken)
        })

    }
    
    private class func logoutResource(accessToken: String) -> URLResource<String>? {
        guard let url = URL(string: "\(User.rokuEnvironment.iotBackendUrls)/user/logout") else {
            print("Invalid url")
            return nil
        }
        
        let body = ""

        var headerFields = AWSHeaderService(url: url, method: .post(body), body: body).awsHeaders()
        
        headerFields["app"] = "harold"
        headerFields["access-token"] = accessToken
        if User.rokuEnvironment.tier == .qa {
            headerFields["apiweb-env"] = "qa"
        }

        return try? URLResource<String>(url: url, method: .post(body), headerFields: headerFields, parseJson: {
            (json) -> String? in
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            guard let message = data["message"] as? String else {
                print("Error: userToken not found")
                return nil
            }
            
            return message
        })
    }
    
    static var sourceID: String {
        #if DEBUG
            return "owl-roku-pre-production"
        #else
            return "owl-roku-production"
        #endif
    }
    
    private class func createUserResource(firstName: String, lastName: String, email: String, password: String, newsLetterOptIn: String) -> URLResource<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>? {
        guard let url = URL(string: "\(User.rokuEnvironment.iotBackendUrls)/user") else { return nil }
        
        let body = "{ \"billingAddress\": { }, \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"email\": \"\(email)\", \"password\": \"\(password)\", \"optInRokuNewsletter\": \"\(newsLetterOptIn)\", \"sourceId\": \"\(sourceID)\" }"

        var headerFields = AWSHeaderService(url: url, method: .post(body), body: body).awsHeaders()
        headerFields["app"] = "harold"
        if User.rokuEnvironment.tier == .qa {
            headerFields["apiweb-env"] = "staging"
        }
        
        return try? URLResource<(profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)>(url: url, method: .post(body), headerFields: headerFields, parseJson: {
            (json) -> (profileID: String?, rokuID: String, channelStoreCode: String?, cultureCode: String?, firstName: String?, lastName: String?, virtualUserId: String?, userToken: String?, oauthToken: OAuthToken?, jwtToken: JSONWebToken?, partnerAccessToken: PartnerAccessToken?)? in
            
//                guard let dictionary = json as? [String: Any] else {
//                    print("Error: Unable to cast json to dictionary")
//                    return nil
//                }
//                guard let data = dictionary["data"] as? [String: Any] else {
//                    print("Error: data not found")
//                    return nil
//                }
//                guard let profileId = data["notificationToken"] as? String else {
//                    print("Error: notificationToken not found")
//                    return nil
//                }
//                guard let rokuId = data["id"] as? String else {
//                    print("Error: roku id not found")
//                    return nil
//                }
//                guard let channelStoreCode = data["channelStoreCode"] as? String else {
//                    print("Error: channelStoreCode not found")
//                    return nil
//                }
//                guard let cultureCode = data["cultureCode"] as? String else {
//                    print("Error: cultureCode not found")
//                    return nil
//                }
//                guard let firstName = data["firstName"] as? String else {
//                    print("Error: firstName not found")
//                    return nil
//                }
//                guard let lastName = data["lastName"] as? String else {
//                    print("Error: lastName not found")
//                    return nil
//                }
//
//                var virtualId: String? = nil
//                if let virtualUserId = data["virtualUserId"] as? String {
//                    virtualId = virtualUserId
//                }
//
//                var userToken: String? = nil
//                if let userTokenData = data["userToken"] as? String {
//                    userToken = userTokenData
//                }
//
//                var oauthToken: OAuthToken? = nil
//                if let oauth = data["oauthAccess"] as? [String: Any], let accessToken = oauth["token"] as? String, let accessTokenExpiry = oauth["expiry"] as? Int {
//                    oauthToken = OAuthToken(accessToken: accessToken, expiration: accessTokenExpiry)
//                }
//
//
//
//                return (profileId, rokuId, channelStoreCode, cultureCode, firstName, lastName, virtualId, userToken, oauthToken, jwtToken)
            
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            guard let rokuId = data["id"] as? String else {
                print("Error: roku id not found")
                return nil
            }
            let channelStoreCode = data["channelStoreCode"] as? String
            
            let cultureCode = data["cultureCode"] as? String
            
            let firstName = data["firstName"] as? String
            
            let lastName = data["lastName"] as? String
            
//            guard let lastName = data["lastName"] as? String else {
//                print("Error: lastName not found")
//                return nil
//            }
            
            
            var virtualId: String? = nil
            if let virtualUserId = data["virtualUserId"] as? String {
                virtualId = virtualUserId
            }
            
            let userToken = data["userToken"] as? String
            
            let profileId = data["notificationToken"] as? String

            
            var oauthToken: OAuthToken? = nil
            if let oauth = data["oauth"] as? [String: Any], let accessToken = oauth["accessToken"] as? String, let accessTokenExpiry = oauth["accessTokenExpiry"] as? Int , let refreshToken = oauth["refreshToken"] as? String {
                oauthToken = OAuthToken(accessToken: accessToken, expiration: accessTokenExpiry, refreshToken: refreshToken)
            }
            
            var partnerAccessToken: PartnerAccessToken? = nil
            if let partnerAccess = data["partnerAccess"] as? [String: Any], let partnerToken = partnerAccess["token"] as? String, let partnerAccessTokenExpiry = partnerAccess["expiry"] as? Int {
                partnerAccessToken = PartnerAccessToken(accessToken: partnerToken, expiry: partnerAccessTokenExpiry)
            }
            
//            guard let jwt = data["jwt"] as? [String: Any], let jsonWebToken = jwt["accessToken"] as? String, let jwtTokenExpiry = jwt["accessTokenExpiry"] as? Double, let jwtToken = JSONWebToken(token: jsonWebToken, expiration: jwtTokenExpiry) else {
//                print("Error: JWT Token not found")
//                return nil
//            }
            
            return (profileId, rokuId, channelStoreCode, cultureCode, firstName, lastName, virtualId, userToken, oauthToken, nil, partnerAccessToken)
        })
    }
    
    static func getConfirmPasswordUrl() -> URL? {
        guard var urlComponents = URLComponents(string: "\(User.rokuEnvironment.iotBackendUrls)/camino/usersvc/users/login") else {
            DDLogError("Cannot create a valid url component")
            return nil
        }
        /*
         `createMobileSessionId` is used by upstream service to not create a new userToken object for the given user
         `confirmPassword` is used by MCS team to confirm password from login resource
         */
        urlComponents.queryItems = [URLQueryItem(name: "createMobileSessionId", value: "false"), URLQueryItem(name: "confirmPassword", value: "true")]
        guard let url = urlComponents.url else { return nil }

        return url
    }
    
    private class func confirmPasswordResource(email: String, password: String) -> URLResource<Bool>? {
        guard let url = self.getConfirmPasswordUrl() else {
            print("Invalid url")
            return nil
        }
        
        let body = "{ \"email\": \"\(email)\", \"password\": \"\(password)\" }"

        var headerFields = AWSHeaderService(url: url, method: .post(body), body: body).awsHeaders()
        headerFields["Content-Type"] = "application/json"
        
        return try? URLResource<Bool>(url: url, method: .post(body), headerFields: headerFields, parseJson: {
            (json) -> Bool? in
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }

            guard let rokuId = data["id"] as? String else {
                print("Error: roku id not found")
                return nil
            }
            
            guard rokuId == User.currentUser?.rokuUserId else {
                print("Error: roku user id do not match")
                return nil
            }
            
            guard data["userToken"] != nil else {
                print("Error: userToken not found")
                return nil
            }
            
            return true
        })

    }
    
    static func getDeleteUserUrl(userId: String, userToken: String) -> URL? {
        guard var urlComponents = URLComponents(string: "\(User.rokuEnvironment.iotBackendUrls)/camino/usersvc/users/${account_id}".replacingOccurrences(of: "${account_id}", with: userId)) else {
            DDLogError("Cannot create a valid url component")
            return nil
        }
        /*
         `userToken` query param is required as per contarct with backend team
         `reason` and `comments` are required fiels on the backend server
            they are used currently on the web as web have different account deletion flow
            harcoded the values here as we do not input this from the user
         */
        
        urlComponents.queryItems = [URLQueryItem(name: "userToken", value: userToken), URLQueryItem(name: "reason", value: "DontUseIt"), URLQueryItem(name: "comments", value: "DeleteFromMobile")]
        guard let url = urlComponents.url else { return nil }

        return url
    }
    
    private class func deleteUserResource() -> URLResource<String>? {
        guard let userId = User.currentUser?.rokuUserId else {
            return nil
        }
        
        guard let userToken = User.currentUser?.userToken else {
            return nil
        }
        
        guard let url = self.getDeleteUserUrl(userId: userId, userToken: userToken) else {
            print("Invalid url")
            return nil
        }

        let headerFields = AWSHeaderService(url: url, method: .delete(nil), body: "").awsHeaders()
        
        return try? URLResource<String>(url: url, method: .delete(nil), headerFields: headerFields, parseJson: {
            (json) -> String? in
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }

            guard let message = data["message"] as? String else {
                print("Error: roku id not found")
                return nil
            }
           
            return message
        })

    }

    private func refreshOAuthResource(oauth: OAuthToken, email: String, userToken: String) -> URLResource<OAuthToken>? {
        
        guard let token = oauth.token else {
            DDLogError("no token")
            return nil
        }
        
        guard var urlComponents = URLComponents(string: "\(User.rokuEnvironment.mediationBackendUrls)/camino/usersvc/auth/token") else {
            DDLogError("Cannot create a valid url component")
            return nil
        }


        urlComponents.queryItems = [URLQueryItem(name: "email", value: email), URLQueryItem(name: "userToken", value: userToken)]
        
        guard let url = urlComponents.url else { return nil }
        
        var headerFields = AWSHeaderService(url: url, method: .get, body: "").awsHeaders()
        headerFields["access-token"] = token
        
        return try? URLResource<OAuthToken>(url: url, method: .get, headerFields: headerFields, parseJson: {
            json -> OAuthToken? in
            guard let dictionary = json as? [String: Any] else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            var oauthToken: OAuthToken?
            if let oauth = data["oauthAccess"] as? [String: Any], let accessToken = oauth["token"] as? String, let accessTokenExpiry = oauth["expiry"] as? Int, let refreshToken = oauth["refreshToken"] as? String {
                oauthToken = OAuthToken(accessToken: accessToken, expiration: accessTokenExpiry, refreshToken: refreshToken)
            }
            return oauthToken
        })

    }

    
    // MARK: Graveyard
    /*
    func getProfilesByUserId(userId: String) -> RokuTask<FeynmanObject>? {
        let profilesCompletionSource = RokuTaskCompletionSource<FeynmanObject>()
        let profilesTask = profilesCompletionSource.task
        
        guard let profilesResource = User.userProfilesResource(userId: userId) else {
            print("Error: cannot create profilesResource")
            return nil
        }
        
        URLService().load(profilesResource).continueWith { (task) in
            if !task.faulted, let profileId = (task.result?.object as? URLResultResponse<String>)?.data  {
                profilesCompletionSource.set(result: FeynmanObject(result: profileId))
            } else {
                profilesCompletionSource.set(error: FeynmanError(reason: "Error: getProfilesByUserId failed"))
            }
        }
        
        return profilesTask
    }

    public class func userProfilesResource(userId: String) -> URLResource<String>? {
        guard let url = CaminoResources.profilesUrl(userId: userId) else {
            print("Invalid url")
            return nil
        }
        let headerFields = AWSHeaderService(url: url, method: .get, body: "").awsHeaders()

        return try? URLResource<String>(
            url: url,
            method: .get,
            headerFields: headerFields,
            parseJson: { (json) -> String? in
                guard let dictionary = json as? [String: Any] else {
                    print("Error: Unable to cast json to dictionary")
                    return nil
                }
                guard let data = dictionary["data"] as? [String: Any] else {
                    print("Error: data not found")
                    return nil
                }
                guard let profiles = data["profiles"] as? [[String: Any]] else {
                    print("Error: profiles not found")
                    return nil
                }
                guard let profileId = profiles.first?["id"] as? String else {
                    print("Error: profileId not found")
                    return nil
                }
                return profileId
        })
    }
     */

}
