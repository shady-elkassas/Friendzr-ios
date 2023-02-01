//
//  ShowMoreTagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/09/2022.
//

import UIKit

class ShowMoreTagsVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tagsDownView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let catsCellId = "TagCollectionViewCell"
    private var layout: UICollectionViewFlowLayout!
    var tagsList:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        bgView?.addGestureRecognizer(tap)
        
        collectionView.register(UINib(nibName: catsCellId, bundle: nil), forCellWithReuseIdentifier: catsCellId)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        self.layout = TagsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        showMoreTagsView.isHidden = true
        self.dismiss(animated:true)
    }
}

extension ShowMoreTagsVC:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catsCellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
        
        let model = "#\(tagsList[indexPath.row])".capitalizingFirstLetter()
        cell.tagNameLbl.text = model
        cell.editBtn.isHidden = true
        cell.editBtnWidth.constant = 0
        cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
        
        cell.layoutSubviews()
        return cell
    }
    
  
}
extension ShowMoreTagsVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
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
