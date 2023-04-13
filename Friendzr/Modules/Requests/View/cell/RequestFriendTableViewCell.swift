//
//  RequestFriendTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/03/2023.
//

import UIKit

class RequestFriendTableViewCell: UITableViewCell {
    
    //    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var friendRequestImg: UIImageView!
    @IBOutlet weak var friendRequestNameLbl: UILabel!
    @IBOutlet weak var friendRequestUserNameLbl: UILabel!
    @IBOutlet weak var friendRequestDateLbl: UILabel!
    @IBOutlet weak var deleteRequestBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var stackViewBtns: UIStackView!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var requestRemovedLbl: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var interestMatchPercentLbl: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var imageIsVerifiedImg: UIImageView!
    @IBOutlet weak var messageRequestLbl: UILabel!
    @IBOutlet weak var messageRequestBoxView: UIView!
    @IBOutlet weak var messageRequestBoxViewHeight: NSLayoutConstraint!
    @IBOutlet weak var showMessageBtn: UIButton!
    
    var HandleDeleteBtn: (() -> ())?
    var HandleAcceptBtn: (() -> ())?
    var HandleMessageBtn: (() -> ())?
    var HandleShowMessageBtn: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendRequestImg.cornerRadiusForHeight()
        messageBtn.cornerRadiusView(radius: 6)
        friendRequestImg.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
        messageRequestBoxView.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
        messageRequestBoxView.cornerRadiusView(radius: 6)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        HandleDeleteBtn?()
    }
    @IBAction func acceptBtn(_ sender: Any) {
        HandleAcceptBtn?()
    }
    @IBAction func messageBtn(_ sender: Any) {
        HandleMessageBtn?()
    }
    
    @IBAction func showMessageBtn(_ sender: Any) {
        HandleShowMessageBtn?()
    }
    
}
