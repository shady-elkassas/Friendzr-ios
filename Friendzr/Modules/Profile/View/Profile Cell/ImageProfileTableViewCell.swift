//
//  ImageProfileTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit

class ImageProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var genderlbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    
    @IBOutlet weak var profileImgLoader: UIActivityIndicatorView!
    
    var HandleEditBtn: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        editBtn.cornerRadiusForHeight()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
    
}
