//
//  CategoriesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/11/2021.
//

import UIKit

class CategoriesVC: UIViewController {
    
    @IBOutlet weak var collecetionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var catID = ""
    var onCategoryCallBackResponse: ((_ data: String, _ value: String) -> ())?
    var catsModel:[CategoryObj]? = [CategoryObj]()
    var catname = ""
    let cellId = "CategoryCollectionViewCell"
    var catsVM:AllCategoriesViewModel = AllCategoriesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Categories"
        initBackButton()
        setupNavBar()
        setupViews()
        getCats()
    }
    
    //MARK:- APIs
    func getCats() {
        self.showLoading()
        catsVM.getAllCategories()
        catsVM.cats.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                self.hideLoading()
                collecetionView.dataSource = self
                collecetionView.delegate = self
                collecetionView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        catsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    func setupViews() {
        collecetionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        saveBtn.cornerRadiusView(radius: 8)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        onCategoryCallBackResponse!(catID,catname)
        self.onPopup()
    }
}

extension CategoriesVC : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catsVM.cats.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collecetionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? CategoryCollectionViewCell else {return UICollectionViewCell()}
        let model = catsVM.cats.value?[indexPath.row]
        cell.tagNameLbl.text = model?.name
        return cell
    }
}

extension CategoriesVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = catsVM.cats.value?[indexPath.row]
        catname = model?.name ?? ""
        catID = model?.id ?? ""
    }
}
