//
//  MyProfileViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import SDWebImage
import ListPlaceholder

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyMessageLbl: UILabel!
    @IBOutlet weak var triAgainBtn: UIButton!
    
    
    var viewmodel: ProfileViewModel = ProfileViewModel()
    var internetConnection:Bool = false
    
    let imageCellID = "ImageProfileTableViewCell"
    let userNameCellId = "ProfileUserNameTableViewCell"
    let interestsCellId = "InterestsProfileTableViewCell"
    let bestDescribesCellId = "BestDescribesTableViewCell"
    let aboutmeCellId = "AboutMeTableViewCell"
    let preferCellId = "PreferToTableViewCell"
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()
    
    var btnSelect:Bool = false
    var selectedVC:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Profile".localizedString
        
        if selectedVC {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        clearNavigationBar()
        setupView()
        
        tableView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMyProfile), name: Notification.Name("updateMyProfile"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideView.isHidden = false
        if selectedVC {
            Defaults.availableVC = "PresentMyProfileViewController"
        }else {
            Defaults.availableVC = "MyProfileViewController"
        }
        
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        self.hideView.isHidden = false
    }
    
    
    @objc func didPullToRefresh() {
        print("Refersh")
        btnSelect = false
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    @objc func updateMyProfile() {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    //MARK: - API
    func getProfileInformation() {
        self.hideView.isHidden = false
        self.hideView.showLoader()
        viewmodel.getProfileInfo()
        viewmodel.userModel.bind { [unowned self]value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
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
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
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
            self.hideView.isHidden = true
            self.emptyView.isHidden = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            internetConnection = true
            getProfileInformation()
        case .wifi:
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            internetConnection = true
            getProfileInformation()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateUserInterfaceBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnection = false
        case .wwan:
            internetConnection = true
        case .wifi:
            internetConnection = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
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
    
    func setupView() {
        tableView.register(UINib(nibName: imageCellID, bundle: nil), forCellReuseIdentifier: imageCellID)
        tableView.register(UINib(nibName: userNameCellId, bundle: nil), forCellReuseIdentifier: userNameCellId)
        tableView.register(UINib(nibName: interestsCellId, bundle: nil), forCellReuseIdentifier: interestsCellId)
        tableView.register(UINib(nibName: bestDescribesCellId, bundle: nil), forCellReuseIdentifier: bestDescribesCellId)
        tableView.register(UINib(nibName: aboutmeCellId, bundle: nil), forCellReuseIdentifier: aboutmeCellId)
        tableView.register(UINib(nibName: preferCellId, bundle: nil), forCellReuseIdentifier: preferCellId)
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 10)
        }
        
        triAgainBtn.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
}

extension MyProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewmodel.userModel.value
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: imageCellID, for: indexPath) as? ImageProfileTableViewCell else {return UITableViewCell()}
            
            cell.profileImgLoader.isHidden = true
                cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            cell.ageLbl.text = "\(model?.age ?? 0)"
            if model?.gender == "other" {
                cell.genderlbl.text = "other(".localizedString + "\(model?.otherGenderName ?? "")" + ")"
            }else {
                cell.genderlbl.text = model?.gender
            }
            
            cell.HandleEditBtn = {
                self.btnSelect = true
                self.updateUserInterfaceBtns()
                if self.internetConnection {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
                    vc.profileModel = self.viewmodel.userModel.value
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }
            
            return cell
        }
        else if indexPath.row == 1 {//name & username
            guard let cell = tableView.dequeueReusableCell(withIdentifier: userNameCellId, for: indexPath) as? ProfileUserNameTableViewCell else {return UITableViewCell()}
            cell.userNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.nameLbl.text = model?.userName
            return cell
        }
        else if indexPath.row == 2 {//interests...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: interestsCellId, for: indexPath) as? InterestsProfileTableViewCell else {return UITableViewCell()}
            cell.tagsListView.removeAllTags()
            for item in model?.listoftagsmodel ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
            }
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        else if indexPath.row == 3 {//I am ..
            guard let cell = tableView.dequeueReusableCell(withIdentifier: bestDescribesCellId, for: indexPath) as? BestDescribesTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            for item in model?.iamList ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
            }
            
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        
        else if indexPath.row == 4 {//preferTo
            guard let cell = tableView.dequeueReusableCell(withIdentifier: preferCellId, for: indexPath) as? PreferToTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            for item in model?.prefertoList ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
            }
            
            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        else {//more about me...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: aboutmeCellId, for: indexPath) as? AboutMeTableViewCell else {return UITableViewCell()}
            cell.aboutMeLbl.text = model?.bio
            cell.titleLbl.text = "More about me..."
            return cell
        }
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.bounds.height
        
        if indexPath.row == 0 {
            return height/2.3
        }
        else {
            return UITableView.automaticDimension
        }
    }
}
