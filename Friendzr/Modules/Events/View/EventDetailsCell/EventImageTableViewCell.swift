//
//  EventImageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit
import ImageSlideshow
import SDWebImage

class EventImageTableViewCell: UITableViewCell {
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var attendeesLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var imagesSlider: ImageSlideshow!
    
    var parentVC:UIViewController = UIViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        
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
