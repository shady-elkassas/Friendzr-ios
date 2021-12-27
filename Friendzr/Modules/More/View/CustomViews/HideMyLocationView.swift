//
//  HideMyLocationView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import Foundation
import UIKit


class HideMyLocationView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var everyoneBtn: UIButton!
    @IBOutlet weak var menBtn: UIButton!
    @IBOutlet weak var womenBtn: UIButton!
    @IBOutlet weak var otherGenderBtn: UIButton!
    
    var HandleHideFromEveryOneBtn: (()->())?
    var HandleHideFromMenBtn: (()->())?
    var HandleHideFromWomenBtn: (()->())?
    var HandlehideViewBtn: (()->())?
    var HandlehHideFromOtherGenderViewBtn: (()->())?

    override func awakeFromNib() {
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        womenBtn.cornerRadiusView(radius: 12)
        menBtn.cornerRadiusView(radius: 12)
        everyoneBtn.cornerRadiusView(radius: 12)
        otherGenderBtn.cornerRadiusView(radius: 12)
    }
    
    @IBAction func everyoneBtn(_ sender: Any) {
        HandleHideFromEveryOneBtn?()
    }
    
    @IBAction func menBtn(_ sender: Any) {
        HandleHideFromMenBtn?()
    }
    
    @IBAction func womenBtn(_ sender: Any) {
        HandleHideFromWomenBtn?()
    }
    
    @IBAction func hideViewBtn(_ sender: Any) {
        HandlehideViewBtn?()
    }
    
    @IBAction func otherGenderBtn(_ sender: Any) {
        HandlehHideFromOtherGenderViewBtn?()
    }
}
