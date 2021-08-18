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
    var HandleUnConfirmBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func unConfirmBtn (_ sender: UIButton) {
        HandleUnConfirmBtn?()
    }
    
    @IBAction func confirmBtn (_ sender: UIButton) {
        HandleConfirmBtn?()
    }
}
