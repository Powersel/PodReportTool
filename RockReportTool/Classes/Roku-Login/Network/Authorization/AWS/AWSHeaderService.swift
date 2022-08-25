//
//  AWSHeaderService.swift
//  Copyright © 2021 Roku. All rights reserved.
//

import Foundation
import CryptoSwift
import CocoaLumberjack

public class AWSHeaderService {

    let awsCredentialsProvider: AWSCredentialsProvider
    var awsHeadersValidator = AWSHeadersValidator()

    let url: URL
    let method: HttpMethod<String>
    let body: String
    
    fileprivate let hmacShaTypeString = "AWS4-HMAC-SHA256"
    fileprivate let awsRegion = "us-east-1"
    fileprivate let serviceType = "execute-api"
    fileprivate let aws4Request = "aws4_request"
    fileprivate let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmssXXXXX"
        return formatter
    }()
    
    public init(url: URL,
                method: HttpMethod<String>,
                body: String,
                awsCredentialsProvider: AWSCredentialsProvider = DefaultAWSCredentialsProvider(with: "")) {
        self.url = url
        self.method = method
        self.body = body
        self.awsCredentialsProvider = awsCredentialsProvider
    }

    public func awsHeaders() -> [String:String] {
        awsCredentialsProvider.prefetch()
        var headerFields = [String:String]()        
        let awsCredentials = awsCredentialsProvider.awsNonBlocking()
        let now = Date()
        let expiry = awsCredentials?.expiration ?? now
        if nil == awsCredentials || expiry < now {
            if let taskId = awsHeadersValidator.registerAWSTask(awsHeaderService: self) {
                DDLogVerbose("no AWS credentials or credentials expired, creating task \(taskId)")
                headerFields[AWSHeadersValidator.AWSHeadersPending] = taskId
            }
        }

        guard let secretSigningKey = awsCredentials?.secretKey else {
            return headerFields
        }
        guard let accessKeyId = awsCredentials?.accessKey else {
            return headerFields
        }
        let date = iso8601()
        guard let host = url.host else { return headerFields }
        
        if let sessionKey = awsCredentials?.sessionKey {
            headerFields["X-Amz-Security-Token"] = sessionKey
        }
        
        headerFields["Host"]            = host
        headerFields["X-Amz-Date"]      = date.full
        
        let signedHeaders = headerFields.map{ $0.key.lowercased() }.sorted().joined(separator: ";")
        let headers = headerFields.map { ($0.key.lowercased() + ":" + $0.value) }.sorted().joined(separator: "\n")

        var path = url.pathNonDecoded
        if let encodedPath = (path as NSString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            path = encodedPath
        }
        
        let queryParameters = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let sortedQueryParameters = queryParameters?.sorted(by: { (queryItem1, queryItem2) -> Bool in
            queryItem1.name < queryItem2.name
        })
        
        let rfc3986Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~="
        let rfc3986CharactersCharsSet: CharacterSet = CharacterSet(charactersIn: rfc3986Characters)
        
        let urlQuery = (sortedQueryParameters?.compactMap{ $0.description.addingPercentEncoding(withAllowedCharacters: rfc3986CharactersCharsSet) })?.joined(separator: "&")
        
        let canonicalRequestHash = [
            method.method,
            path,
            urlQuery ?? "",
            headers,
            "",
            signedHeaders,
            body.sha256()
            ].joined(separator: "\n").sha256()
        
        let awsRegion = "us-east-1"
        let serviceType = "execute-api"
        let aws4Request = "aws4_request"
        let hmacShaTypeString = "AWS4-HMAC-SHA256"
        let credential = [date.short, awsRegion, serviceType, aws4Request].joined(separator: "/")
        
        let stringToSign = [
            hmacShaTypeString,
            date.full,
            credential,
            canonicalRequestHash
            ].joined(separator: "\n")
        
        guard let signature = hmacStringToSign(stringToSign: stringToSign, secretSigningKey: secretSigningKey, shortDateString: date.short)
            else { return headerFields}
        
        let authorization = hmacShaTypeString + " Credential=" + accessKeyId + "/" + credential + ", SignedHeaders=" + signedHeaders + ", Signature=" + signature
        headerFields["Authorization"] = authorization
        return headerFields
    }
    
    fileprivate func iso8601() -> (full: String, short: String) {
        let date = iso8601Formatter.string(from: Date())
        let index = date.index(date.startIndex, offsetBy: 8)
        let shortDate = String(date[..<index])

        return (full: date, short: shortDate)
    }
    
    private func hmacStringToSign(stringToSign: String, secretSigningKey: String, shortDateString: String) -> String? {
        let k1 = "AWS4" + secretSigningKey
        guard let sk1 = try? HMAC(key: [UInt8](k1.utf8), variant: .sha256).authenticate([UInt8](shortDateString.utf8)),
            let sk2 = try? HMAC(key: sk1, variant: .sha256).authenticate([UInt8](awsRegion.utf8)),
            let sk3 = try? HMAC(key: sk2, variant: .sha256).authenticate([UInt8](serviceType.utf8)),
            let sk4 = try? HMAC(key: sk3, variant: .sha256).authenticate([UInt8](aws4Request.utf8)),
            let signature = try? HMAC(key: sk4, variant: .sha256).authenticate([UInt8](stringToSign.utf8)) else { return .none }
        return signature.toHexString()
    }

}
