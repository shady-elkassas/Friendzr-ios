//
//  RequestVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import ListPlaceholder

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
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hidesImgs: [UIImageView]!
    @IBOutlet var proImgs: [UIImageView]!
    
    //MARK: - Properties
    let cellID = "RequestsTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:RequestsViewModel = RequestsViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var refreshControl = UIRefreshControl()
    
    var cellSelected:Bool = false
    var internetConnect:Bool = false
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        pullToRefresh()
        self.title = "Requests".localizedString
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateResquests), name: Notification.Name("updateResquests"), object: nil)
        
        segmentControl.selectedSegmentIndex = 0
        RequestesType.type = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initProfileBarButton()
        
        CancelRequest.currentTask = false
        setupHideView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    
    @objc func updateResquests() {
        updateUserInterface()
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllUserRequests(pageNumber: currentPage)
    }
    
    func getAllUserRequests(pageNumber:Int) {
        hideView.hideLoader()
        viewmodel.getAllRequests(requestesType: RequestesType.type, pageNumber: pageNumber)
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                hideView.hideLoader()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                if RequestesType.type == 2 {
                    Defaults.frindRequestNumber = value.data?.count ?? 0
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
                    HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    let requestSend = 0
    let receivedRequest = 0
    
    func loadAllUserRequests(pageNumber:Int) {
        hideView.showLoader()
        viewmodel.getAllRequests(requestesType: RequestesType.type, pageNumber: pageNumber)
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                if RequestesType.type == 2 {
                    Defaults.frindRequestNumber = value.data?.count ?? 0
                }else {
                    Defaults.frindRequestNumber = Defaults.frindRequestNumber
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    hideView.hideLoader()
                    hideView.isHidden = true
                }
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                
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
            self.emptyView.isHidden = false
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
            loadAllUserRequests(pageNumber: 0)
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
            loadAllUserRequests(pageNumber: 0)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateNetworkForBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "maskGroup9")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if cellSelected {
            emptyView.isHidden = true
            self.view.makeToast("No avaliable network ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable network ,Please try again!".localizedString
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
        getAllUserRequests(pageNumber: 0)
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
            hideView.isHidden = false
            hideView.showLoader()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.updateUserInterface()
            }
        case 1:
            RequestesType.type = 1
            hideView.isHidden = false
            hideView.showLoader()
            
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
        if viewmodel.requests.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RequestsTableViewCell else {return UITableViewCell()}
            cell.setNeedsLayout()
            cell.setNeedsDisplay()
            
            let model = viewmodel.requests.value?.data?[indexPath.row]
            
            if RequestesType.type == 1 {
                cell.acceptBtn.isHidden = true
            }else {
                cell.acceptBtn.isHidden = false
            }
            
            cell.friendRequestNameLbl.text = model?.userName
            cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.friendRequestDateLbl.text = model?.regestdata
            cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            
            if indexPath.row == (viewmodel.requests.value?.data?.count ?? 0) - 1 {
                cell.bottomView.isHidden = true
            }else {
                cell.bottomView.isHidden = false
            }
            
            cell.HandleAcceptBtn = {
                self.cellSelected = true
                self.updateNetworkForBtns()
                if self.internetConnect {
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let message = message else {return}
                        DispatchQueue.main.async {
                            self.view.makeToast(message)
                        }
                        
                        DispatchQueue.main.async {
                            self.updateUserInterface()
                        }
                        
                        cell.stackViewBtns.isHidden = true
                        cell.messageBtn.isHidden = false
                        cell.requestRemovedLbl.isHidden = true
                        
                    }
                }
            }
            
            cell.HandleDeleteBtn = {
                self.cellSelected = true
                self.updateNetworkForBtns()
                if self.internetConnect {
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let message = message else {return}
                        DispatchQueue.main.async {
                            self.view.makeToast(message)
                        }
                        
                        DispatchQueue.main.async {
                            self.updateUserInterface()
                        }
                        
                        cell.stackViewBtns.isHidden = true
                        cell.messageBtn.isHidden = true
                        cell.requestRemovedLbl.isHidden = false
                    }
                }
            }
            
            cell.HandleMessageBtn = {
                self.cellSelected = true
                self.updateNetworkForBtns()
                if self.internetConnect {
                    Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: model?.userId ?? "", isFriend: true, titleChatImage: model?.image ?? "", titleChatName: model?.userName ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1)
                }else {
                    return
                }
            }
            
            return cell
            
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            return cell
            
        }
    }
}

//MARK: - Extensions Table View Delegate
extension RequestVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.requests.value?.data?.count == 0 {
            return 350
        }else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        updateNetworkForBtns()
        if internetConnect {
            if viewmodel.requests.value?.data?.count != 0 {
                let model = viewmodel.requests.value?.data?[indexPath.row]
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
                vc.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
                    self.view.makeToast("No more data here".localizedString)
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
