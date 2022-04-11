//
//  SelectedTagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/11/2021.
//

import UIKit
import SwiftUI
import ListPlaceholder
import Network

class SelectedTagsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyMessageLbl: UILabel!
    @IBOutlet weak var triAgainBtn: UIButton!

    lazy var addNewTagView = Bundle.main.loadNibNamed("AddNewTagView", owner: self, options: nil)?.first as? AddNewTagView
    
    private var layout: UICollectionViewFlowLayout!
    var viewmodel = InterestsViewModel()
    
    var btnSelect:Bool = false
//    var internetConnection:Bool = false

    var onInterestsCallBackResponse: ((_ data: [String], _ value: [String]) -> ())?
    
    var arrData = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedDataIds = [String]() // This is selected cell id array
    var arrSelectedDataNames = [String]() // This is selected cell name array
    
    let cellId = "TagCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
//        initAddTagButton()
        title = "I enjoy".localizedString
        
        setupView()
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SelectedTagsVC"
        print("availableVC >> \(Defaults.availableVC)")

        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.emptyView.isHidden = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.getAllTags()
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.getAllTags()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupView() {
        saveBtn.cornerRadiusView(radius: 8)
        triAgainBtn.cornerRadiusView(radius: 6)
        
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    func getAllTags() {
        self.collectionView.hideLoader()
        viewmodel.getAllInterests()
        viewmodel.interests.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.collectionView.delegate = self
                self.collectionView.dataSource = self
                self.collectionView.reloadData()
                self.layout = TagsLayout()
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }

    func HandleInternetConnection() {
        if btnSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyMessageLbl.text = "Network is unavailable, please try again!".localizedString
            triAgainBtn.alpha = 1.0
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        onInterestsCallBackResponse!(arrSelectedDataIds,arrSelectedDataNames)
        self.onPopup()
    }
    
    @IBAction func triAgain(_ sender: Any) {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
        let model = viewmodel.interests.value?[indexPath.row]
        cell.tagNameLbl.text = "#" + (model?.name ?? "").capitalizingFirstLetter()
        
//        if model?.isSharedForAll == true {
            cell.editBtn.isHidden = true
            cell.editBtnWidth.constant = 0
//        }else {
//            cell.editBtn.isHidden = false
//            cell.editBtnWidth.constant = 30
//        }
        
        if arrSelectedDataIds.contains(model?.id ?? "") {
            cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
        }
        else {
            cell.containerView.backgroundColor = .black
        }
        
        cell.HandleEditBtn = {
            self.showOptionTags(id:model?.id ?? "",name:model?.name ?? "")
        }
        
        cell.layoutSubviews()
        return cell
    }
}

extension SelectedTagsVC: UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewmodel.interests.value?[indexPath.row]
        let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
//        if model?.isSharedForAll == true {
            return CGSize(width: width! + 50, height: 45)
//        }else {
//            return CGSize(width: width! + 80, height: 45)
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
        btnSelect = true
        if NetworkConected.internetConect {
            print("You selected cell #\(indexPath.row)!")
            let strData = viewmodel.interests.value?[indexPath.row]
            
            if arrSelectedDataIds.contains(strData?.id ?? "") {
                arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
                arrSelectedDataIds = arrSelectedDataIds.filter { $0 != strData?.id}
                arrSelectedDataNames = arrSelectedDataNames.filter { $0 != strData?.name}
            }
            else {
                if Defaults.userTagM_MaxNumber != 0 {
                    if arrSelectedDataIds.count < Defaults.userTagM_MaxNumber {
                        arrSelectedIndex.append(indexPath)
                        arrSelectedDataIds.append(strData?.id ?? "")
                        arrSelectedDataNames.append(strData?.name ?? "")
                    }else {
                        DispatchQueue.main.async {
                            self.view.makeToast("The number of tags must not exceed \(Defaults.userTagM_MaxNumber)".localizedString)
                        }
                    }
                }else {
                    if arrSelectedDataIds.count < 8 {
                        arrSelectedIndex.append(indexPath)
                        arrSelectedDataIds.append(strData?.id ?? "")
                        arrSelectedDataNames.append(strData?.name ?? "")
                    }else {
                        DispatchQueue.main.async {
                            self.view.makeToast("The number of tags must not exceed 8".localizedString)
                        }
                    }
                }

            }
            
            print(arrSelectedDataIds)
            collectionView.reloadData()
        }
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
        self.addNewTagView?.newTagTxt.text = ""
        
        addNewTagView?.HandleConfirmBtn = {
            if self.addNewTagView?.newTagTxt.text == "" {
                self.view.makeToast("Please type the name of the tag first".localizedString)
            }else {
                
                self.viewmodel.addMyNewInterest(name: self.addNewTagView?.newTagTxt.text ?? "") { error, data in
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let data = data else {return}
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.getAllTags()
                        if Defaults.userTagM_MaxNumber != 0 {
                            if self.arrSelectedDataIds.count < Defaults.userTagM_MaxNumber {
                                self.arrSelectedDataIds.append(data.entityId ?? "")
                                self.arrSelectedDataNames.append(data.name ?? "")
                                print(self.arrSelectedDataNames)
                                self.collectionView.reloadData()
                            }
                        }else {
                            if self.arrSelectedDataIds.count < 8 {
                                self.arrSelectedDataIds.append(data.entityId ?? "")
                                self.arrSelectedDataNames.append(data.name ?? "")
                                print(self.arrSelectedDataNames)
                                self.collectionView.reloadData()
                            }
                        }
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
    
    
    func showOptionTags(id:String,name:String) {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Edit".localizedString, style: .default, handler: { action in
                self.addNewTagView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.addNewTagView?.newTagTxt.text = name
                
                self.addNewTagView?.HandleConfirmBtn = {
                    if self.addNewTagView?.newTagTxt.text == "" {
                        self.view.makeToast("Please type the name of the tag first".localizedString)
                    }else {
                        self.viewmodel.EditInterest(ByID: id, name: self.addNewTagView?.newTagTxt.text ?? "") { error, data in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = data else {return}
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                
                self.view.addSubview((self.addNewTagView)!)
                
            }))
            actionAlert.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                self.arrSelectedDataIds = self.arrSelectedDataIds.filter { $0 != id}
                self.arrSelectedDataNames = self.arrSelectedDataNames.filter { $0 != name}
                
                self.viewmodel.deleteInterest(ById: id) { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {return}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.getAllTags()
                    }
                    
//                    DispatchQueue.main.async {
//                        self.view.makeToast("Deleted successfully".localizedString)
//                    }
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Edit".localizedString, style: .default, handler: { action in
                self.addNewTagView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.addNewTagView?.newTagTxt.text = name
                
                self.addNewTagView?.HandleConfirmBtn = {
                    if self.addNewTagView?.newTagTxt.text == "" {
                        self.view.makeToast("Please type the name of the tag first".localizedString)
                    }else {
                        self.viewmodel.EditInterest(ByID: id, name: self.addNewTagView?.newTagTxt.text ?? "") { error, data in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = data else {return}
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.getAllTags()
                            }
                            
//                            DispatchQueue.main.async {
//                                self.view.makeToast("Edit successfully".localizedString)
//                            }
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
                
                self.view.addSubview((self.addNewTagView)!)
            }))
            actionSheet.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                self.arrSelectedDataIds = self.arrSelectedDataIds.filter { $0 != id}
                self.arrSelectedDataNames = self.arrSelectedDataNames.filter { $0 != name}
                
                self.viewmodel.deleteInterest(ById: id) { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {return}
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.getAllTags()
                    }
                    
//                    DispatchQueue.main.async {
//                        self.view.makeToast("Deleted successfully".localizedString)
//                    }
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
}
