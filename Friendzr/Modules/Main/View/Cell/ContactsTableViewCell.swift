//
//  ContactsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var imageIsVerifiedImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.cornerRadiusForHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
