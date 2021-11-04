//
//  CategoryTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/08/2021.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.cornerRadiusView(radius: 6)
//        containerView.setBorder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if isSelected {
            containerView.backgroundColor = UIColor.FriendzrColors.primary
            titleLbl.textColor = .white
        }else {
            containerView.backgroundColor = .clear
            titleLbl.textColor = UIColor.setColor(lightColor: .black, darkColor: .white)
        }
    }
}
