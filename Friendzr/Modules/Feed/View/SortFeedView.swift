//
//  SortFeedView.swift
//  Friendzr
//
//  Created by Shady Elkassas on 06/06/2022.
//

import UIKit

class SortFeedView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectInterestsImg: UIImageView!
    @IBOutlet weak var selectDistanceImg: UIImageView!
    @IBOutlet weak var selectInterestsBtn: UIButton!
    @IBOutlet weak var selectDistanceBtn: UIButton!
    @IBOutlet weak var dismissView: UIButton!
    
    var HandlehideViewBtn: (()->())?
    var HandleSortByDistanceBtn: (()->())?
    var HandleSortByInterestsBtn: (()->())?
    
    override func awakeFromNib() {
        containerView.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func dismissViewBtn(_ sender: Any) {
        HandlehideViewBtn?()
    }
    
    @IBAction func selectDistanceBtn(_ sender: Any) {
        HandleSortByDistanceBtn?()
    }
    
    @IBAction func selectInterestsBtn(_ sender: Any) {
        HandleSortByInterestsBtn?()
    }
}
