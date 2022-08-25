//
//  User+Injection.swift
//  Copyright © 2022 Roku. All rights reserved.
//

import Foundation

public class UserRegistrationService: RegistrationService {
    
    public var name : String { return "User" }
    
    public func registerServices() {
        let resolver = Resolver.main
        let cached = ResolverScope.cached
        resolver.register { AccountService() }.scope(cached)
        resolver.register { VirtualIdService() }.scope(cached)
        resolver.register { TokenService() }.scope(cached)

    }
}
