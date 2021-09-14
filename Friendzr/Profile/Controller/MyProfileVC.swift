//
//  ProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import SDWebImage

class MyProfileVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var aboutMeLBl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    
    //MARK: - Properties
    var viewmodel: ProfileViewModel = ProfileViewModel()
    var cellID = "TagLabelCollectionViewCell"
    var strWidth:CGFloat = 0
    var strheight:CGFloat = 0
    
    private let tagsLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.backgroundColor = .black
        lbl.text = "Football"
        lbl.font = UIFont(name: "Montserrat-Regular", size: 10)
        return lbl
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getProfileInformation()
    }
    override func viewWillAppear(_ animated: Bool) {
        initBackButton(btnColor: .black)
        clearNavigationBar()
    }

    //MARK: - API
    func getProfileInformation() {
        viewmodel.getProfileInfo()
        viewmodel.userModel.bind { [unowned self]value in
            
            DispatchQueue.main.async {
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                self.setProfileData()
                let tagsCount = value.listoftagsmodel?.count
                collectionViewHeight.constant = CGFloat(((tagsCount! / 2) * 30))
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    //MARK: - Helper
    func setupView() {
        editBtn.cornerRadiusForHeight()
        collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
    }
    
    func setProfileData() {
        let model = viewmodel.userModel.value
        aboutMeLBl.text = model?.bio
        userNameLbl.text = model?.userName
        nameLbl.text = model?.userName
        ageLbl.text = "\(model?.age ?? 0)"
        genderLbl.text = model?.gender
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
    }
    
    //MARK: - Actions
    @IBAction func editBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
        vc.userModel = viewmodel.userModel.value
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.userModel.value?.listoftagsmodel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? TagLabelCollectionViewCell else {return UICollectionViewCell()}
        let model = viewmodel.userModel.value?.listoftagsmodel?[indexPath.row]
        cell.titleLbl.text = "#\(model?.tagname ?? "")"
        cell.containerView.cornerRadiusView(radius: 8)
        return cell
    }
}

extension MyProfileVC: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewmodel.userModel.value?.listoftagsmodel?[indexPath.row]
        strWidth = (model?.tagname.widthOfString(usingFont: UIFont(name: "Montserrat-Regular", size: 12)!))!
        strheight = (model?.tagname.heightOfString(usingFont: UIFont(name: "Montserrat-Regular", size: 12)!))!
        print("strWidth = \(strWidth)","strheight = \(strheight)")
        
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width / 4, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
