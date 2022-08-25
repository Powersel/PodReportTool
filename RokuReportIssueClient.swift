//
//  RokuReportIssueClient.swift
//  RockReportTool
//
//  Created by Sergiy Shevchuk on 28.07.2022.
//

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
    
    
}

extension RokuReportIssueClient: RokuReportIssueProtocol {
    ///  Gets a response from Camino endpoint
    func createIssue(with payload: IssuePayload, completionHandler: @escaping (IssueResponse?, Error?) -> Void) {
        let QAIssueReportEndpoint = "https://qa.mobile.roku.com/camino/issuesvc/issue"
        let tmpURL = URL(string: QAIssueReportEndpoint)
        
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
//        let notificationCenter = NotificationCenter.default
//
//        notificationCenter.addObserver(self,
//                                       selector: #selector(appMovedToBackground),
//                                       name: UIApplication.didEnterBackgroundNotification,
//                                       object: nil)
//
//        notificationCenter.addObserver(self,
//                                       selector: #selector(appMovedToForeground),
//                                       name: UIApplication.willEnterForegroundNotification,
//                                       object: nil)
    }

    /// Stop listening of system notifications
    func stopListeners() {
//        let notificationCenter = NotificationCenter.default
//
//        notificationCenter.removeObserver(self,
//                                          name: UIApplication.willEnterForegroundNotification,
//                                          object: nil)
//
//        notificationCenter.removeObserver(self,
//                                          name: UIApplication.didEnterBackgroundNotification,
//                                          object: nil)
    }

    /// When app goes to background state, whe start playing a "white noise" sound
    /// Thus, we can garantiue full upload of media files to S3.
//    @objc func appMovedToBackground() {
//        guard let path = Bundle.main.path(forResource: "silence.wav", ofType: nil) else {
//                return
//        }
//        let url = URL(fileURLWithPath: path)
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            soundEffect = try AVAudioPlayer(contentsOf: url)
//            soundEffect?.volume = 0
//            soundEffect?.numberOfLoops = -1
//            soundEffect?.play()
//        } catch {
//            DDLogError(error.localizedDescription)
//        }
//    }

    /// When app backs to foreground state, whe stop playing a "white noise" sound.
//    @objc func appMovedToForeground() {
//        soundEffect?.stop()
//    }
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
