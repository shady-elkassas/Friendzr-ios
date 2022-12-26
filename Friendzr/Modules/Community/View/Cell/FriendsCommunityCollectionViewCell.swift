//
//  FriendsCommunityCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 24/08/2022.
//

import UIKit
import SDWebImage

class FriendsCommunityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTitleLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var interestMatchLbl: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var skipBtnView: UIView!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var tagsView: TagListView!
    @IBOutlet weak var noAvailableInterestLbl: UILabel!
    @IBOutlet weak var seemoreLbl: UILabel!
    @IBOutlet weak var seemoreBtn: UIButton!
    @IBOutlet weak var viewProfileFromTagsBtn: UIButton!
    
    var HandleViewProfileBtn: (()->())?
    var HandleSendRequestBtn: (()->())?
    var HandleCancelRequestBtn: (()->())?
    var HandleSkipBtn: (()->())?
    var HandleSeeMoreBtn: (()->())?
    
    var model:RecommendedPeopleObj! {
        didSet {
            nameTitleLbl.text = model?.name
            
            let kmNum:Double = (model?.distanceFromYou ?? 0) * 1.60934 //convert miles to kms
            milesLbl.text = "\(kmNum.rounded(toPlaces: 1)) km from you"
            interestMatchLbl.text = "\(Int(model?.interestMatchPercent ?? 0.0)) % interest match"
            
            userImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            userImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            
            seemoreBtn.isHidden = true
            seemoreLbl.isHidden = true
            
            tagsView.removeAllTags()
            if (model?.matchedInterests?.count ?? 0) == 0 {
                noAvailableInterestLbl.isHidden = false
            }
            else {
                noAvailableInterestLbl.isHidden = true
                for item in model?.matchedInterests ?? [] {
                    tagsView.addTag(tagId: item, title: "#" + (item).capitalizingFirstLetter())
                }
            }
        }
    }
    
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
        skipBtnView.cornerRadiusView(radius: 6)
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
    
    @IBAction func userImgBtn(_ sender: Any) {
        HandleViewProfileBtn?()
    }
    @IBAction func seemoreBtn(_ sender: Any) {
        HandleSeeMoreBtn?()
    }
    
    @IBAction func viewProfileFromTagsBtn(_ sender: Any) {
        HandleViewProfileBtn?()
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
