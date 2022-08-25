//
//  RootViewController.swift
//  RockReportTool_Example
//
//  Created by Sergiy Shevchuk on 11.08.2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RockReportTool

final class RootViewController: UIViewController {
    
    public init() {
        super.init(nibName: "RootViewController", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        super.init(nibName: "RootViewController", bundle: Bundle(for: type(of: self)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
    }
    
    @IBAction func didClick(_ sender: Any) {
        let poolID = ""
        let awsEndpoint = ""
        
        let controller = RokuReportToolViewController()
        controller.viewLogic = ReportToolViewLogic(poolID: poolID, endPointURL: awsEndpoint)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
