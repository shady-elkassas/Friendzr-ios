//
//  NearbyEventsCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/11/2021.
//

import UIKit

class NearbyEventsCollectionViewCell: UICollectionViewCell {

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
        eventImg.setCornerforTop(withShadow: false, cornerMask: [.layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8)
//        eventImg.setCornerforBottom(withShadow: false, cornerMask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8)
        containerView.cornerRadiusView(radius: 8)
//        containerView.setBorder()
    }
    
//    @IBAction func directionBtn(_ sender: Any) {
//        HandleDirectionBtn?()
//    }
}
