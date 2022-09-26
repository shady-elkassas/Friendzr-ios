//
//  ShareEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/02/2022.
//

import UIKit
import ListPlaceholder
import Network

class ShareEventVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    @IBOutlet weak var friendsEmptyView: UIView!
    @IBOutlet weak var emptyFriendslbl: UILabel!
    @IBOutlet weak var friendsTV: UITableView!
    
    @IBOutlet weak var groupsSearchBar: UISearchBar!
    @IBOutlet weak var groupsEmptyView: UIView!
    @IBOutlet weak var emptygroupslbl: UILabel!
    @IBOutlet weak var groupsTV: UITableView!
    
    @IBOutlet weak var eventsSearchBar: UISearchBar!
    @IBOutlet weak var eventsEmptyView: UIView!
    @IBOutlet weak var emptyeventslbl: UILabel!
    @IBOutlet weak var eventsTV: UITableView!
    
    @IBOutlet weak var eventsSearchView: UIView!
    @IBOutlet weak var groupsSearchView: UIView!
    @IBOutlet weak var friendsSearchView: UIView!
    
    @IBOutlet var namesFirendsViews: [UIImageView]!
    @IBOutlet var selectImgsView: [UIImageView]!
    
    @IBOutlet weak var hideView1: UIView!
    @IBOutlet weak var hideView2: UIView!
    @IBOutlet weak var hideView3: UIView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    
    //MARK: - Properties
    var cellID = "ShareTableViewCell"
    var eventID:String = ""
    var myFriendsVM:AllFriendesViewModel = AllFriendesViewModel()
    var myEventsVM:EventsViewModel = EventsViewModel()
    var myGroupsVM:GroupViewModel = GroupViewModel()
    var shareEventMessageVM:ChatViewModel = ChatViewModel()
    
    var isLoadingFriendsList:Bool = false
    var isLoadingGroupsList:Bool = false
    var isLoadingEventsList:Bool = false
    
    var currentFriendsPage:Int = 1
    var currentGroupsPage:Int = 1
    var currentEventsPage:Int = 1
    
    
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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Share".localizedString
        setupViews()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        initCloseBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("availableVC >> \(Defaults.availableVC)")
        setupNavBar()
    }
    
    //MARK: - APIs
    func getAllMyEvents(pageNumber:Int,search:String) {
        hideView3.isHidden = true
        myEventsVM.getMyEvents(pageNumber: pageNumber, search: search)
        myEventsVM.events.bind { [weak self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self?.eventsTV.delegate = self
                    self?.eventsTV.dataSource = self
                    self?.eventsTV.reloadData()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingEventsList = false
                    self?.eventsTV.tableFooterView = nil
                }
                
                if value.data?.count == 0 {
                    self?.eventsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No events match your search"
                    }else {
                        self?.emptyFriendslbl.text = "You have no events yet"
                    }
                }else {
                    self?.eventsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyGroups(pageNumber:Int,search:String) {
        hideView2.isHidden = true
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.groupsTV.delegate = self
                    self?.groupsTV.dataSource = self
                    self?.groupsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    self?.groupsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No groups match your search"
                    }else {
                        self?.emptyFriendslbl.text = "You have no groups yet"
                    }
                }else {
                    self?.groupsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myGroupsVM.errorMsg.bind { [weak self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyFriends(pageNumber:Int,search:String) {
        hideView1.isHidden = true
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [weak self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self?.friendsTV.delegate = self
                    self?.friendsTV.dataSource = self
                    self?.friendsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    self?.friendsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No friends match your search"
                    }else {
                        self?.emptyFriendslbl.text = "you have no friends yet"
                    }
                }else {
                    self?.friendsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myFriendsVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    func LoadAllMyEvents(pageNumber:Int,search:String) {
        hideView3.isHidden = false
        hideView3.showLoader()
        myEventsVM.getMyEvents(pageNumber: pageNumber, search: search)
        myEventsVM.events.bind { [weak self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self?.eventsTV.delegate = self
                    self?.eventsTV.dataSource = self
                    self?.eventsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self?.hideView3.isHidden = true
                    self?.hideView3.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self?.eventsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No events match your search"
                    }else {
                        self?.emptyFriendslbl.text = "You have no events yet"
                    }
                }else {
                    self?.eventsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    func LoadAllMyGroups(pageNumber:Int,search:String) {
        hideView2.isHidden = false
        hideView2.showLoader()
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [weak self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.groupsTV.delegate = self
                    self?.groupsTV.dataSource = self
                    self?.groupsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self?.hideView2.isHidden = true
                    self?.hideView2.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self?.groupsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No groups match your search"
                    }else {
                        self?.emptyFriendslbl.text = "You have no groups yet"
                    }
                }else {
                    self?.groupsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myGroupsVM.errorMsg.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    func LoadAllMyFriends(pageNumber:Int,search:String) {
        hideView1.isHidden = false
        hideView1.showLoader()
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [weak self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self?.friendsTV.delegate = self
                    self?.friendsTV.dataSource = self
                    self?.friendsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self?.hideView1.isHidden = true
                    self?.hideView1.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self?.friendsEmptyView.isHidden = false
                    if search != "" {
                        self?.emptyFriendslbl.text = "No friends match your search"
                    }else {
                        self?.emptyFriendslbl.text = "you have no friends yet"
                    }
                }else {
                    self?.friendsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myFriendsVM.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    
    func loadMoreFriendsList() {
        currentFriendsPage += 1
        getAllMyFriends(pageNumber: currentFriendsPage, search: friendsSearchBar.text ?? "")
    }
    
    func loadMoreGroupsList() {
        currentGroupsPage += 1
        getAllMyGroups(pageNumber: currentGroupsPage, search: groupsSearchBar.text ?? "")
    }
    
    func loadMoreEventsList() {
        currentEventsPage += 1
        getAllMyEvents(pageNumber: currentEventsPage, search: eventsSearchBar.text ?? "")
    }
    
    func shareEventToUser(_ cell:ShareTableViewCell,_ model:UserConversationModel?,_ messageDate:String,_ messageTime:String,_ url:URL?) {
        cell.sendBtn.setTitle("Sending...", for: .normal)
        cell.sendBtn.isUserInteractionEnabled = false
        self.shareEventMessageVM.SendMessage(withUserId: model?.userId ?? "", AndMessage: "POP", AndMessageType: 4, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url! ,eventShareid: self.eventID) { error, data in
            
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
                model?.isSendEvent = true
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
    }
    
    func shareEventToEvent(_ cell:ShareTableViewCell,_ model:EventObj?,_ messageDate:String,_ messageTime:String,_ url:URL?) {
        cell.sendBtn.setTitle("Sending...", for: .normal)
        cell.sendBtn.isUserInteractionEnabled = false
        self.shareEventMessageVM.SendMessage(withEventId: model?.id ?? "", AndMessageType: 4, AndMessage: "POP", messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!, eventShareid: self.eventID) { error, data in
            
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
                model?.isSendEvent = true
                
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
    }
    
    func shareEventToGroup(_ cell:ShareTableViewCell,_ model:UserChatObj?,_ messageDate:String,_ messageTime:String,_ url:URL?) {
        cell.sendBtn.setTitle("Sending...", for: .normal)
        cell.sendBtn.isUserInteractionEnabled = false
        self.shareEventMessageVM.SendMessage(withGroupId: model?.id ?? "", AndMessageType: 4, AndMessage: "POP", messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!, eventShareid: self.eventID) { error, data in
            
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
                model?.isSendEvent = true
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
    }
    
    
    //MARK: - Helpers
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
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.LoadAllMyEvents(pageNumber: 1,search:"")
                self.LoadAllMyGroups(pageNumber: 1, search: "")
                self.LoadAllMyFriends(pageNumber: 1, search: "")
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                NetworkConected.internetConect = true
                self.LoadAllMyEvents(pageNumber: 1,search:"")
                self.LoadAllMyGroups(pageNumber: 1, search: "")
                self.LoadAllMyFriends(pageNumber: 1, search: "")
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    func shareEvent() {
        // Setting description
        let firstActivityItem = "https://friendzr.com/about-us/"
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: firstActivityItem)!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "Share_ic")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = activityViewController.view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections =  UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    func setupViews() {
        friendsTV.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        groupsTV.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        eventsTV.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        setupSearchBar()
        
        for itm in namesFirendsViews {
            itm.cornerRadiusView(radius: 6)
        }
        
        for itmm in selectImgsView {
            itmm.cornerRadiusView(radius: 6)
        }
    }
    func HandleInternetConnection() {
        emptyView.isHidden = false
        emptyImg.image = UIImage.init(named: "feednodata_img")
        emptyLbl.text = "No available network, please try again!".localizedString
        tryAgainBtn.alpha = 1.0
    }
    func setupSearchBar() {
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        
        friendsSearchBar.delegate = self
        friendsSearchView.cornerRadiusView(radius: 6)
        friendsSearchView.setBorder()
        friendsSearchBar.backgroundImage = UIImage()
        friendsSearchBar.searchTextField.textColor = .black
        friendsSearchBar.searchTextField.backgroundColor = .clear
        friendsSearchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        friendsSearchBar.searchTextField.attributedPlaceholder = placeHolder
        friendsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchResult), for: .editingChanged)
        friendsSearchBar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        
        groupsSearchBar.delegate = self
        groupsSearchView.cornerRadiusView(radius: 6)
        groupsSearchView.setBorder()
        groupsSearchBar.backgroundImage = UIImage()
        groupsSearchBar.searchTextField.textColor = .black
        groupsSearchBar.searchTextField.backgroundColor = .clear
        groupsSearchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        groupsSearchBar.searchTextField.attributedPlaceholder = placeHolder
        groupsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchResult), for: .editingChanged)
        
        groupsSearchBar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        
        eventsSearchBar.delegate = self
        eventsSearchView.cornerRadiusView(radius: 6)
        eventsSearchView.setBorder()
        eventsSearchBar.backgroundImage = UIImage()
        eventsSearchBar.searchTextField.textColor = .black
        eventsSearchBar.searchTextField.backgroundColor = .clear
        eventsSearchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        eventsSearchBar.searchTextField.attributedPlaceholder = placeHolder
        eventsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchResult), for: .editingChanged)
        eventsSearchBar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        
    }
    
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: friendsTV.bounds.width, height: 50))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    //MARK: - Actions
    @IBAction func shareOutSideFriendzrBtn(_ sender: Any) {
        shareEvent()
    }
}

//MARK: - UITableViewDataSource
extension ShareEventVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendsTV {
            if myFriendsVM.friends.value?.data?.count == 0 {
                return 0
            }else {
                return myFriendsVM.friends.value?.data?.count ?? 0
            }
        }
        else if tableView == groupsTV {
            if myGroupsVM.listChat.value?.data?.count == 0 {
                return 0
            }else {
                return myGroupsVM.listChat.value?.data?.count ?? 0
            }
        }
        else {
            if myEventsVM.events.value?.data?.count == 0 {
                return 0
            }else {
                return myEventsVM.events.value?.data?.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if tableView == friendsTV {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
            let model1 = myFriendsVM.friends.value?.data?[indexPath.row]
            cell.titleLbl.text = model1?.userName
            
            if model1?.isSendEvent == true {
                cell.sendBtn.isUserInteractionEnabled = false
                cell.sendBtn.setTitle("Sent", for: .normal)
                cell.sendBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
                cell.sendBtn.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
                cell.sendBtn.backgroundColor = .white
            }
            else {
                cell.sendBtn.isUserInteractionEnabled = true
                cell.sendBtn.setTitle("Send", for: .normal)
                cell.sendBtn.setTitleColor(UIColor.white, for: .normal)
                cell.sendBtn.backgroundColor = UIColor.FriendzrColors.primary
            }
            
            cell.HandleSendBtn = {
                self.shareEventToUser(cell, model1, messageDate, messageTime, url)
            }
            return cell
        }
        else if tableView == groupsTV {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
            let model2 = myGroupsVM.listChat.value?.data?[indexPath.row]
            cell.titleLbl.text = model2?.chatName
            
            if model2?.isSendEvent == true {
                cell.sendBtn.isUserInteractionEnabled = false
                cell.sendBtn.setTitle("Sent", for: .normal)
                cell.sendBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
                cell.sendBtn.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
                cell.sendBtn.backgroundColor = .white
            }
            else {
                cell.sendBtn.isUserInteractionEnabled = true
                cell.sendBtn.setTitle("Send", for: .normal)
                cell.sendBtn.setTitleColor(UIColor.white, for: .normal)
                cell.sendBtn.backgroundColor = UIColor.FriendzrColors.primary
            }
            
            cell.HandleSendBtn = {
                self.shareEventToGroup(cell, model2, messageDate, messageTime, url)
            }
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
            let model3 = myEventsVM.events.value?.data?[indexPath.row]
            cell.titleLbl.text = model3?.title
            
            if model3?.isSendEvent == true {
                cell.sendBtn.isUserInteractionEnabled = false
                cell.sendBtn.setTitle("Sent", for: .normal)
                cell.sendBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
                cell.sendBtn.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
                cell.sendBtn.backgroundColor = .white
            }
            else {
                cell.sendBtn.isUserInteractionEnabled = true
                cell.sendBtn.setTitle("Send", for: .normal)
                cell.sendBtn.setTitleColor(UIColor.white, for: .normal)
                cell.sendBtn.backgroundColor = UIColor.FriendzrColors.primary
            }
            
            cell.HandleSendBtn = {
                self.shareEventToEvent(cell, model3, messageDate, messageTime, url)
            }
            
            return cell
        }
        
    }
}

//MARK: - UITableViewDelegate
extension ShareEventVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == friendsTV,(scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height, !isLoadingFriendsList {
            
            self.isLoadingFriendsList = true
            
            if currentFriendsPage < myFriendsVM.friends.value?.totalPages ?? 0 {
                self.friendsTV.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentFriendsPage)")
                    self.loadMoreFriendsList()
                }
            }else {
                self.friendsTV.tableFooterView = nil
                return
            }
        }
        else if scrollView == groupsTV,(scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height, !isLoadingGroupsList {
            
            self.isLoadingGroupsList = true
            
            if currentGroupsPage < myGroupsVM.listChat.value?.totalPages ?? 0 {
                self.groupsTV.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentFriendsPage)")
                    self.loadMoreGroupsList()
                }
            }else {
                self.groupsTV.tableFooterView = nil
                return
            }
        }
        else if scrollView == eventsTV,(scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height, !isLoadingEventsList {
            
            self.isLoadingEventsList = true
            
            if currentEventsPage < myEventsVM.events.value?.totalPages ?? 0 {
                self.eventsTV.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentFriendsPage)")
                    self.loadMoreEventsList()
                }
            }else {
                self.eventsTV.tableFooterView = nil
                return
            }
        }
    }
}

//MARK: - UISearchBarDelegate
extension ShareEventVC: UISearchBarDelegate{
    @objc func updateSearchResult() {
        guard let text1 = friendsSearchBar.text else {return}
        guard let text2 = groupsSearchBar.text else {return}
        guard let text3 = eventsSearchBar.text else {return}
        print(text1,text2,text3)
        
        if NetworkConected.internetConect {
            if text1 != "" {
                currentFriendsPage = 1
                self.getAllMyFriends(pageNumber: 1, search: text1)
            }else {
                currentFriendsPage = 1
                self.getAllMyFriends(pageNumber: 1, search: "")
            }
        }
        
        if NetworkConected.internetConect {
            if text2 != "" {
                currentGroupsPage = 1
                self.getAllMyGroups(pageNumber: 1, search: text2)
            }else {
                currentGroupsPage = 1
                self.getAllMyGroups(pageNumber: 1, search: "")
            }
        }
        
        if NetworkConected.internetConect {
            if text3 != "" {
                currentEventsPage = 1
                self.getAllMyEvents(pageNumber: 1, search: text3)
            }else {
                currentEventsPage = 1
                self.getAllMyEvents(pageNumber: 1, search: "")
            }
        }
    }
}
