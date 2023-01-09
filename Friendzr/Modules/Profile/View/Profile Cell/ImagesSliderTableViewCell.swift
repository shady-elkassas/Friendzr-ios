//
//  ImagesSliderTableViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 02/01/2023.
//

import UIKit

class ImagesSliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
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
    
    
    let cellID = "ImageCollectionViewCell"
    var images:[UIImage] = [UIImage]()
    
    var HandleMessageBtn: (()->())?
    var HandleRefuseBtn: (()->())?
    var HandleCancelBtn: (()->())?
    var HandleAcceptBtn: (()->())?
    var HandleUnFriendBtn: (()->())?
    var HandleSendRequestBtn: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)

        sendRequestBtn.cornerRadiusForHeight()
        cancelBtn.cornerRadiusForHeight()
        acceptBtn.cornerRadiusForHeight()
        refuseBtn.cornerRadiusForHeight()
        messageBtn.cornerRadiusForHeight()
        unfriendBtn.cornerRadiusForHeight()
        cancelBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        messageBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        refuseBtn.setBorder(color: UIColor.white.cgColor, width: 1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
    
    @IBAction func acceptBtn(_ sender: Any) {
        HandleAcceptBtn?()
    }
    
}
extension ImagesSliderTableViewCell:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.imgView.image = images[indexPath.row]
        return cell
    }
}

extension ImagesSliderTableViewCell: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

extension ImagesSliderTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collection = collectionView.bounds
        return CGSize(width: collection.width, height: collection.height)
    }
}
