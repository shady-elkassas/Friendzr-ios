//
//  ChatListTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var lastMessageDateLbl: UILabel!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var attachImg: UIImageView!
    @IBOutlet weak var attachTypeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImg.cornerRadiusForHeight()
        profileImg.setBorder()
        attachImg.cornerRadiusView(radius: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
