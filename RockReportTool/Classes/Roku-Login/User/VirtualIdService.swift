//
//  VirtualIdService.swift
//
//  Created by Harold Sun on 2/5/20.
//

import UIKit
import CocoaLumberjack

public class VirtualIdService: Resolving {

    public func getVirtualAccountId(accountId : String) -> RokuTask<NSString>? {
        let completionSource = RokuTaskCompletionSource<NSString>()
        guard let configResource = userResource(accountId : accountId) else {
            print("Error: Cannot create userResource ")
            return nil
        }
        let urlService : URLService = resolver.resolve()
        urlService.load(configResource).continueWith { (task) in
            if let error = task.error {
                completionSource.set(error: FeynmanError(reason: error.localizedDescription))
            }
            else if let result = (task.result?.object as? URLResultResponse<String?>)?.data {
                completionSource.set(result: result as NSString)
            }
            else {
                completionSource.set(error: FeynmanError(reason: "virtual id result was not found or of expected type"))
            }
        }
        return completionSource.task
    }
    
    fileprivate func userResource(accountId : String) -> URLResource<String?>? {
        guard let url = URL(string: "\(User.rokuEnvironment.mediationBackendUrls)/camino/usersvc/users/${account_id}/virtualuser".replacingOccurrences(of: "${account_id}", with: accountId)) else {
            print("Invalid url")
            return nil
        }

        var headerFields = AWSHeaderService(url: url, method: .get, body: "").awsHeaders()
        if User.rokuEnvironment.tier == .qa {
            headerFields["apiweb-env"] = "staging"
        }

        return try? URLResource<String?>(url: url, method: .get, headerFields: headerFields, parseJson: { (json) -> String? in
            
            guard let dictionary = json as? JSONDictionary else {
                print("Error: Unable to cast json to dictionary")
                return nil
            }
            guard let data = dictionary["data"] as? [String: Any] else {
                print("Error: data not found")
                return nil
            }
            if let virtualAccountId = data["virtualUserId"] as? String {
                return virtualAccountId
            }
            return nil
        })
    }

}

