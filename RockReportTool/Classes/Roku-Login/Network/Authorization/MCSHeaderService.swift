//
//  MCSHeaderService.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import AdSupport
import CocoaLumberjack

// This class can be used to generate the headers used to talk to MCS
//      in an untethered mode.
// Additional headers in tethered mode can be generated using HeaderService.
public class MCSHeaderService {
    
#if os(iOS)
    static let ClientVersionHeaderOS = "ios"
#elseif os(tvOS)
    static let ClientVersionHeaderOS = "tvos"
#endif

    private var MobileClientAppHeader : String? {
        return "remote"
    }
    
    // This variable represents (in the Roku main app) what value to send for app=
    //      in x-roku-reserved-client-version header.
    // It is set in setClientVersionApp(), which is called by ReportingService.trackVisit().
    // In the TRC standalone app, this variable is ignored and trc-standalone is always sent.
    fileprivate static var clientVersionApp = "turing"

    static let ClientVersionHeaderVersion = "2.0"

    public func MCSHeaders(url: URL? = nil, method: HttpMethod<String>? = nil, body: String? = nil, clientApp: String? = nil) -> [String:String] {
        
        var headerFields = [String:String]()
        
        // if we have all the URL fields, add AWS credentials
        if let url = url, let method = method, let body = body {
            headerFields = awsHeaders(url: url, method: method, body: body)
        }
        
        headerFields["os"]              = MCSHeaderService.ClientVersionHeaderOS
        headerFields["version"]         = MCSHeaderService.ClientVersionHeaderVersion  //Newman
        if let app = MobileClientAppHeader {
            headerFields["app"]         = app
        }
        if let appVersion = Bundle.main.releaseVersionNumber {
            headerFields["appversion"]  = appVersion
        }
        headerFields["x-roku-reserved-client-id"] = AppIdentity.deviceId()
        headerFields["x-roku-reserved-client-version"] = MCSHeaderService.clientVersionHeader(clientApp: clientApp)

        headerFields["x-roku-reserved-culture-code"] = NSLocale.autoupdatingCurrent.identifier

        if let user = User.currentUser {
            if let userId = user.rokuUserId {
                headerFields["x-roku-reserved-user-id"] = userId
                headerFields["x-roku-reserved-account-id"] = userId
            }
            if let virtualUserId = user.virtualUserId {
                headerFields["x-roku-reserved-virtual-user-id"] = virtualUserId
            }
            if let channelStoreCode = user.channelStoreCode {
                headerFields["x-roku-reserved-channel-store-code"] = channelStoreCode
            }

            if let userSubscriptions = user.subscribedProviders, userSubscriptions.count > 0 {
                let providerIdsHeader = userSubscriptions.joined(separator: ",")
                headerFields["x-roku-reserved-providerProductIds"] = providerIdsHeader
            }
        }

        // profileId has a fallback to mobileDeviceId
        if let profileId = User.currentUser?.profileId ?? AppIdentity.deviceId() {
            headerFields["x-roku-reserved-profile-id"] = profileId
            headerFields["profile-id-is-uuid"] = User.currentUser?.profileId == nil ? "true" : "false"
        }

        headerFields["x-roku-reserved-time-zone-offset"] = timeZoneOffSet
        
        // only send mobile app's RIDA in other targets
        let asIdentifierManager = ASIdentifierManager.shared()
        headerFields["x-roku-reserved-rida"] = (AppIdentity.isLAT() ? asIdentifierManager.advertisingIdentifier.uuidString : "")
        headerFields["x-roku-reserved-lat"] = AppIdentity.isLAT() ? "true" : "false"
        headerFields["x-roku-reserved-correlation"] = "mob_\(UUID().uuidString)"

        return headerFields
    }
    
    public static func clientVersionHeader(clientApp: String? = nil) -> String {
        var header = "version=\(ClientVersionHeaderVersion), os=\(ClientVersionHeaderOS), platform=mobile, appversion=\(Bundle.main.releaseVersionNumber ?? "")"
        // prefer clientApp if explicitly passed
        header += ", app=\(clientApp ?? clientVersionApp)"
        return header
    }

    // called by ReportingService.trackVisit() to set app= value as user moves from tab to tab.
    public static func setClientVersionApp(clientVersionApp: String) {
        self.clientVersionApp = clientVersionApp
    }

    private func awsHeaders(url: URL, method: HttpMethod<String>, body: String) -> [String:String] {
        let awsHeaderService = AWSHeaderService(url: url, method: method, body: body)
        return awsHeaderService.awsHeaders()
    }

    private var timeZoneOffSet: String {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.dateFormat = "ZZZZZ"
        
        if let timeZoneIdentifier = UserDefaults.standard.string(forKey: UserDefaultsTimeZoneKey),
            let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            localTimeZoneFormatter.timeZone = timeZone
            return localTimeZoneFormatter.string(from: Date())
        }
        
        let timeZone = TimeZone.current
        localTimeZoneFormatter.timeZone = timeZone
        return localTimeZoneFormatter.string(from: Date())
    }
}

