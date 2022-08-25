//
//  TraceService.swift
//
//
//  Created by Ivan Kim on 3/28/19.
//

import Foundation
import SwiftyJSON

@objc public protocol TraceService_ObjC {
    func startServerSpan(operation: String)
    func startServerSpan(operation: String, spanTags: Dictionary<String, String>?)
    func forceClose()
    func unforcedCloseWithDelay(_ delay: Double)
}

public protocol TraceService: TraceService_ObjC {
    func createClientSpan(operation: String, url: String, method: String, spanTags: [String:String]) -> ClientSpan?
    func addClientSpan(clientSpan: ClientSpan)
    func closeClientSpan(clientSpan: ClientSpan, status: Int)
    func unforcedClose()
    func unforcedClose(withDelay: Double?)
    var traceId: String? { get }
}

protocol ClientSpanDelegate {
    func didCloseClientSpan()
}

public class ClientSpan {
    var parentSpanId: String
    var spanId: String
    var startTimestamp: Int64
    var endTimestamp: Int64?
    var operation: String
    var url: String
    var status: Int = 200
    var method: String
    var spanTags: Dictionary<String, String>?
    
    var delegate: ClientSpanDelegate?
    
    public init(parentSpanId: String, spanId: String, startTimestamp: Int64, operation: String, url: String, method: String, spanTags: Dictionary<String, String>? = nil) {
        self.parentSpanId = parentSpanId
        self.spanId = spanId
        self.startTimestamp = startTimestamp
        self.operation = operation
        self.url = url
        self.method = method
        self.spanTags = spanTags
    }
    
    public func close(endTimestamp: Int64, status: Int) {
        self.endTimestamp = endTimestamp
        self.status = status
        
        delegate?.didCloseClientSpan()
    }
    
    public func asJSON() -> JSON {
        var clientSpan = JSONDictionary()
        clientSpan["parentSpanId"] = self.parentSpanId
        clientSpan["spanId"] = self.spanId
        clientSpan["startTimestamp"] = self.startTimestamp
        clientSpan["endTimestamp"] = self.endTimestamp
        clientSpan["operation"] = self.operation
        clientSpan["url"] = self.url
        clientSpan["status"] = self.status
        clientSpan["method"] = self.method
        clientSpan["spanTags"] = self.spanTags
        
        return JSON(clientSpan)
    }
}

@objc public class DefaultTraceService: BaseService, TraceService, TraceService_ObjC, ClientSpanDelegate {
    
    fileprivate var clientSpans = [ClientSpan]()
    
    public var traceId: String?
    var serverSpanId: String?
    var serverStartTimestamp: Int64?
    var serverOperation: String?
    var serverSpanTags: Dictionary<String, String>?
    let serviceName = "mobile"
    fileprivate var allowClientSpans = false
    let clientSpansSerialQueue = DispatchQueue(label: "com.roku.feynman.ClientSpansSerialQueue")
    
    static func randomString(length: Int) -> String {
        let letters = "abcdef0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public func createClientSpan(operation: String, url: String, method: String, spanTags: [String:String]) -> ClientSpan? {
        return ClientSpan(parentSpanId: serverSpanId ?? "", spanId: DefaultTraceService.createSpanId(), startTimestamp: DefaultTraceService.currentTimestampMicroseconds(), operation: operation, url: url, method: method, spanTags: spanTags)
    }
    
    public static func createTraceId() -> String {
        return DefaultTraceService.randomString(length: 32)
    }
    
    public static func createSpanId() -> String {
        return DefaultTraceService.randomString(length: 16)
    }
    
    public static func currentTimestampMicroseconds() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000 * 1000)
    }

    @objc public func startServerSpan(operation: String) {
        startServerSpan(operation: operation, spanTags: nil)
    }
    
    @objc public func startServerSpan(operation: String, spanTags: Dictionary<String, String>?) {
        if traceId == nil {
            self.traceId = DefaultTraceService.createTraceId()
            self.serverSpanId = DefaultTraceService.createSpanId()
            self.serverStartTimestamp = DefaultTraceService.currentTimestampMicroseconds()
            self.serverOperation = operation
            self.serverSpanTags = spanTags
            
            self.allowClientSpans = true
        }
    }
    
    public func addClientSpan(clientSpan: ClientSpan) {
        if allowClientSpans && traceId != nil {
            clientSpan.delegate = self
            clientSpansSerialQueue.sync {
                self.clientSpans.append(clientSpan)
            }
        }
    }
    
    public func closeClientSpan(clientSpan: ClientSpan, status: Int) {
        clientSpan.close(endTimestamp: DefaultTraceService.currentTimestampMicroseconds(), status: status)
    }
    
    @objc public func unforcedCloseWithDelay(_ delay: Double) {
        self.unforcedClose(withDelay: delay)
    }

    public func unforcedClose() {
        unforcedClose(withDelay: nil)
    }
    
    public func unforcedClose(withDelay: Double? = nil) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + (withDelay ?? 1.5)) {
            self.allowClientSpans = false
        }
    }
    
    @objc public func forceClose() {
        self.allowClientSpans = false
        let unclosedSpans =  (clientSpans.filter { $0.endTimestamp == nil })
        for unclosedSpan in unclosedSpans {
            unclosedSpan.endTimestamp = DefaultTraceService.currentTimestampMicroseconds()
            unclosedSpan.status = 206
        }
        if traceId != nil {
            self.sendSpan()
        }
    }
    
    public func sendSpan() {
        
        guard let traceId = self.traceId else {
            return
        }
        let latestClientSpanEndtime = clientSpans.max { (first, second) -> Bool in
            first.endTimestamp ?? 0 < second.endTimestamp ?? 0
            }?.endTimestamp ?? DefaultTraceService.currentTimestampMicroseconds()
        
        var trace = JSONDictionary()
        trace["traceId"] = traceId
        trace["serviceName"] = "mobile"
        var traceJSON = JSON(trace)
        
        var serverSpan = JSONDictionary()
        serverSpan["spanId"] = self.serverSpanId ?? ""
        serverSpan["startTimestamp"] = self.serverStartTimestamp ?? 0
        serverSpan["endTimestamp"] = latestClientSpanEndtime
        serverSpan["operation"] = self.serverOperation ?? ""
        if let appVersion = Bundle.main.releaseVersionNumber {
            serverSpan["version"] = appVersion
        }
        if clientSpans.isEmpty {
            self.traceId = nil
            return
            //serverSpan["status"] = 500
            //serverSpanTags?["message"] = "Empty client spans"
        }
        if let serverSpanTags = self.serverSpanTags {
            serverSpan["spanTags"] = JSON(serverSpanTags)
        }
        
        let serverSpanJSON = JSON(serverSpan)
        
        traceJSON["serverSpan"] = serverSpanJSON
        
        traceJSON["clientSpans"] = JSON(clientSpans.map{ $0.asJSON() })
        
        if let json = traceJSON.rawString(.utf8, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let userToken = User.jwt {
            
            var headerFields = [String:String]()
            headerFields["Authorization"] = "Bearer \(userToken)"
            headerFields["x-roku-reserved-client-version"] = MCSHeaderService.clientVersionHeader()
            
            let _ = self.postRequest(url: User.rokuEnvironment.traceServiceURL, body: json, contentType: WebContentType.json, headers: headerFields, parseJson: false)
        }
        self.traceId = nil
        clientSpansSerialQueue.sync {
            self.clientSpans.removeAll()
        }
    }
    
    func didCloseClientSpan() {
        
        if traceId == nil {
            return
        }
        
        if allowClientSpans {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.5) {
                self.didCloseClientSpan()
            }
        } else if (clientSpans.filter { $0.endTimestamp == nil }).count == 0 {
            self.sendSpan()
        }
    }
}
