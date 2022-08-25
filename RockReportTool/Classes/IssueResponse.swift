//
//  IssueResponse.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import Foundation

public struct IssueResponseError: Error, Decodable {
    public let title: String
    public let message: String
    public let code: Int
}

public protocol IssueMediaUploadResponse {
    var uploaded: Bool { get set }
    var error: Error? { get set }
    var action: ReportingEvent { get }
}

public struct ImageMediaUploadResponse: IssueMediaUploadResponse {
    public var uploaded: Bool
    public var error: Error?
    public let action = ReportingEvent.actionImageUpload
}

public struct VideoMediaUploadResponse: IssueMediaUploadResponse {
    public var uploaded: Bool
    public var error: Error?
    public let action = ReportingEvent.actionVideoUpload
}

@objc public class IssueResponse: NSObject, Decodable {
    @objc public let issueId: String
    @objc public let imageUploadUrl: IssueAWSPresingedPayload?
    @objc public let videoUploadUrl: IssueAWSPresingedPayload?

    public let error: IssueResponseError?
    
    public init(
        issueId: String,
        imagePayload: IssueAWSPresingedPayload?,
        videoPayload: IssueAWSPresingedPayload?,
        error: IssueResponseError?
    ) {
        self.issueId = issueId
        self.imageUploadUrl = imagePayload
        self.videoUploadUrl = videoPayload
        self.error = error
    }
    
    public func getAWSPresingedPayload(with key: String) -> IssueAWSPresingedPayload? {
        let isPhotoPayload = key == "photo"
        return isPhotoPayload ? imageUploadUrl : videoUploadUrl
    }
}

