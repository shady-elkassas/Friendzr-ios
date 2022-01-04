//
//  GhostModeTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 02/01/2022.
//

import UIKit

class GhostModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.cornerRadiusView(radius: 12)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
