//
//  SelectedFriendTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/01/2022.
//

import UIKit

class SelectedFriendTableViewCell: UITableViewCell {

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
        if isSelected {
            selectedImg.image = UIImage(named: "selected_ic")
        }else {
            selectedImg.image = UIImage(named: "unSelected_ic")
        }
    }
    
}
