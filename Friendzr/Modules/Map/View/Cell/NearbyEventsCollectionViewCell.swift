//
//  NearbyEventsCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/11/2021.
//

import UIKit

class NearbyEventsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventColorView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var joinedLbl: UILabel!
//    @IBOutlet weak var directionBtn: UIButton!
    
//    var HandleDirectionBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        eventImg.cornerRadiusView(radius: 10)
        containerView.cornerRadiusView(radius: 10)
        eventColorView.setCornerforTop()
    }
    
//    @IBAction func directionBtn(_ sender: Any) {
//        HandleDirectionBtn?()
//    }
}
