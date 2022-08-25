//
//  CoreTypes.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import AWSCore

public typealias RokuTask = AWSTask
public typealias RokuTaskCompletionSource = AWSTaskCompletionSource

struct FailableType<Type: Decodable>: Decodable {
    let type: Type?
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.type = try container.decode(Type.self)
        } catch let error {
            addError(decoder, error: error)
            self.type = nil
        }
    }
}


struct DecodingContext {
    let jsonDecoder: JSONDecoder?
}


public class RokuError: Error {
    var reason: String?
    
    init(reason: String) {
        self.reason = reason
    }
    
    public var localizedDescription: String {
        get { return "\(String(describing: reason))" }
    }
}
