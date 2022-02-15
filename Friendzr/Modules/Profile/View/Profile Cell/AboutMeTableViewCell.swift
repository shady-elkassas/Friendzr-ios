//
//  AboutMeTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit

class AboutMeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var aboutMeLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
