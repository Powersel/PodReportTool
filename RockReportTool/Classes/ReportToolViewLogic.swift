//
//  ReportToolViewLogic.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import Foundation
import AVFoundation
import UIKit

public final class ReportToolViewLogic: NSObject {
    
    private let titleFieldID = "reportTitleField"
    private let titleDefaultText = "     What happened?*"
    private let desctiptionFieldID = "reportDescriptionField"
    private let desctiptionDefaultText = "     How did it happen?*"
    private let textFieldTextDefaulrColor = UIColor.hexStringToUIColor(hex: "#7D7D7D")
    
    private let analyticsCategoryKey = "ReportIssue"
    private let analyticsSubcategoryFailed  = "Failed "
    private let analyticsSubcategorySuccess = "Success"
    
    private var summaryFieldText = ""
    private var descriptionFieldText = ""
    
    private let titleMaxLength: Int = 160
    private let descriptionMaxLength: Int = 3000
    private let defaultVideoLength = 60.0 // Seconds
    
//    private var issueID: String = "AAAA"
    private var photoImage: UIImage?
    
    private var videoURL: URL?
    private var videoData: Data?
    private var screenshotImage: UIImage?
    
    // Discuss netwok layer with Nishant
    // private let issueClient = IssueClient()
    private let issueClient: RokuReportIssueProtocol
    
    weak var delegate: RokuReportToolViewLogicProtocol?
    weak var toastDelegate: RokuReportToolToastDelegate?
        
    public init(poolID: String, endPointURL: String) {
        self.issueClient = RokuReportIssueClient(with: poolID, endPointURL: endPointURL)
    }
    
    // MARK: - Public
    
    func sendReport() {
        if isTextViewsFilled()  {
            delegate?.showDialogView(with: .emptyTextFields)
        } else {
            _ = videoURL != nil ? checkVideoLength() : sendRequest()
        }
    }
    
    func sendMediaFiles() {
        if let _videoURL = videoURL {
            self.delegate?.showSpinnerView()
            DispatchQueue.global(qos: .background).async {
                self.trimmVideo(with: _videoURL)
            }
        }
    }
    
    func clearPhotoCache() {
        photoImage = nil
    }
    
    func clearVideoCache() {
        if let _videoURL = videoURL {
            let manager = FileManager.default
            _ = try? manager.removeItem(at: _videoURL)
        }
        videoURL = nil
    }
    
    func clearTemporaryFiles() {
        guard let folderPath = temporaryFilesFolder() else { return }
        let fileManager = FileManager.default
        do {
            let filePaths = try fileManager.subpaths(atPath: folderPath.path)
            if let _filePaths = filePaths {
                for filePath in _filePaths {
                    try fileManager.removeItem(atPath: folderPath.path + "/" + filePath)
                }
            }
        } catch let error {
            let message = "--->Temporary files removing error \(error.localizedDescription)"
            print(message)
        }
    }
    
    // MARK: - Private
    
    private func showCameraSelectionController() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let newPhotoActionTitle = NSLocalizedString("Take new photo",
                                                    comment:"Take new photo button title, in Issue report screen")
        alert.addAction(UIAlertAction(title: newPhotoActionTitle,
                                      style: .default,
                                      handler: { _ in
            self.cameraAuthorizationRequest(with: .photo)
        }))
        
        let callLibraryTitle = NSLocalizedString("Choose from Photo Library",
                                                 comment:"PhotoLibrary button title, in Issue report screen")
        alert.addAction(UIAlertAction(title: callLibraryTitle,
                                      style: .default,
                                      handler: { _ in
            self.presentGalerry(with: .photo)
        }))
        
        let canceButtonlTitle = NSLocalizedString("Cancel",
                                                  comment:"Cancel button Photo title, in Issue report screen")
        alert.addAction(UIAlertAction.init(title: canceButtonlTitle,
                                           style: .cancel,
                                           handler: nil))
        
        delegate?.presentController(controller: alert)
    }
    
    private func showVideoSelectionController() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let newVideoActionTitle = NSLocalizedString("Take new video",
                                                    comment:"Take new video button title, in Issue report screen")
        alert.addAction(UIAlertAction(title: newVideoActionTitle,
                                      style: .default,
                                      handler: { _ in
            self.cameraAuthorizationRequest(with: .video)
        }))
        
        let callLibraryTitle = NSLocalizedString("Choose from Video Library",
                                                 comment:"VideoLibrary button title, in Issue report screen")
        alert.addAction(UIAlertAction(title: callLibraryTitle,
                                      style: .default,
                                      handler: { _ in
            self.presentGalerry(with: .video)
        }))
        
        let canceButtonlTitle = NSLocalizedString("Cancel",
                                                  comment:"Cancel button Video title, in Issue report screen")
        alert.addAction(UIAlertAction.init(title: canceButtonlTitle,
                                           style: .cancel,
                                           handler: nil))
        
        delegate?.presentController(controller: alert)
    }
    
    private func cameraAuthorizationRequest(with type: ReportToolMediaType) {
        
        // Intentionally not adding default case so in the future if this changes we want this to be catch this error during compile time and handle it appropriately.
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentMediaController(with: type)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.presentMediaController(with: type)
                } else {
                    self.delegate?.showDialogView(with: .cameraAccessRestriction)
                }
            }
        case .denied, .restricted:
            delegate?.showDialogView(with: .cameraAccessRestriction)
        }
    }
    
    private func presentMediaController(with type: ReportToolMediaType) {
        switch type {
        case .photo:
            self.presentPhotoCameraController()
        case .video:
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted:
                self.presentVideoCameraController()
            case .denied:
                delegate?.showDialogView(with: .microphoneAccessRestriction)
            case .undetermined:
                session.requestRecordPermission({(granted: Bool)-> Void in
                    if granted {
                        self.presentVideoCameraController()
                    } else{
                        self.delegate?.showDialogView(with: .microphoneAccessRestriction)
                    }
                })
            }
        }
    }
    
    private func presentPhotoCameraController() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        picker.mediaTypes = [ReportToolMediaType.photo.rawValue]
        configureImagePicker(with: picker)
    }
    
    private func presentVideoCameraController() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [ReportToolMediaType.video.rawValue]
        picker.cameraCaptureMode = .video
        picker.cameraDevice = .rear
        picker.videoQuality = .typeHigh
        picker.allowsEditing = false
        picker.delegate = self
        delegate?.presentController(controller: picker)
    }
    
    private func presentGalerry(with type: ReportToolMediaType) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        let mediaTypes = type == .photo ? [ReportToolMediaType.photo.rawValue] : [ReportToolMediaType.video.rawValue]
        picker.mediaTypes = mediaTypes
        configureImagePicker(with: picker)
    }
    
    private func configureImagePicker(with picker: UIImagePickerController) {
        picker.allowsEditing = false
        picker.delegate = self
        delegate?.presentController(controller: picker)
    }
    
    private func trimmVideo(with fileURL: URL) {
        let asset = AVAsset(url: fileURL as URL)
        let videoLength = asset.duration.seconds
        let startPoint = videoLength < defaultVideoLength ? 0.0 : videoLength - defaultVideoLength
        
        guard var outputURL = temporaryFilesFolder() else { return }
        
        let manager = FileManager.default
        let mediaType = fileURL.pathExtension
        
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).\(mediaType)")
        } catch let error {
            handleVideoErrorState(with: error)
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset,
                                                       presetName: AVAssetExportPresetHighestQuality) else {
            delegate?.hideSpinnerView()
            delegate?.unlockSendButtonUserInteraction()
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let leftEdge = CMTime(seconds: Double(startPoint), preferredTimescale: 1000)
        let rightEdge = CMTime(seconds: Double(videoLength), preferredTimescale: 1000)
        let clipRange = CMTimeRange(start: leftEdge, end: rightEdge)
        
        exportSession.timeRange = clipRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                self.sendTrimmedVideo(with: outputURL)
            default:
                print("failed-cancelled \(String(describing: exportSession.error))")
                self.delegate?.hideSpinnerView()
                self.delegate?.unlockSendButtonUserInteraction()
                break
            }
        }
    }
    
    private func temporaryFilesFolder() -> URL? {
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
        return documentDirectory.appendingPathComponent("issueIDVideoAssets")
    }
    
    private func processVideo(with outputURL: URL) {
        videoURL = outputURL
        if let thumbNail = videoPreview(at: outputURL) {
            delegate?.showThumbnail(with: .video, image: thumbNail)
        }
    }
    
    private func videoPreview(at url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 5)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch _ as NSError {
            // Skip it
            return nil
        }
    }
    
    private func checkVideoLength() {
        guard let _videoURL = videoURL else { return }
        let asset = AVAsset(url: _videoURL)
        let time = asset.duration
        _ = time.seconds > 60.0 ? delegate?.showDialogView(with: .trimmVideo) : sendRequest()
    }
    
    private func isTextViewsFilled() -> Bool {
        let summaryText = delegate?.getSummaryText() ?? ""
        let isSummaryEmpty: Bool = delegate?.getSummaryText().count ?? 0 >= 1
        let isDefaultSummary = summaryText == titleDefaultText
        let isSummaryTextExists = isSummaryEmpty && !isDefaultSummary
        
        let descriptionText = delegate?.getDescriptionText() ?? ""
        let isDescriptionEmpty: Bool = delegate?.getDescriptionText().count ?? 0 >= 1
        let isDefaultDescription = descriptionText == desctiptionDefaultText
        let isDescriptionTextExists = isDescriptionEmpty && !isDefaultDescription
        
        let isFilled = isSummaryTextExists && isDescriptionTextExists
        
        _ = !isFilled ? delegate?.disableSendButton() : delegate?.enableSendButton()
        return !isFilled
    }
    
    // MAKR: - User UI notifications
    
    private func showSuccessToast(with issuePayload: IssuePayload) {
        trackIssueCreationSuccess(with: issuePayload)
        delegate?.hideSpinnerView()
        delegate?.showDialogView(with: .reportHasBeenSent)
    }
    
    // MARK: - Network layer
    
    func sendTrimmedVideo(with url: URL) {
        do {
            videoData = try Data(contentsOf: url)
            videoURL = url
            sendRequest()
        } catch let error {
            handleVideoErrorState(with: error)
        }
    }
    
    private func sendRequest() {
        delegate?.showSpinnerView()
        
        let imagePayload = getImageDataPayload(with: photoImage)
        let videoPayload = getVideoDataPayload(with: videoURL)
        
        let mediaPayload = IssueMediaPayloads(with: imagePayload,
                                              videoPayload: videoPayload)
        
        // This is a test data!
        
        let payload = IssuePayload(issueId: "8X-306-017",
                                   serialNumber: "X01000PM0W8X",
                                   deviceID: "S02A20DM0W8X",
                                   firmwareVersion: "11.5.0.4106",
                                   uptime: "32227",
                                   networkType: "wifi",
                                   summary: "A",
                                   issueDescription: "A",
                                   mediaPayload: mediaPayload)
        
        sendIssue(with: payload, mediaPayload: mediaPayload)
    }
    
    private func sendIssue(with payload: IssuePayload,
                           mediaPayload: IssueMediaPayloads) {
        
        issueClient.createIssue(with: payload) { issue, error in
            if let _ = error as? URLServiceError {
                // Handling 4xx-5xx errors
                self.handleErrorState(payload: payload)
            } else if let issueResponse = issue {
                if let error = issueResponse.error {
                    self.handleUserError(with: error, payload: payload)
                } else if issueResponse.imageUploadUrl == nil &&
                            issueResponse.videoUploadUrl == nil {
                    // This scenario says that issue does not have media to upload
                    // That's why we should present succsess toast
                    self.showSuccessToast(with: payload)
                } else {
                    // This scenario says that issue has some media to upload
                    self.uploadIssueMedia(witn: issueResponse,
                                          issuePayload: payload,
                                          mediaPayload: mediaPayload)
                }
            }
        }
        
//        issueClient.createIssue(with: payload) { issue, error in
//            if let networkError = error {
//                print(networkError)
//            } else if let issueResponse = issue {
//                print(issueResponse)
//            } else {
//                print("Upload media data")
//            }
//        }
    }
    
    private func uploadIssueMedia(witn issueResponse: IssueResponse,
                                  issuePayload: IssuePayload,
                                  mediaPayload: IssueMediaPayloads) {
        //        issueClient.uploadMedia(with: issueResponse,
        //                                mediaPayloads: mediaPayload) { mediaUploadResponse in
        //
        //            guard let mediaUploadResponse = mediaUploadResponse else {
        //                self.handleErrorState(payload: issuePayload)
        //                return
        //            }
        //
        //            var responseError: Error? = nil
        //
        //            mediaUploadResponse.forEach { response in
        //                if let error = response.error {
        //                    responseError = error
        //                    self.handleErrorState(with: error, payload: issuePayload, response: response)
        //                } else {
        //                    self.trackMediaUpload(with: issuePayload, response: response)
        //                }
        //            }
        //
        //            if responseError == nil {
        //                self.showSuccessToast(with: issuePayload)
        //            }
    }
    
    private func getVideoDataPayload(with fileURL: URL?) -> IssueMediaPayload? {
        guard let _fileURL = fileURL else { return nil }
        let fileExtension = _fileURL.lastPathComponent
        do {
            let fileData = try Data(contentsOf: _fileURL)
            return IssueMediaPayload(data: fileData,
                                     fileExtension: fileExtension,
                                     type: .video)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func getImageDataPayload(with image: UIImage?) -> IssueMediaPayload? {
        guard let _image = image, let fileData = _image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        let fileExtension = ".jpg"
        return IssueMediaPayload(data: fileData,
                                 fileExtension: fileExtension,
                                 type: .photo)
    }
    
    //MARK: - Errors handling
    
    private func handleErrorState(with error: Error? = nil,
                                  payload: IssuePayload,
                                  response: IssueMediaUploadResponse? = nil) {
//        delegate?.hideSpinnerView()
//
//        if let _response = response {
//            trackIssueMediaUploadFail(with: _response,
//                                      issuePayload: payload)
//        } else {
//            trackIssueCreationFail(with: error, issuePayload: payload)
//        }
//
//#if DEBUG
//        if let _error = error {
//            delegate?.showDialogView(with: .debugError(_error))
//        } else {
//            delegate?.showDialogView(with: .error)
//        }
//#else
//        delegate?.showDialogView(with: .error)
//#endif
    }
    
    private func handleVideoErrorState(with error: Error) {
//        delegate?.hideSpinnerView()
//        delegate?.showDialogView(with: .trimmVideoError(error))
    }
    
    private func handleUserError(with error: IssueResponseError, payload: IssuePayload) {
//        delegate?.hideSpinnerView()
//        switch error.code {
//        case 418, 419:
//            delegate?.showDialogView(with: .oversizeMediaPayload(error.title, error.message))
//        default:
//            handleErrorState(with: error, payload: payload)
//        }
    }
}

extension ReportToolViewLogic: UITextViewDelegate {
    
    public func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        guard let viewLablel = textView.accessibilityLabel else {
            return false
        }
        
        if text == "\n" {
            let nextTag = textView.tag + 1
            
            if let nextResponder = textView.superview?.viewWithTag(nextTag) {
                nextResponder.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
        }
        
        let textLength = textView.text.count
        
        switch viewLablel {
        case desctiptionFieldID:
            if textLength <= descriptionMaxLength {
                return true
            }
        case titleFieldID:
            if textLength < titleMaxLength {
                return true
            }
        default:
            return false
        }
        
        return false
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        _ = isTextViewsFilled()
        
        guard let viewLablel = textView.accessibilityLabel else { return }
        
        switch viewLablel {
        case desctiptionFieldID:
            descriptionFieldText = textView.text
        case titleFieldID:
            delegate?.updateSummaryCounter()
            summaryFieldText = textView.text
        default:
            return
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == textFieldTextDefaulrColor {
            textView.text = nil
            textView.textColor = UIColor.hexStringToUIColor(hex: "#3D3A44")
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard let viewLablel = textView.accessibilityLabel else {
            return
        }
        
        switch viewLablel {
        case desctiptionFieldID:
            if textView.text.isEmpty {
                textView.text = desctiptionDefaultText
                textView.textColor = textFieldTextDefaulrColor
            }
        case titleFieldID:
            if textView.text.isEmpty {
                textView.text = titleDefaultText
                textView.textColor = textFieldTextDefaulrColor
            }
        default:
            return
        }
    }
}

extension ReportToolViewLogic: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let mediaType = info[.mediaType] as? String {
            switch mediaType {
            case ReportToolMediaType.video.rawValue:
                if let mediaURL = info[.mediaURL] as? URL {
                    processVideo(with: mediaURL)
                }
            case ReportToolMediaType.photo.rawValue:
                if photoImage != nil {
                    break
                }

                if let image = info[.originalImage] as? UIImage {
                    photoImage = image
                    delegate?.showThumbnail(with: .photo, image: image)
                }

            default:
                break
            }
        }
    }
}

extension ReportToolViewLogic: IssueReportMediaButtonDelegate {
    public func goToPhotoController() {
        showCameraSelectionController()
    }
    
    public func goToVideoController() {
        showVideoSelectionController()
    }
    
    public func removeThumbnail(with mediaType: IssueReportMediaButton.UploadMediaType) {
        switch mediaType {
        case .photo:
            delegate?.showDialogView(with: .removePhotoThumbnail)
        case .video:
            delegate?.showDialogView(with: .removeVideoThumbnail)
        }
    }
}

private extension ReportToolViewLogic {
    func trackIssueCreationSuccess(with issuePayload: IssuePayload) {
        let imageSize = issuePayload.mediaPayload["imageSize"] ?? 0
        let imageSizeValue = imageSize == 0 ? "" : String(imageSize)
        let videoSize = issuePayload.mediaPayload["videoSize"] ?? 0
        let videoSizeValue = imageSize == 0 ? "" : String(videoSize)
        let values: [String] = [issuePayload.serialNumber,
                                issuePayload.issueId,
                                imageSizeValue,
                                videoSizeValue]
        
        // Discuss with Nishant reporting or analytics sevice
        
//        reportingService.trackAction(reportingEvent: .actionIssueCreation,
//                                     category: analyticsCategoryKey,
//                                     subcategory: analyticsSubcategorySuccess,
//                                     values: values,
//                                     sourceDeviceType: nil)
    }
    
    func trackIssueCreationFail(with error: Error? = nil,
                                issuePayload: IssuePayload) {
        guard let _error = error as NSError? else { return }
        let failureReaon = _error.localizedDescription
        let failureCode = String(_error.code)
        let values: [String] = [issuePayload.serialNumber,
                                issuePayload.issueId,
                                failureCode,
                                failureReaon]
        
//        reportingService.trackAction(reportingEvent: .actionIssueCreation,
//                                     category: analyticsCategoryKey,
//                                     subcategory: analyticsSubcategoryFailed,
//                                     values: values,
//                                     sourceDeviceType: nil)
    }
    
    func trackMediaUpload(with issuePayload: IssuePayload,
                          response: IssueMediaUploadResponse) {
        let values: [String] = [issuePayload.serialNumber, issuePayload.issueId]
        trackSuccessfullMediaUpload(with: values, reportingEvent: response.action)
    }
    
    func trackSuccessfullMediaUpload(with values:[String],
                                     reportingEvent: ReportingEvent) {
//        reportingService.trackAction(reportingEvent: reportingEvent,
//                                     category: analyticsCategoryKey,
//                                     subcategory: analyticsSubcategorySuccess,
//                                     values: values,
//                                     sourceDeviceType: nil)
    }
    
    func trackIssueMediaUploadFail(with response: IssueMediaUploadResponse,
                                   issuePayload: IssuePayload) {
        if let error = response.error as NSError? {
            trackMediaUploadFail(with: response.action,
                                 issuePayload: issuePayload,
                                 error: error)
        }
    }
    
    func trackMediaUploadFail(with reportingEvent: ReportingEvent,
                              issuePayload: IssuePayload,
                              error: NSError) {
        let failureReason = error.localizedDescription
        let failureCode = String( error.code)
        let values: [String] = [issuePayload.serialNumber,
                                issuePayload.issueId,
                                failureCode,
                                failureReason]
//        reportingService.trackAction(reportingEvent: reportingEvent,
//                                     category: analyticsCategoryKey,
//                                     subcategory: analyticsSubcategoryFailed,
//                                     values: values,
//                                     sourceDeviceType: nil)
    }
}

extension ReportToolViewLogic: UINavigationControllerDelegate {
    
}

extension ReportToolViewLogic: UIControllerLifeCycle {
    public func didAppear() {
//        updateIssueID()
    }
}

