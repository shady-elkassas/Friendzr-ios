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
    
    var internetConnect:Bool = false

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
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "ShareEventVC"
        print("availableVC >> \(Defaults.availableVC)")
    }
    
    //MARK: - APIs
    func getAllMyEvents(pageNumber:Int,search:String) {
        hideView3.isHidden = true
        myEventsVM.getMyEvents(pageNumber: pageNumber, search: search)
        myEventsVM.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.eventsTV.delegate = self
                    self.eventsTV.dataSource = self
                    self.eventsTV.reloadData()
                }
                if value.data?.count == 0 {
                    self.eventsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No events match your search"
                    }else {
                        self.emptyFriendslbl.text = "You have no events yet"
                    }
                }else {
                    self.eventsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyGroups(pageNumber:Int,search:String) {
        hideView2.isHidden = true
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.groupsTV.delegate = self
                    self.groupsTV.dataSource = self
                    self.groupsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    self.groupsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No groups match your search"
                    }else {
                        self.emptyFriendslbl.text = "You have no groups yet"
                    }
                }else {
                    self.groupsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myGroupsVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyFriends(pageNumber:Int,search:String) {
        hideView1.isHidden = true
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.friendsTV.delegate = self
                    self.friendsTV.dataSource = self
                    self.friendsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    self.friendsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No friends match your search"
                    }else {
                        self.emptyFriendslbl.text = "you have no friends yet"
                    }
                }else {
                    self.friendsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myFriendsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    func LoadAllMyEvents(pageNumber:Int,search:String) {
        hideView3.isHidden = false
        hideView3.showLoader()
        myEventsVM.getMyEvents(pageNumber: pageNumber, search: search)
        myEventsVM.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.eventsTV.delegate = self
                    self.eventsTV.dataSource = self
                    self.eventsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.hideView3.isHidden = true
                    self.hideView3.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self.eventsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No events match your search"
                    }else {
                        self.emptyFriendslbl.text = "You have no events yet"
                    }
                }else {
                    self.eventsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func LoadAllMyGroups(pageNumber:Int,search:String) {
        hideView2.isHidden = false
        hideView2.showLoader()
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.groupsTV.delegate = self
                    self.groupsTV.dataSource = self
                    self.groupsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.hideView2.isHidden = true
                    self.hideView2.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self.groupsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No groups match your search"
                    }else {
                        self.emptyFriendslbl.text = "You have no groups yet"
                    }
                }else {
                    self.groupsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myGroupsVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func LoadAllMyFriends(pageNumber:Int,search:String) {
        hideView1.isHidden = false
        hideView1.showLoader()
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.friendsTV.delegate = self
                    self.friendsTV.dataSource = self
                    self.friendsTV.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.hideView1.isHidden = true
                    self.hideView1.hideLoader()
                }
                
                if value.data?.count == 0 {
                    self.friendsEmptyView.isHidden = false
                    if search != "" {
                        self.emptyFriendslbl.text = "No friends match your search"
                    }else {
                        self.emptyFriendslbl.text = "you have no friends yet"
                    }
                }else {
                    self.friendsEmptyView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        myFriendsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
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
        friendsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchFriendsResult), for: .editingChanged)
        
        
        groupsSearchBar.delegate = self
        groupsSearchView.cornerRadiusView(radius: 6)
        groupsSearchView.setBorder()
        groupsSearchBar.backgroundImage = UIImage()
        groupsSearchBar.searchTextField.textColor = .black
        groupsSearchBar.searchTextField.backgroundColor = .clear
        groupsSearchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        groupsSearchBar.searchTextField.attributedPlaceholder = placeHolder
        groupsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchFriendsResult), for: .editingChanged)
        
        
        eventsSearchBar.delegate = self
        eventsSearchView.cornerRadiusView(radius: 6)
        eventsSearchView.setBorder()
        eventsSearchBar.backgroundImage = UIImage()
        eventsSearchBar.searchTextField.textColor = .black
        eventsSearchBar.searchTextField.backgroundColor = .clear
        eventsSearchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        eventsSearchBar.searchTextField.attributedPlaceholder = placeHolder
        eventsSearchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchFriendsResult), for: .editingChanged)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if tableView == friendsTV {
            let model = myFriendsVM.friends.value?.data?[indexPath.row]
            cell.titleLbl.text = model?.userName
            cell.HandleSendBtn = {
                self.shareEventToUser(cell, model, messageDate, messageTime, url)
            }
        }
        
        else if tableView == groupsTV {
            let model = myGroupsVM.listChat.value?.data?[indexPath.row]
            cell.titleLbl.text = model?.chatName
            cell.HandleSendBtn = {
                self.shareEventToGroup(cell, model, messageDate, messageTime, url)
            }
            
        }
        else {
            let model = myEventsVM.events.value?.data?[indexPath.row]
            cell.titleLbl.text = model?.title
            cell.HandleSendBtn = {
                self.shareEventToEvent(cell, model, messageDate, messageTime, url)
            }
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ShareEventVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

//MARK: - UISearchBarDelegate
extension ShareEventVC: UISearchBarDelegate{
    @objc func updateSearchFriendsResult() {
        guard let text1 = friendsSearchBar.text else {return}
        guard let text2 = groupsSearchBar.text else {return}
        guard let text3 = eventsSearchBar.text else {return}
        print(text1,text2,text3)
        
        if internetConnect {
            if text1 != "" {
                self.getAllMyFriends(pageNumber: 1, search: text1)
            }else {
                self.getAllMyFriends(pageNumber: 1, search: "")
            }
        }
        
        if internetConnect {
            if text2 != "" {
                self.getAllMyGroups(pageNumber: 1, search: text2)
            }else {
                self.getAllMyGroups(pageNumber: 1, search: "")
            }
            
        }
        
        if internetConnect {
            if text3 != "" {
                self.getAllMyEvents(pageNumber: 1, search: text3)
            }else {
                self.getAllMyEvents(pageNumber: 1, search: "")
            }
        }
    }
}
