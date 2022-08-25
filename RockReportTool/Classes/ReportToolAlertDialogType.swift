//
//  ReportToolAlertDialogType.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import Foundation

public enum ReportToolAlertDialogType {
    case removeVideoThumbnail
    case removePhotoThumbnail
    case trimmVideo
    case trimmVideoError(Error)
    case emptyTextFields
    case error
    case debugError(Error)
    case ecp2Error
    case oversizeMediaPayload(String, String)
    case cameraAccessRestriction
    case microphoneAccessRestriction
    case reportHasnotBeenSent
    case reportHasBeenSent
}
