//
//  ShowMessageFromRequestsView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/03/2023.
//

import Foundation
import UIKit

class ShowMessageFromRequestsView: UIView {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteRequest: UIButton!
    @IBOutlet weak var acceptRequestBtn: UIButton!
    @IBOutlet weak var messageBoxView: UIView!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var hideBtn: UIButton!
    
    var HandleAcceptBtn: (()->())?
    var HandleDeleteRequestBtn: (()->())?
    var HandleHideBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        messageBoxView.setBorder()
        containerView.cornerRadiusView(radius: 8)
        messageBoxView.cornerRadiusView(radius: 6)
        deleteRequest.cornerRadiusView(radius: 6)
        acceptRequestBtn.cornerRadiusView(radius: 6)
    }
    
    @IBAction func deleteRequest(_ sender: Any) {
        HandleDeleteRequestBtn?()
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
    
    @IBAction func acceptRequestBtn(_ sender: Any) {
        HandleAcceptBtn?()
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
    
    @IBAction func hideBtnView(_ sender: Any) {
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
}
