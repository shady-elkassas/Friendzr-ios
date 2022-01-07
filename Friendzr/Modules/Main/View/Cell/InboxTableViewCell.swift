//
//  InboxTableViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 06/01/2022.
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
