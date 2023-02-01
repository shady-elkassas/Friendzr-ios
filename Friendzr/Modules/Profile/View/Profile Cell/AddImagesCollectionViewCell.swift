//
//  AddImagesCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/01/2023.
//

import UIKit

class AddImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var superContainerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var removeImgBtn: UIButton!
    
    
    var HandleRemoveBtn: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImg.cornerRadiusView(radius: 8)
    }
    
    
    
    @IBAction func removeImgBtn(_ sender: Any) {
        HandleRemoveBtn?()
    }
}
