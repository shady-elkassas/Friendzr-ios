//
//  EventsInLocationTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/09/2021.
//

import UIKit

class EventsInLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var joinedLbl: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    
    
    var HandleDirectionBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        eventImg.cornerRadiusView(radius: 10)
        eventImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
    }
    
    
    @IBAction func directionBtn(_ sender: Any) {
        HandleDirectionBtn?()
    }
}
