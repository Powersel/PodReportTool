//
//  CoreRokuEnvironments.swift
//  Roku
//
//  Created by Harold Sun on 10/21/21.
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation

public enum RokuEnvironmentTier : Int {
    case production = 0
    case staging = 1
    case staging2 = 2
    case qa = 3
    case development = 4
    case local = 5
}

public class CoreRokuEnvironmentProvider {
    func environment(tier: RokuEnvironmentTier) -> CoreRokuEnvironments {
        return CoreRokuEnvironments(tier: tier)
    }
}

public class CoreRokuEnvironments {

    static private var provider = CoreRokuEnvironmentProvider()
    
    public let tier : RokuEnvironmentTier
    public let mobileMiddlewareTier : RokuEnvironmentTier
    
    private var traceServiceHost = "https://traces.sr.roku.com"
    
    public static var production : CoreRokuEnvironments {
        get { return provider.environment(tier: .production) }
    }
    public static var staging : CoreRokuEnvironments {
        get { return provider.environment(tier: .staging) }
    }
    public static var staging2 : CoreRokuEnvironments {
        get { return provider.environment(tier: .staging2) }
    }
    public static var qa : CoreRokuEnvironments {
        get { return provider.environment(tier: .qa) }
    }
    public static var development : CoreRokuEnvironments {
        get { return provider.environment(tier: .development) }
    }
    
    public convenience init(tier: RokuEnvironmentTier) {
        self.init(tier: tier, mobileMiddlewareTier : tier)
    }
    
    public init(tier: RokuEnvironmentTier, mobileMiddlewareTier: RokuEnvironmentTier) {
        self.tier = tier
        self.mobileMiddlewareTier = mobileMiddlewareTier
    }

    public var commonHeaders: [String: String] {
        return [
            "x-roku-reserved-dev-id": "1a2f5fd09622fd2b68be13fff92f09aebb6837fd",
            "x-roku-reserved-version": "999.99E99999X",
        ]
    }
    

    public var iotBackendUrls: String {
        switch self.mobileMiddlewareTier {
        case .local:
            return "http://127.0.0.1:3000"
        case .production:
            return "https://prod.mobile.roku.com/iot"
        case .staging:
            fallthrough
        case .staging2:
            fallthrough
        case .qa:
            return "https://qa.mobile.roku.com/iot"
        case .development:
            return "https://dev.mobile.roku.com/iot"
        }
    }
    
    public var mediationBackendUrls: String {
        switch self.mobileMiddlewareTier {
        case .local:
            return "http://127.0.0.1:3000"
        case .production:
            return "https://prod.mobile.roku.com"
        case .staging:
            fallthrough
        case .staging2:
            return "https://stg.mobile.roku.com"
        case .qa:
            return "https://qa.mobile.roku.com"
        case .development:
            return "https://dev.mobile.roku.com"
        }
    }
    
    var traceServiceURL: String {
        return traceServiceHost
    }
}
