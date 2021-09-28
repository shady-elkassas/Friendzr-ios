//
//  RequestVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class RequestVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var totalRequestLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    let cellID = "RequestTableViewCell"
    var viewmodel:RequestsViewModel = RequestsViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var refreshControl = UIRefreshControl()
    
    var cellSelected:Bool = false
    var internetConnect:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Request"
        setupNavBar()
        initProfileBarButton()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    //MARK:- APIs
    func getAllUserRequests() {
        self.showLoading()
        viewmodel.getAllRequests()
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                totalRequestLbl.text = " \(value.count)"
                
                showEmptyView()
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
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllUserRequests()
        case .wifi:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllUserRequests()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func showEmptyView() {
        if viewmodel.requests.value?.count == 0 {
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
        if cellSelected {
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
        getAllUserRequests()
        self.refreshControl.endRefreshing()
    }
    
    func setup() {
        //register cell in table view
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
}

//MARK: - Extensions Table View Data Source
extension RequestVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.requests.value?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RequestTableViewCell else {return UITableViewCell()}
        let model = viewmodel.requests.value?[indexPath.row]
        
        cell.friendRequestNameLbl.text = model?.userName
        cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
        cell.friendRequestDateLbl.text = model?.regestdata
        cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        cell.HandleAcceptBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = false
                cell.requestRemovedLbl.isHidden = true
            }
        }
        
        cell.HandleDeleteBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = true
                cell.requestRemovedLbl.isHidden = false
            }
            
        }
        
        cell.HandleMessageBtn = {
            self.tabBarController?.selectedIndex = 0
        }
        
        return cell
    }
}

//MARK: - Extensions Table View Delegate
extension RequestVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelected = true
        updateUserInterface()
        if internetConnect {
            let model = viewmodel.requests.value?[indexPath.row]
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
            vc.userID = model?.userId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
}
