//
//  ReportToolIsseuClient.swift
//  RockReportTool
//
//  Created by Powersel on 15.07.2022.

import Foundation

import Foundation
import AVFoundation

public typealias IssueMediaUploadCompletion = (([IssueMediaUploadResponse]?) -> Void)

fileprivate typealias S3MediaUploadCompletion = (Bool?, Error?) -> ()

protocol RokuReportIssueProtocol {
    ///  Gets a response from Camino endpoint
    func createIssue(with payload: IssuePayload, completionHandler: @escaping (IssueResponse?, Error?) -> Void)

    ///  Send a media file to AWS bucket
    func uploadMedia(with issueResponse: IssueResponse,
                     mediaPayloads: IssueMediaPayloads,
                     completionHandler: @escaping IssueMediaUploadCompletion)
}

final class RokuReportIssueClient: NSObject {
    private struct PayloadMediaBody: Codable {
        let imageSize: Int?
        let videoSize: Int?
    }
    
    private struct PayloadBody: Codable {
        let issueId: String
        let serialNumber: String
        let deviceId: String
        let firmwareVersion: String
        let upTime: String
        let networkType: String
        let summary: String
        let description: String
        var media: PayloadMediaBody?
    }
    
    /// Represents name of custom background taks for ReportIssue networks queries
    private let backgroundTaskName = "Issue report uploading network tasks, has finished"
    
    /// Represents AVAudioPlayer object for background mode network uploads
    private var soundEffect: AVAudioPlayer?

    /// Represents task ID of UI background struct
    private var backgroundTaskID :UIBackgroundTaskIdentifier?
    
    private lazy var issueURLSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()
    
    private let awsCredentialsProvider: AWSCredentialsProvider
    private let endPointURL: String
    
    init(with poolID: String, endPointURL: String) {
        self.awsCredentialsProvider = DefaultAWSCredentialsProvider(with: poolID)
        self.awsCredentialsProvider.prefetch()
        self.endPointURL = endPointURL
    }
}

fileprivate func getIssueResource<A: Decodable>(_ url: URL,
                                                _ method: HttpMethod<String>,
                                                _ headerFields: [String: String]) -> URLResource<A> {
    
    return URLResource<A>(url: url, method: method, headerFields: headerFields, parse: { (data) -> A? in
        let decoder = JSONDecoder()
        decoder.context = DecodingContext(jsonDecoder: decoder)
        do {
            let response = try decoder.decode(IssueAPIResponse<A>.self, from: data)
            if let errors = decoder.userInfo[.errorKey] as? [Error],
               let error = errors.first as? IssueResponseError {
                /// This scenarion, happens when image or video file is larger then max size.
                /// 10MB for image and 100MB for video
                let errorResponse = IssueResponse(issueId: "",
                                             imagePayload: nil,
                                             videoPayload: nil,
                                             error: error)
                return errorResponse as? A
            } else if let errors = decoder.userInfo[.errorKey] as? [Error] {
                /// Processing of JSON parsing errors
//                try! processErrors(url.lastPathComponent, errors)
                print("Error")
                return nil
            } else {
                /// Succsess path
                return response.data
            }
        } catch let error {
            /// Processing of 4xx-5xx errors
//            try! processErrors(url.lastPathComponent, [error])
            print("Critical error")
            return nil
        }
    })
}

extension RokuReportIssueClient: RokuReportIssueProtocol {
    ///  Gets a response from Camino endpoint
    func createIssue(with payload: IssuePayload,
                     completionHandler: @escaping (IssueResponse?, Error?) -> Void) {
        
        guard let networkServiceURL = URL(string: endPointURL) else {
            return
        }
        
        var body = PayloadBody(issueId: payload.issueId,
                               serialNumber: payload.serialNumber,
                               deviceId: payload.deviceId,
                               firmwareVersion: payload.firmwareVersion,
                               upTime: payload.upTime,
                               networkType: payload.networkType,
                               summary: payload.summary,
                               description: payload.issueDescription)
        
        if !payload.mediaPayload.isEmpty {
            let mediaPayload = PayloadMediaBody(imageSize: payload.mediaPayload["imageSize"],
                                                videoSize: payload.mediaPayload["videoSize"])
            body.media = mediaPayload
        }
        
        guard let objectBody = try? JSONEncoder().encode(body),
              let jsonBody = String(data: objectBody, encoding: .utf8)
        else { return }
        
        var headerFields = AWSHeaderService(url: networkServiceURL,
                                            method: .post(jsonBody),
                                            body: jsonBody,
                                            awsCredentialsProvider: awsCredentialsProvider).awsHeaders()
        
        headerFields["Content-Length"] = "\(jsonBody.lengthOfBytes(using: .utf8))"
        headerFields["Content-Type"] = "application/json; charset=UTF-8"
        
        let resource: URLResource<IssueResponse> = getIssueResource(networkServiceURL, .post(jsonBody), headerFields)
        
        URLService().load(resource) { result in
            switch result {
            case .success(let responseData):
                completionHandler(responseData.data ,nil)
            case .failure(let error):
                completionHandler(nil ,error)
            }
        }
    }

    ///  Send a media file to AWS bucket
    func uploadMedia(with issueResponse: IssueResponse,
                     mediaPayloads: IssueMediaPayloads,
                     completionHandler: @escaping IssueMediaUploadCompletion) {
        
    }
}


private extension RokuReportIssueClient {
    /// Start listening of system notifications.
    func startListeners() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }

    /// Stop listening of system notifications
    func stopListeners() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.removeObserver(self,
                                          name: UIApplication.willEnterForegroundNotification,
                                          object: nil)

        notificationCenter.removeObserver(self,
                                          name: UIApplication.didEnterBackgroundNotification,
                                          object: nil)
    }

    /// When app goes to background state, whe start playing a "white noise" sound
    /// Thus, we can garantiue full upload of media files to S3.
    @objc func appMovedToBackground() {
        guard let path = Bundle.main.path(forResource: "silence.wav", ofType: nil) else {
                return
        }
        let url = URL(fileURLWithPath: path)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            soundEffect = try AVAudioPlayer(contentsOf: url)
            soundEffect?.volume = 0
            soundEffect?.numberOfLoops = -1
            soundEffect?.play()
        } catch {
            print(error.localizedDescription)
        }
    }

    // When app backs to foreground state, whe stop playing a "white noise" sound.
    @objc func appMovedToForeground() {
        soundEffect?.stop()
    }
}

/// Shows uploading progress of AWS query
extension RokuReportIssueClient: URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print("=== \(task.taskIdentifier) - \(progress)")
    }
}

final public class IssueAPIResponse<T: Decodable>: Decodable {
    public let apiVersion: String?
    public let data: T?
    public let error: IssueResponseError?
    
    private enum CodingKeys: String, CodingKey { case apiVersion, data, error }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(FailableType<T>.self, forKey: .data)?.type
        apiVersion = try container.decodeIfPresent(FailableType<String>.self, forKey: .apiVersion)?.type
        
        if let err = try container.decodeIfPresent(FailableType<IssueResponseError>.self, forKey: .error)?.type {
            error = err
        } else {
            self.error = nil
        }
    }
}

