//
//  ExternalImageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/03/2022.
//

import UIKit
import ImageSlideshow
import SDWebImage

class ExternalImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gradiendView: GradientView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imagesSlider: ImageSlideshow!

    var parentVC:UIViewController = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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

    }
    
}
