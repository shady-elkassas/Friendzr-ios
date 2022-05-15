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
import SDWebImage
import Network

//MARK: - singletone Network Conected
class NetworkConected {
    static var internetConect: Bool = false
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
    @IBOutlet var bannerView: UIView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var prosImg: [UIImageView]!
    @IBOutlet var hidesImg: [UIImageView]!
    
    
    //MARK: - Properties
    let cellID = "InboxTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:ChatViewModel = ChatViewModel()
    var groupVM:GroupViewModel = GroupViewModel()
    
    var refreshControl = UIRefreshControl()
    var cellSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var isSearch:Bool = false
    var leaveOrJoinTitle:String = ""
    var bannerView2: GADBannerView!
    
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
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if !Defaults.hideAds {
            setupAds()
        }else {
            bannerViewHeight.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "InboxVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        initProfileBarButton()
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: true)
        CancelRequest.currentTask = false
        
        currentPage = 1
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupHideView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - APIs
    @objc func reloadChatList() {
        DispatchQueue.main.async {
            if self.isSearch {
                self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
            }else {
                self.getAllChatList(pageNumber: 1,search: "")
            }
        }
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        if isSearch {
            getAllChatList(pageNumber: currentPage,search: searchBar.text ?? "")
        }else {
            getAllChatList(pageNumber: currentPage,search: "")
        }
    }
    
    func getAllChatList(pageNumber:Int,search:String) {
        hideView.hideLoader()
        viewmodel.getChatList(pageNumber: pageNumber,search: search)
        viewmodel.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                NotificationCenter.default.post(name: Notification.Name("updatebadgeInbox"), object: nil, userInfo: nil)
                
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isLoadingList = false
                        self.tableView.tableFooterView = nil
                    }
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    func loadAllchatList(pageNumber:Int) {
        hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getChatList(pageNumber: pageNumber,search: "")
        viewmodel.listChat.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoadingList = false
                    self.tableView.tableFooterView = nil
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                if error == "Internal Server Error" {
                    self.HandleInternetConnection()
                }else if error == "Bad Request" {
                    self.HandleinvalidUrl()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                }
            }
        }
    }
    
    //HandleinvalidUrl
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "inboxnodata_img")
        emptyLbl.text = "No messages sent or received as yet".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    //HandleInternetConnection
    func HandleInternetConnection() {
        if cellSelect {
            emptyView.isHidden = true
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    //pullToRefresh
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        
        cellSelect = false
        
        if NetworkConected.internetConect {
            currentPage = 1
            DispatchQueue.main.async {
                self.updateUserInterface()
            }
        }
        
        self.refreshControl.endRefreshing()
    }
    
    //createFooterView
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
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
    
    //network connection APIs
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            self.hideView.isHidden = true
            NetworkConected.internetConect = false
            self.HandleInternetConnection()
        case .wwan:
            NetworkConected.internetConect = true
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            self.loadAllchatList(pageNumber: 1)
        case .wifi:
            NetworkConected.internetConect = true
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            self.loadAllchatList(pageNumber: 1)
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func setupHideView() {
        for itm in hidesImg {
            itm.cornerRadiusView(radius: 6)
        }
        for item in prosImg {
            item.cornerRadiusForHeight()
        }
    }
    //setupViews
    func setupView() {
        setupSearchBar()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName:emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
        bannerView.setCornerforTop()
    }
    //setup SearchBar
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
    
    //MARK: - Actions
    @IBAction func tryAgainBtn(_ sender: Any) {
        cellSelect = false
        updateUserInterface()
    }
}

//MARK: - Extensions UITableViewDataSource
extension InboxVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.listChat.value?.data?.count != 0 {
            return viewmodel.listChat.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewmodel.listChat.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InboxTableViewCell else {return UITableViewCell()}
            let model = viewmodel.listChat.value?.data?[indexPath.row]
            cell.nameLbl.text = model?.chatName
            //            cell.lastMessageDateLbl.text = "\(model?.latestdate ?? "") \(model?.latesttime ?? "")"
            
            cell.profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profileImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            if viewmodel.listChat.value?.data?.count ?? 0 != 0 {
                if indexPath.row == ((viewmodel.listChat.value?.data?.count ?? 0) - 1) {
                    cell.downView.isHidden = true
                }else {
                    cell.downView.isHidden = false
                }
            }
            
            if model?.message_not_Read != 0 {
                cell.noMessagesUnreadLbl.isHidden = false
                cell.noMessagesUnreadLbl.text = "\(model?.message_not_Read ?? 0)"
            }else {
                cell.noMessagesUnreadLbl.isHidden = true
            }
            
            if model?.isMute == true {
                cell.muteImg.isHidden = false
            }else {
                cell.muteImg.isHidden = true
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
                cell.attachImg.image = UIImage(named: "placeHolderApp")
                cell.attachTypeLbl.text = "Photo".localizedString
                cell.attachImg.sd_setImage(with: URL(string: model?.messagesattach ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            }
            else if model?.messagestype == 3 {
                cell.attachImg.isHidden = false
                cell.attachTypeLbl.isHidden = false
                cell.lastMessageLbl.isHidden = true
                cell.attachImg.image = UIImage(named: "attachFile_ic")
                cell.attachTypeLbl.text = "File".localizedString
                cell.attachImg.sd_setImage(with: URL(string: model?.messagesattach ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
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
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            cell.controlBtn.isHidden = true
            cell.emptyImg.image = UIImage(named: "inboxnodata_img")
            cell.titleLbl.text = "No messages sent or received as yet"
            return cell
        }
        
    }
}

//MARK: - UITableViewDelegate
extension InboxVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.listChat.value?.data?.count != 0 {
            return 75
        }else {
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if NetworkConected.internetConect {
            goToConversation(indexPath)
        }
        else {
            self.view.makeToast("Network is unavailable, please try again!")
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if viewmodel.listChat.value?.data?.count != 0  {
            return SwipeCell(indexPath)
        }
        else {
            return []
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
//                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

//MARK: - UISearchBarDelegate & initNewConversationBarButton
extension InboxVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text = searchBar.text else {return}
        print(text)
        
        if NetworkConected.internetConect {
            if text != "" {
                isSearch = true
                getAllChatList(pageNumber: 1, search: text)
            }else {
                isSearch = false
                getAllChatList(pageNumber: 1,search: "")
            }
        }else {
            HandleInternetConnection()
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

//MARK: - Custom last message date
extension InboxVC {
    func lastMessageDateTime(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
        let dateStr = "\(date)T\(time):00+0000"
        let date = formatter.date(from: dateStr)
        
        let relativeFormatter = buildFormatter(locale: formatter.locale, hasRelativeDate: true)
        let relativeDateString = dateFormatterToString(relativeFormatter, date ?? Date())
        // "Jan 18, 2018"
        
        let nonRelativeFormatter = buildFormatter(locale: formatter.locale)
        let normalDateString = dateFormatterToString(nonRelativeFormatter, date ?? Date())
        // "Jan 18, 2018"
        
        let customFormatter = buildFormatter(locale: formatter.locale, dateFormat: "DD MMMM")
        _ = dateFormatterToString(customFormatter, date ?? Date())
        // "18 January"
        
        if relativeDateString == normalDateString {
            print("Use custom date \(normalDateString)") // Jan 18
            return  normalDateString
        } else {
            print("Use relative date \(relativeDateString)") // Today, Yesterday
            return "\(relativeDateString) \(time)"
        }
    }
    
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

//MARK: - Ads Delegate
extension InboxVC: GADBannerViewDelegate {
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

//MARK: - Customize Swipe funcs
extension InboxVC {
    
    func SwipeCell(_ indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = self.viewmodel.listChat.value?.data?[indexPath.row]
        
        let muteTitle = model?.isMute ?? false ? "UnMute".localizedString : "Mute".localizedString
        let deleteTitle = model?.isChatGroup ?? true ? "Clear".localizedString : "Delete".localizedString
        
        if model?.isChatGroup == true {
            if model?.leaveGroup == 0 {
                self.leaveOrJoinTitle = "Exit".localizedString
            }else {
                self.leaveOrJoinTitle = "Join".localizedString
            }
        }else {
            if model?.leaveventchat == false {
                self.leaveOrJoinTitle = "Exit".localizedString
            }else {
                self.leaveOrJoinTitle = "Join".localizedString
            }
        }
        
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        
        let deleteAction = UITableViewRowAction(style: .default, title: deleteTitle.localizedString) { action, indexPath in
            print("deleteAction")
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                if NetworkConected.internetConect {
                    self.ClearOrDeleteChat(isEvent: model?.isevent ?? false, isGroup: model?.isChatGroup ?? false, ID: model?.id ?? "", registrationDateTime: "\(actionDate) \(actionTime)")
                }
                else {
                    self.view.makeToast("Network is unavailable, please try again!")
                }
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            self.present(settingsActionSheet, animated:true, completion:nil)
            
        }
        
        let leaveAction = UITableViewRowAction(style: .default, title: self.leaveOrJoinTitle) { action, indexPath in
            print("LeaveAction")
            
            self.LeaveChat(isEvent: model?.isevent ?? false, leaveventchat: model?.leaveventchat ?? false, isGroup: model?.isChatGroup ?? false, ID: model?.id ?? "", actionDate: actionDate, actionTime: actionTime)
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { action, indexPath in
            print("muteAction")
            if model?.isMute == true {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    if NetworkConected.internetConect {
                        self.MuteChat(isEvent: model?.isevent ?? false, isGroup: model?.isChatGroup ?? false, ID: model?.id ?? "", registrationDateTime: "", isMute: false, model: self.viewmodel.listChat.value?.data?[indexPath.row])
                    }
                    else {
                        self.view.makeToast("Network is unavailable, please try again!")
                    }
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
                
            }
            else {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Confirm".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    
                    if NetworkConected.internetConect {
                        self.MuteChat(isEvent: model?.isevent ?? false, isGroup: model?.isChatGroup ?? false, ID: model?.id ?? "", registrationDateTime: "", isMute: true, model: self.viewmodel.listChat.value?.data?[indexPath.row])
                    }
                    else {
                        self.view.makeToast("Network is unavailable, please try again!")
                    }
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
                
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
                    return [deleteAction]
                }
            }
        }
        else if model?.isChatGroup == true {
            if model?.isChatGroupAdmin == true {
                return [deleteAction,muteAction]
            }else {
                if model?.leaveGroup == 0 {
                    return [deleteAction,leaveAction,muteAction]
                }else {
                    return [deleteAction]
                }
            }
        }
        else {
            return [deleteAction,muteAction]
        }
    }

    func LeaveChat(isEvent:Bool,leaveventchat:Bool,isGroup:Bool,ID:String,actionDate:String,actionTime:String) {
        if isEvent {
            if leaveventchat == false {
                leaveEventChat(ID, actionDate, actionTime)
            }
            else {
                joinEventChat(ID, actionDate, actionTime)
            }
        }
        else {
            leaveGroupChat(ID, actionDate)
        }
    }
    func MuteChat(isEvent:Bool,isGroup:Bool,ID:String,registrationDateTime:String,isMute:Bool,model:UserChatObj?) {
        if isGroup {
            muteGroupChat(ID, isMute,model)
        }
        else {
            muteEventOrUserChat(ID, isEvent, isMute, model)
        }
    }
    func ClearOrDeleteChat(isEvent:Bool,isGroup:Bool,ID:String,registrationDateTime:String) {
        if isGroup {
            clearGroupChat(ID, registrationDateTime)
        }
        else {
            deleteEventOrUserChat(ID, isEvent, registrationDateTime)
        }
    }

    func clearGroupChat(_ ID: String, _ registrationDateTime: String) {
        self.groupVM.clearGroupChat(ByID: ID, registrationDateTime: registrationDateTime) { error, data in
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
                if self.isSearch {
                    self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
                }else {
                    self.getAllChatList(pageNumber: 1,search: "")
                }
            }
        }
    }
    func deleteEventOrUserChat(_ ID: String, _ isEvent: Bool, _ registrationDateTime: String) {
        self.viewmodel.deleteChat(ByID: ID, isevent: isEvent, deleteDateTime: registrationDateTime) { error, data in
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
                self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
            }
        }
    }
    func leaveEventChat(_ ID: String, _ actionDate: String, _ actionTime: String) {
        self.viewmodel.LeaveChat(ByID: ID, ActionDate: actionDate, Actiontime: actionTime) { error, data in
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
                self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
            }
        }
    }
    func joinEventChat(_ ID: String, _ actionDate: String, _ actionTime: String) {
        self.viewmodel.joinChat(ByID: ID, ActionDate: actionDate, Actiontime: actionTime) { error, data in
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
                self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
            }
        }
    }
    func leaveGroupChat(_ ID: String, _ actionDate: String) {
        self.groupVM.leaveGroupChat(ByID: ID, registrationDateTime: actionDate) { error, data in
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
                self.getAllChatList(pageNumber: 1,search: self.searchBar.text ?? "")
            }
        }
    }
    func muteGroupChat(_ ID: String, _ isMute: Bool, _ model:UserChatObj?) {
        self.groupVM.muteGroupChat(ByID: ID, mute: isMute) { error, data in
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
                model?.isMute?.toggle()
                self.tableView.reloadData()
            }
        }
    }
    func muteEventOrUserChat(_ ID: String, _ isevent:Bool,_ isMute: Bool, _ model:UserChatObj?) {
        self.viewmodel.muteChat(ByID: ID, isevent: isevent, mute: isMute) { error, data in
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
                model?.isMute?.toggle()
                self.tableView.reloadData()
            }
        }
    }
    
    func goToConversation(_ indexPath: IndexPath) {
        if viewmodel.listChat.value?.data?.count != 0 {
            let vc = ConversationVC()
            let model = viewmodel.listChat.value?.data?[indexPath.row]
            if model?.isevent == true {
                vc.isEvent = true
                vc.eventChatID = model?.id ?? ""
                vc.chatuserID = ""
                
                if model?.leaveventchat == true {
                    vc.leavevent = 2
                }else {
                    vc.leavevent = model?.leavevent ?? 0
                }
                
                vc.leaveGroup = 1
                vc.isFriend = false
                vc.titleChatImage = model?.image ?? ""
                vc.titleChatName = model?.chatName ?? ""
                vc.isChatGroupAdmin = false
                vc.isChatGroup = false
                vc.groupId = ""
                vc.isEventAdmin = model?.myevent ?? false
                vc.eventType = model?.eventtype ?? ""
            }
            else {
                if (model?.isChatGroup ?? false) == true {
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = ""
                    vc.leavevent = 1
                    vc.leaveGroup = model?.leaveGroup ?? 0
                    vc.isFriend = false
                    vc.titleChatImage = model?.image ?? ""
                    vc.titleChatName = model?.chatName ?? ""
                    vc.isChatGroupAdmin = model?.isChatGroupAdmin ?? false
                    vc.isChatGroup = model?.isChatGroup ?? false
                    vc.groupId = model?.id ?? ""
                    vc.isEventAdmin = false
                }
                else {
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = model?.id ?? ""
                    vc.leaveGroup = 1
                    vc.isFriend = model?.isfrind ?? false
                    vc.leavevent = model?.leavevent ?? 0
                    vc.titleChatImage = model?.image ?? ""
                    vc.titleChatName = model?.chatName ?? ""
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = false
                }
            }
            
            vc.titleChatImage = model?.image ?? ""
            vc.titleChatName = model?.chatName ?? ""
            CancelRequest.currentTask = false
            
            Defaults.message_Count = Defaults.message_Count - (model?.message_not_Read ?? 0)
            NotificationCenter.default.post(name: Notification.Name("updatebadgeInbox"), object: nil, userInfo: nil)
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
