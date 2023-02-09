//
//  NotificationTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import UIKit
import SDWebImage

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationBodyLbl: UILabel!
    @IBOutlet weak var notificationDateLbl: UILabel!
    @IBOutlet weak var notificationTitleLbl: UILabel!
    @IBOutlet weak var notificationImg: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    
    var model: NotificationObj! {
        didSet {
            notificationBodyLbl.text = model?.body
            notificationTitleLbl.text = model?.title
            
//            notificationDateLbl.text = model?.createdAt
            
            notificationImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            notificationImg.sd_setImage(with: URL(string: model?.imageUrl ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        notificationImg.cornerRadiusForHeight()
        notificationImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
        containerView.cornerRadiusView(radius: 8)
        containerView.setBorder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
