//
//  AddFriendsToPrivateEventTableViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 24/03/2022.
//

import UIKit

class AddFriendsToPrivateEventTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var bottomView: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImg.cornerRadiusForHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
