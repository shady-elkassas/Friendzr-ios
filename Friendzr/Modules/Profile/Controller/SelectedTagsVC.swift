//
//  SelectedTagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/11/2021.
//

import UIKit
import SwiftUI

class newTag {
    
    var id: String? = ""
    var name: String? = ""
    var isSelected: Bool = false
    
    init(id:String,name:String,isSelected:Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
}

class SelectedTagsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var hideView: UIView!
    
    lazy var addNewTagView = Bundle.main.loadNibNamed("AddNewTagView", owner: self, options: nil)?.first as? AddNewTagView
    
    private var layout: UICollectionViewFlowLayout!
    var viewmodel = InterestsViewModel()
    var selectedInterests:[InterestObj]!
    
    var onInterestsCallBackResponse: ((_ data: [String], _ value: [String]) -> ())?
    
    var arrData = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedDataIds = [String]() // This is selected cell id array
    var arrSelectedDataNames = [String]() // This is selected cell name array
    var isSelected:Bool = false
    
    let cellId = "TagCollectionViewCell"
    let myTagsCellId = "MyTagsCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        initAddTagButton()
        title = "Choose Your Tags"
        
        setupView()
        getAllTags()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    func setupView() {
        saveBtn.cornerRadiusView(radius: 8)
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        collectionView.register(UINib(nibName: myTagsCellId, bundle: nil), forCellWithReuseIdentifier: myTagsCellId)
    }
    
    func getAllTags() {
        self.showLoading()
        viewmodel.getAllInterests()
        viewmodel.interests.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.hideLoading()
                hideView.isHidden = true
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                layout = TagsLayout()
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    
    @IBAction func saveBtn(_ sender: Any) {
        onInterestsCallBackResponse!(arrSelectedDataIds,arrSelectedDataNames)
        self.onPopup()
    }
    
}

extension SelectedTagsVC:UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.interests.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 0 {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
//            cell.tagNameLbl.text = "My Tags"
//            cell.tagNameLbl.textColor = UIColor.FriendzrColors.primary!
//            cell.containerView.backgroundColor = .clear
//            return cell
//        }else if indexPath.section == 1 {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myTagsCellId, for: indexPath) as? MyTagsCollectionViewCell else {return UICollectionViewCell()}
//            let model = newTagsAdded[indexPath.row]
//            cell.tagTitleLbl.text = "#\(model.name ?? "")"
//            return cell
//        }else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
            let model = viewmodel.interests.value?[indexPath.row]
            cell.tagNameLbl.text = "#\(model?.name ?? "")"
            
            if arrSelectedDataIds.contains(model?.id ?? "") {
                cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
            }
            else {
                cell.containerView.backgroundColor = .black
            }
            
            cell.layoutSubviews()
            return cell
//        }
    }
}

extension SelectedTagsVC: UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if indexPath.section == 0 {
//            return CGSize(width: 110, height: 45)
//        }else if indexPath.section == 1 {
//            let model = newTagsAdded[indexPath.row]
//            let width = model.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
//            return CGSize(width: width! + 150, height: 45)
//        }else {
            let model = viewmodel.interests.value?[indexPath.row]
            let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
            return CGSize(width: width! + 50, height: 45)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
//        if indexPath.section == 0 {
//            return
//        }else if indexPath.section == 1 {
//            return
//        }
//        else {
            let strData = viewmodel.interests.value?[indexPath.row]
            
            if arrSelectedDataIds.contains(strData?.id ?? "") {
                arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
                arrSelectedDataIds = arrSelectedDataIds.filter { $0 != strData?.id}
                arrSelectedDataNames = arrSelectedDataNames.filter { $0 != strData?.name}
            }
            else {
                if arrSelectedDataIds.count < 8 {
                    arrSelectedIndex.append(indexPath)
                    arrSelectedDataIds.append(strData?.id ?? "")
                    arrSelectedDataNames.append(strData?.name ?? "")
                }else {
                    //                self.showAlert(withMessage: "Please the number of tags must not be more than 8")
                    
                    DispatchQueue.main.async {
                        self.view.makeToast("Please the number of tags must not be more than 8")
                    }
                }
            }

            print(arrSelectedDataIds)
            collectionView.reloadData()
//        }
    }
    
    
    func initAddTagButton() {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "newTag_ic"), for: .normal)
        button.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
        button.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 12)
        button.addTarget(self, action:  #selector(addnewtag), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func addnewtag() {
        addNewTagView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        addNewTagView?.HandleConfirmBtn = {
            if self.addNewTagView?.newTagTxt.text == "" {
                self.view.makeToast("Please type the name of the tag first")
            }else {
                
                self.viewmodel.addMyNewInterest(name: self.addNewTagView?.newTagTxt.text ?? "") { error, data in
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = data else {return}
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.getAllTags()
                    }
                }
            }
            
            
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.addNewTagView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.addNewTagView?.alpha = 0
            }) { (success: Bool) in
                self.addNewTagView?.removeFromSuperview()
                self.addNewTagView?.alpha = 1
                self.addNewTagView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((addNewTagView)!)
    }
    
}
