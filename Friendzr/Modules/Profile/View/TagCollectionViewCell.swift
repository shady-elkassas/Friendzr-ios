//
//  TagCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 17/11/2021.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagNameLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 10)
    }
}
