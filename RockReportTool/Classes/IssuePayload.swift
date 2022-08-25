//
//  IssuePayload.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import Foundation

public enum IssueMediaPayloadType: String {
    case photo = "photo"
    case video = "video"
}

public struct IssueMediaPayload {
    let data: Data
    let fileExtension: String
    let type: IssueMediaPayloadType
}
 
public struct IssueMediaPayloads {
    let photo: IssueMediaPayload?
    let video: IssueMediaPayload?
    let payloads: [IssueMediaPayloadType: IssueMediaPayload]
    
    public init(with photoPayload: IssueMediaPayload?, videoPayload: IssueMediaPayload?) {
        self.photo = photoPayload
        self.video = videoPayload
        var payloads: [IssueMediaPayloadType: IssueMediaPayload] = [:]
        if let _photo = photoPayload {
            payloads.updateValue(_photo,
                                 forKey: .photo)
        }
        if let _video = videoPayload {
            payloads.updateValue(_video,
                                 forKey: .video)
        }
        self.payloads = payloads
    }
}

@objc public class IssueAWSPresingedPayload: NSObject, Decodable {
    let url: String
    let fields: [String: String]

    init(url: String, fields: [String: String]) {
        self.url = url
        self.fields = fields
    }
}

@objc public class IssuePayload: NSObject {
    let issueId: String
    let serialNumber: String
    let deviceId: String
    let firmwareVersion: String
    let upTime: String
    let networkType: String
    let summary: String
    let issueDescription: String
    var mediaPayload: [String: Int]
    
    init(issueId: String,
         serialNumber: String,
         deviceID: String,
         firmwareVersion: String,
         uptime: String,
         networkType: String,
         summary: String,
         issueDescription: String,
         mediaPayload: IssueMediaPayloads) {
        
        self.issueId = issueId
        self.serialNumber = serialNumber
        self.deviceId = deviceID
        
        self.firmwareVersion = firmwareVersion
        
        self.upTime = uptime
        self.networkType = networkType
        
        self.summary = summary
        self.issueDescription = issueDescription
        
        self.mediaPayload = [:]
        
        if let imageData = mediaPayload.photo?.data {
            self.mediaPayload.updateValue(imageData.count, forKey: "imageSize")
        }
        
        if let videoData = mediaPayload.video?.data {
            self.mediaPayload.updateValue(videoData.count, forKey: "videoSize")
        }
    }
}
