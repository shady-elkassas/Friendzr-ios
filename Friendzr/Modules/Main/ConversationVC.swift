//
//  ConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import MapKit
import AVFoundation
import MobileCoreServices
import AVKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import ListPlaceholder

class ConversationVC: MessagesViewController,UIPopoverPresentationControllerDelegate {
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Public properties
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let fileRecordName = ""
    var fileUpload = ""
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var sendingImageView: UIImage?
    
    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    lazy var audioController = AudioVC(messageCollectionView: messagesCollectionView)
    lazy var messageList: [UserMessage] = []
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    var keyboardManager = KeyboardManager()
    let subviewInputBar = InputBarAccessoryView()
    
    //    lazy var textMessageSizeCalculator: CustomTextLayoutSizeCalculator = CustomTextLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
    
    // MARK: - Private properties
    var senderUser = UserSender(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName)
    
    var viewmodel:ChatViewModel = ChatViewModel()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var chatuserID = ""
    
    var isEvent:Bool = false
    var eventChatID:String = ""
    var leavevent:Int = 0 //0 is in event,1 leave vent,2 leave chat event
    
    var receiveName:String = ""
    var receiveimg = ""
    var isFriend:Bool? = false
    var titleChatImage = ""
    var titleChatName:String = ""
    
    
    var titleID:String? = ""
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
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
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    let database = Firestore.firestore()
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        initBackChatButton()
        showDownView()
        setupMessages()
        
        configureMessageInputBar()
        setupLeftInputButton(tapMessage: false, Recorder: "play")
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessages), name: Notification.Name("listenToMessages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForEvent), name: Notification.Name("listenToMessagesForEvent"), object: nil)
        
        subviewInputBar.delegate = self
        additionalBottomInset = 88
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessagesChat), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stopAnyOngoingPlaying()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationbar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    @objc func listenToMessages() {
        getUserChatMessages(pageNumber: 1)
    }
    
    @objc func listenToMessagesForEvent() {
        getEventChatMessages(pageNumber: 1)
    }
    
    func insertMessage(_ message: UserMessage) {
        messageList.append(message)
        setupNavigationbar()
        
        //        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        //         Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        })
    }
    
    func reloadLastIndexInCollectionView() {
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        let contentOffset = messagesCollectionView.contentOffset
        messagesCollectionView.reloadData()
        messagesCollectionView.layoutIfNeeded()
        messagesCollectionView.setContentOffset(contentOffset, animated: false)
        messagesCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
    }
    
    @objc func updateMessagesChat() {
        print("POP")
        setupNavigationbar()
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func showDownView() {
        if isEvent {
            if leavevent == 0 {
                messageInputBar.isHidden = false
                initOptionsInChatEventButton()
            }else if leavevent == 1 {
                setupDownView(textLbl: "You have left this event".localizedString)
            }else {
                setupDownView(textLbl: "You have left this chat event".localizedString)
            }
        }else {
            if isFriend == true {
                messageInputBar.isHidden = false
                initOptionsInChatUserButton()
            }else {
                setupDownView(textLbl: "You are now not a friend of this user and will not be able to message him".localizedString)
            }
        }
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor.FriendzrColors.primary
        messageInputBar.sendButton.setTitleColor(UIColor.FriendzrColors.primary, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.FriendzrColors.primary?.withAlphaComponent(0.3),
            for: .highlighted
        )
        
        messageInputBar.inputTextView.textColor = UIColor.setColor(lightColor: .black, darkColor: .white)
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    func configureInputBarPadding() {
        // Entire InputBar padding
        messageInputBar.padding.bottom = 8
        // or MiddleContentView padding
        messageInputBar.middleContentViewPadding.right = -38
        // or InputTextView padding
        messageInputBar.inputTextView.textContainerInset.bottom = 8
    }
    
    func setupMessages() {
        if isEvent {
            self.getEventChatMessages(pageNumber: 1)
        }else {
            self.getUserChatMessages(pageNumber: 1)
        }
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func onLocationCallBack(_ lat: Double, _ lng: Double,_ title:String) -> () {
        print("\(lat)", "\(lng)",title)
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        
        self.insertMessage(UserMessage(location: CLLocation(latitude: lat, longitude: lng), user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: 4))
        
        self.messagesCollectionView.reloadData()
    }
    
    //MARK: - APIs
    func getDate(dateStr:String,timeStr:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.autoupdatingCurrent
        return dateFormatter.date(from: "\(dateStr)T\(timeStr):00+0000") // replace Date String
    }
    
    func getUserChatMessages(pageNumber:Int) {
        CancelRequest.currentTask = false
        
        if pageNumber > viewmodel.messages.value?.totalPages ?? 1 {
            return
        }
        
        viewmodel.getChatMessages(ByUserId: chatuserID, pageNumber: pageNumber)
        viewmodel.messages.bind { [unowned self] value in
            DispatchQueue.main.async {

                messageList.removeAll()
                
                for itm in value.data ?? [] {
                    if itm.currentuserMessage! {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                    }else {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }
                        else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                if pageNumber <= 1 {
                    if messageList.isEmpty {
                        messagesCollectionView.reloadData()
                    }else {
                        reloadLastIndexInCollectionView()
                        
                    }
                }else {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
                self.refreshControl.endRefreshing()
                
                updateTitleView(image: titleChatImage, subtitle: titleChatName, titleId: chatuserID, isEvent: false)
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
                    self.showAlert(withMessage: error)
                }
            }
        }
    }
    
    func getEventChatMessages(pageNumber:Int) {
        CancelRequest.currentTask = false
        
        viewmodel.getChatMessages(ByEventId: eventChatID, pageNumber: pageNumber)
        viewmodel.eventmessages.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                
                messageList.removeAll()
                for itm in value.pagedModel?.data ?? [] {
                    if itm.currentuserMessage! {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }else {
                                messageList.insert(UserMessage(image: UIImage(named: "placeholder")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }else {
                                messageList.insert(UserMessage(image: UIImage(named: "placeholder")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                    }else {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                if pageNumber <= 1 {
                    if messageList.isEmpty {
                        messagesCollectionView.reloadData()
                    }else {
                        reloadLastIndexInCollectionView()
                    }
                }else {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
                self.refreshControl.endRefreshing()
                updateTitleView(image: titleChatImage, subtitle: titleChatName, titleId: eventChatID, isEvent: true)
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
    
      
//    func LoadUserChatMessages(pageNumber:Int) {
//        CancelRequest.currentTask = false
//
//        if pageNumber > viewmodel.messages.value?.totalPages ?? 1 {
//            return
//        }
//
//        self.messagesCollectionView.hideLoader()
//        viewmodel.getChatMessages(ByUserId: chatuserID, pageNumber: pageNumber)
//        viewmodel.messages.bind { [unowned self] value in
//            DispatchQueue.main.async {
//                self.hideLoading()
//
//                messageList.removeAll()
//
//                for itm in value.data ?? [] {
//                    if itm.currentuserMessage! {
//                        if itm.messagetype == 1 { //text
//                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                        }else if itm.messagetype == 2 { //image
//                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }else if itm.messagetype == 3 { //file
//                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }
//
//                    }else {
//                        if itm.messagetype == 1 { //text
//                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                        }
//                        else if itm.messagetype == 2 { //image
//                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }
//                        else if itm.messagetype == 3 { //file
//                            if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }
//
//                        receiveimg = itm.userimage ?? ""
//                        receiveName = itm.username ?? ""
//                    }
//                }
//
//                if pageNumber <= 1 {
//                    if messageList.isEmpty {
//                        messagesCollectionView.reloadData()
//                        messagesCollectionView.hideLoader()
//                    }else {
//                        messagesCollectionView.showLoader()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.messagesCollectionView.hideLoader()
//                        }
//                        reloadLastIndexInCollectionView()
//                    }
//                }else {
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                }
//
//                self.refreshControl.endRefreshing()
//
//                updateTitleView(image: titleChatImage, subtitle: titleChatName, titleId: chatuserID, isEvent: false)
//            }
//        }
//
//        // Set View Model Event Listener
//        viewmodel.error.bind { [unowned self]error in
//            DispatchQueue.main.async {
//                self.hideLoading()
//                if error == "Internal Server Error" {
//                    HandleInternetConnection()
//                }else if error == "Bad Request" {
//                    HandleinvalidUrl()
//                }else {
//                    self.showAlert(withMessage: error)
//                }
//            }
//        }
//    }
    
//    func LoadEventChatMessages(pageNumber:Int) {
//        CancelRequest.currentTask = false
//
//        self.messagesCollectionView.hideLoader()
//        viewmodel.getChatMessages(ByEventId: eventChatID, pageNumber: pageNumber)
//        viewmodel.eventmessages.bind { [unowned self] value in
//            DispatchQueue.main.async {
//                self.hideLoading()
//
//                messageList.removeAll()
//                for itm in value.pagedModel?.data ?? [] {
//                    if itm.currentuserMessage! {
//                        if itm.messagetype == 1 { //text
//                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                        }else if itm.messagetype == 2 { //image
//                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }else {
//                                messageList.insert(UserMessage(image: UIImage(named: "placeholder")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }else if itm.messagetype == 3 { //file
//                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
//                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }else {
//                                messageList.insert(UserMessage(image: UIImage(named: "placeholder")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }
//                    }else {
//                        if itm.messagetype == 1 { //text
//                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                        }else if itm.messagetype == 2 { //image
//                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
//                                messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }else if itm.messagetype == 3 { //file
//                            if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
//                                messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
//                            }
//                        }
//
//                        receiveimg = itm.userimage ?? ""
//                        receiveName = itm.username ?? ""
//                    }
//                }
//
//                if pageNumber <= 1 {
//                    if messageList.isEmpty {
//                        messagesCollectionView.reloadData()
//                        self.messagesCollectionView.hideLoader()
//                    }else {
//                        reloadLastIndexInCollectionView()
//
//                        messagesCollectionView.showLoader()
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.messagesCollectionView.hideLoader()
//                        }
//                    }
//                }else {
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                }
//
//                self.refreshControl.endRefreshing()
//                updateTitleView(image: titleChatImage, subtitle: titleChatName, titleId: eventChatID, isEvent: true)
//            }
//        }
//
//        // Set View Model Event Listener
//        viewmodel.error.bind { [unowned self]error in
//            DispatchQueue.main.async {
//                self.hideLoading()
//                if error == "Internal Server Error" {
//                    HandleInternetConnection()
//                }else if error == "Bad Request" {
//                    HandleinvalidUrl()
//                }else {
//                    self.showAlert(withMessage: error)
//                }
//            }
//        }
//    }

    
    func HandleinvalidUrl() {
        DispatchQueue.main.async {
            self.view.makeToast("sorry for that we have some maintaince with our servers please try again in few moments".localizedString)
        }
    }
    
    func HandleInternetConnection() {
        DispatchQueue.main.async {
            self.view.makeToast("No avaliable network ,Please try again!".localizedString)
        }
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            self.currentPage += 1
            if self.isEvent {
                self.getEventChatMessages(pageNumber: self.currentPage)
            }else {
                self.getUserChatMessages(pageNumber: self.currentPage)
            }
        }
    }
}

extension ConversationVC {
    func initBackChatButton() {
        
        var imageName = ""
        if Language.currentLanguage() == "ar" {
            imageName = "back_icon"
        }else {
            imageName = "back_icon"
        }
        
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(backToInbox), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToInbox() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            Router().toHome()
        })
    }
    
    func initOptionsInChatUserButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleUserOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func initOptionsInChatEventButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleEventOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleUserOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Unfriend".localizedString, style: .default, handler: { action in
                self.unFriendAccount()
            }))
            actionAlert.addAction(UIAlertAction(title: "Block".localizedString, style: .default, handler: { action in
                self.blockFriendAccount()
            }))
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if self.isEvent == true {
                    Router().toReportVC(id: self.eventChatID, isEvent: true, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }else {
                    Router().toReportVC(id: self.chatuserID, isEvent: false, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Unfriend".localizedString, style: .default, handler: { action in
                self.unFriendAccount()
            }))
            actionSheet.addAction(UIAlertAction(title: "Block".localizedString, style: .default, handler: { action in
                self.blockFriendAccount()
            }))
            actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if self.isEvent == true {
                    Router().toReportVC(id: self.eventChatID, isEvent: true, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }else {
                    Router().toReportVC(id: self.chatuserID, isEvent: false, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @objc func handleEventOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//            actionAlert.addAction(UIAlertAction(title: "Leave", style: .default, handler: { action in
//                self.leaveEvent()
//            }))
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if self.isEvent == true {
                    Router().toReportVC(id: self.eventChatID, isEvent: true, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }else {
                    Router().toReportVC(id: self.chatuserID, isEvent: false, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//            actionSheet.addAction(UIAlertAction(title: "Leave", style: .default, handler: { action in
//                self.leaveEvent()
//            }))
            actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if self.isEvent == true {
                    Router().toReportVC(id: self.eventChatID, isEvent: true, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }else {
                    Router().toReportVC(id: self.chatuserID, isEvent: false, chatimg: self.titleChatImage, chatname: self.titleChatName)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func leaveEvent() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to leave this event chat?".localizedString
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.HandleConfirmBtn = {
            self.viewmodel.LeaveChat(ByID: self.eventChatID, ActionDate: actionDate, Actiontime: actionTime) { error, data in
                self.hideLoading()
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
                    self.view.makeToast("You have successfully left the chat".localizedString)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
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
        
        self.view.addSubview((alertView)!)
        
    }
    
    func unFriendAccount() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 5) { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast(message)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
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
        
        self.view.addSubview((alertView)!)
    }
    
    func blockFriendAccount() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 3) { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast(message)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
            }
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
        
        self.view.addSubview((alertView)!)
    }
}


extension ConversationVC {
    func updateTitleView(image: String, subtitle: String?,titleId:String,isEvent:Bool) {
        
        let imageUser = UIImageView(frame: CGRect(x: 0, y: -5, width: 25, height: 25))
        imageUser.backgroundColor = UIColor.clear
        imageUser.image = UIImage(named: image)
        imageUser.contentMode = .scaleToFill
        imageUser.cornerRadiusView(radius: 12.5)
        imageUser.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 0, height: 0))
        subtitleLabel.textColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(imageUser)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            imageUser.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - imageUser.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            imageUser.frame.origin.x = newX
        }
        
        self.titleID = titleId

        let btn = UIButton(frame: titleView.frame)
        if isEvent == true {
            btn.addTarget(self, action: #selector(goToEventDetailsVC), for: .touchUpInside)
        }else {
            btn.addTarget(self, action: #selector(goToUserProfileVC), for: .touchUpInside)
        }
        
        titleView.addSubview(btn)
        
        navigationItem.titleView = titleView
    }
    
    @objc func goToUserProfileVC() {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
        vc.userID = self.titleID!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToEventDetailsVC() {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else {return}
        vc.eventId = self.titleID!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
