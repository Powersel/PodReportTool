//  RokuLoadingView.swift
//  RockReportTool

import UIKit

final class RokuLoadingUtil: UIViewController {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var spinnerContainer: UIView!
    
    var spinner: RokuSpinner?
    var text: String?
    var counter: Int32 = 0
    
    let kMaxLoadingLabelLeadingSpace:CGFloat = 8
    
    init(text: String, countdown: Int32) {
        super.init(nibName: "RokuLoadingUtil", bundle: Bundle(for: type(of: self)))
        self.counter = countdown
        self.text = text
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let text = text, !text.isEmpty {
            loadingLabel.text = text
            loadingLabel.preferredMaxLayoutWidth = self.view.bounds.size.width - 2 * kMaxLoadingLabelLeadingSpace
        }

        let someSpinner = RokuSpinner(frame: CGRect(x: 0, y: 0, width: 10, height: 10),
                                      counter: Int(counter),
                                      useLargeImage: true)
        spinner = someSpinner
        self.spinnerContainer.addSubview(someSpinner)
        someSpinner.translatesAutoresizingMaskIntoConstraints = false
        _ = RokuAutoLayout.centerHorizontally(view: someSpinner, in: spinnerContainer)
        _ = RokuAutoLayout.centerVertically(view: someSpinner, in: spinnerContainer)
    }
    
    private func configureUI() {
        let backgroundColor = UIColor.hexStringToUIColor(hex: "#000000").withAlphaComponent(0.8)
        view.backgroundColor = backgroundColor
        
        loadingLabel.textColor = .white
    }
}
