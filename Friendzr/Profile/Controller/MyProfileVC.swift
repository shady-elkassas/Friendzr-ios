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
    @IBOutlet weak var hideView: UIView!
    
    //MARK: - Properties
    var viewmodel: ProfileViewModel = ProfileViewModel()
    var cellID = "TagLabelCollectionViewCell"
    var strWidth:CGFloat = 0
    var strheight:CGFloat = 0
    
    var internetConnection:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackButton(btnColor: .black)
        clearNavigationBar()
    }
    
    //MARK: - API
    func getProfileInformation() {
        self.showLoading()
        viewmodel.getProfileInfo()
        viewmodel.userModel.bind { [unowned self]value in
            self.hideLoading()
            DispatchQueue.main.async {
                hideView.isHidden = true
                self.setProfileData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            self.hideLoading()
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    //MARK: - Helper
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnection = false
            HandleInternetConnection()
        case .wwan:
            internetConnection = true
            getProfileInformation()
        case .wifi:
            internetConnection = true
            getProfileInformation()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }
    
    func setupView() {
        editBtn.cornerRadiusForHeight()
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: "Montserrat-Regular", size: 12)!
    }
    
    func setProfileData() {
        let model = viewmodel.userModel.value
        aboutMeLBl.text = model?.bio
        userNameLbl.text = "@\(model?.generatedusername ?? "")"
        nameLbl.text = model?.userName
        ageLbl.text = "\(model?.age ?? 0)"
        genderLbl.text = model?.gender
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        
        tagListView.removeAllTags()
        for item in model?.listoftagsmodel ?? [] {
            tagListView.addTag("#\(item.tagname)")
        }
        print("tagListView.rows \(tagListView.rows)")
        tagsViewhHeight.constant = CGFloat(tagListView.rows * 35)
    }
    
    //MARK: - Actions
    @IBAction func editBtn(_ sender: Any) {
        updateUserInterface()
        if internetConnection {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
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
