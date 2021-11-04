//
//  BlockedTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import UIKit

class BlockedTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var unblockBtn: UIButton!
    
    var HandleUnblockBtn: (()->())?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImg.cornerRadiusForHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func unblockbtn(_ sender: Any) {
        HandleUnblockBtn?()
    }
    
}
