//
//  NewFriendsCommunityCollectionViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 07/09/2022.
//

import UIKit

class NewFriendsCommunityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameTitleLbl: UILabel!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var interestMatchLbl: UILabel!
    @IBOutlet weak var viewProfileBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var milesLbl: UILabel!
    @IBOutlet weak var skipBtnView: UIView!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noAvailableInterestLbl: UILabel!

    var HandleViewProfileBtn: (()->())?
    var HandleSendRequestBtn: (()->())?
    var HandleCancelRequestBtn: (()->())?
    var HandleSkipBtn: (()->())?
    private var layout: UICollectionViewFlowLayout!
    var tagsList:[String] = [String]()
    let cellID = "TagCollectionViewCell"
    
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
        
        
        collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        self.layout = TagsLayout()
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

extension NewFriendsCommunityCollectionViewCell:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
        let model = tagsList[indexPath.row]
        cell.tagNameLbl.text = model
        cell.editBtn.isHidden = true
        cell.editBtnWidth.constant = 0
        cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
        cell.layoutSubviews()
        return cell
    }
}

extension NewFriendsCommunityCollectionViewCell:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = tagsList[indexPath.row]
        let width = model.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
        return CGSize(width: width + 50, height: 45)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
