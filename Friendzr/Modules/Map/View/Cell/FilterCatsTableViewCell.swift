//
//  FilterCatsTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/06/2022.
//

import UIKit

class FilterCatsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectedImg: UIImageView!
    
    @IBOutlet weak var bottomView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        if isSelected {
//            selectedImg.image = UIImage(named: "selected_ic")
//        }else {
//            selectedImg.image = UIImage(named: "unSelected_ic")
//        }
    }
}
