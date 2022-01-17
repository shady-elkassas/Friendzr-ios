//
//  NotificationsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import UIKit
import ListPlaceholder

class NotificationsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    var viewmodel:NotificationsViewModel = NotificationsViewModel()
    let cellID = "NotificationTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var refreshControl = UIRefreshControl()
    
    var internetConect:Bool = false
    var btnsSelect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Notifications".localizedString
        setupNavBar()
        pullToRefresh()
        initBackButton()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getNotificationsList(pageNumber: currentPage)
    }
    
    func getNotificationsList(pageNumber:Int) {
        viewmodel.getNotifications(pageNumber: pageNumber)
        viewmodel.notifications.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.hideLoader()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    func LoadAllNotifications(pageNumber:Int) {
        viewmodel.getNotifications(pageNumber: pageNumber)
        viewmodel.notifications.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                if value.data?.count != 0 {
                    tableView.showLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.tableView.hideLoader()
                    }
                }
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
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
            self.emptyView.isHidden = false
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            self.emptyView.isHidden = true
            LoadAllNotifications(pageNumber: 1)
        case .wifi:
            internetConect = true
            self.emptyView.isHidden = true
            LoadAllNotifications(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "emptyImage")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if btnsSelect {
            emptyView.isHidden = true
            self.view.makeToast("No avaliable network ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable network ,Please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        getNotificationsList(pageNumber: 1)
        self.refreshControl.endRefreshing()
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        btnsSelect = false
        updateUserInterface()
    }
    
}

extension NotificationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.notifications.value?.data?.count != 0 {
            return viewmodel.notifications.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewmodel.notifications.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? NotificationTableViewCell else {return UITableViewCell()}
            let model = viewmodel.notifications.value?.data?[indexPath.row]
            cell.notificationBodyLbl.text = model?.body
            cell.notificationTitleLbl.text = model?.title
            cell.notificationDateLbl.text = model?.createdAt
            cell.notificationImg.sd_setImage(with: URL(string: model?.imageUrl ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            return cell
        }
    }
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.notifications.value?.data?.count != 0 {
            return 100
        }else {
            return 350
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelect = true
        updateUserInterface()
        if internetConect {
            if viewmodel.notifications.value?.data?.count != 0 {
                
                let model = viewmodel.notifications.value?.data?[indexPath.row]
                
                if model?.action == "Friend_Request" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else { return}
                    vc.userID = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "Accept_Friend_Request" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else { return}
                    vc.userID = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "event_chat" {
                    Router().toConversationVC(isEvent: true, eventChatID: model?.action_code ?? "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: "", titleChatName: "")
                }else if model?.action == "user_chat" {
                    Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: model?.action_code ?? "", isFriend: true, titleChatImage: model?.imageUrl ?? "", titleChatName: model?.title ?? "")
                }else if model?.action == "event_Updated" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "update_Event_Data" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "event_attend" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "Event_reminder" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if model?.action == "Check_events_near_you" {
                    Router().toMap()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.notifications.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
                }
            }else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
                    self.view.makeToast("No more data here".localizedString)
                }
                return
            }
        }
    }
}
