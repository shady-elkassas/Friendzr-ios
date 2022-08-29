//
//  FriendsCommunityCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 24/08/2022.
//

import UIKit

class FriendsCommunityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTitleLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var interestMatchLbl: UILabel!
    @IBOutlet weak var tagsView: TagView!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var milesLbl: UILabel!
    
    
    var HandleViewProfileBtn: (()->())?
    var HandleSendRequestBtn: (()->())?
    var HandleSkipBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupView()
    }

    func setupView() {
        viewProfileBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        userImg.cornerRadiusView(radius: 10)
        sendRequestBtn.cornerRadiusView(radius: 6)
        viewProfileBtn.cornerRadiusView(radius: 6)
        skipBtn.cornerRadiusView(radius: 6)
    }
    
    
    @IBAction func viewProfileBtn(_ sender: Any) {
        HandleViewProfileBtn?()
    }
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        HandleSkipBtn?()
    }
}
