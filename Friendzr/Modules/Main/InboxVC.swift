//
//  InboxVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import SwiftUI
import ListPlaceholder
import GoogleMobileAds

extension InboxVC {
    func lastMessageDateTime(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZZZZ"
        let dateStr = "\(date)T\(time)Z"
        let date = formatter.date(from: dateStr)
        
        let relativeFormatter = buildFormatter(locale: formatter.locale, hasRelativeDate: true)
        let relativeDateString = dateFormatterToString(relativeFormatter, date!)
        // "Jan 18, 2018"

        let nonRelativeFormatter = buildFormatter(locale: formatter.locale)
        let normalDateString = dateFormatterToString(nonRelativeFormatter, date!)
        // "Jan 18, 2018"

        let customFormatter = buildFormatter(locale: formatter.locale, dateFormat: "DD MMMM")
        let customDateString = dateFormatterToString(customFormatter, date!)
        // "18 January"

        if relativeDateString == normalDateString {
            print("Use custom date \(normalDateString)") // Jan 18
            return  normalDateString
        } else {
            print("Use relative date \(relativeDateString)") // Today, Yesterday
            return "\(relativeDateString) \(time)"
        }
    }
}

class InboxVC: UIViewController ,UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var prosImg: [UIImageView]!
    @IBOutlet var hidesImg: [UIImageView]!
    
    
    
    //MARK: - Properties
    let cellID = "InboxTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:ChatViewModel = ChatViewModel()
    var searchVM:SearchUserViewModel = SearchUserViewModel()
    var groupVM:GroupViewModel = GroupViewModel()
    
    var refreshControl = UIRefreshControl()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var isSearch:Bool = false
    var leaveOrJoinTitle:String = ""
    
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
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
        
        setupView()
        
        initNewConversationBarButton()
        self.title = "Inbox".localizedString
        
        pullToRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChatList), name: Notification.Name("reloadChatList"), object: nil)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "InboxVC"
        print("availableVC >> \(Defaults.availableVC)")

        initProfileBarButton()
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: true)
        CancelRequest.currentTask = false
        seyupAds()
        
        setupHideView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - APIs
    func seyupAds() {
        bannerView.adUnitID = URLs.adUnitBanner
        //        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.setCornerforTop()
    }
    
    @objc func reloadChatList() {
        DispatchQueue.main.async {
            self.getAllChatList(pageNumber: 1)
        }
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllChatList(pageNumber: currentPage)
    }
    
    func getAllChatList(pageNumber:Int) {
        hideView.hideLoader()
        viewmodel.getChatList(pageNumber: pageNumber)
        viewmodel.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }

                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func loadAllchatList(pageNumber:Int) {
        hideView.showLoader()
        viewmodel.getChatList(pageNumber: pageNumber)
        viewmodel.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func getSearchUsers(text:String) {
        searchVM.SearshUsersinChat(ByUserName: text)
        searchVM.usersinChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        searchVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else if error == "Bad Request" {
                    HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                }
            }
        }
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "emptyImage")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if cellSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")

        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
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
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        cellSelect = false
        updateUserInterface()
    }
    
    //MARK: - Helper
    func setupHideView() {
        for itm in hidesImg {
            itm.cornerRadiusView(radius: 6)
        }
        for item in prosImg {
            item.cornerRadiusForHeight()
        }
        
    }
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            self.hideView.isHidden = true
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            loadAllchatList(pageNumber: 1)
        case .wifi:
            internetConect = true
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            loadAllchatList(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupView() {
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName:emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchContainerView.cornerRadiusView(radius: 6)
        searchContainerView.setBorder()
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
}

//MARK: - Extensions
extension InboxVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if searchVM.usersinChat.value?.data?.count != 0 {
                return searchVM.usersinChat.value?.data?.count ?? 0
            }else {
                return 1
            }
        }else {
            if viewmodel.listChat.value?.data?.count != 0 {
                return viewmodel.listChat.value?.data?.count ?? 0
            }else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            if searchVM.usersinChat.value?.data?.count != 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InboxTableViewCell else {return UITableViewCell()}
                let model = searchVM.usersinChat.value?.data?[indexPath.row]
                cell.nameLbl.text = model?.chatName
                cell.lastMessageLbl.text = model?.messages
                
                cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
                
                if viewmodel.listChat.value?.data?.count ?? 0 != 0 {
                    if indexPath.row == ((viewmodel.listChat.value?.data?.count ?? 0) - 1) {
                        cell.downView.isHidden = true
                    }else {
                        cell.downView.isHidden = false
                    }
                }
                
                cell.lastMessageDateLbl.text = lastMessageDateTime(date: model?.latestdate ?? "", time: model?.latesttime ?? "")
                
                //handle type message
                if model?.messagestype == 0 {
                    cell.attachImg.isHidden = true
                    cell.attachTypeLbl.isHidden = true
                    cell.lastMessageLbl.isHidden = false
                    cell.lastMessageLbl.text = ""
                }
                else if model?.messagestype == 1 {
                    cell.attachImg.isHidden = true
                    cell.attachTypeLbl.isHidden = true
                    cell.lastMessageLbl.isHidden = false
                    cell.lastMessageLbl.text = model?.messages
                }
                else if model?.messagestype == 2 {
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "placeholder")
                    cell.attachTypeLbl.text = "Photo".localizedString
                }
                else if model?.messagestype == 3 {
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "attachFile_ic")
                    cell.attachTypeLbl.text = "File".localizedString
                }
                else {
                    print("\(model?.messagestype ?? 0)")
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "Events_ic")
                    cell.attachTypeLbl.text = "Event".localizedString
                }
                
                return cell
            }else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
                return cell
            }
        }else {
            if viewmodel.listChat.value?.data?.count != 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InboxTableViewCell else {return UITableViewCell()}
                let model = viewmodel.listChat.value?.data?[indexPath.row]
                cell.nameLbl.text = model?.chatName
                cell.lastMessageDateLbl.text = "\(model?.latestdate ?? "") \(model?.latesttime ?? "")"
                cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
                
                if viewmodel.listChat.value?.data?.count ?? 0 != 0 {
                    if indexPath.row == ((viewmodel.listChat.value?.data?.count ?? 0) - 1) {
                        cell.downView.isHidden = true
                    }else {
                        cell.downView.isHidden = false
                    }
                }
                
                
                cell.lastMessageDateLbl.text = lastMessageDateTime(date: model?.latestdate ?? "", time: model?.latesttime ?? "")
                
                //handle type message
                if model?.messagestype == 0 {
                    cell.attachImg.isHidden = true
                    cell.attachTypeLbl.isHidden = true
                    cell.lastMessageLbl.isHidden = false
                    cell.lastMessageLbl.text = ""
                }
                else if model?.messagestype == 1 {
                    cell.attachImg.isHidden = true
                    cell.attachTypeLbl.isHidden = true
                    cell.lastMessageLbl.isHidden = false
                    cell.lastMessageLbl.text = model?.messages
                }
                else if model?.messagestype == 2 {
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "placeholder")
                    cell.attachTypeLbl.text = "Photo".localizedString
                }
                else if model?.messagestype == 3 {
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "attachFile_ic")
                    cell.attachTypeLbl.text = "File".localizedString
                }
                else {
                    print("\(model?.messagestype ?? 0)")
                    cell.attachImg.isHidden = false
                    cell.attachTypeLbl.isHidden = false
                    cell.lastMessageLbl.isHidden = true
                    cell.attachImg.image = UIImage(named: "Events_ic")
                    cell.attachTypeLbl.text = "Event".localizedString
                }
                return cell
            }else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
                cell.controlBtn.isHidden = true
                return cell
            }
        }
    }
}
extension InboxVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearch {
            if searchVM.usersinChat.value?.data?.count != 0 {
                return 75
            }else {
                return 350
            }
        }else {
            if viewmodel.listChat.value?.data?.count != 0 {
                return 75
            }else {
                return 350
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchVM.usersinChat.value?.data?.count != 0 || viewmodel.listChat.value?.data?.count != 0  {
            //
            var model = viewmodel.listChat.value?.data?[indexPath.row]
            //
            if isSearch {
                model = searchVM.usersinChat.value?.data?[indexPath.row]
            }
            
            Router().toConversationVC(isEvent: model?.isevent ?? false, eventChatID: model?.id ?? "", leavevent: model?.leavevent ?? 0, chatuserID: model?.id ?? "", isFriend: model?.isfrind ?? false, titleChatImage: model?.image ?? "", titleChatName: model?.chatName ?? "", isChatGroupAdmin: model?.isChatGroupAdmin ?? false, isChatGroup: model?.isChatGroup ?? false, groupId: model?.id ?? "",leaveGroup: model?.leaveGroup ?? 0, isEventAdmin: model?.myevent ?? false)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if searchVM.usersinChat.value?.data?.count != 0 || viewmodel.listChat.value?.data?.count != 0  {
            let model = self.viewmodel.listChat.value?.data?[indexPath.row]
            let muteTitle = model?.isMute ?? false ? "UnMute".localizedString : "Mute".localizedString
            let deleteTitle = model?.isChatGroup ?? true ? "Clear".localizedString : "Delete".localizedString
            
            if model?.leavevent == 0 {
                self.leaveOrJoinTitle = "Exit".localizedString
            }else {
                self.leaveOrJoinTitle = "Join".localizedString
            }
            
            if model?.isChatGroup == true {
                if model?.leaveGroup == 0 {
                    self.leaveOrJoinTitle = "Exit".localizedString
                }else {
                    self.leaveOrJoinTitle = "Join".localizedString
                }
            }else {
                if model?.leavevent == 0 {
                    self.leaveOrJoinTitle = "Exit".localizedString
                }else {
                    self.leaveOrJoinTitle = "Join".localizedString
                }
            }
            
            
            let actionDate = formatterDate.string(from: Date())
            let actionTime = formatterTime.string(from: Date())
            
            
            let deleteAction = UITableViewRowAction(style: .default, title: deleteTitle.localizedString) { action, indexPath in
                print("deleteAction")
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        if model?.isChatGroup == true {
                            self.groupVM.clearGroupChat(ByID: model?.id ?? "", registrationDateTime: "\(actionDate) \(actionTime)") { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }else {
                            self.viewmodel.deleteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, deleteDateTime: "\(actionDate) \(actionTime)") { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
                else {
                    let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                    
                    settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                        if model?.isChatGroup == true {
                            self.groupVM.clearGroupChat(ByID: model?.id ?? "", registrationDateTime: "\(actionDate) \(actionTime)") { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }else {
                            self.viewmodel.deleteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, deleteDateTime: "\(actionDate) \(actionTime)") { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }
                    }))
                    settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                    
                    self.present(settingsActionSheet, animated:true, completion:nil)
                }
            }
            
            let leaveAction = UITableViewRowAction(style: .default, title: self.leaveOrJoinTitle) { action, indexPath in
                print("LeaveAction")
                
                if model?.leavevent == 0 {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            self.viewmodel.LeaveChat(ByID: model?.id ?? "", ActionDate: actionDate, Actiontime: actionTime) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
//                                DispatchQueue.main.async {
//                                    self.view.makeToast("You have left the chat".localizedString)
//                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            self.viewmodel.LeaveChat(ByID: model?.id ?? "", ActionDate: actionDate, Actiontime: actionTime) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
//                                DispatchQueue.main.async {
//                                    self.view.makeToast("You have left the chat".localizedString)
//                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    
                }else {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            self.viewmodel.joinChat(ByID: model?.id ?? "", ActionDate: actionDate, Actiontime: actionTime) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
//                                DispatchQueue.main.async {
//                                    self.view.makeToast("You have joined the chat".localizedString)
//                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            self.viewmodel.joinChat(ByID: model?.id ?? "", ActionDate: actionDate, Actiontime: actionTime) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard let _ = data else {
                                    return
                                }
                                
//                                DispatchQueue.main.async {
//                                    self.view.makeToast("You have joined the chat".localizedString)
//                                }
                                
                                DispatchQueue.main.async {
                                    self.getAllChatList(pageNumber: 1)
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    
                }
            }
            
            let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { action, indexPath in
                print("muteAction")
                if model?.isMute == true {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            if model?.isChatGroup == true {
                                self.groupVM.muteGroupChat(ByID: model?.id ?? "", mute: false) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                                
                            }else {
                                self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: false) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            if model?.isChatGroup == true {
                                self.groupVM.muteGroupChat(ByID: model?.id ?? "", mute: false) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                                
                            }else {
                                self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: false) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                }
                else {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            if model?.isChatGroup == true {
                                self.groupVM.muteGroupChat(ByID: model?.id ?? "", mute: true) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                                
                            }else {
                                self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: true) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                    else {
                        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                        
                        settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                            if model?.isChatGroup == true {
                                self.groupVM.muteGroupChat(ByID: model?.id ?? "", mute: true) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                                
                            }else {
                                self.viewmodel.muteChat(ByID: model?.id ?? "", isevent: model?.isevent ?? false, mute: true) { error, data in
                                    if let error = error {
                                        DispatchQueue.main.async {
                                            self.view.makeToast(error)
                                        }
                                        return
                                    }
                                    
                                    guard let _ = data else {
                                        return
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.viewmodel.listChat.value?.data?[indexPath.row].isMute?.toggle()
                                        tableView.reloadData()
                                    }
                                }
                            }
                        }))
                        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                        
                        self.present(settingsActionSheet, animated:true, completion:nil)
                    }
                }
            }
            
            leaveAction.backgroundColor = UIColor.darkGray
            muteAction.backgroundColor = UIColor.FriendzrColors.primary!
            
            if model?.isevent == true {
                if model?.myevent == true {
                    return [deleteAction,muteAction]
                }else {
                    if model?.leavevent == 0 {
                        return [deleteAction,leaveAction,muteAction]
                    }else {
                        return [deleteAction,leaveAction]
                    }
                }
            }
            else if model?.isChatGroup == true {
                if model?.leaveGroup == 0 {
                    return [deleteAction,leaveAction,muteAction]
                }else {
                    return [deleteAction]
                }
            }
            else {
                return [deleteAction,muteAction]
            }
        }else {
            return []
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isSearch {
            print("Search")
        }else {
            if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
                self.isLoadingList = true
                if currentPage < viewmodel.listChat.value?.totalPages ?? 0 {
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
}

extension InboxVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        if text != "" {
            isSearch = true
            getSearchUsers(text: text)
        }else {
            isSearch = false
            getAllChatList(pageNumber: 1)
        }
    }
    
    func initNewConversationBarButton() {
        let button = UIButton.init(type: .custom)
        button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        let image = UIImage(named: "newMessage_ic")?.withRenderingMode(.automatic)
        
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.setColor(lightColor: .black, darkColor: .white)
        button.addTarget(self, action: #selector(PresentNewConversation), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func PresentNewConversation() {
        print("PresentNewConversation")
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "NewConversationNC") as? UINavigationController, let _ = controller.viewControllers.first as? NewConversationVC {
            self.present(controller, animated: true)
        }
    }
}

extension InboxVC : GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
        bannerViewHeight.constant = 0
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Receive Ad")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
        bannerView.load(GADRequest())
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}

extension InboxVC {
    func buildFormatter(locale: Locale, hasRelativeDate: Bool = false, dateFormat: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        if let dateFormat = dateFormat { formatter.dateFormat = dateFormat }
        formatter.doesRelativeDateFormatting = hasRelativeDate
        formatter.locale = locale
        return formatter
    }
    
    func dateFormatterToString(_ formatter: DateFormatter, _ date: Date) -> String {
        return formatter.string(from: date)
    }
}
