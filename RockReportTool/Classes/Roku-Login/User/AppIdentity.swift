//
//  AppIdentity.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import AdSupport
import AppTrackingTransparency
import CocoaLumberjack

fileprivate var canTrack = false

@objc public class AppIdentity : NSObject {
    @objc public static func deviceId() -> String? {
        if let mobileDeviceId = persistentId_legacy(), mobileDeviceId.count > 0 {
            return mobileDeviceId
        }

        // moving forward, use IDFV for mobile device id
        DDLogVerbose("returning IDFV")
        if let uuidString = UIDevice.current.identifierForVendor?.uuidString,
           let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return "\(uuidString)_\(bundleName)"
        }
        
        return nil
    }

    @objc public static func isLAT() -> Bool {
        let mgr = ASIdentifierManager.shared()
        if #available(iOS 14.5, *) {
            return !(ATTrackingManager.trackingAuthorizationStatus == .authorized) || !canTrack
        } else {
            return !mgr.isAdvertisingTrackingEnabled || !canTrack
        }
    }

    @objc public static func setCanTrack(tracking : Bool) {
        canTrack = tracking
    }

    fileprivate static func persistentId_legacy() -> String? {
        // Check in the keychain for an existing key but no longer create
        let PersistTag = "com.roku.devicetoken"
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: PersistTag,
                                    kSecAttrService as String: PersistTag,
                                    kSecReturnData as String: true]
        
        var dataRef : CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        if status == errSecSuccess, let data = dataRef as? Data {
            return String(data:data, encoding:.utf8)
        }
        
        // No pre-existing persistentId from this application, don't generate for new users
        return nil;
    }
}

