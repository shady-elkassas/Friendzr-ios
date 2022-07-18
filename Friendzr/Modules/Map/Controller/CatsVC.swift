//
//  CatsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/06/2022.
//

import UIKit

class CatsVC: UIViewController, UIViewControllerTransitioningDelegate {

    
//    @IBOutlet weak var SuperView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var applyBtn: UIButton!
    
    
    var viewmodel:AllCategoriesViewModel = AllCategoriesViewModel()
    let cellId = "TagCollectionViewCell"

    var selectedIDs = [String]()
    var selectedNames = [String]()
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var selectedCats:[CategoryObj] = [CategoryObj]()
    private var layout: UICollectionViewFlowLayout!

    var onListCatsCallBackResponse: ((_ listIDs: [String],_ listNames: [String],_ selectCats:[CategoryObj]) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        self.transitioningDelegate = self

        setupNavBar()
        initCloseBarButton()
        
        setupViews()
        clearNavigationBar()
        getCats()
        
        Defaults.availableVC = "CatsVC"
        print("availableVC >> \(Defaults.availableVC)")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        self.layout = TagsLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
    }
    //MARK: - APIs
    func getCats() {
        viewmodel.getAllCategories()
        viewmodel.cats.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                self.collectionView.reloadData()
                self.layout = TagsLayout()
            }
            
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
            }
        }
    }
    
    func setupViews() {
        collectionView.allowsMultipleSelection = true
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        applyBtn.cornerRadiusView(radius: 8)
    }    
    
    @IBAction func applyBtn(_ sender: Any) {
        onListCatsCallBackResponse?(selectedIDs,selectedNames,selectedCats)
        self.onDismiss()
    }
}

//MARK: - UICollectionViewDataSource
extension CatsVC:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.cats.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
        let model = viewmodel.cats.value?[indexPath.row]
        cell.tagNameLbl.text = model?.name ?? ""
        cell.editBtn.isHidden = true
        cell.editBtnWidth.constant = 0
        
        if selectedIDs.contains(model?.id ?? "") {
            cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
        }
        else {
            cell.containerView.backgroundColor = .black
        }
        
        cell.layoutSubviews()
        return cell
    }
}

//MARK: - UICollectionViewDelegate && UICollectionViewDelegateFlowLayout
extension CatsVC: UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewmodel.cats.value?[indexPath.row]
        let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
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
        if NetworkConected.internetConect {
            print("You selected cell #\(indexPath.row)!")
            let strData = viewmodel.cats.value?[indexPath.row]
            
            if selectedIDs.contains(strData?.id ?? "") {
                arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
                selectedIDs = selectedIDs.filter { $0 != strData?.id}
                selectedNames = selectedNames.filter { $0 != strData?.name}
            }
            else {
                arrSelectedIndex.append(indexPath)
                selectedIDs.append(strData?.id ?? "")
                selectedNames.append(strData?.name ?? "")
            }
            
            print(selectedIDs)
            collectionView.reloadData()
            
        }
    }
}
