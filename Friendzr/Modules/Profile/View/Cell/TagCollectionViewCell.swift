//
//  TagCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/11/2021.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagNameLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var editBtnWidth: NSLayoutConstraint!
    
    
    var HandleEditBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.cornerRadiusView(radius: 10)
    }
    
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
    
}
