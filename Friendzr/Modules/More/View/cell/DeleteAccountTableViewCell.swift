//
//  DeleteAccountTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 26/10/2021.
//

import UIKit

class DeleteAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var langLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
