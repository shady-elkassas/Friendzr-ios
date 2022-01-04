//
//  ProblemTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit

class ProblemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.cornerRadiusView(radius: 8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if isSelected {
            titleLbl.textColor = .white
            self.containerView.backgroundColor = UIColor.FriendzrColors.primary!
        }else {
            titleLbl.textColor = .black
            self.containerView.backgroundColor = UIColor.clear
        }
    }
}
