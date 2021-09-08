//
//  InterestsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import UIKit

class InterestsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var interestNameLbl: UILabel!
    @IBOutlet weak var bottonView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
