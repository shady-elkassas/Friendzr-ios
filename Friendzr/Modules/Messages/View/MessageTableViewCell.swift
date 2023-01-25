//
//  MessageTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/05/2022.
//

import UIKit
import MapKit
import ImageSlideshow
import SDWebImage


protocol MessageTableViewCellDelegate: class {
    func messageTableViewCellUpdate()
}

class MessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePic: UIImageView?
    @IBOutlet weak var messageTextView: UITextView?
    @IBOutlet weak var messageDateLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    
    var HandleUserProfileBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        HandleUserProfileBtn?()
    }
}

class MessageAttachmentTableViewCell: MessageTableViewCell {
    
    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentDateLbl: UILabel!
    @IBOutlet weak var tapImageBtn: UIButton!
    @IBOutlet weak var userProfileBtn: UIButton!
    @IBOutlet weak var imagesSlider: ImageSlideshow!
    
    weak var delegate: MessageTableViewCellDelegate?
    var parentVC:UIViewController = UIViewController()
    var HandleTapAttachmentBtn: (() -> ())?
    var HandleProfileBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageViewHeightConstraint.constant = 250
        attachmentImageViewWidthConstraint.constant = 250
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        imagesSlider.addGestureRecognizer(recognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        attachmentImageView.contentMode = .scaleAspectFill
        attachmentImageView.image = nil
        attachmentImageViewHeightConstraint.constant = 250
        attachmentImageViewWidthConstraint.constant = 250
    }
    
    @objc func didTap() {
        let fullScreenController = imagesSlider.presentFullScreenController(from: parentVC)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: nil)
        print("Did Tap")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func tapattachmentBtn(_ sender: Any) {
        HandleTapAttachmentBtn?()
    }
    
    @IBAction func userProfileBtn(_ sender: Any) {
        HandleProfileBtn?()
    }
}

class ShareLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePic: UIImageView?
    @IBOutlet weak var messageDateLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var HandleUserProfileBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        HandleUserProfileBtn?()
    }
}
