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
//    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var interestNameLbl: UILabel!
//    @IBOutlet weak var bottonView: UIView!
    @IBOutlet weak var sliderLbl: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sliderLbl.maximumValue = 100
        sliderLbl.minimumValue = 0
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
