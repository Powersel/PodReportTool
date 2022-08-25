//
//  RokuReportToolViewController.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import UIKit

typealias ButtonActionCompletionHandler = () -> ()

final public class RokuReportToolViewController: RokuBaseViewController {
    
    @IBOutlet weak var naviBackButton: UIButton!
    @IBOutlet weak var screenTitle: UILabel!
    
    @IBOutlet weak var summaryContainer: UIView!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var summaryCounterLabel: UILabel!
    
//    @IBOutlet weak var issueIDLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var optionalMediaLabel: UILabel!
    @IBOutlet weak var mediaButtonsStackView: UIStackView!
    @IBOutlet weak var sendReportButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    public var viewLogic: ReportToolViewLogic!
    
    private let sendButtonActiveColor = UIColor.hexStringToUIColor(hex: "#662D91")
    private let sendButtonActiveTintColor = UIColor.white
    
    private let sendButtonDisableColor = UIColor.hexStringToUIColor(hex: "#CCCCCC")
    private let sendButtonDisableTintColor = UIColor.hexStringToUIColor(hex: "#7D7D7D")
    
    public init() {
        super.init(nibName: "RokuReportToolViewController", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: "RokuReportToolViewController", bundle: Bundle(for: type(of: self)))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        UIFont.loadMyFonts
        configureUI()
        viewLogic.delegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewLogic.didAppear()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func sendReportButtonClicked(_ sender: Any) {
        if sendReportButton.isUserInteractionEnabled == true {
            sendReportButton.isUserInteractionEnabled = false
            viewLogic.sendReport()
        }
    }
    
    @IBAction func goBackClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleScreenTap() {
        view.endEditing(true)
    }
}

// MARK: - Private

private extension RokuReportToolViewController {
    private func configureUI() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(RokuReportToolViewController.handleScreenTap))
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#E5E5E5")
    
        configureFonts()
        configureNavigationBar()
        configureLabels()
        configureTextViews()
        configureButtons()
        configureThumbnails()
    }
    
    private func configureFonts() {
//        let localBundle = Bundle(for: type(of: self))
//
//            let aaa = UIFont(name: "Gotham-Light", size: 12.0)
//            let bbb = UIFont(name: "Gotham-Medium-Lat", size: 12.0)
//            let ccc = UIFont(name: "Gotham-BookItalic", size: 12.0)
//            let ddd = UIFont(name: "Gotham-Book-Lat", size: 12.0)
//            let eee = UIFont(name: "Gotham-Bold-Lat", size: 12.0)
//
//        print(localBundle)
    }
    
    private func configureLabels() {
        // ModelData object uses original Roku app
        //        guard let box = modelData.getSelectedBox() else {
        //            return
        //        }
        
//        let controllerTitle = "Issue report tool"
//        let naviTitle = NSLocalizedString(controllerTitle,
//                                          comment: "Issue report screen title")
//        navigationController?.title = naviTitle
        
//        issueIDLabel.textAlignment = .left
//        issueIDLabel.textColor = .white
//        let fetchingTitle = NSLocalizedString("Fetching Issue ID...",
//                                              comment: "A/B screenm issue id title")
//        updateIssueIDLabelText(with: fetchingTitle)
        
        infoLabel.textAlignment = .right
        let infoLabelTitle = NSLocalizedString("*Required",
                                               comment: "Info label title, in Issue report screen")
        let infoLabelColor = UIColor.hexStringToUIColor(hex: "#3D3A44")
        let labelFont = UIFont(name: "Gotham", size: 12) ?? UIFont()
        let  infoLabelTitleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: labelFont,
                                                                         NSAttributedString.Key.foregroundColor: infoLabelColor]
        let attributedInfoTitle = NSAttributedString(string: infoLabelTitle, attributes: infoLabelTitleAttributes)
        infoLabel.attributedText = attributedInfoTitle
        
        let mediaLabelTitle = NSLocalizedString("Media",
                                                comment: "Media label title, in Issue report screen")
        optionalMediaLabel.textAlignment = .left
        optionalMediaLabel.textColor = UIColor.hexStringToUIColor(hex: "#3D3A44")
        optionalMediaLabel.font = UIFont(name: "Gotham-Bold", size: 14)
        optionalMediaLabel.text = mediaLabelTitle
    }
    
    private func configureTextViews() {
        let backColor = UIColor.white
        summaryContainer.backgroundColor = backColor
        summaryContainer.layer.borderWidth = 1.0
        summaryContainer.layer.borderColor = UIColor.hexStringToUIColor(hex: "#CCCCCC").cgColor
        
        summaryCounterLabel.numberOfLines = 0
        summaryCounterLabel.text = "0/160"
        summaryCounterLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        
        let defaultTextColor = UIColor.hexStringToUIColor(hex: "#7D7D7D")
        
        summaryTextView.textContainer.maximumNumberOfLines = 2
        summaryTextView.delegate = viewLogic
        let summaryViewDefaultText = NSLocalizedString("     What happened?*",
                                                       comment: "Summary text view default title, in Issue report screen")
        summaryTextView.text = summaryViewDefaultText
        summaryTextView.textColor = defaultTextColor
        summaryTextView.backgroundColor = .clear
        summaryTextView.keyboardType = .asciiCapable
        
        descriptionTextView.textContainer.maximumNumberOfLines = 0
        descriptionTextView.delegate = viewLogic
        let descriptionViewDefaultText = NSLocalizedString("     How did it happen?*",
                                                           comment:"Description text view default title, in Issue report screen")
        descriptionTextView.text = descriptionViewDefaultText
        descriptionTextView.textColor = UIColor.hexStringToUIColor(hex: "#7D7D7D")
        descriptionTextView.backgroundColor = backColor
        descriptionTextView.keyboardType = .asciiCapable
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#CCCCCC").cgColor
    }
    
//    private func updateIssueIDLabelText(with text: String) {
//        let title = NSLocalizedString("Issue ID: ",
//                                      comment:"Issue ID label title, in Issue report screen")
//        let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//        let titleAttributes = [NSAttributedString.Key.font: titleFont]
//        let titleAttrText = NSMutableAttributedString(string: title,
//                                                      attributes: titleAttributes)
//
//        let textFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
//        let textAttributes = [NSAttributedString.Key.font: textFont]
//        let attributedText = NSAttributedString(string: text,
//                                                attributes: textAttributes)
//
//        titleAttrText.append(attributedText)
//        issueIDLabel.attributedText = titleAttrText
//    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        
        screenTitle.text = "Report an issue"
        let screenTitleTextColor = UIColor.hexStringToUIColor(hex: "#393F47")
//        let aaaaa = AttributedString(<#T##string: String##String#>, attributes: <#T##AttributeContainer#>)
//        let aaaa =NSAttributedString(<#T##attrStr: AttributedString##AttributedString#>)
//        screenTitle.attributedText 
        screenTitle.textColor = screenTitleTextColor
        let screenTitleFont = UIFont(name: "Gotham", size: 16)
        screenTitle.font = screenTitleFont
        
        naviBackButton.setTitle("", for: .normal)
        
        if let closeImage = UIImage(named: "back-button-icon",
                                    in: Bundle(for: type(of: self)),
                                    compatibleWith: nil) {
            naviBackButton.setImage(closeImage, for: .normal)
        }
    }
    
    private func configureButtons() {
        sendReportButton.backgroundColor = sendButtonDisableColor
        let sendReportTitle = NSLocalizedString("Send report", comment:"Send report button title, in Issue report screen")
        sendReportButton.setTitle(sendReportTitle, for: .normal)
        sendReportButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        sendReportButton.titleLabel?.tintColor = sendButtonDisableTintColor
        sendReportButton.layer.cornerRadius = 4
    }
    
    private func configureThumbnails() {
        mediaButtonsStackView.alignment = .fill
        mediaButtonsStackView.distribution = .fillEqually
        mediaButtonsStackView.spacing = 8.0
        
        let photoThumbnail = IssueReportMediaButton(mediaType: .photo)
        photoThumbnail.translatesAutoresizingMaskIntoConstraints = false
        photoThumbnail.delegate = viewLogic
        
        let videoThumbnail = IssueReportMediaButton(mediaType: .video)
        videoThumbnail.translatesAutoresizingMaskIntoConstraints = false
        videoThumbnail.delegate = viewLogic
        
        mediaButtonsStackView.addArrangedSubview(photoThumbnail)
        mediaButtonsStackView.addArrangedSubview(videoThumbnail)
    }
    
    private func getMediaButton(with mediaType: IssueReportMediaButton.UploadMediaType) -> UIView? {
        switch mediaType {
        case .photo:
            return mediaButtonsStackView.arrangedSubviews.first
        case .video:
            return mediaButtonsStackView.arrangedSubviews.last
        }
    }
    
    private func cleanMediaButtonThumbNail(with mediaType: IssueReportMediaButton.UploadMediaType) {
        guard let previewImage = getMediaButton(with: mediaType) as? IssueReportMediaButton else {
            return
        }
        previewImage.changeViewState()
        _ = mediaType == .photo ? viewLogic.clearPhotoCache() : viewLogic.clearVideoCache()
    }
    
    private func showDialogView(with title: String,
                                message: String,
                                actionTitle: String,
                                actionCompletion: ButtonActionCompletionHandler?,
                                cancelTitle: String,
                                cancelAction: ButtonActionCompletionHandler?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let completionAction = UIAlertAction(title: actionTitle, style: .destructive) { okAction in
            if let actionCompletion = actionCompletion {
                actionCompletion()
            }
        }
        alertController.addAction(completionAction)
        
        if cancelTitle.count > 0 {
            let completionCancel = UIAlertAction(title: cancelTitle, style: .cancel) { okAction in
                if let cancelAction = cancelAction {
                    cancelAction()
                }
            }
            alertController.addAction(completionCancel)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

extension RokuReportToolViewController: RokuReportToolViewLogicProtocol {
    public func updateSummaryCounter() {
        let counter = summaryTextView.text.count
        summaryCounterLabel.text = String(counter) + "/160"
    }
    
    public func showThumbnail(with mediaType: ReportToolMediaType,
                              image: UIImage) {
        let type: IssueReportMediaButton.UploadMediaType = mediaType == .photo ? IssueReportMediaButton.UploadMediaType.photo : IssueReportMediaButton.UploadMediaType.video
        DispatchQueue.main.async { [weak self] in
            guard let _self = self,
                  let previewImage = _self.getMediaButton(with: type) as? IssueReportMediaButton
            else { return }
            previewImage.presentThumbnail(with: image)
            previewImage.changeViewState()
        }
    }
    
    public func presentController(controller: UIViewController) {
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    public func getSummaryText() -> String {
        return summaryTextView.text
    }
    
    public func getDescriptionText() -> String {
        return descriptionTextView.text
    }
    
    public func showSpinnerView() {
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            if _self.isSpinnerActive() { return }
            let uploadindTitle = NSLocalizedString("Uploading your data...",
                                                   comment:"Uploading cover screen title, in Issue report screen")
            _self.showLoadingView(text: uploadindTitle, countdown: 0)
        }
    }
    
    public func hideSpinnerView() {
        removeLoading()
    }
    
    public func isSpinnerActive() -> Bool {
        return isLoadingUtilActive()
    }
    
    public func enableSendButton() {
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            if _self.sendReportButton.backgroundColor == _self.sendButtonDisableColor {
                _self.sendReportButton.backgroundColor = _self.sendButtonActiveColor
                _self.sendReportButton.titleLabel?.tintColor = _self.sendButtonActiveTintColor
            }
        }
    }
    
    public func disableSendButton() {
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            if _self.sendReportButton.backgroundColor != _self.sendButtonDisableColor {
                _self.sendReportButton.backgroundColor = _self.sendButtonDisableColor
                _self.sendReportButton.titleLabel?.tintColor = _self.sendButtonDisableTintColor
            }
        }
    }
    
    public func unlockSendButtonUserInteraction() {
        sendReportButton.isUserInteractionEnabled = true
    }
    
    public func showDialogView(with dialogType: ReportToolAlertDialogType) {
        hideSpinnerView()
        
        var title = ""
        var message = ""
        
        var actionTitle = ""
        var actionCompletion: ButtonActionCompletionHandler?
        
        let cancelTitleText = NSLocalizedString("Cancel",
                                                comment:"Cancel button title, dialog view in Issue report screen")
        var cancelTitle: String = cancelTitleText
        var cancelCompletion: ButtonActionCompletionHandler?
        
        let issueIDReloadCompletion: ButtonActionCompletionHandler = { [weak self] in
            guard let _self = self else { return }
//            _self.viewLogic.updateIssueID()
            _self.unlockSendButtonUserInteraction()
        }
        
        let okActionTitle = NSLocalizedString("Ok",
                                              comment:"Ok action button title, dialog view in Issue report screen")
        
        let unlockSendBtnCompletion: ButtonActionCompletionHandler = { [weak self] in
            guard let _self = self else { return }
            _self.unlockSendButtonUserInteraction()
        }
        
        switch dialogType {
        case .trimmVideo:
            let trimmVideoTitle = NSLocalizedString("Your video will be trimmed",
                                                    comment:"Trimm video dialog view title, in Issue report screen")
            title = trimmVideoTitle
            let trimmVideoMessage = NSLocalizedString("Only the last 60 seconds of your video will be sent. Would you like to go back and create a new video?",
                                                      comment:"Trimm video dialog view message, in Issue report screen")
            message = trimmVideoMessage
            let actionTitleText = NSLocalizedString("Send trimmed video",
                                                    comment:"Trimm video dialog view, action button title, in Issue report screen")
            actionTitle = actionTitleText
            let cancelTitleText = NSLocalizedString("Go back",
                                                    comment:"Trimm video dialog view, cancel button title, in Issue report screen")
            cancelTitle = cancelTitleText
            actionCompletion = { [weak self] in
                guard let _self = self else { return }
                _self.viewLogic.sendMediaFiles()
            }
            
            cancelCompletion = unlockSendBtnCompletion
        case .removePhotoThumbnail:
            let removePhotoTitle = NSLocalizedString("Remove photo?",
                                                     comment:"Remove photo dialog view title, in Issue report screen")
            title = removePhotoTitle
            let removePhotoMessage = NSLocalizedString("After removing, you can attach a new photo to your report.",
                                                       comment:"Remove photo dialog view message, in Issue report screen")
            message = removePhotoMessage
            let actionTitleText = NSLocalizedString("Remove photo",
                                                    comment:"Remove photo dialog view, action button title, in Issue report screen")
            actionTitle = actionTitleText
            actionCompletion = { [weak self] in
                guard let _self = self else { return }
                _self.cleanMediaButtonThumbNail(with: .photo)
            }
        case .removeVideoThumbnail:
            let removeVideoTitle = NSLocalizedString("Remove video?",
                                                     comment:"Remove video dialog view title, in Issue report screen")
            title = removeVideoTitle
            let removeVideoMessage = NSLocalizedString("After removing, you can attach a new video to your report.",
                                                       comment:"Remove video dialog view message, in Issue report screen")
            message = removeVideoMessage
            let actionTitleText = NSLocalizedString("Remove video",
                                                    comment:"Remove video dialog view, action button title, in Issue report screen")
            actionTitle = actionTitleText
            actionCompletion = { [weak self] in
                guard let _self = self else { return }
                _self.cleanMediaButtonThumbNail(with: .video)
            }
        case .error:
            let errorTitle = NSLocalizedString("Something went wrong",
                                               comment:"Error dialog view title, in Issue report screen")
            title = errorTitle
            let errorMessage = NSLocalizedString("Try sending your report again, or cancel to return to the report form.",
                                                 comment:"Error dialog view message, in Issue report screen")
            message = errorMessage
            let actionTitleText = NSLocalizedString("Retry",
                                                    comment:"Error dialog view, action button title, in Issue report screen")
            actionTitle = actionTitleText
            actionCompletion = issueIDReloadCompletion
            cancelCompletion = unlockSendBtnCompletion
        case .trimmVideoError(let error):
            let trimmVideoErrorTitle = NSLocalizedString("Something went wrong with video processing, please, try again",
                                                         comment:"Trimm video error dialog view title, in Issue report screen")
            title = trimmVideoErrorTitle
            message = error.localizedDescription
            actionTitle = okActionTitle
            actionCompletion = unlockSendBtnCompletion
            cancelCompletion = unlockSendBtnCompletion
        case .emptyTextFields:
            let warningTitle = NSLocalizedString("Warning",
                                                 comment:"Empty text fields dialog view title, in Issue report screen")
            title = warningTitle
            let warningMessage = NSLocalizedString("Summary and description fields, should not be empty",
                                                   comment:"Empty text fields dialog view message, in Issue report screen")
            message = warningMessage
            actionTitle = okActionTitle
            actionCompletion = unlockSendBtnCompletion
            cancelTitle = ""
        case .debugError(let error):
            let warningTitle = "Warning, you are in DEBUG mode"
            title = warningTitle
            let warningMessage = error.localizedDescription
            message = warningMessage
            actionTitle = okActionTitle
            actionCompletion = issueIDReloadCompletion
            cancelCompletion = unlockSendBtnCompletion
        case .ecp2Error:
            title = NSLocalizedString("Something went wrong",
                                      comment:"Issue ID ECP2 request error dialog title, Issue report screen")
            message = NSLocalizedString("An issue ID couldn't be created. Retry now, or cancel and try again later", comment:"ECP2 issue ID error title, in Issue report screen")
            actionTitle = NSLocalizedString("Retry", comment:"Try again button title, in Issue report screen")
            cancelTitle = NSLocalizedString("Cancel",
                                            comment:"Cancel button title, dialog view in Issue report screen")
            actionCompletion = issueIDReloadCompletion
            cancelCompletion = unlockSendBtnCompletion
        case .oversizeMediaPayload(let titleText, let messageText):
            title = titleText
            message = messageText
            actionTitle = NSLocalizedString("Ok", comment:"Try again button title, in Issue report screen")
            cancelTitle = ""
            actionCompletion = unlockSendBtnCompletion
        case .cameraAccessRestriction:
            title = NSLocalizedString("Camera permissions must be granted to report an issue",
                                      comment: "Camera access permission title")
            message = NSLocalizedString("Please enable it in Settings > Privacy > Camera", comment: "Camera access permission message")
            actionTitle = NSLocalizedString("Ok", comment:"Try again button title, in Issue report screen")
            cancelTitle = ""
        case .microphoneAccessRestriction:
            title = NSLocalizedString("Microphone permissions must be granted to report an issue",
                                      comment: "Microphone permission title")
            message = NSLocalizedString("Please enable it in Settings > Privacy > Microphone", comment: "Microphone permission message")
            actionTitle = NSLocalizedString("Ok", comment:"Try again button title, in Issue report screen")
            cancelTitle = ""
        case .reportHasnotBeenSent:
            title = NSLocalizedString("Your report has not been sent",
                                      comment: "Report has not been sent alert title")
            message = NSLocalizedString("Closing this form now will delete the information it contains.",
                                        comment: "Report has not been sent description title")
            actionTitle = NSLocalizedString("Cancel",
                                            comment:"Cancel button title, in Issue report screen")
            cancelTitle = NSLocalizedString("Close without sending",
                                            comment:"Navigation back alert button title, in Issue report screen")
            actionCompletion = nil
            cancelCompletion = { [weak self] in
                guard let _self = self else { return }
                _self.navigationController?.popViewController(animated: true)
            }
        case .reportHasBeenSent:
            message = NSLocalizedString("Issue has been created",
                                        comment: "Report has not been sent description title")
            actionTitle = NSLocalizedString("OK",
                                            comment:"OK button title, in Issue report screen")
            cancelTitle = ""
            actionCompletion = { [weak self] in
                guard let _self = self else { return }
                _self.navigationController?.popViewController(animated: true)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let _self = self else { return }
            _self.showDialogView(with: title,
                                 message: message,
                                 actionTitle: actionTitle,
                                 actionCompletion: actionCompletion,
                                 cancelTitle: cancelTitle,
                                 cancelAction: cancelCompletion)
        }
    }
    
//    public func updateIssueIDLabel(with issueID: String) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.updateIssueIDLabelText(with: issueID)
//        }
//    }
}
