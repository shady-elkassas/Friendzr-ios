//
//  BlockAlertView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import Foundation
import UIKit


class BlockAlertView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var unConfirmBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    var HandleConfirmBtn: (()->())?
//    var HandleUnConfirmBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func unConfirmBtn (_ sender: UIButton) {
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
    
    @IBAction func confirmBtn (_ sender: UIButton) {
        HandleConfirmBtn?()
    }
}
