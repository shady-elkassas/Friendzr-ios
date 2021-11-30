//
//  SelectedTagsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/11/2021.
//

import UIKit

class SelectedTagsVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var hideView: UIView!
    
    private var layout: UICollectionViewFlowLayout!
    var viewmodel = InterestsViewModel()
    var selectedInterests:[InterestObj]!
    var onInterestsCallBackResponse: ((_ data: [String], _ value: [String]) -> ())?
    
    var arrData = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedDataIds = [String]() // This is selected cell id array
    var arrSelectedDataNames = [String]() // This is selected cell name array
    
    let cellId = "TagCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        title = "Choose Your Tags"
        
        setupView()
        getAllTags()
    }
    
    func setupView() {
        saveBtn.cornerRadiusView(radius: 8)
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.interests.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
}

extension SelectedTagsVC: UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewmodel.interests.value?[indexPath.row]
        let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
        print("\(width ?? 0.0)")
        
        return CGSize(width: width! + 50, height: 45)
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
        
        let strData = viewmodel.interests.value?[indexPath.row]
        
        if arrSelectedDataIds.contains(strData?.id ?? "") {
            arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
            arrSelectedDataIds = arrSelectedDataIds.filter { $0 != strData?.id}
            arrSelectedDataNames = arrSelectedDataNames.filter { $0 != strData?.name}
        }
        else {
            if arrSelectedDataIds.count < 5 {
                arrSelectedIndex.append(indexPath)
                arrSelectedDataIds.append(strData?.id ?? "")
                arrSelectedDataNames.append(strData?.name ?? "")
            }else {
                self.showAlert(withMessage: "Please the number of tags must not be more than 5")
            }
        }
        
        
        print(arrSelectedDataIds)
        
        collectionView.reloadData()
    }
}
