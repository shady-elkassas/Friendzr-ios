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
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tagsViewhHeight: NSLayoutConstraint!
    
    //MARK: - Properties
    var viewmodel: ProfileViewModel = ProfileViewModel()
    var cellID = "TagLabelCollectionViewCell"
    var strWidth:CGFloat = 0
    var strheight:CGFloat = 0

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
                self.setProfileData()
                for item in value.listoftagsmodel ?? [] {
                    tagListView.addTag("#\(item.tagname)")
                }
                
                print("tagListView.rows \(tagListView.rows)")
                tagsViewhHeight.constant = CGFloat(tagListView.rows * 35)
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
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: "Montserrat-Regular", size: 12)!
    }
    
    func setProfileData() {
        let model = viewmodel.userModel.value
        aboutMeLBl.text = model?.bio
        userNameLbl.text = model?.generatedusername
        nameLbl.text = model?.userName
        ageLbl.text = "\(model?.age ?? 0)"
        genderLbl.text = model?.gender
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
    }
    
    //MARK: - Actions
    @IBAction func editBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MyProfileVC : TagListViewDelegate {
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
//        sender.removeTagView(tagView)
    }
}
