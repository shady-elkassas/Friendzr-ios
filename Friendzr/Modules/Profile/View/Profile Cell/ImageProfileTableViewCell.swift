//
//  ImageProfileTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import ImageSlideshow
import SDWebImage

class ImageProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var genderlbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var imagesSlider: ImageSlideshow!
    
    @IBOutlet weak var arrowPreviousBtn: UIButton!
    @IBOutlet weak var arrowNextBtn: UIButton!
    
    var HandleEditBtn: (()->())?
    var HandleArrowPreviousBtn: (()->())?
    var HandleArrowNextBtn: (()->())?
    var parentVC:UIViewController = UIViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        editBtn.cornerRadiusForHeight()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imagesSlider.addGestureRecognizer(recognizer)
    }

    @objc func didTap() {
        let fullScreenController = imagesSlider.presentFullScreenController(from: parentVC)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        print("Did Tap")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func editBtn(_ sender: Any) {
        HandleEditBtn?()
    }
    
    @IBAction func arrowNextBtn(_ sender: Any) {
        HandleArrowNextBtn?()
    }
    
    @IBAction func arrowPreviousBtn(_ sender: Any) {
        HandleArrowPreviousBtn?()
    }
}
