//
//  VerifyFaceRegistrationAlertView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/01/2022.
//

import Foundation
import UIKit


class VerifyFaceRegistrationAlertView : UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var titleAlertLbl: UILabel!
    @IBOutlet weak var subTitleAlertLbl: UILabel!
    
    var HandleOkBtn: (()->())?

    override func awakeFromNib() {
        
        containerView.cornerRadiusView(radius: 8)
    }
    
    @IBAction func okBtn(_ sender: Any) {
        HandleOkBtn?()
        
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
