//
//  FriendsCommunityCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/08/2022.
//

import UIKit

class FriendsCommunityCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTitleLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var interestMatchLbl: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var milesLbl: UILabel!
    
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var tagsView: TagListView!
    @IBOutlet weak var tagsListViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagsTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noAvailableInterestLbl: UILabel!
    @IBOutlet weak var emptyView: UIView!
    
    var HandleViewProfileBtn: (()->())?
    var HandleSendRequestBtn: (()->())?
    var HandleCancelRequestBtn: (()->())?
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
        cancelRequestBtn.cornerRadiusView(radius: 6)
        cancelRequestBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
        
        tagsView.delegate = self
        tagsView.textFont = UIFont(name: "Montserrat-SemiBold", size: 9)!
    }
    
    
    @IBAction func viewProfileBtn(_ sender: Any) {
        HandleViewProfileBtn?()
    }
    
    @IBAction func sendRequestBtn(_ sender: Any) {
        HandleSendRequestBtn?()
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        HandleCancelRequestBtn?()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        HandleSkipBtn?()
    }
}

extension FriendsCommunityCollectionViewCell : TagListViewDelegate {
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(tagView.tagId)")
        //        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        //        sender.removeTagView(tagView)
    }
    
}
