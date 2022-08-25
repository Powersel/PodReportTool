//
//  Network+Injection.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import AWSAuthCore

class NetworkRegistrationService: RegistrationService {
    public var name : String { return "Network" }
    
    public func registerServices() {
        let resolver = Resolver.main
        let cached = ResolverScope.cached
        
        // please keep alphabetical by protocol name
        resolver.register { AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId:"") }.scope(cached)
//        resolver.register { DefaultAWSCredentialsProvider() as AWSCredentialsProvider }.scope(cached)

        resolver.register { AWSHeadersValidator() }.scope(cached)
        resolver.register { () -> HeadersValidator in
            // this is so that we return same instance for AWSHeadersValidator and HeadersValidator
            let awsValidator : AWSHeadersValidator = resolver.resolve()
            return awsValidator
        }.scope(cached)

        resolver.register { MCSHeaderService() }.scope(cached)
        resolver.register { CoreRokuEnvironmentProvider() as CoreRokuEnvironmentProvider }.scope(cached)
        resolver.register { CoreSharedURLSessionProvider() as SharedURLSessionProvider }.scope(cached)
        resolver.register { DefaultTraceService() as TraceService }.scope(cached)
        resolver.register { () -> TraceService_ObjC in
            // this is so that we return same instance for TraceService and TraceService_ObjC
            let service : TraceService = resolver.resolve()
            return service
        }.scope(cached)

        resolver.register { URLService() }

    }
}

