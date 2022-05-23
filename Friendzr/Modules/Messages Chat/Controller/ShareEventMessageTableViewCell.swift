//
//  ShareEventMessageTableViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 22/05/2022.
//

import UIKit

class ShareEventMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var attendeesLbl: UILabel!
    @IBOutlet weak var startEventDateLbl: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        eventImage.contentMode = .scaleToFill
        attachmentImageViewHeightConstraint.constant = 180
        attachmentImageViewWidthConstraint.constant = screenW / 1.4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
