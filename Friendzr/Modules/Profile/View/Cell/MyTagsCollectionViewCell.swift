//
//  MyTagsCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/01/2022.
//

import UIKit

class MyTagsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var tagTitleLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.setBorder()
        containerView.cornerRadiusView(radius: 10)
    }
    
    @IBAction func editBtn(_ sender: Any) {
    }
}
