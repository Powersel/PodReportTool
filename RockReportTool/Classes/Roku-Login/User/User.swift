//
//  User.swift
//  RokuCore
//
//  Created by Ivan Kim on 6/29/18.
//

import Foundation
import KeychainAccess
import CocoaLumberjack

@objc public class User: NSObject, NSCoding, Codable, Synchronizable {

    private static let legacyRokuKeychainWrapper : Keychain = {
        let bundleID = Bundle.main.bundleIdentifier
        var groupID: String
        switch bundleID {
        case "com.wyze.paas":
            groupID = "89964793U.com.wyze.paas"
        case "com.wyze.Owl":
            groupID = "G3S9LHD28S.com.wyze.Owl"
        case "com.roku.ios.rokuhome":
            groupID = "X2879UAD7T.RokuKeychainGroup"
        default:
            groupID = "X2879UAD7T.RokuKeychainGroup"
        }
        print("groupID \(groupID)")
        return Keychain(service: "RokuKeychainWrapper", accessGroup: groupID)
    }()
    
    private static let rokuBundleKeychainWrapper : Keychain = {
        let bundleID = Bundle.main.bundleIdentifier
        var groupID: String
        switch bundleID {
        case "com.wyze.paas":
            groupID = "89964793U.com.wyze.paas"
        case "com.wyze.Owl":
            groupID = "G3S9LHD28S.com.wyze.Owl"
        case "com.roku.ios.rokuhome":
            groupID = "X2879UAD7T.com.roku.ios.rokuhome"
        default:
            groupID = "X2879UAD7T.com.roku.ios.rokuhome"
        }
        print("groupID \(groupID)")
        return Keychain(service: "RokuKeychainWrapper", accessGroup: groupID)
    }()
    
    enum CodingKeys: String, CodingKey {
       case userToken, oauthToken, userJWTToken, profileId,rokuUserId, virtualUserId, channelStoreCode, cultureCode, email, firstName, lastName, parentalControlPIN, subscribedProviders, partnerToken, currentPIN, externalIP
     }
    
    private var accountService = AccountService()
    private var virtualIdService = VirtualIdService()
    private var tokenService = TokenService()
    
    private static var LoggedInUserKey = "loggedInUser"
    private static var _current : User?    // the current User
    
    override public init() {}

    @objc public var userToken: String?
    @objc public var oauthToken: OAuthToken?
    @objc public var userJWTToken: JSONWebToken?
    @objc public var profileId: String?
    @objc public var rokuUserId: String?
    @objc public var virtualUserId: String?
    @objc public var channelStoreCode: String?
    @objc public var cultureCode: String?
    @objc public var email: String?
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var parentalControlPIN: String?
    @objc public var subscribedProviders: [String]?
    
    // owl
    @objc public var partnerToken: PartnerAccessToken?

    // do we need these still?
    private var currentPIN: String?
    private var externalIP: String?

    // static, not sure where else to put it
    @objc public static var deviceJWTToken: JSONWebToken?

    // Derived fields
    public static var jwt : String? {
        return User.currentUser?.userJWTToken?.token ?? User.deviceJWTToken?.token
    }
    
    public static var partnerToken : String? {
        return User.currentUser?.partnerToken?.token
    }
        
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userToken, forKey: "userToken")
        aCoder.encode(self.userJWTToken, forKey: "userJWTToken")
        aCoder.encode(self.oauthToken, forKey: "oauthToken")
        aCoder.encode(self.profileId, forKey: "profileId")
        aCoder.encode(self.rokuUserId, forKey: "rokuUserId")
        aCoder.encode(self.virtualUserId, forKey: "virtualUserId")
        aCoder.encode(self.channelStoreCode, forKey: "channelStoreCode")
        aCoder.encode(self.cultureCode, forKey: "cultureCode")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.currentPIN, forKey: "currentPIN")
        aCoder.encode(self.externalIP, forKey: "externalIP")
        aCoder.encode(self.parentalControlPIN, forKey: "parentalControlPIN")
        aCoder.encode(self.subscribedProviders, forKey: "subscribedProviders")
        aCoder.encode(self.partnerToken, forKey: "partnerAccess")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        if let userToken = aDecoder.decodeObject(forKey: "userToken") as? String {
            self.userToken = userToken
        }
        NSKeyedUnarchiver.setClass(JSONWebToken.classForKeyedUnarchiver(), forClassName: "Roku.JSONWebToken")
        
        if let userJWTToken = aDecoder.decodeObject(forKey: "userJWTToken") as? JSONWebToken {
            self.userJWTToken = userJWTToken
        }
        
        NSKeyedUnarchiver.setClass(OAuthToken.classForKeyedUnarchiver(), forClassName: "Roku.OAuthToken")
        
        if let oauthToken = aDecoder.decodeObject(forKey: "oauthToken") as? OAuthToken {
            self.oauthToken = oauthToken
        }
        
        if let profileId = aDecoder.decodeObject(forKey: "profileId") as? String {
            self.profileId = profileId
        }
        
        if let rokuUserId = aDecoder.decodeObject(forKey: "rokuUserId") as? String {
            self.rokuUserId = rokuUserId
        }

        if let virtualUserId = aDecoder.decodeObject(forKey: "virtualUserId") as? String {
            self.virtualUserId = virtualUserId
        }

        if let channelStoreCode = aDecoder.decodeObject(forKey: "channelStoreCode") as? String {
            self.channelStoreCode = channelStoreCode
        }
        
        if let cultureCode = aDecoder.decodeObject(forKey: "cultureCode") as? String {
            self.cultureCode = cultureCode
        }
        
        if let email = aDecoder.decodeObject(forKey: "email") as? String {
            self.email = email
        }
        
        if let firstName = aDecoder.decodeObject(forKey: "firstName") as? String {
            self.firstName = firstName
        }
        
        if let lastName = aDecoder.decodeObject(forKey: "lastName") as? String {
            self.lastName = lastName
        }
        
        if let currentPIN = aDecoder.decodeObject(forKey: "currentPIN") as? String {
            self.currentPIN = currentPIN
        }
        if let externalIP = aDecoder.decodeObject(forKey: "externalIP") as? String {
            self.externalIP = externalIP
        }
        if let parentalControlPIN = aDecoder.decodeObject(forKey: "parentalControlPIN") as? String {
            self.parentalControlPIN = parentalControlPIN
        }
        if let subscribedProviders = aDecoder.decodeObject(forKey: "subscribedProviders") as? [String] {
            self.subscribedProviders = subscribedProviders
        }
        if let partnerToken = aDecoder.decodeObject(forKey: "partnerAccess") as? PartnerAccessToken{
            self.partnerToken = partnerToken
        }
    }
    
    // for synchronization in methods
    private static let syncLock = User()
    
    // for blocking multiple synchronous threads simultaneously while waiting for async load of user
    private static var userLoadedGroup = DispatchGroup()
        
    // for initial load
    private static var loadCalled = false
    
    @objc public static var currentUser: User? {
        get {
            // loadUser() needs to be called once at start of app (would be easier if we had class 'initialize' section or dispatch_once!)
            syncLock.synchronized(syncLock) {
                if !loadCalled {
                    loadCalled = true
                    userLoadedGroup.enter()
                    DispatchQueue.global().async {
                        if !loadNewUser() {
                            legacyLoadUser()
                        }
                    }
                }
            }
            
            // use the DispatchGroup to block this thread until load has finished
            userLoadedGroup.wait()
            
//            DDLogVerbose("returning existing User.currentUser \(_current?.email ?? "<nil>") \(_current?.virtualUserId ?? "<nil>")")
            return _current
        }
        set {
            syncLock.synchronized(syncLock) {
                if let user = newValue {
                    // try saving
                    if user.save() {
                        DDLogVerbose("saved \(user.email ?? "") as new User.currentUser")
                        _current = user
                    }
                }
                else {
                    DDLogVerbose("deleting User.currentUser = \(_current?.email ?? ""), User.currentUser now nil")
                    removeCurrentUser()
                }
            }
        }
    }
    
    public static func reloadUser() {
        userLoadedGroup.enter()
        DispatchQueue.global().async {
            if !loadNewUser() {
                legacyLoadUser()
            }
        }
    }
    
    private static func legacyLoadUser() {
        
        // pull from disk
        NSKeyedUnarchiver.setClass(User.classForKeyedUnarchiver(), forClassName: "Roku.User")
        do {
            // get data from keychain
            guard let userData = try legacyRokuKeychainWrapper.getData(LoggedInUserKey) else {
                DDLogVerbose("no User data in keychain for legacy user")
                userLoadedGroup.leave()
                return
            }
            
            // decode as User
            if let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
                fetchTasksForLegacyUser(user, userLoadedGroup: userLoadedGroup)
            }
            else {
                DDLogWarn("failed to decode User from userData for legacy user")
                userLoadedGroup.leave()
                return
            }
        } catch {
            DDLogError("error fetching User data from keychain for legacy user")
            userLoadedGroup.leave()
            return
        }
    }
    
    static func fetchTasksForLegacyUser(_ user: User, userLoadedGroup: DispatchGroup) {
        DDLogInfo("fetchTasksForLegacyUser")
        fetchTasks(user: user, userLoadedGroup: userLoadedGroup)
    }
    
    static func fetchTasksForNewUser(_ user: User, userLoadedGroup: DispatchGroup) {
        DDLogInfo("fetchTasksForNewUser")
        fetchTasks(user: user, userLoadedGroup: userLoadedGroup)
    }
    
    static func fetchTasks(user: User, userLoadedGroup: DispatchGroup) {
        // various credentials can expire, so re-fetch those
        let tasks = user.checkMissingExpiredFields()
        DDLogVerbose("num missing/expired fields: \(tasks.count)")
        
        if tasks.count > 0 {
            Task.whenAll(tasks).continueWith { (_) in
                
                print("fetchTasks")
                DDLogVerbose("missing/expired tasks complete")
                #if DEBUG
                tasks.forEach { task in
                    DDLogVerbose("Task result: \(task.result ?? false)")
                }
                #endif
                
                // all tasks must succeed otherwise consider it a failure
                let success = tasks.reduce(true, { (scs, task) in
                    return scs && (task.result ?? false)
                })
                
                if !success {
                    // if we couldn't retrieve all expired fields, set current to nil
                    DDLogError("loaded User from userData, missing/expired fetch failed")
                    _current = nil
                    userLoadedGroup.leave()
                    return
                }
                // save user b/c we fetched missing/expired fields
                _current = user
                if !saveCurrentUser() {
                    // if we couldn't save those fields to disk, set current to nil
                    DDLogError("loaded User from userData, missing/expired fetched successfully, failed to save")
                    _current = nil
                    userLoadedGroup.leave()
                    return
                }
                
                DDLogVerbose("loaded User from userData, missing/expired fetched successfully")
                userLoadedGroup.leave()
                return
            }
        }
        else {
            DDLogVerbose("loaded User from userData, no missing/expired fields")
            _current = user
            saveCurrentUser()
            userLoadedGroup.leave()
            return
        }
    }
    
    
    private static func loadNewUser() -> Bool {
        
        do {
            // get data from new keychain
            guard let userData = try rokuBundleKeychainWrapper.getData(LoggedInUserKey) else {
                DDLogVerbose("no User data in bundle keychain")
                return false
            }
            
            if let user = try? PropertyListDecoder().decode(User.self, from: userData)  {
                fetchTasksForNewUser(user, userLoadedGroup: userLoadedGroup)
                return true
            } else {
                DDLogWarn("failed to decode User from userData and PropertyListDecoder")
                userLoadedGroup.leave()
                return true
            }
        } catch {
            DDLogError("error fetching User data from keychain")
            return false
        }
    }
    
    public static var rokuEnvironment: CoreRokuEnvironments = .production
    
    public static func saveCurrentUser() -> Bool {
        return syncLock.synchronized(syncLock) { ()->Bool in
            if let user = _current {
                return user.save()
            }
            return false
        }
    }
    
    private func save() -> Bool {
        do {
            let userData = try PropertyListEncoder().encode(self)
            try User.rokuBundleKeychainWrapper.set(userData, key: User.LoggedInUserKey)
            
            DDLogVerbose("User.currentUser = \(email ?? "") saved successfully")
            return true
        } catch _ {
        }
        return false
    }
    
    // set User.currentUser to nil to remove the user
    private static func removeCurrentUser() {
        do {
            try rokuBundleKeychainWrapper.remove(LoggedInUserKey)
            _current = nil
        } catch let err {
            print("failed to remove from keychain err=\(err)")
        }
    }
    
    // even after transition, a user can contain expired fields
    private func checkMissingExpiredFields() -> [Task<Bool>] {
        var tasks = [Task<Bool>]()
        
        // oauthToken might be expired
        if let oauthToken = oauthToken, let expiration = oauthToken.expiration, expiration < Date() {
            tasks.append(fetchUserMissingTokens(tokenType: .OAUTH))
        } else {
            DDLogVerbose("oauthToken expiration = \(String(describing: oauthToken?.expiration))")
        }
        
        if nil == partnerToken || nil == partnerToken?.expiry {
            tasks.append(fetchUserMissingTokens(tokenType: .PARTNERACCESS))
        }
        else if partnerToken?.isExpired() == true {
            tasks.append(fetchUserMissingTokens(tokenType: .PARTNERACCESS))
        }
        else {
            DDLogVerbose("partnertoken.expiry = \(String(describing:partnerToken?.expiry))")
        }
        
        // virtualUserId might be missing
        if nil == virtualUserId {
            tasks.append(fetchVirtualUserId())
        }
        else {
            DDLogVerbose("virtualUserId = \(virtualUserId ?? "")")
        }
//
        // TODO: add a check for OAuthToken
        // TODO: add a check for OAuthToken
        // TODO: add a check for OAuthToken

        return tasks
    }
    
    private func fetchUserOAuth() -> Task<Bool> {
        let source = TaskCompletionSource<Bool>()
        if let email = email, let userToken = userToken, let oauth = oauthToken {
            DDLogInfo("fetching OAuthToken for \(email)")
            DispatchQueue.global().async {
                self.accountService.refreshUserOAuth(oauth: oauth, email: email, userToken: userToken).continueWith { [weak self] task in
                    if let oauth = task.result {
                        DDLogInfo("fetch OAuthToken for \(email) succeeded")
                        self?.oauthToken = oauth
                        source.set(result: true)
                    } else {
                        DDLogInfo("fetch OAuthToken for \(email) failed")
                        source.set(result: false)
                    }
                 }
            }
        } else {
            DDLogError("fetch OAuthToken for \(email ?? "") failed, missing email, userToken, or oauthToken")
            source.set(result: false)
        }
        return source.task
    }


    
    private func fetchUserMissingTokens(tokenType: TokenType) -> Task<Bool> {
        
        let source = TaskCompletionSource<Bool>()
        if let token = self.oauthToken?.token {
            DDLogVerbose("fetching \(tokenType.rawValue) for \(email ?? "")")
            DispatchQueue.global().async {
                self.tokenService.getToken(token: token, refreshToken: self.oauthToken?.refreshToken, tokenType: tokenType)?.continueWith(block: { [weak self] (task) -> Void in
                    if let token = task.result {
                        DDLogVerbose("fetch \(tokenType.rawValue) for \(self?.email ?? "") succeeded")
                        if tokenType == .OAUTH, let t = token as? OAuthToken {
                            self?.oauthToken = t
                        }
                        if tokenType == .PARTNERACCESS, let t = token as? PartnerAccessToken {
                            self?.partnerToken = t
                        }
                        
                        source.set(result: true)
                    }
                    else {
                        DDLogError("fetch \(tokenType.rawValue) for \(self?.email ?? "") failed")
                        source.set(result: false)
                    }
                })
            }
        }
        else {
            DDLogError("fetch \(tokenType.rawValue) for \(email ?? "") failed, no rokuUserId")
            source.set(result: false)
        }
        return source.task
    }
    
    
    private func fetchVirtualUserId() -> Task<Bool> {
        let source = TaskCompletionSource<Bool>()
        if let accountId = rokuUserId {
            DDLogVerbose("fetching virtualUserId for \(email ?? "")")
            DispatchQueue.global().async {
                self.virtualIdService.getVirtualAccountId(accountId: accountId)?.continueWith(block: { [weak self] (task) -> Void in
                    if let virtualId = task.result {
                        DDLogVerbose("fetch virtualUserId for \(self?.email ?? "") succeeded")
                        self?.virtualUserId = virtualId as String
                        source.set(result: true)
                    }
                    else {
                        DDLogError("fetch virtualUserId for \(self?.email ?? "") failed")
                        source.set(result: false)
                    }
                })
            }
        }
        else {
            DDLogError("fetch virtualUserId for \(email ?? "") failed, no rokuUserId")
            source.set(result: false)
        }
        return source.task
    }
}
