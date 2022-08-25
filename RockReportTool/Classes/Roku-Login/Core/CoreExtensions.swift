//
//  CoreExtensions.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import UIKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

protocol EnumCollection : Hashable {}
extension EnumCollection {
    static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}

extension String {
    func escapeCharacterData() -> String {
        return self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "'", with: "&apos;")
            .replacingOccurrences(of: "\"", with: "&quot;")
        
    }
    
    func unescapeCharacterData() -> String {
        return self.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    public func hexToStr() -> String {
        
        let regex = try! NSRegularExpression(pattern: "(0x)?([0-9A-Fa-f]{2})", options: .caseInsensitive)
        let textNS = self as NSString
        let matchesArray = regex.matches(in: textNS as String, options: [], range: NSMakeRange(0, textNS.length))
        let characters = matchesArray.map {
            Character(UnicodeScalar(UInt32(textNS.substring(with: $0.range(at: 2)), radix: 16)!)!)
        }
        
        return String(characters)
    }
    
    func appendStringWithSmartSpace(string: String?) -> String {
        guard let strongString = string else {
            return self
        }
        if self.isEmpty {
            return strongString
        } else if self.hasSuffix("\n") {
            return "\(self)\(strongString)"
        } else {
            return "\(self) \(strongString)"
        }
    }
    
    func replacingOccurrences(matchingPattern pattern: String, replacementProvider: (String) -> String?) -> String {
        let expression = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = expression.matches(in: self, options: [], range: NSRange(startIndex..<endIndex, in: self))
        return matches.reversed().reduce(into: self) { (current, result) in
            let range = Range(result.range, in: current)!
            let token = String(current[range])
            guard let replacement = replacementProvider(token) else { return }
            current.replaceSubrange(range, with: replacement)
        }
    }
    
    var isValidURL: Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
    
    func addingPercentEncodingForRFC3986() -> String? {
        /*
         https://www.ietf.org/rfc/rfc3986.txt
         2.3.  Unreserved Characters
         Characters that are allowed in a URI but do not have a reserved
         purpose are called unreserved.  These include uppercase and lowercase
         letters, decimal digits, hyphen, period, underscore, and tilde.
         
         unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"

         https://en.wikipedia.org/wiki/Percent-encoding
         https://developer.apple.com/documentation/foundation/nsurlcomponents/1407752-queryitems
         */
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }

}

extension UInt8 {
    func toBool() -> Bool {
        switch self {
        case 0x01:
            return true
        case 0x00:
            return false
        default:
            return false
        }
    }
}

extension URL {
    var pathNonDecoded : String {
        let urlString = absoluteString
        var pth = path
        if let host = host, let hostIndex = urlString.range(of: host) {
            // strip scheme and host
            let urlWithoutHost = String(urlString[hostIndex.upperBound...])
            pth = urlWithoutHost

            // strip query params
            if let queryIndex = urlWithoutHost.range(of: "?") {
                let endPathIndex = urlWithoutHost.index(before: queryIndex.lowerBound)
                pth = String(urlWithoutHost[urlWithoutHost.startIndex...endPathIndex])
            }
        }
        return pth
    }
}

extension URLSession {
    func synchronousDataTask(with urlRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

extension CodingUserInfoKey {
    static let trackerBeacon = CodingUserInfoKey(rawValue: "trackerBeacon")!
    static let contextKey = CodingUserInfoKey(rawValue: "context")!
    static let errorKey = CodingUserInfoKey(rawValue: "error")!
}

func addError(_ decoder: Decoder, error: Error) {
    if let jsonDecoder = decoder.context?.jsonDecoder {
        if var errors = jsonDecoder.errors {
            errors.append(error)
            jsonDecoder.errors = errors
        } else {
            jsonDecoder.errors = [error]
        }
    }
}

extension JSONDecoder {
    var errors: [Error]? {
        get { return userInfo[.errorKey] as? [Error] }
        set { userInfo[.errorKey] = newValue }
    }
    
    var context: DecodingContext? {
        get { return userInfo[.contextKey] as? DecodingContext }
        set { userInfo[.contextKey] = newValue }
    }
}

extension Decoder {
    var context: DecodingContext? { return userInfo[.contextKey] as? DecodingContext }
}

