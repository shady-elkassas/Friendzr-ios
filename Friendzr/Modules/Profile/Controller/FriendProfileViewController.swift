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
import AMShimmer

class FriendProfileViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyMessageLbl: UILabel!
    @IBOutlet weak var triAgainBtn: UIButton!
    
    //MARK: - Properties
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
    var isNotFriend:Bool = false
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var btnSelect:Bool = false
    var isFeedVC:Bool = false
    
    var onFeedTransactionCallBackResponse: ((_ isFeed: Bool) -> ())?

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
    
    //MARK: - Life Cycle
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
        
        if isFeedVC {
            Defaults.availableVC = "FeedVC"
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
        AMShimmer.stop(for: self.hideView)
        
        if isFeedVC {
            onFeedTransactionCallBackResponse?(true)
        }else {
            onFeedTransactionCallBackResponse?(false)
        }
    }
    
    //MARK: - APIs
    func getFriendProfileInformation() {
        AMShimmer.stop(for: self.hideView)
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [weak self]value in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.title = value.userName ?? ""
                self?.tableView.dataSource = self
                self?.tableView.delegate = self
                self?.tableView.reloadData()
            }
            
            DispatchQueue.main.async {
                if value.key == 0 {
                    self?.isNotFriend = true
                }else {
                    self?.isNotFriend = false
                }
            }
            
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func loadUserData() {
        AMShimmer.start(for: self.hideView)
        viewmodel.getFriendDetails(ById: userID)
        viewmodel.model.bind { [weak self]value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                DispatchQueue.main.async {
                    self?.title = value.userName ?? ""
                    self?.tableView.dataSource = self
                    self?.tableView.delegate = self
                    self?.tableView.reloadData()
                }
                
                DispatchQueue.main.async {
                    if value.key == 0 {
                        self?.isNotFriend = true
                    }else {
                        self?.isNotFriend = false
                    }
                    
                    self?.hideView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
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
    
    //MARK: - Helpers
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
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
}

//MARK: - UITableViewDataSource
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
            
            statusFriend(model, cell)
            
            cell.HandleSendRequestBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.sendFriendRequest(cell, "\(actionDate) \(actionTime)")
                }
            }
            
            cell.HandleCancelBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.cancelFriendRequest(cell, "\(actionDate) \(actionTime)")
                }
            }
            
            cell.HandleRefuseBtn = {
                self.showAllertForRefuseFriend("\(actionDate) \(actionTime)")
            }
            
            cell.HandleAcceptBtn = {
                self.btnSelect = true
                if NetworkConected.internetConect == true {
                    self.acceptFriendRequest("\(actionDate) \(actionTime)")
                }
            }
            
            cell.HandleUnFriendBtn = {
                self.showAlertForUnFriend(cell, "\(actionDate) \(actionTime)")
            }
            cell.HandleMessageBtn = { //messages chat
                self.btnSelect = true
                if NetworkConected.internetConect {
                    guard let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC else {return}
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = model?.userid ?? ""
                    vc.leaveGroup = 1
                    vc.isFriend = true
                    vc.leavevent = 0
                    vc.titleChatImage = model?.userImage ?? ""
                    vc.titleChatName = model?.userName ?? ""
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = false
                    CancelRequest.currentTask = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }
            
            setupTitleBtns(cell)
            
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
            
            for item in model?.listoftagsmodel ?? [] {
                if Defaults.interestIds.contains(where: {$0 == item.tagID}) {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter()).isSelected = true
                } else {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter()).isSelected = false
                }
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
        
        else if indexPath.row == 3 {//what i am
            guard let cell = tableView.dequeueReusableCell(withIdentifier: bestDescribesCellId, for: indexPath) as? BestDescribesTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            for item in model?.iamList ?? [] {
                if item.tagname.contains("#") == false {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
                }else {
                    print("iamList.tagname.contains(#)")
                }
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
                if item.tagname.contains("#") == false {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#" + (item.tagname).capitalizingFirstLetter())
                }else {
                    print("prefertoList.tagname.contains(#)")
                }
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

//MARK: - UITableViewDelegate && UIPopoverPresentationControllerDelegate
extension FriendProfileViewController:UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return screenH/3
        }
        else {
            //            if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
            //                return 150
            //            }
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
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleUserOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleUserOptionsBtn() {
        reportActionSheet()
    }
    
    func reportActionSheet() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //        if isFriendNow {
        //            actionSheet.addAction(UIAlertAction(title: "Unfriend".localizedString, style: .default, handler: { action in
        //                self.showAlertForUnFriend()
        //            }))
        
        actionSheet.addAction(UIAlertAction(title: "Block".localizedString, style: .default, handler: { action in
            self.showAlertForBlock()
        }))
        //        }
        
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

//MARK: - Cell Btns Action
extension FriendProfileViewController {
    
    func statusFriend(_ model: FriendObj?, _ cell: FriendImageProfileTableViewCell) {
        switch model?.key {
        case 0:
            //Status = normal case
            cell.acceptBtn.isHidden = true
            cell.refuseBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.sendRequestBtn.isHidden = false
            cell.friendStackView.isHidden = true
            cell.unfriendBtn.isHidden = true
            cell.messageBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            cell.acceptBtn.isHidden = true
            cell.refuseBtn.isHidden = true
            cell.cancelBtn.isHidden = false
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unfriendBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            cell.acceptBtn.isHidden = false
            cell.refuseBtn.isHidden = false
            cell.cancelBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unfriendBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            cell.acceptBtn.isHidden = true
            cell.refuseBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = false
            cell.unfriendBtn.isHidden = false
            cell.friendStackView.isHidden = false
            break
        case 4:
            //Status = I block user
            cell.acceptBtn.isHidden = true
            cell.refuseBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unfriendBtn.isHidden = true
            cell.friendStackView.isHidden = true
            break
        case 5:
            //Status = user block me
            cell.acceptBtn.isHidden = true
            cell.refuseBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unfriendBtn.isHidden = true
            cell.friendStackView.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
    }
    
    func sendFriendRequest( _ cell: FriendImageProfileTableViewCell, _ requestdate:String) {
        self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 1, isNotFriend: isNotFriend,requestdate: requestdate) { error, message in
            
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
                NotificationCenter.default.post(name: Notification.Name("reloadRecommendedPeople"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                self.getFriendProfileInformation()
            }
        }
    }
    
    func cancelFriendRequest( _ cell: FriendImageProfileTableViewCell, _ requestdate:String) {
        self.changeTitleBtns(btn: cell.cancelBtn, title: "Canceling...".localizedString)
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6, isNotFriend: isNotFriend,requestdate: requestdate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            DispatchQueue.main.async {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                self.getFriendProfileInformation()
            }
            
        }
    }
    
    func showAlertForUnFriend( _ cell: FriendImageProfileTableViewCell, _ requestdate:String) {
        self.btnSelect = true
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        self.alertView?.HandleConfirmBtn = {
            if NetworkConected.internetConect == true {
                self.unFriendRequest(cell, requestdate)
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
    
    func unFriendRequest( _ cell: FriendImageProfileTableViewCell, _ requestdate:String) {
        cell.sendRequestBtn.isHidden = false
        cell.friendStackView.isHidden = true
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 5, isNotFriend: isNotFriend,requestdate: requestdate) { error, message in
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
    }
    
    func acceptFriendRequest( _ requestdate:String) {
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 2, isNotFriend: isNotFriend,requestdate: requestdate ) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                self.getFriendProfileInformation()
            }
        }
    }
    
    func showAllertForRefuseFriend( _ requestdate:String) {
        self.btnSelect = true
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to refuse this request?".localizedString
        
        self.alertView?.HandleConfirmBtn = {
            if NetworkConected.internetConect == true {
                self.refuseFriendRequest(requestdate)
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
    
    func refuseFriendRequest( _ requestdate:String) {
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 6, isNotFriend: isNotFriend,requestdate: requestdate) { error, message in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            Defaults.frindRequestNumber -= 1
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                self.getFriendProfileInformation()
            }
        }
    }
    
    func showAlertForBlock() {
        self.btnSelect = true
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        self.alertView?.HandleConfirmBtn = {
            // handling code
            if NetworkConected.internetConect == true {
                self.blockFriendRequest()
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
    func blockFriendRequest() {
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        self.requestFriendVM.requestFriendStatus(withID: self.userID, AndKey: 3, isNotFriend: isNotFriend,requestdate: "\(actionDate) \(actionTime)") { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            if self.selectedVC {
                Router().toFeed()
            }else {
                self.onPopup()
            }
        }
    }

    func setupTitleBtns(_ cell: FriendImageProfileTableViewCell) {
        cell.sendRequestBtn.setTitle("Send Request".localizedString, for: .normal)
        cell.cancelBtn.setTitle("Cancel Request".localizedString, for: .normal)
        cell.acceptBtn.setTitle("Accept".localizedString, for: .normal)
        cell.refuseBtn.setTitle("Cancel".localizedString, for: .normal)
        cell.unfriendBtn.setTitle("Unfriend".localizedString, for: .normal)
        cell.messageBtn.setTitle("Message".localizedString, for: .normal)
    }
}
