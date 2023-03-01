//
//  NotificationsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import UIKit
import ListPlaceholder
import Network
import SDWebImage
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class NotificationsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var prosImg: [UIImageView]!
    @IBOutlet var hidesImg: [UIImageView]!
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!

    //MARK: - Properties
    var viewmodel:NotificationsViewModel = NotificationsViewModel()
    let cellID = "NotificationTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var refreshControl = UIRefreshControl()
    var btnsSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var bannerView2: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Notifications".localizedString
        setupNavBar()
        pullToRefresh()
        initBackButton()
        setupHideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "NotificationsVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        
        Defaults.notificationcount = 0
        UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateUserInterface()
        }
        
        setupAds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        
        Defaults.notificationcount = 0
        UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount
        NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
    }
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getNotificationsList(pageNumber: currentPage)
    }
    
    func getNotificationsList(pageNumber:Int) {
        hideView.hideLoader()
        viewmodel.getNotifications(pageNumber: pageNumber)
        viewmodel.notifications.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.hideView.hideLoader()
                    self?.hideView.isHidden = true
                }
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func LoadAllNotifications(pageNumber:Int) {
        hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getNotifications(pageNumber: pageNumber)
        viewmodel.notifications.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.hideView.hideLoader()
                    self?.hideView.isHidden = true
                }
                
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self?.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self?.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self?.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Helper
    
    func setupAds() {
        bannerView2 = GADBannerView(adSize: GADAdSizeBanner)
        bannerView2.adUnitID = URLs.adUnitBanner
        bannerView2.rootViewController = self
        bannerView2.load(GADRequest())
        bannerView2.delegate = self
        bannerView2.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(bannerView2)
    }
    
    func setupHideView() {
        for itm in prosImg {
            itm.cornerRadiusView(radius: 6)
        }
        
        for item in hidesImg {
            item.cornerRadiusView(radius: 6)
        }
    }
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                self.emptyView.isHidden = false
                self.hideView.isHidden = true
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                self.LoadAllNotifications(pageNumber: 1)
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                self.LoadAllNotifications(pageNumber: 1)
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "notificationnodata_img")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    func HandleInternetConnection() {
        if btnsSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
        bannerView.setCornerforTop()
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
        currentPage = 1
        getNotificationsList(pageNumber: currentPage)
        self.refreshControl.endRefreshing()
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        btnsSelect = false
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
            
            cell.notificationImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.notificationImg.sd_setImage(with: URL(string: model?.imageUrl ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            let datee = getDate(isoDate: (model?.notificationDate ?? "") + "+0000")
            let datSTr = datee?.toString(withFormat: "dd-MM-yyyy HH:mm")
            cell.notificationDateLbl.text = datSTr
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            cell.emptyImg.image = UIImage(named: "notificationnodata_img")
            cell.titleLbl.text = "You’re all up to date"
            return cell
        }
    }
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.notifications.value?.data?.count != 0 {
            return 75
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelect = true
        if NetworkConected.internetConect {
            if viewmodel.notifications.value?.data?.count != 0 {

                let model = viewmodel.notifications.value?.data?[indexPath.row]

                if model?.action == "Friend_Request" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else { return}
                    vc.userID = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Accept_Friend_Request" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else { return}
                    vc.userID = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "event_Updated" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "update_Event_Data" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "event_attend" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Event_reminder" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Check_events_near_you" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Check_private_events" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else { return}
                    vc.eventId = model?.action_code ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Joined_ChatGroup" {
                    Router().toInbox()
                }
                else if model?.action == "Kickedout_ChatGroup" {
                    Router().toInbox()
                }
                else if model?.action == "Inbox_chat" {
                    Router().toInbox()
                }
                else if model?.action == "Friend_Requests" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Request, AndContollerID: "RequestVC") as? RequestVC else { return}
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Private_mode" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Request, AndContollerID: "SettingsVC") as? SettingsVC else { return}
                    vc.checkoutName = "privateMode"
                    Defaults.isDeeplinkClicked = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if model?.action == "Edit_profile" {
                    self.view.makeToast("Your account is already completed.")
                }
//                else {
//                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.notifications.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
                }
            }
            else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
//                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

extension NotificationsVC: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerViewHeight.constant = 0
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
