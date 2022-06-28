//
//  InboxTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/01/2022.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var lastMessageDateLbl: UILabel!
    @IBOutlet weak var attachImg: UIImageView!
    @IBOutlet weak var attachTypeLbl: UILabel!
    @IBOutlet weak var muteImg: UIImageView!
    
    @IBOutlet weak var noMessagesUnreadLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImg.cornerRadiusForHeight()
        noMessagesUnreadLbl.cornerRadiusForHeight()
        profileImg.setBorder()
        attachImg.cornerRadiusView(radius: 4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
