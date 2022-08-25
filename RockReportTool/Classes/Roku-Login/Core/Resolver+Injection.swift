//
//  Resolver+Injection.swift
//  Copyright © 2022 Roku. All rights reserved.
//

import Foundation

@objc public protocol RegistrationService {
    var name: String { get }
    func registerServices()
}

fileprivate var additionalRegistrations = [ RegistrationService ]()

extension Resolver: ResolverRegistering, Synchronizable {
    public static func registerAllServices() {
        main.registerAdditionalServices()
    }

    @objc public static func addServiceRegistrationBlock(regService: RegistrationService) {
        print("adding \(regService.self)")
        additionalRegistrations.append(regService)
    }
    
    internal func registerAdditionalServices() {
        for service in additionalRegistrations {
            print("registering services from \(service.name)")
            service.registerServices()
        }
    }
    
}
