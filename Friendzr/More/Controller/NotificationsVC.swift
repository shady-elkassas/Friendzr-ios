//
//  NotificationsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import UIKit

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
    
    var refreshControl = UIRefreshControl()
    
    var internetConect:Bool = false
    var btnsSelect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Notifications"
        setupNavBar()
        pullToRefresh()
        initBackButton()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getNotificationsList(pageNumber: currentPage)
    }
    
    func getNotificationsList(pageNumber:Int) {
        self.showLoading()
        viewmodel.getNotifications(pageNumber: pageNumber)
        viewmodel.notifications.bind { [unowned self] value in
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
            getNotificationsList(pageNumber: 1)
        case .wifi:
            internetConect = true
            self.emptyView.isHidden = true
            getNotificationsList(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func showEmptyView() {
        if viewmodel.notifications.value?.data?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
        }
        
        tryAgainBtn.alpha = 0.0
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

    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
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
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    @objc func refreshAllEvents() {
        updateUserInterface()
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        btnsSelect = false
        updateUserInterface()
    }

}

extension NotificationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.notifications.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? NotificationTableViewCell else {return UITableViewCell()}
        let model = viewmodel.notifications.value?.data?[indexPath.row]
        cell.notificationBodyLbl.text = model?.body
        cell.notificationTitleLbl.text = model?.title
        cell.notificationDateLbl.text = model?.createdAt
        cell.notificationImg.sd_setImage(with: URL(string: model?.imageUrl ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        return cell
    }
}

extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelect = true
        updateUserInterface()
        if internetConect {
            
        }else {
            return
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
                    self.view.makeToast("No more data here")
                }
                return
            }
        }
    }
}
