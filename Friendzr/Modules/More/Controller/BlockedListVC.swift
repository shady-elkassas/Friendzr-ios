//
//  BlockedListVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import UIKit
import ListPlaceholder
import Network
import SDWebImage

class BlockedListVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    @IBOutlet var proImgs: [UIImageView]!

    
    //MARK: - Properties
    let cellID = "BlockedTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    var viewmodel:AllBlockedViewModel = AllBlockedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    var refreshControl = UIRefreshControl()
    var btnsSelect:Bool = false
    
    var currentPage : Int = 1
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

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Blocked List".localizedString
        initBackButton()
        setupSearchBar()
        setupViews()
        
        pullToRefresh()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "BlockedListVC"
        print("availableVC >> \(Defaults.availableVC)")

        CancelRequest.currentTask = false
        setupHideView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK:- APIs
    func loadMoreItemsForList(){
        currentPage += 1
        getAllBlockedList(pageNumber: currentPage,search: searchbar.text ?? "")
    }
    
    func getAllBlockedList(pageNumber:Int,search:String) {
        hideView.hideLoader()
        viewmodel.getAllBlockedList(pageNumber: pageNumber,search: search)
        viewmodel.blocklist.bind { [weak self] value in
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
    
    func LoadBlockedList(pageNumber:Int,search:String) {
        self.hideView.showLoader()
        viewmodel.getAllBlockedList(pageNumber: pageNumber,search:search)
        viewmodel.blocklist.bind { [weak self] value in
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
    
    func unblockFriend( _ model:friendChatObj?, _ actionDate:String) {
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4, requestdate: actionDate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                self.updateUserInterface()
            }
        }
    }
    
    //MARK: - Helper
    func setupHideView() {
        for itm in proImgs {
            itm.cornerRadiusForHeight()
        }
        
        for item in hideImgs {
            item.cornerRadiusView(radius: 6)
        }
    }
    
    func setupSearchBar() {
        searchbar.delegate = self
        searchBarView.cornerRadiusView(radius: 6)
        searchBarView.setBorder()
        searchbar.backgroundImage = UIImage()
        searchbar.searchTextField.textColor = .black
        searchbar.searchTextField.backgroundColor = .clear
        searchbar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchbar.searchTextField.attributedPlaceholder = placeHolder
        searchbar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        searchbar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    
    func setupViews() {
        tryAgainBtn.cornerRadiusView(radius: 8)
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                self.emptyView.isHidden = false
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.LoadBlockedList(pageNumber: 1,search: self.searchbar.text ?? "")
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.emptyView.isHidden = true
                self.LoadBlockedList(pageNumber: 1,search: self.searchbar.text ?? "")
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
        emptyImg.image = UIImage.init(named: "blocklistnodata_img")
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
        getAllBlockedList(pageNumber: 1,search: searchbar.text ?? "")
        self.refreshControl.endRefreshing()
    }
    
    //MARK:- Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        btnsSelect = false
    }
    
}

//MARK: - Extensions
extension BlockedListVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
        getAllBlockedList(pageNumber: 1,search: text)
    }
}

extension BlockedListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.blocklist.value?.data?.count != 0 {
            return viewmodel.blocklist.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())

        if viewmodel.blocklist.value?.data?.count != 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? BlockedTableViewCell else {return UITableViewCell()}
            let model = viewmodel.blocklist.value?.data?[indexPath.row]
            cell.nameLbl.text = model?.userName
            
            cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            if indexPath.row == ((viewmodel.blocklist.value?.data?.count ?? 0) - 1 ) {
                cell.underView.isHidden = true
            }
            
            cell.HandleUnblockBtn = {
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                self.alertView?.titleLbl.text = "Confirm?".localizedString
                self.alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
                
                self.alertView?.HandleConfirmBtn = {
                    // handling code
                    self.btnsSelect = true
                    if NetworkConected.internetConect {
                        self.unblockFriend(model,"\(actionDate) \(actionTime)")
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
            
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            cell.emptyImg.image = UIImage(named: "blocklistnodata_img")
            cell.titleLbl.text = "No Friendzrs have been blocked"
            return cell
        }
    }
}

extension BlockedListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.blocklist.value?.data?.count != 0 {
            return 75
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelect = true
        if NetworkConected.internetConect {
            if viewmodel.blocklist.value?.data?.count != 0 {
                let model = viewmodel.blocklist.value?.data?[indexPath.row]
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                vc.userID = model?.userId ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            
            if currentPage < viewmodel.blocklist.value?.totalPages ?? 0 {
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
