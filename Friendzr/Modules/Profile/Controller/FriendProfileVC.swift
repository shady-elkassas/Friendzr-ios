//
//  FriendProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

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
    @IBOutlet weak var hideView: UIView!
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initBackButton()
        clearNavigationBar()
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    func getFriendProfileInformation() {
        self.showLoading()
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [unowned self]value in
            self.hideLoading()
            DispatchQueue.main.async {
                hideView.isHidden = true
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
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    //set data for user
    
    //MARK: - Actions
    @IBAction func sendRequestBtn(_ sender: Any) {
        self.updateUserInterfaceBtns()
        if self.internetConect == true {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 1) { error, message in
                self.hideLoading()
                if let error = error {
//                    self.showAlert(withMessage: error)
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
//                self.showAlert(withMessage: message)
                DispatchQueue.main.async {
                    self.view.makeToast(message)
                }
                
                self.getFriendProfileInformation()
            }
        }
    }
    
    @IBAction func cancelRequestBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to cancel this request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6) { error, message in
                    self.hideLoading()
                    if let error = error {
//                        self.showAlert(withMessage: error)
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = message else {return}
//                    self.showAlert(withMessage: message)
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    self.getFriendProfileInformation()
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
    
    @IBAction func refusedRequestBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to cancel this request?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6) { error, message in
                    self.hideLoading()
                    if let error = error {
//                        self.showAlert(withMessage: error)
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = message else {return}
//                    self.showAlert(withMessage: message)
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    self.getFriendProfileInformation()
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
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 2) { error, message in
                self.hideLoading()
                if let error = error {
//                    self.showAlert(withMessage: error)
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
//                self.showAlert(withMessage: message)
                DispatchQueue.main.async {
                    self.view.makeToast(message)
                }
                self.getFriendProfileInformation()
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
                
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 5) { error, message in
                    self.hideLoading()
                    if let error = error {
//                        self.showAlert(withMessage: error)
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = message else {return}
//                    self.showAlert(withMessage: message)
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    
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
                
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 3) { error, message in
                    self.hideLoading()
                    if let error = error {
//                        self.showAlert(withMessage: error)
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = message else {return}
//                    self.showAlert(withMessage: message)
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    
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
    
    @IBAction func unBlockBtn(_ sender: Any) {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            // handling code
            self.updateUserInterfaceBtns()
            if self.internetConect == true {
                
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 4) { error, message in
                    self.hideLoading()
                    if let error = error {
//                        self.showAlert(withMessage: error)
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let message = message else {return}
//                    self.showAlert(withMessage: message)
                    DispatchQueue.main.async {
                        self.view.makeToast(message)
                    }
                    
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
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            getFriendProfileInformation()
        case .wifi:
            internetConect = true
            getFriendProfileInformation()
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
        self.view.makeToast( "No avaliable newtwok ,Please try again!".localizedString)
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
    
    func setupData() {
        let model = viewmodel.model.value
        aboutFriendLbl.text = model?.bio
        userNameLbl.text = "@\(model?.displayedUserName ?? "")"
        nameLbl.text = model?.userName
        ageLbl.text = "\(model?.age ?? 0)"
        genderLbl.text = model?.gender
        profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        
        tagListView.removeAllTags()
        for item in model?.listoftagsmodel ?? [] {
            tagListView.addTag(tagId: item.tagID, title: "#\(item.tagname)")
        }
        
        print("tagListView.rows \(tagListView.rows)")
        tagListViewHeight.constant = CGFloat(tagListView.rows * 25)
        
        if tagListView.rows == 1 {
            tagsTopConstrains.constant = 16
            tagsBotomConstrains.constant = 16
        }else if tagListView.rows == 2 {
            tagsTopConstrains.constant = 18
            tagsBotomConstrains.constant = 26
        }else if tagListView.rows == 3 {
            tagsTopConstrains.constant = 18
            tagsBotomConstrains.constant = 40
        }else {
            tagsTopConstrains.constant = 18
            tagsBotomConstrains.constant = 46
        }
        
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
