//
//  URLResource.swift
//  Copyright © 2018 Roku Inc. All rights reserved.
//

import UIKit
import SWXMLHash

public class ResourceError: Error {
    public init() {}
    public var localizedDescription: String {
        get { return "Resource not available" }
    }
}

public class URLResource <T> {
    public var url: URL
    public var method: HttpMethod<Data> = .get
    public var headerFields: [String: String] = [:]
    public var parse: (Data) -> T?
    public var memCache: URLMemCache?
    public var timeout: TimeInterval = 60
    public var useCache: Bool = true
    public var disableRedirects: Bool = false
    
    public init(url: URL, headerFields: [String: String], parse: @escaping (Data) -> T?) {
        self.url    = url
        self.method = .get
        self.headerFields = headerFields
        self.parse = parse
    }

    public convenience init(url: URL, parseImage: @escaping (UIImage) -> T?) {
        self.init(url: url, isWebP: false, imageScale: 1.0, parseImage: parseImage)
    }
    
    public convenience init(url: URL, imageScale: CGFloat, parseImage: @escaping (UIImage) -> T?) {
        self.init(url: url, isWebP: false, imageScale: imageScale, parseImage: parseImage)
    }

    public convenience init(url: URL, isWebP: Bool, parseImage: @escaping (UIImage) -> T?) {
        self.init(url: url, isWebP: isWebP, imageScale: 1.0, parseImage: parseImage)
    }
    
    public init(url: URL, isWebP: Bool, imageScale: CGFloat, imageHeight: CGFloat? = nil, debug: Bool = false, parseImage: @escaping (UIImage) -> T?) {
        var newURL = url
        // if we are passed an explicit height, rewrite the magic URL to
        //     get the image height we want, at the scale we want
        // if the rewrite fails, then we will use the original URL
        var resizedHeight : Int?
        if let height = imageHeight {
            let height = Int(height * imageScale)
            resizedHeight = height
            if let magicUrl = URLResource.resized(magicImgUrl: url, height: height) {
                newURL = magicUrl
            }
        }

        self.url = newURL
        self.method = .get
        self.headerFields = [:]

        self.parse = { data in
            var image : UIImage?
            
            if isWebP {
                // on iOS 14+, use built in webP decoding
                if #available(iOS 14.0, *) {
                    image = UIImage(data:data)
                }
                else {
                    // not sure what to do in other targets that don't contain UIImageWebP.  Just comment or #if this out?
                    //image = UIImageWebP.image(fromWebPData: data, imageScale: imageScale)
                }
            }
            else {
                image = UIImage(data: data, scale: imageScale)
            }
            if let img = image {
                return parseImage(img)
            }
            else {
                return nil
            }
        }
        
        if debug {
            debugPrint("XXXXXXXXXXXXXX IMAGE RESOURCE XXXXXXXXXXXXXX")
            debugPrint("URL             :\(url)")
            debugPrint("RewrittenURL    :\(newURL)")
            debugPrint("isWebP          : \(isWebP)")
            debugPrint("imageScale      : \(imageScale)")
            debugPrint("imageheight     : \(String(describing: imageHeight))")
            debugPrint("resizedHeight   : \(String(describing: resizedHeight))")
            debugPrint("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        }
        
        self.memCache = URLImageCache.shared
        
    }
    
    private static func resized(magicImgUrl url: URL, height : Int) -> URL? {
        let urlString : String = url.absoluteString
        if let sizeRange = urlString.range(of: "magic/0x") {
            let after = urlString[sizeRange.upperBound..<urlString.endIndex]
            if let endIndex = after.firstIndex(of: "/") {
                let newUrl = urlString.replacingCharacters(in: sizeRange.lowerBound..<endIndex, with: "magic/0x\(height)")
                return URL(string: newUrl)
            }
        }
        return nil
    }    
    
    public init(url: URL, parseJSON: @escaping (Any) -> T?) {
        self.url = url
        self.method = .get
        self.headerFields = [:]
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
            return json.flatMap(parseJSON)
        }
    }
    
    public init(url: URL, methodData: HttpMethod<Data>, headerFields: [String: String], parseHeaders: @escaping (Any) -> T? ) {
        self.url = url
        self.headerFields = headerFields
        
        switch methodData {
        case .get:
            self.method = .get
        case .post(let body):
            self.method = .post(body)
        case .put(let body):
            self.method = .put(body)
        case .delete(let body):
            self.method = .delete(body)
        case .patch(let body):
            self.method = .patch(body)
        }
        
        self.parse = { data in
            do {
                guard data.count > 0 else {
                    return nil
                }
                
                let headers = (try PropertyListSerialization.propertyList(from: data, options: [], format: nil))
                return parseHeaders(headers)
            } catch let error {
                print("error: \(error)")
                return nil
            }
        }
    }
    
    public init(url: URL, method: HttpMethod<String>, headerFields: [String: String], parseHeaders: @escaping (Any) -> T? ) {
        self.url = url
        self.headerFields = headerFields
        
        switch method {
        case .get:
            self.method = .get
        case .post(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .post(bodyData!)
        case .put(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .put(bodyData!)
        case .delete(let body):
            let bodyData = body?.data(using: .utf8)
            self.method = .delete(bodyData)
        case .patch(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .patch(bodyData!)
        }
        
        self.parse = { data in
            do {
                guard data.count > 0 else {
                    return nil
                }
                
                let headers = (try PropertyListSerialization.propertyList(from: data, options: [], format: nil))
                return parseHeaders(headers)
            } catch let error {
                print("error: \(error)")
                return nil
            }
        }
    }
    
    public init(url: URL, methodData: HttpMethod<Data>, headerFields: [String: String], parseData: @escaping (Any) -> T?) throws {
        self.url = url
        self.headerFields = headerFields
        
        switch methodData {
        case .get:
            self.method = .get
        case .post(let body):
            self.method = .post(body)
        case .put(let body):
            self.method = .put(body)
        case .delete(let body):
            self.method = .delete(body)
        case .patch(let body):
            self.method = .patch(body)
        }
        
        self.parse = { data in
            return parseData(data)
        }
    }
    
    public init(url: URL, methodData: HttpMethod<Data>, headerFields: [String: String], parseJson: @escaping (Any) -> T?) throws {
        self.url = url
        self.headerFields = headerFields
        
        switch methodData {
        case .get:
            self.method = .get
        case .post(let body):
            self.method = .post(body)
        case .put(let body):
            self.method = .put(body)
        case .delete(let body):
            self.method = .delete(body)
        case .patch(let body):
            self.method = .patch(body)
        }
        
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                return parseJson(json)
            } catch let error {
                print("json error: \(error)")
                return nil
            }
        }
    }
    
    public init(url: URL, method: HttpMethod<String>, headerFields: [String: String], parse: @escaping (Data) -> T?) {
        self.url    = url
        switch method {
            case .get:
                self.method = .get
            case .post(let body):
                let bodyData = body.data(using: .utf8)
                self.method = .post(bodyData!)
            case .put(let body):
                let bodyData = body.data(using: .utf8)
                self.method = .put(bodyData!)
            case .delete(let body):
                let bodyData = body?.data(using: .utf8)
                self.method = .delete(bodyData)
            case .patch(let body):
                let bodyData = body.data(using: .utf8)
                self.method = .patch(bodyData!)
        }

        self.headerFields = headerFields
        self.parse = parse
    }

    public init(url: URL, method: HttpMethod<String>, headerFields: [String: String], parseJson: @escaping (Any) -> T?) throws {
        self.url = url
        self.headerFields = headerFields
        
        switch method {
        case .get:
            self.method = .get
        case .post(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .post(bodyData!)
        case .put(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .put(bodyData!)
        case .delete(let body):
            let bodyData = body?.data(using: .utf8)
            self.method = .delete(bodyData)
        case .patch(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .patch(bodyData!)
        }
        
        self.parse = { data in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                return parseJson(json)
            } catch let error {
                print("json error: \(error)")
                return nil
            }
        }
    }
    
    public init(url: URL, method: HttpMethod<String>, headerFields: [String: String], parseXml: @escaping (XMLIndexer) -> T?) {
        self.url = url
        self.headerFields = headerFields
        
        switch method {
        case .get:
            self.method = .get
        case .post(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .post(bodyData!)
        case .put(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .put(bodyData!)
        case .delete(let body):
            let bodyData = body?.data(using: .utf8)
            self.method = .delete(bodyData)
        case .patch(let body):
            let bodyData = body.data(using: .utf8)
            self.method = .patch(bodyData!)
        }
        
        self.parse = { data in
            let xml = XMLHash.parse(data)
            return parseXml(xml)
        }
    }
    
}

extension URLResource {
    
    public func store<T>(object: T) {
        memCache?.store(key: self.url.absoluteString, object: object)
    }
    
    public func retrieve<T>() -> T? {
        return memCache?.retrieve(self.url.absoluteString)
    }
    
}
