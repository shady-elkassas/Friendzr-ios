//
//  MapAlertView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/07/2022.
//

import Foundation
import UIKit


class MapAlertView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var offBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var hideViewBtn: UIButton!
    
    var HandleOffBtn: (()->())?
    var HandleEditBtn: (()->())?
    var HandleHideViewBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 8)
        editBtn.cornerRadiusForHeight()
        offBtn.cornerRadiusForHeight()
    }
    
    
    @IBAction func hideViewBtn(_ sender: Any) {
        HandleHideViewBtn?()
    }
    
    @IBAction func offBtn (_ sender: UIButton) {
        HandleOffBtn?()
    }
    
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
    
}
