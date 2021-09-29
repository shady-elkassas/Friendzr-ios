//
//  FeedVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class FeedVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    
    //MARK: - Properties
    let cellID = "FeedsTableViewCell"
    var viewmodel:FeedViewModel = FeedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    var refreshControl = UIRefreshControl()
    let switchBarButton = UISwitch()
    
    var btnsSelected:Bool = false
    var internetConnect:Bool = false
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        initProfileBarButton()
        setup()
        initSwitchBarButton()
        pullToRefresh()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFeeds(pageNumber: currentPage)
    }
    func getAllFeeds(pageNumber:Int) {
        self.showLoading()
        viewmodel.getAllUsers(pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil

                showEmptyView()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    //MARK: - Helper
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
            getAllFeeds(pageNumber: 0)
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllFeeds(pageNumber: 0)
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
    
    func showEmptyView() {
        if viewmodel.feeds.value?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
        }
        
        tryAgainBtn.alpha = 0.0
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "maskGroup9")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if btnsSelected {
            emptyView.isHidden = true
            self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable newtwok ,Please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func HandleUnauthorized() {
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }

}

//MARK: - Extensions
extension FeedVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.feeds.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FeedsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.feeds.value?[indexPath.row]
        cell.friendRequestNameLbl.text = model?.userName
        cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
        cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        //status key
        switch model?.key {
        case 0:
            //Status = normal case
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = false
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = false
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            cell.respondBtn.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = false
            cell.unblockBtn.isHidden = true
            break
        case 4:
            //Status = I block user
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = false
            break
        case 5:
            //Status = user block me
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
        
        cell.HandleSendRequestBtn = { //send request
            self.btnsSelected = true
            self.updateNetworkForBtns()
            if self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        cell.HandleRespondBtn = { //respond request
            self.btnsSelected = true
            self.updateNetworkForBtns()
            
            if self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        cell.HandleBlockBtn = { //block account
            self.btnsSelected = true
            self.updateNetworkForBtns()
            
            if self.self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 3) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        cell.HandleUnblocktBtn = { //unblock account
            self.btnsSelected = true
            self.updateNetworkForBtns()
            
            if self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        
        cell.HandleUnfreiendBtn = { //unfriend account
            self.btnsSelected = true
            self.updateNetworkForBtns()
            
            if self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 5) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        cell.HandleCancelRequestBtn = { // cancel request
            
            self.btnsSelected = true
            self.updateNetworkForBtns()
            
            if self.internetConnect {
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    self.getAllFeeds(pageNumber: 0)
                }
            }else {
                return
            }
        }
        
        return cell
    }
}
//extension Table View Delegate
extension FeedVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelected = true
        updateNetworkForBtns()
        
        if internetConnect {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
            vc.userID = viewmodel.feeds.value?[indexPath.row].userId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
          if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
              self.isLoadingList = true
              self.tableView.tableFooterView = self.createFooterView()
              DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                  print("self.currentPage >> \(self.currentPage)")
                  self.loadMoreItemsForList()
              }
          }
      }
}

extension FeedVC {
    func initSwitchBarButton() {
        switchBarButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        switchBarButton.onTintColor = UIColor.FriendzrColors.primary
        switchBarButton.thumbTintColor = .white
        switchBarButton.addTarget(self, action: #selector(handleSwitchBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: switchBarButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleSwitchBtn() {
        print("\(switchBarButton.isOn)")
        
        if switchBarButton.isOn {
            guard let vc = UIViewController.viewController(withStoryboard: .Feed, AndContollerID: "FiltringDirectionVC") as? FiltringDirectionVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
