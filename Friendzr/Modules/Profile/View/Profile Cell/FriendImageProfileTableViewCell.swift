//
//  FriendImageProfileTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import ImageSlideshow
import SDWebImage

class FriendImageProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var refuseBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLlb: UILabel!
    @IBOutlet weak var friendStackView: UIStackView!
    @IBOutlet weak var unfriendBtn: UIButton!
    @IBOutlet weak var imagesSlider: ImageSlideshow!
    @IBOutlet weak var unBlockBtn: UIButton!
    @IBOutlet weak var arrowPreviousBtn: UIButton!
    @IBOutlet weak var arrowNextBtn: UIButton!

    var HandleMessageBtn: (()->())?
    var HandleRefuseBtn: (()->())?
    var HandleCancelBtn: (()->())?
    var HandleAcceptBtn: (()->())?
    var HandleUnFriendBtn: (()->())?
    var HandleSendRequestBtn: (()->())?
    var HandleUnblockBtn: (()->())?
    var HandleArrowPreviousBtn: (()->())?
    var HandleArrowNextBtn: (()->())?

    let localSource = [BundleImageSource(imageString: "image1"), BundleImageSource(imageString: "image2"), BundleImageSource(imageString: "image3"), BundleImageSource(imageString: "image4"),BundleImageSource(imageString: "image5")]

    var parentVC:UIViewController = UIViewController()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sendRequestBtn.cornerRadiusForHeight()
        cancelBtn.cornerRadiusForHeight()
        acceptBtn.cornerRadiusForHeight()
        refuseBtn.cornerRadiusForHeight()
        messageBtn.cornerRadiusForHeight()
        unfriendBtn.cornerRadiusForHeight()
        unBlockBtn.cornerRadiusForHeight()
        cancelBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        messageBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        refuseBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imagesSlider.addGestureRecognizer(recognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func didTap() {
        let fullScreenController = imagesSlider.presentFullScreenController(from: parentVC)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        print("Did Tap")
    }
    
    @IBAction func unFriendBtn(_ sender: Any) {
        HandleUnFriendBtn?()
    }
    @IBAction func messageBtn(_ sender: Any) {
        HandleMessageBtn?()
    }
    
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        HandleCancelBtn?()
    }
    
    @IBAction func refuseBtn(_ sender: Any) {
        HandleRefuseBtn?()
    }
    
    @IBAction func unBlockBtn(_ sender: Any) {
        HandleUnblockBtn?()
    }
    @IBAction func acceptBtn(_ sender: Any) {
        HandleAcceptBtn?()
    }
    
    @IBAction func arrowNextBtn(_ sender: Any) {
        HandleArrowNextBtn?()
    }
    
    @IBAction func arrowPreviousBtn(_ sender: Any) {
        HandleArrowPreviousBtn?()
    }
}
