//
//  FriendProfileViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import ListPlaceholder
import Network
import SDWebImage

class FriendProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyMessageLbl: UILabel!
    @IBOutlet weak var triAgainBtn: UIButton!
    
    let imageCellId = "FriendImageProfileTableViewCell"
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
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    var viewmodel:FriendViewModel = FriendViewModel()
    var userID:String = ""
    var userName:String = ""
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
//    var internetConect:Bool = false
    var btnSelect:Bool = false
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var selectedVC:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        if selectedVC {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        
        clearNavigationBar()
        setupView()
        
        initOptionsUserButton()
        tableView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(updateFriendVC), name: Notification.Name("updateFriendVC"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedVC {
            Defaults.availableVC = "PresentFriendProfileViewController"
        }else {
            Defaults.availableVC = "FriendProfileViewController"
            
        }
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        hideView.hideLoader()
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        btnSelect = false
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    func setupView() {
        tableView.register(UINib(nibName: imageCellId, bundle: nil), forCellReuseIdentifier: imageCellId)
        tableView.register(UINib(nibName: userNameCellId, bundle: nil), forCellReuseIdentifier: userNameCellId)
        tableView.register(UINib(nibName: interestsCellId, bundle: nil), forCellReuseIdentifier: interestsCellId)
        tableView.register(UINib(nibName: bestDescribesCellId, bundle: nil), forCellReuseIdentifier: bestDescribesCellId)
        tableView.register(UINib(nibName: aboutmeCellId, bundle: nil), forCellReuseIdentifier: aboutmeCellId)
        tableView.register(UINib(nibName: preferCellId, bundle: nil), forCellReuseIdentifier: preferCellId)
        triAgainBtn.cornerRadiusView(radius: 6)
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 10)
        }
    }
    
    @objc func updateFriendVC() {
        DispatchQueue.main.async {
            self.getFriendProfileInformation()
        }
    }
    
    //MARK:- APIs
    func getFriendProfileInformation() {
        self.hideView.hideLoader()
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.title = value.userName ?? ""
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            self.hideLoading()
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func loadUserData() {
        self.hideView.showLoader()
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                DispatchQueue.main.async {
                    self.title = value.userName ?? ""
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
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.emptyView.isHidden = false
                self.hideView.isHidden = true
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.loadUserData()
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.loadUserData()
            }
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
        }
        else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyMessageLbl.text = "Network is unavailable, please try again!".localizedString
            triAgainBtn.alpha = 1.0
        }
    }
    
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
}

extension FriendProfileViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        let model = viewmodel.model.value
        
        if indexPath.row == 0 {//image
            guard let cell = tableView.dequeueReusableCell(withIdentifier: imageCellId, for: indexPath) as? FriendImageProfileTableViewCell else {return UITableViewCell()}
            
            cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.ageLbl.text = "\(model?.age ?? 0)"
            
            if model?.gender == "other" {
                cell.genderLlb.text = "other(".localizedString + "\(model?.otherGenderName ?? "")" + ")"
            }else {
                cell.genderLlb.text = model?.gender
            }
            
            switch model?.key {
            case 0:
                //Status = normal case
                cell.acceptBtn.isHidden = true
                cell.refuseBtn.isHidden = true
                cell.cancelBtn.isHidden = true
                cell.sendRequestBtn.isHidden = false
                cell.friendStackView.isHidden = true
                cell.unblockBtn.isHidden = true
                break
            case 1:
                //Status = I have added a friend request
                cell.acceptBtn.isHidden = true
                cell.refuseBtn.isHidden = true
                cell.cancelBtn.isHidden = false
                cell.sendRequestBtn.isHidden = true
                cell.friendStackView.isHidden = true
                cell.unblockBtn.isHidden = true
                break
            case 2:
                //Status = Send me a request to add a friend
                cell.acceptBtn.isHidden = false
                cell.refuseBtn.isHidden = false
                cell.cancelBtn.isHidden = true
                cell.sendRequestBtn.isHidden = true
                cell.friendStackView.isHidden = true
                cell.unblockBtn.isHidden = true
                break
            case 3:
                //Status = We are friends
                cell.acceptBtn.isHidden = true
                cell.refuseBtn.isHidden = true
                cell.cancelBtn.isHidden = true
                cell.sendRequestBtn.isHidden = true
                cell.friendStackView.isHidden = false
                cell.unblockBtn.isHidden = true
                break
            case 4:
                //Status = I block user
                cell.acceptBtn.isHidden = true
                cell.refuseBtn.isHidden = true
                cell.cancelBtn.isHidden = true
                cell.sendRequestBtn.isHidden = true
                cell.friendStackView.isHidden = true
                cell.unblockBtn.isHidden = false
                break
            case 5:
                //Status = user block me
                cell.acceptBtn.isHidden = true
                cell.refuseBtn.isHidden = true
                cell.cancelBtn.isHidden = true
                cell.sendRequestBtn.isHidden = true
                cell.friendStackView.isHidden = true
                cell.unblockBtn.isHidden = true
                break
            case 6:
                break
            default:
                break
            }
            
            cell.HandleSendRequestBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
                    self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 1,requestdate: "\(actionDate) \(actionTime)") { error, message in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = message else {return}
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            self.getFriendProfileInformation()
                        }
                    }
                }
            }
            
            cell.HandleCancelBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.changeTitleBtns(btn: cell.cancelBtn, title: "Canceling...".localizedString)
                    self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6,requestdate: "\(actionDate) \(actionTime)") { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = message else {return}
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            self.getFriendProfileInformation()
                        }
                        
                    }
                }
            }
            
            cell.HandleRefuseBtn = {
                self.btnSelect = true
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                self.alertView?.titleLbl.text = "Confirm?".localizedString
                self.alertView?.detailsLbl.text = "Are you sure you want to refuse this request?".localizedString
                
                self.alertView?.HandleConfirmBtn = {
                    if NetworkConected.internetConect == true {
                        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6,requestdate: "\(actionDate) \(actionTime)") { error, message in
                            self.hideLoading()
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                            }
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                            }
                            
                            DispatchQueue.main.async {
                                self.getFriendProfileInformation()
                            }
                            
                        }
                    }
                    
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.alertView?.alpha = 0
                    }) { (success: Bool) in
                        self.alertView?.removeFromSuperview()
                        self.alertView?.alpha = 1
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.alertView)!)
            }
            
            cell.HandleAcceptBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 2,requestdate: "\(actionDate) \(actionTime)") { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            
                            return
                        }
                        
                        guard let _ = message else {return}
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            self.getFriendProfileInformation()
                        }
                    }
                }
            }
            
            cell.HandleUnFriendBtn = {
                self.btnSelect = true
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                self.alertView?.titleLbl.text = "Confirm?".localizedString
                self.alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
                
                self.alertView?.HandleConfirmBtn = {
                    if NetworkConected.internetConect == true {
                        
                        cell.sendRequestBtn.isHidden = false
                        cell.friendStackView.isHidden = true
                        
                        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 5,requestdate: "\(actionDate) \(actionTime)") { error, message in
                            self.hideLoading()
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            
                            if self.selectedVC {
                                DispatchQueue.main.async {
                                    Router().toHome()
                                }
                            }else {
                                DispatchQueue.main.async {
                                    self.getFriendProfileInformation()
                                }
                            }
                        }
                    }else {
                        return
                    }
                    
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.alertView?.alpha = 0
                    }) { (success: Bool) in
                        self.alertView?.removeFromSuperview()
                        self.alertView?.alpha = 1
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.alertView)!)
            }
            
            cell.HandleBlockBtn = {
                self.btnSelect = true
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.alertView?.titleLbl.text = "Confirm?".localizedString
                self.alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
                
                self.alertView?.HandleConfirmBtn = {
                    // handling code
                    if NetworkConected.internetConect == true {
                        self.changeTitleBtns(btn: cell.blockBtn, title: "Sending...".localizedString)
                        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 3,requestdate: "\(actionDate) \(actionTime)") { error, message in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            
                            if self.selectedVC {
                                Router().toHome()
                            }else {
                                self.onPopup()
                            }
                        }
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.alertView?.alpha = 0
                    }) { (success: Bool) in
                        self.alertView?.removeFromSuperview()
                        self.alertView?.alpha = 1
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.alertView)!)
            }
            
            cell.HandleUnblockBtn = {
                self.btnSelect = true
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                self.alertView?.titleLbl.text = "Confirm?".localizedString
                self.alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
                
                self.alertView?.HandleConfirmBtn = { [self] in
                    // handling code
                    if NetworkConected.internetConect == true {
                        
                        self.changeTitleBtns(btn: cell.unblockBtn, title: "Sending...")
                        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 4,requestdate: "\(actionDate) \(actionTime)") { error, message in
                            
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            DispatchQueue.main.async {
                                self.getFriendProfileInformation()
                            }
                        }
                    }else {
                        return
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.alertView?.alpha = 0
                    }) { (success: Bool) in
                        self.alertView?.removeFromSuperview()
                        self.alertView?.alpha = 1
                        self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.alertView)!)
            }
            
            cell.sendRequestBtn.setTitle("Send Request".localizedString, for: .normal)
            cell.cancelBtn.setTitle("Cancel Request".localizedString, for: .normal)
            cell.acceptBtn.setTitle("Accept".localizedString, for: .normal)
            cell.refuseBtn.setTitle("Cancel".localizedString, for: .normal)
            cell.unblockBtn.setTitle("Unblock".localizedString, for: .normal)
            cell.unFriendBtn.setTitle("Unfriend".localizedString, for: .normal)
            cell.blockBtn.setTitle("Block".localizedString, for: .normal)
            
            return cell
            
        }
        else if indexPath.row == 1 {//name & username
            guard let cell = tableView.dequeueReusableCell(withIdentifier: userNameCellId, for: indexPath) as? ProfileUserNameTableViewCell else {return UITableViewCell()}
            cell.userNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.nameLbl.text = model?.userName
            return cell
        }
        else if indexPath.row == 2 {//interests
            guard let cell = tableView.dequeueReusableCell(withIdentifier: interestsCellId, for: indexPath) as? InterestsProfileTableViewCell else {return UITableViewCell()}
            cell.tagsListView.removeAllTags()
            //            if (model?.listoftagsmodel?.count ?? 0) > 4 {
            //                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[0].tagID ?? "", title: model?.listoftagsmodel?[0].tagname ?? "")
            //                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[1].tagID ?? "", title: model?.listoftagsmodel?[1].tagname ?? "")
            //                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[2].tagID ?? "", title: model?.listoftagsmodel?[2].tagname ?? "")
            //                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[3].tagID ?? "", title: model?.listoftagsmodel?[3].tagname ?? "")
            //            }else {
            for item in model?.listoftagsmodel ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
            }
            //            }
            
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
        else if indexPath.row == 3 {//what i am
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
        else if indexPath.row == 4 {//I prefer to...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: preferCellId, for: indexPath) as? PreferToTableViewCell else {return UITableViewCell()}
            cell.tagsListView.removeAllTags()
            for item in model?.prefertoList ?? [] {
                cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname))
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

extension FriendProfileViewController:UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return screenH/3
        }
        else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.model.value
        if indexPath.row == 0 {
            guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
            popupVC.imgURL = model?.userImage
            present(popupVC, animated: true, completion: nil)
        }
    }
}
extension FriendProfileViewController {
    func initOptionsUserButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //        button.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)
        //        button.cornerRadiusForHeight()
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleUserOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleUserOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.selectedVC = "PresentC"
                    vc.isEvent = false
                    vc.id = self.userID
                    vc.reportType = 3
                    self.present(controller, animated: true)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }
        else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.selectedVC = "PresentC"
                    vc.isEvent = false
                    vc.id = self.userID
                    vc.reportType = 3
                    self.present(controller, animated: true)
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
}
