//
//  CategoriesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/11/2021.
//

import UIKit

class CategoriesVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var collecetionView: UICollectionView!
    @IBOutlet weak var saveBtn: UIButton!
    
    //MARK: - Properties
    var catID = ""
    var onCategoryCallBackResponse: ((_ data: String, _ value: String) -> ())?
    var catsModel:[CategoryObj]? = [CategoryObj]()
    var catname = ""
    let cellId = "CategoryCollectionViewCell"
    var catsVM:AllCategoriesViewModel = AllCategoriesViewModel()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Categories".localizedString
        initBackButton()
        setupViews()
        getCats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CancelRequest.currentTask = false
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - APIs
    func getCats() {
        catsVM.getAllCategories()
        catsVM.cats.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                self?.collecetionView.dataSource = self
                self?.collecetionView.delegate = self
                self?.collecetionView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        catsVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    //MARK: - Helpers
    func setupViews() {
        collecetionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        saveBtn.cornerRadiusView(radius: 8)
    }
    
    //MARK: - Actions
    @IBAction func saveBtn(_ sender: Any) {
        onCategoryCallBackResponse!(catID,catname)
        self.onPopup()
    }
}

//MARK: - UICollectionViewDataSource
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
//MARK: - UICollectionViewDelegateFlowLayout && UICollectionViewDelegate
extension CategoriesVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = catsVM.cats.value?[indexPath.row]
        catname = model?.name ?? ""
        catID = model?.id ?? ""
    }
}
