//
//  ShareEventVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/02/2022.
//

import UIKit

class ShareEventVC: UIViewController {
    
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
    
    
    var cellID = "ShareTableViewCell"
    var eventID:String = ""
    var myFriendsVM:AllFriendesViewModel = AllFriendesViewModel()
    var myEventsVM:EventsViewModel = EventsViewModel()
    var myGroupsVM:GroupViewModel = GroupViewModel()
    var shareEventMessageVM:ChatViewModel = ChatViewModel()
    
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
        
        title = "Share".localizedString
        setupViews()
        getAllMyEvents(pageNumber: 1,search:"")
        getAllMyGroups(pageNumber: 1, search: "")
        getAllMyFriends(pageNumber: 1, search: "")
        initCloseBarButton()
        setupNavBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "ShareEventVC"
        print("availableVC >> \(Defaults.availableVC)")
    }
    
    //MARK:- APIs
    func getAllMyEvents(pageNumber:Int,search:String) {
        myEventsVM.getMyEvents(pageNumber: pageNumber, search: search)
        myEventsVM.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.eventsTV.delegate = self
                    self.eventsTV.dataSource = self
                    self.eventsTV.reloadData()
                }
                if value.data?.count == 0 {
                    eventsEmptyView.isHidden = false
                    if search != "" {
                        emptyFriendslbl.text = "No events match your search"
                    }else {
                        emptyFriendslbl.text = "You have no events"
                    }
                }else {
                    eventsEmptyView.isHidden = true
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
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.groupsTV.delegate = self
                    self.groupsTV.dataSource = self
                    self.groupsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    groupsEmptyView.isHidden = false
                    if search != "" {
                        emptyFriendslbl.text = "No groups match your search"
                    }else {
                        emptyFriendslbl.text = "You have no groups"
                    }
                }else {
                    groupsEmptyView.isHidden = true
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
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.friendsTV.delegate = self
                    self.friendsTV.dataSource = self
                    self.friendsTV.reloadData()
                }
                
                if value.data?.count == 0 {
                    friendsEmptyView.isHidden = false
                    if search != "" {
                        emptyFriendslbl.text = "No friends match your search"
                    }else {
                        emptyFriendslbl.text = "You have no friends"
                    }
                }else {
                    friendsEmptyView.isHidden = true
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
    
    @IBAction func shareOutSideFriendzrBtn(_ sender: Any) {
        shareEvent()
    }
    
}

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
                    }
                }
            }
        }
        else if tableView == groupsTV {
            let model = myGroupsVM.listChat.value?.data?[indexPath.row]
            cell.titleLbl.text = model?.chatName
            cell.HandleSendBtn = {
                cell.sendBtn.setTitle("Sending...", for: .normal)
                cell.sendBtn.isUserInteractionEnabled = false
                self.shareEventMessageVM.SendMessage(withGroupId: model?.id ?? "", AndMessageType: 4, AndMessage: "oo", messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!, eventShareid: self.eventID) { error, data in
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                            cell.sendBtn.setTitle("Sent", for: .normal)
                        }
                        return
                    }
                    
                    guard let _ = data else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        cell.sendBtn.isUserInteractionEnabled = false
                        cell.sendBtn.setTitle("Send", for: .normal)
                        cell.sendBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
                        cell.sendBtn.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
                        cell.sendBtn.backgroundColor = .white
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
                    }
                }
            }
            
        }
        else {
            let model = myEventsVM.events.value?.data?[indexPath.row]
            cell.titleLbl.text = model?.title
            cell.HandleSendBtn = {
                cell.sendBtn.setTitle("Sending...", for: .normal)
                cell.sendBtn.isUserInteractionEnabled = false
                self.shareEventMessageVM.SendMessage(withEventId: model?.id ?? "", AndMessageType: 4, AndMessage: "oo", messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!, eventShareid: self.eventID) { error, data in
                    
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
                    }
                }
            }
        }
        
        return cell
    }
}

extension ShareEventVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}


extension ShareEventVC: UISearchBarDelegate{
    @objc func updateSearchFriendsResult() {
        guard let text1 = friendsSearchBar.text else {return}
        guard let text2 = groupsSearchBar.text else {return}
        guard let text3 = eventsSearchBar.text else {return}
        print(text1,text2,text3)
        
        if text1 != "" {
            getAllMyFriends(pageNumber: 1, search: text1)
        }else {
            getAllMyFriends(pageNumber: 1, search: "")
            
        }
        
        if text2 != "" {
            getAllMyGroups(pageNumber: 1, search: text2)
        }else {
            getAllMyGroups(pageNumber: 1, search: "")
        }
        
        if text3 != "" {
            getAllMyEvents(pageNumber: 1, search: text3)
        }else {
            getAllMyEvents(pageNumber: 1, search: "")
        }
    }
}
