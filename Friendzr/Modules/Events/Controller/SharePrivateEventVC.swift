//
//  SharePrivateEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/03/2022.
//

import UIKit
import ListPlaceholder

class SharePrivateEventVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyLbl: UILabel!
    
    @IBOutlet weak var hideViews: UIView!
    @IBOutlet var namesFirendsViews: [UIImageView]!
    @IBOutlet var btnImgsView: [UIImageView]!
    
    var shareEventMessageVM:ChatViewModel = ChatViewModel()
    var viewmodel:AttendeesViewModel = AttendeesViewModel()
    
    var eventID:String = ""
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var cellSelected:Bool = false
    var internetConnect:Bool = false
    
    var cellID = "ShareTableViewCell"
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Share"
        
        initCloseBarButton()
        
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        
        setupSearchBar()
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupHideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SharePrivateEventVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    
    func setupHideView() {
        for item in btnImgsView {
            item.cornerRadiusView(radius: 6)
        }
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchView.cornerRadiusView(radius: 6)
        searchView.setBorder()
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchBar.searchTextField.attributedPlaceholder = placeHolder
        searchBar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllAttendees(pageNumber: currentPage, search: searchBar.text ?? "")
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            internetConnect = true
            LaodAllAttendees(pageNumber: 1, search: searchBar.text ?? "")
        case .wifi:
            internetConnect = true
            LaodAllAttendees(pageNumber: 1, search: searchBar.text ?? "")
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
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            internetConnect = true
        case .wifi:
            internetConnect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func getAllAttendees(pageNumber:Int,search:String) {
        hideViews.isHidden = true
        viewmodel.getEventAttendees(ByEventID: eventID, pageNumber: pageNumber, search: search)
        viewmodel.attendees.bind { [unowned self] value in
            DispatchQueue.main.async {
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
                self.view.makeToast(error)
            }
        }
    }
    
    func LaodAllAttendees(pageNumber:Int,search:String) {
        hideViews.isHidden = false
        hideViews.showLoader()
        
        viewmodel.getEventAttendees(ByEventID: eventID, pageNumber: pageNumber, search: search)
        viewmodel.attendees.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                DispatchQueue.main.async {
                    hideViews.hideLoader()
                    hideViews.isHidden = true
                }
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                showEmptyView()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.view.makeToast(error)
            }
        }
    }
    
    func showEmptyView() {
        if viewmodel.attendees.value?.data?.count == 0 {
            emptyView.isHidden = false
            emptyLbl.text = "You haven't any data yet".localizedString
        }else {
            emptyView.isHidden = true
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
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
}

extension SharePrivateEventVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.attendees.value?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        
        
        let model = viewmodel.attendees.value?.data?[indexPath.row]
        
        if model?.myEventO == true {
            cell.sendBtn.isHidden = true
        }else {
            cell.sendBtn.isHidden = false
        }
        cell.titleLbl.text = model?.userName
        
        cell.HandleSendBtn = {
            self.updateNetworkForBtns()
            if self.internetConnect {
                cell.sendBtn.setTitle("Sending...", for: .normal)
                cell.sendBtn.isUserInteractionEnabled = false
                self.shareEventMessageVM.SendMessage(withUserId: model?.userId ?? "", AndMessage: "oo", AndMessageType: 4, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url! ,eventShareid: self.eventID) { error, data in
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                            cell.sendBtn.setTitle("Send", for: .normal)
                        }
                        return
                    }
                    
                    guard let _ = data else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        cell.sendBtn.isUserInteractionEnabled = false
                        cell.sendBtn.setTitle("Sent", for: .normal)
                        cell.sendBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
                        cell.sendBtn.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
                        cell.sendBtn.backgroundColor = .white
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
            
        }
        return cell
    }
}

extension SharePrivateEventVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let model = viewmodel.attendees.value?.data?[indexPath.row]
    //
    //        if model?.myEventO == true {
    //            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
    //            self.navigationController?.pushViewController(vc, animated: true)
    //        }else {
    //            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
    //            vc.userID = model?.userId ?? ""
    //            self.navigationController?.pushViewController(vc, animated: true)
    //        }
    //    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            self.isLoadingList = true
            if currentPage < viewmodel.attendees.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
                }
            }else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

//MARK: - SearchBar Delegate
extension SharePrivateEventVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        
        self.updateNetworkForBtns()
        
        if self.internetConnect {
            self.getAllAttendees(pageNumber: 0, search: text)
        }
    }
}
