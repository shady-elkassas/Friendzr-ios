//
//  UsersFeedTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/01/2022.
//

import UIKit
import SDWebImage

class UsersFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var friendRequestImg: UIImageView!
    @IBOutlet weak var friendRequestNameLbl: UILabel!
    @IBOutlet weak var friendRequestUserNameLbl: UILabel!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var unblockBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var accseptRequestBtn: UIButton!
    @IBOutlet weak var superStackView: UIStackView!
    @IBOutlet weak var refusedRequestBtn: UIButton!
    @IBOutlet weak var subStackView: UIStackView!
    
    @IBOutlet weak var imageIsVerifiedImg: UIImageView!
    @IBOutlet weak var interestMatchPercentLbl: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    
    var HandleSendRequestBtn: (() -> ())?
    var HandleCancelRequestBtn: (() -> ())?
    var HandleMessageBtn: (() -> ())?
    var HandleUnblocktBtn: (() -> ())?
    var HandleAccseptBtn: (() -> ())?
    var HandleRefusedBtn: (() -> ())?

    var parenVC:UIViewController = UIViewController()
    
    var model: UserFeedObj! {
        didSet {
            
            friendRequestNameLbl.text = model?.userName
            friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            
//            if model.imageIsVerified {
//                imageIsVerifiedImg.isHidden = true
//            }else {
//                imageIsVerifiedImg.isHidden = true
//            }
            
            imageIsVerifiedImg.isHidden = true

            friendRequestImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            
            if Defaults.token != "" {
                interestMatchPercentLbl.isHidden = false
                progressBarView.isHidden = false
                interestMatchPercentLbl.text = "\(model?.interestMatchPercent ?? 0) % interests match"
                progressBarView.progress = Float(model?.interestMatchPercent ?? 0) / 100
            }else {
                interestMatchPercentLbl.isHidden = true
                progressBarView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendRequestImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
        cancelRequestBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        sendRequestBtn.cornerRadiusView(radius: 6)
        cancelRequestBtn.cornerRadiusView(radius: 6)
        messageBtn.cornerRadiusView(radius: 6)
        unblockBtn.cornerRadiusView(radius: 6)
        friendRequestImg.cornerRadiusForHeight()
        
        sendRequestBtn.layer.applySketchShadow(color: UIColor.color("#F4F8F3")!, alpha: 1, x: 34, y: 34, blur: 89, spread: 5)
        cancelRequestBtn.layer.applySketchShadow(color: UIColor.color("#F4F8F3")!, alpha: 1, x: 34, y: 34, blur: 89, spread: 5)
        
        cancelRequestBtn.titleLabel?.numberOfLines = 2
        cancelRequestBtn.titleLabel?.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        HandleCancelRequestBtn?()
    }
    
    @IBAction func unblockBtn(_ sender: Any) {
        HandleUnblocktBtn?()
    }
    
    
    @IBAction func messageBtn(_ sender: Any) {
        HandleMessageBtn?()
    }
    
    @IBAction func refusedRequestBtn(_ sender: Any) {
        HandleRefusedBtn?()
    }
    
    @IBAction func accseptRequestBtn(_ sender: Any) {
        HandleAccseptBtn?()
    }
}
