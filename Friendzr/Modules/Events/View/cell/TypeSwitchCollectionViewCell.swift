//
//  TypeSwitchCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/04/2023.
//

import UIKit

class TypeSwitchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.cornerRadiusView(radius: 8)
    }
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ? UIColor.FriendzrColors.primary : .white
            titleLbl.textColor = isSelected ? .white : .black
        }
    }
}
