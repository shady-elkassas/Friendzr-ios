//
//  FriendProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import ListPlaceholder

class FriendProfileVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var svBtns: UIStackView!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var unfriendBtn: UIButton!
    @IBOutlet weak var sendRequestBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var aboutFriendLbl: UILabel!
    @IBOutlet weak var cancelRequestBtn: UIButton!
    @IBOutlet weak var respondBtn: UIButton!
    @IBOutlet weak var unblockBtn: UIButton!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    @IBOutlet weak var refusedBtn: UIButton!
    @IBOutlet weak var tagsTopConstrains: NSLayoutConstraint!
    @IBOutlet weak var tagsBotomConstrains: NSLayoutConstraint!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    var viewmodel:FriendViewModel = FriendViewModel()
    var userID:String = ""
    
    var strWidth:CGFloat = 0
    var strheight:CGFloat = 0
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var internetConect:Bool = false
        
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        initOptionsUserButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackColorButton()
        clearNavigationBar()
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        superView.hideLoader()
    }
    
    //MARK:- APIs
    func getFriendProfileInformation() {
        self.superView.hideLoader()
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            self.hideLoading()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                setupData()
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
    
    
    func loadUserData() {
        self.superView.showLoader()
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                setupData()
                self.superView.hideLoader()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
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
    
    //MARK: - Actions
    @IBAction func sendRequestBtn(_ sender: Any) {
        self.updateUserInterfaceBtns()
        if self.internetConect == true {
            changeTitleBtns(btn: sendRequestBtn, title: "Sending...".localizedString)
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 1) { error, message in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = message else {return}
                self.getFriendProfileInformation()
            }
        }
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        self.updateUserInterfaceBtns()
        if self.internetConect == true {
            self.changeTitleBtns(btn: self.cancelRequestBtn, title: "Canceling...".localizedString)
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6) { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = message else {return}
                self.getFriendProfileInformation()
            }
        }
    }
    
    @IBAction func refusedRequestBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to refuse this request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6) { error, message in
                    self.hideLoading()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = message else {return}
                    self.getFriendProfileInformation()
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func respondBtn(_ sender: Any) {
        self.updateUserInterfaceBtns()
        if self.internetConect == true {
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 2) { error, message in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                    return
                }
                
                guard let _ = message else {return}

                self.getFriendProfileInformation()
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                }
            }
        }
    }
    
    @IBAction func unfriendBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                
                self.sendRequestBtn.isHidden = false
                self.svBtns.isHidden = true
                
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 5) { error, message in
                    self.hideLoading()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = message else {return}
                    
                    self.getFriendProfileInformation()
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func blockBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            // handling code
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                self.changeTitleBtns(btn: self.blockBtn, title: "Sending...".localizedString)
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 3) { error, message in
                    self.hideLoading()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = message else {return}
                    self.getFriendProfileInformation()
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
        
        self.view.addSubview((alertView)!)
    }
    
    @IBAction func unBlockBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
        
        alertView?.HandleConfirmBtn = { [self] in
            // handling code
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                
                self.changeTitleBtns(btn: self.unblockBtn, title: "Sending...")
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 4) { error, message in
                    self.hideLoading()
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = message else {return}
                    self.getFriendProfileInformation()
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
        
        self.view.addSubview((alertView)!)
    }
    
    //MARK: - Helpers
    
    //change title for any btns
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }

    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            loadUserData()
        case .wifi:
            internetConect = true
            loadUserData()
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
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
        case .wifi:
            internetConect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast( "No avaliable network ,Please try again!".localizedString)
    }
    
    func setup() {
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: "Montserrat-Regular", size: 10)!
        tagListView.tagLineBreakMode = .byTruncatingTail
        
        sendRequestBtn.cornerRadiusView(radius: 15)
        cancelRequestBtn.cornerRadiusView(radius: 15)
        respondBtn.cornerRadiusView(radius: 15)
        refusedBtn.cornerRadiusView(radius: 15)
        unblockBtn.cornerRadiusView(radius: 15)
        unfriendBtn.cornerRadiusView(radius: 15)
        blockBtn.cornerRadiusView(radius: 15)
        blockBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        cancelRequestBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        unblockBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        refusedBtn.setBorder(color: UIColor.white.cgColor, width: 1)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
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
    
    let myGroup = DispatchGroup()

    func setupData() {
        let model = viewmodel.model.value
        myGroup.notify(queue: .main) { [self] in
            myGroup.enter()
            DispatchQueue.main.async {
                self.tagListView.removeAllTags()
                for item in model?.listoftagsmodel ?? [] {
                    self.tagListView.addTag(tagId: item.tagID, title: "#\(item.tagname)")
                }
                
                print("tagListView.rows \(self.tagListView.rows)")
                self.tagListViewHeight.constant = CGFloat(self.tagListView.rows * 25)
                
                if self.tagListView.rows == 1 {
                    self.tagsTopConstrains.constant = 16
                    self.tagsBotomConstrains.constant = 16
                }else if self.tagListView.rows == 2 {
                    self.tagsTopConstrains.constant = 18
                    self.tagsBotomConstrains.constant = 26
                }else if self.tagListView.rows == 3 {
                    self.tagsTopConstrains.constant = 18
                    self.tagsBotomConstrains.constant = 40
                }else {
                    self.tagsTopConstrains.constant = 18
                    self.tagsBotomConstrains.constant = 46
                }
            }
            
            DispatchQueue.main.async {
                
                self.aboutFriendLbl.text = model?.bio
                self.userNameLbl.text = "@\(model?.displayedUserName ?? "")"
                self.nameLbl.text = model?.userName
                self.ageLbl.text = "\(model?.age ?? 0)"
                
                if model?.gender == "other" {
                    genderLbl.text = "other(".localizedString + "\(model?.otherGenderName ?? ""))"
                }else {
                    genderLbl.text = model?.gender
                }
                
                self.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            }
            
            DispatchQueue.main.async {
                self.btnsState(model)
                self.changeTitleBtns(btn: self.sendRequestBtn, title: "Send Request".localizedString)
                self.changeTitleBtns(btn: self.cancelRequestBtn, title: "Cancel Request".localizedString)
                self.changeTitleBtns(btn: self.unblockBtn, title: "Unblock".localizedString)
                self.changeTitleBtns(btn: self.blockBtn, title: "Block".localizedString)
                self.changeTitleBtns(btn: self.respondBtn, title: "Accept".localizedString)
            }
            
            myGroup.leave()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
        }
        
    }
    
    func btnsState(_ model: FriendObj?) {
        switch model?.key {
        case 0:
            //Status = normal case
            respondBtn.isHidden = true
            refusedBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = false
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            respondBtn.isHidden = true
            refusedBtn.isHidden = true
            cancelRequestBtn.isHidden = false
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            respondBtn.isHidden = false
            refusedBtn.isHidden = false
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            respondBtn.isHidden = true
            refusedBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = false
            unblockBtn.isHidden = true
            break
        case 4:
            //Status = I block user
            respondBtn.isHidden = true
            refusedBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = false
            break
        case 5:
            //Status = user block me
            respondBtn.isHidden = true
            refusedBtn.isHidden = true
            cancelRequestBtn.isHidden = true
            sendRequestBtn.isHidden = true
            svBtns.isHidden = true
            unblockBtn.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
    }
    
}

extension FriendProfileVC : TagListViewDelegate {
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        //        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        //        sender.removeTagView(tagView)
    }
}

extension FriendProfileVC {
    func initOptionsUserButton() {
        let imageName = "menu_WH_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)
        button.cornerRadiusForHeight()
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
                    vc.selectedVC = "Present"
                    vc.isEvent = false
                    vc.id = self.userID
                    vc.reportType = 3
                    self.present(controller, animated: true)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.selectedVC = "Present"
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
