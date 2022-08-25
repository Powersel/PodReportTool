//
//  RokuBaseViewController.swift
//  RockReportTool
//
//  Created by Powersel on 12.07.2022.
//

import UIKit

public class RokuBaseViewController: UIViewController {
    
        fileprivate var loadingUtil: RokuLoadingUtil?
        
        func isLoadingUtilActive() -> Bool {
            return false
        }
        
        func displayAlertView(title: String = NSLocalizedString("Unable to sign in", comment: "Title show in a dialog"),
                              message: String,
                              completion: (() -> ())? = nil) {
            let ok = NSLocalizedString("Okay", comment: "Title of the Ok button")

            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    //        alert.view.themeClass = NoThemeClass
            alert.addAction(UIAlertAction(title: ok, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: completion)
        }
        
        func showLoadingView(text: String, countdown: Int32) {
            self.loadingUtil = RokuLoadingUtil(text: text, countdown: countdown)
            let superView = self.view
            
            guard let loadingUtil = self.loadingUtil, let subView = loadingUtil.view else {
                return
            }
            subView.translatesAutoresizingMaskIntoConstraints = false

            DispatchQueue.main.async {
                if subView.superview == nil {
                    superView?.addSubview(subView)
                    self.addChild(self.loadingUtil!)
                    loadingUtil.didMove(toParent: self)

                    let viewsDictionary = ["superView": superView, "subView": subView]
                    let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                               options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                               metrics: nil,
                                                                               views: viewsDictionary as [String : Any])
                    let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                             options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                             metrics: nil,
                                                                             views: viewsDictionary as [String : Any])
                    superView?.addConstraints(horizontalConstraints)
                    superView?.addConstraints(verticalConstraints)
                }

                loadingUtil.view.alpha = 0
                UIView.animate(withDuration: 0.1, animations: {
                    self.loadingUtil?.view.alpha = 1
                }, completion: nil)
            }
        }
        
        open func removeLoading() {
            if loadingUtil == nil {
                return
            }
    
            DispatchQueue.main.async {
                if self.loadingUtil?.view.superview == nil {
                    self.loadingUtil = nil
                    return
                }
    
                UIView.animate(withDuration: 0.1, animations: {
                    self.loadingUtil?.view.alpha = 0
                }, completion: { (finished) in
                    if !finished {
                        return
                    }
                    self.loadingUtil?.view.removeFromSuperview()
                    if self.loadingUtil?.parent != nil {
                        self.loadingUtil?.removeFromParent()
                    }
                })
            }
        }
}
