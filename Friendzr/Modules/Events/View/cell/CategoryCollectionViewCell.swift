//
//  CategoryCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 23/11/2021.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagNameLbl: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.cornerRadiusView(radius: 8)
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                containerView.backgroundColor = .FriendzrColors.primary!
            }else {
                containerView.backgroundColor = .black
            }
        }
    }
}
