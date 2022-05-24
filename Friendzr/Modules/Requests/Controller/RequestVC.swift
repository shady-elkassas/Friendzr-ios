//
//  RequestVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import ListPlaceholder
import GoogleMobileAds
import Network
import SDWebImage

class RequestesType {
    static var type: Int = 2
}

class RequestVC: UIViewController ,UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    //    @IBOutlet weak var totalRequestLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet var bannerView: UIView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hidesImgs: [UIImageView]!
    @IBOutlet var proImgs: [UIImageView]!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    
    //MARK: - Properties
    let cellID = "RequestsTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:RequestsViewModel = RequestsViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var refreshControl = UIRefreshControl()
    
    var cellSelected:Bool = false
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false
    
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
    
    var bannerView2: GADBannerView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        pullToRefresh()
        self.title = "Requests".localizedString
        
        if !Defaults.hideAds {
            setupAds()
        }else {
            bannerViewHeight.constant = 0
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResquests), name: Notification.Name("updateResquests"), object: nil)
        
        segmentControl.selectedSegmentIndex = 0
        RequestesType.type = 2
        initProfileBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "RequestVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        setupHideView()
        
        setupNavBar()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    
    @objc func updateResquests() {
        getAllUserRequests(pageNumber: 1)
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllUserRequests(pageNumber: currentPage)
    }
    
    var xrecieved :[UserFeedObj] = [UserFeedObj]()
    
    func getAllUserRequests(pageNumber:Int) {
        hideView.hideLoader()
        viewmodel.getAllRequests(requestesType: RequestesType.type, pageNumber: pageNumber)
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoadingList = false
                    self.tableView.tableFooterView = nil
                }

                
                self.xrecieved.removeAll()
                for itm in value.data ?? [] {
                    if itm.key == 2 {
                        self.xrecieved.append(itm)
                    }
                }
                
                if RequestesType.type == 2 {
                    Defaults.frindRequestNumber = self.xrecieved.count
                }else {
                    Defaults.frindRequestNumber = Defaults.frindRequestNumber
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
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
    
    func loadAllUserRequests(pageNumber:Int) {
        hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getAllRequests(requestesType: RequestesType.type, pageNumber: pageNumber)
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                
                self.xrecieved.removeAll()
                for itm in value.data ?? [] {
                    if itm.key == 2 {
                        self.xrecieved.append(itm)
                    }
                }
                
                if RequestesType.type == 2 {
                    Defaults.frindRequestNumber = self.xrecieved.count
                }else {
                    Defaults.frindRequestNumber = Defaults.frindRequestNumber
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoadingList = false
                    self.tableView.tableFooterView = nil
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
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
    
    //MARK: - Helper
    func setupCellBtns(_ cell: RequestsTableViewCell, _ model: UserFeedObj?) {
        if RequestesType.type == 1 { // sent
            cell.acceptBtn.isHidden = true
            if model?.key == 1 {
                cell.stackViewBtns.isHidden = false
                cell.messageBtn.isHidden = true
                cell.requestRemovedLbl.isHidden = true
            }else if model?.key == 3 {
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = false
                cell.requestRemovedLbl.isHidden = true
            }
        }
        else { // received
            cell.acceptBtn.isHidden = false
            if model?.key == 2 {
                cell.stackViewBtns.isHidden = false
                cell.messageBtn.isHidden = true
                cell.requestRemovedLbl.isHidden = true
            }else if model?.key == 3 {
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = false
                cell.requestRemovedLbl.isHidden = true
            }
        }
    }
    
    func acceptRequest(_ model: UserFeedObj?, _ requestdate:String, _ cell: RequestsTableViewCell) {
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2,requestdate: requestdate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let message = message else {return}
            print(message)
            
            DispatchQueue.main.async {
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = false
                cell.requestRemovedLbl.isHidden = true
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
        }
    }
    
    func cancelRequest(_ model: UserFeedObj?, _ requestdate:String, _ cell: RequestsTableViewCell) {
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6,requestdate: requestdate ) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            DispatchQueue.main.async {
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = true
                cell.requestRemovedLbl.isHidden = false
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
        }
    }
    
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
        for itm in proImgs {
            itm.cornerRadiusForHeight()
        }
        
        for item in hidesImgs {
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
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.loadAllUserRequests(pageNumber: 1)
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                NetworkConected.internetConect = true
                self.loadAllUserRequests(pageNumber: 1)
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
        emptyImg.image = UIImage.init(named: "feednodata_img")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if cellSelected {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }
        else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        currentPage = 0
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        self.refreshControl.endRefreshing()
    }
    
    func setup() {
        //register cell in table view
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName:emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
        
        segmentControl.setTitleColor(UIColor.black, state: .normal)
        segmentControl.setTitleColor(UIColor.white, state: .selected)
        segmentControl.setTitleFont(UIFont(name: "Montserrat-Bold", size: 12)!)
        bannerView.setCornerforTop()
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            RequestesType.type = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateUserInterface()
            }
        case 1:
            RequestesType.type = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateUserInterface()
            }
        default:
            break;
        }
    }
    
}

//MARK: - Extensions Table View Data Source
extension RequestVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.requests.value?.data?.count != 0 {
            return viewmodel.requests.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        if viewmodel.requests.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RequestsTableViewCell else {return UITableViewCell()}
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
            
            let model = viewmodel.requests.value?.data?[indexPath.row]
            
            setupCellBtns(cell, model)
            
            cell.friendRequestNameLbl.text = model?.userName
            cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.friendRequestDateLbl.text = model?.regestdata
            
            cell.friendRequestImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            if indexPath.row == (viewmodel.requests.value?.data?.count ?? 0) - 1 {
                cell.bottomView.isHidden = true
            }else {
                cell.bottomView.isHidden = false
            }
            
            cell.HandleAcceptBtn = {
                self.cellSelected = true
                if NetworkConected.internetConect {
                    self.acceptRequest(model, "\(actionDate) \(actionTime)", cell)
                }
            }
            
            cell.HandleDeleteBtn = {
                self.cellSelected = true
                if NetworkConected.internetConect {
                    self.cancelRequest(model, "\(actionDate) \(actionTime)", cell)
                    
                }
            }
            
            cell.HandleMessageBtn = {
                self.cellSelected = true
                if NetworkConected.internetConect {
                    let vc = ConversationVC()
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = model?.userId ?? ""
                    vc.leaveGroup = 1
                    vc.isFriend = true
                    vc.leavevent = 0
                    vc.titleChatImage = model?.image ?? ""
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
            
            return cell
            
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            if RequestesType.type == 1 {
                cell.titleLbl.text = "You don’t have any new connection requests. \nSee who else is online over on your Feed"
            }else {
                cell.titleLbl.text = "You don’t have any pending connection requests. \nHead to your Feed and start up a new chat"
            }
            
            cell.emptyImg.image = UIImage(named: "requestesnodata_img")
            
            return cell
            
        }
    }
}

//MARK: - Extensions Table View Delegate
extension RequestVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.requests.value?.data?.count == 0 {
            return UITableView.automaticDimension
        }else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        if NetworkConected.internetConect {
            if viewmodel.requests.value?.data?.count != 0 {
                let model = viewmodel.requests.value?.data?[indexPath.row]
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                vc.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.requests.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
                }
            }else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
//                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

extension UISegmentedControl {
    
    func setTitleColor(_ color: UIColor, state: UIControl.State = .normal) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.foregroundColor] = color
        self.setTitleTextAttributes(attributes, for: state)
    }
    
    func setTitleFont(_ font: UIFont, state: UIControl.State = .normal) {
        var attributes = self.titleTextAttributes(for: state) ?? [:]
        attributes[.font] = font
        self.setTitleTextAttributes(attributes, for: state)
    }
    
}

extension RequestVC: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        //        addBannerViewToView(bannerView2)
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
