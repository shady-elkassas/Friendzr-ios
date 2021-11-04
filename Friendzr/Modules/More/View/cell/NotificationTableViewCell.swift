//
//  NotificationTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationBodyLbl: UILabel!
    @IBOutlet weak var notificationDateLbl: UILabel!
    @IBOutlet weak var notificationTitleLbl: UILabel!
    @IBOutlet weak var notificationImg: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        notificationImg.cornerRadiusView(radius: 8)
        containerView.cornerRadiusView(radius: 8)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}