//
//  ChatVC.swift
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

class ChatVC: MessagesViewController,UIPopoverPresentationControllerDelegate {
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    // MARK: - Public properties
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let fileRecordName = "demo.caf"
    var fileUpload = ""
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var sendingImageView: UIImage?
    
    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    lazy var audioController = AudioVC(messageCollectionView: messagesCollectionView)
    lazy var messageList: [UserMessage] = []
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    // MARK: - Private properties
    var senderUser = UserSender(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName)
    
    var viewmodel:ChatViewModel = ChatViewModel()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    //    var chatUserModel:UserChatObj? = UserChatObj()
    var chatuserID = ""
    
    var isEvent:Bool = false
    var eventChatID:String = ""
    var leavevent:Int = 0 //0 is in event,1 leave vent,2 leave chat event
    
    var receiveName:String = ""
    var receiveimg = ""
    var isFriend:Bool? = false
    var titleChatImage = ""
    var titleChatName:String = ""
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    
    let database = Firestore.firestore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        initBackButton()
        setupMessages()
        
        configureMessageInputBar()
        setupLeftInputButton(tapMessage: false, Recorder: "play")
        
        //        setupRecorder()
        
        //        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        //        messagesCollectionView.addGestureRecognizer(longPress)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessages), name: Notification.Name("listenToMessages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForEvent), name: Notification.Name("listenToMessagesForEvent"), object: nil)
        
//        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
//        messagesCollectionView.register(CustomCell.self)
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
        if isEvent {
            if leavevent == 0 {
                messageInputBar.inputTextView.becomeFirstResponder()
                messageInputBar.isHidden = false
            }else if leavevent == 1 {
                messageInputBar.isHidden = true
                self.showAlert(withMessage: "You have left this event")
            }else {
                messageInputBar.isHidden = true
                self.showAlert(withMessage: "You have left this chat event")
            }
        }else {
            if isFriend == true {
                messageInputBar.inputTextView.becomeFirstResponder()
                messageInputBar.isHidden = false
            }else {
                messageInputBar.isHidden = true
                self.showAlert(withMessage: "You are now not a friend of this user and will not be able to message him")
            }
        }
    }
        
    @objc func listenToMessages() {
        getUserChatMessages(pageNumber: 1)
    }
    
    @objc func listenToMessagesForEvent() {
        getEventChatMessages(pageNumber: 1)
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
    
    private func configureInputBarPadding() {
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
            getUserChatMessages(pageNumber: 1)
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
        
        self.messageList.append(UserMessage(location: CLLocation(latitude: lat, longitude: lng), user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: 4))
        
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
        
        if pageNumber > viewmodel.messages.value?.totalPages ?? 1 {
            return
        }
        
        self.showLoading()
        viewmodel.getChatMessages(ByUserId: chatuserID, pageNumber: pageNumber)
        viewmodel.messages.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                
                messageList.removeAll()
                
                for itm in value.data ?? [] {
                    if itm.currentuserMessage! {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                    }else {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }
                        else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        else if itm.messagetype == 3 { //file
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                
                updateTitleView(image: titleChatImage, subtitle: titleChatName)
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
    
    func getEventChatMessages(pageNumber:Int) {
        self.showLoading()
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
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                    }else {
                        if itm.messagetype == 1 { //text
                            messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                        }else if itm.messagetype == 2 { //image
                            if itm.messageAttachedVM?.count != 0 {
                                messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: "\(itm.messagesdate ?? "") \(itm.messagestime ?? "")", messageType: itm.messagetype ?? 0), at: 0)
                            }
                        }
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                updateTitleView(image: titleChatImage, subtitle: titleChatName)
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
    
    func HandleinvalidUrl() {
        self.showAlert(withMessage: "sorry for that we have some maintaince with our servers please try again in few moments".localizedString)
    }
    
    func HandleInternetConnection() {
        self.showAlert(withMessage: "No avaliable newtwok ,Please try again!".localizedString)
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


// MARK: - MessagesDataSource
extension ChatVC: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return senderUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        
        let name = (isFromCurrentSender(message: message) ? senderUser.displayName : model.user.displayName)
        
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Light", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        //        let dateString = formatter.string(from: model.sentDate)
        return NSAttributedString(string: model.dateandtime, attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Light", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
    }
}

// MARK: - MessageCellDelegate
extension ChatVC: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let model = messageList[indexPath.section]
        
        if model.user.senderId == senderUser.senderId {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileVC") as? MyProfileVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
            vc.userID = model.user.senderId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messageList[indexPath.section]
        switch message.kind {
        case .attributedText(_):break
        case .location(let locItem):
            let location = locItem.location.coordinate
            //            let locationlng = locItem.location.coordinate.longitude
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:
                                                "comgooglemaps://?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=driving")!)
                
            } else {
                NSLog("Can't use comgooglemaps://");
            }
            break
        case .contact(_):break
        case .emoji(_):break
        case .linkPreview(_):break
        case .photo(_):break
        case .video(_):break
        case .audio(_):break
        case .text(_):break
        default: break
            
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messageList[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            if message.messageType == 2 {
                guard let imgURL = media.url else {return}
                guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
                popupVC.imgURL = imgURL.description
                present(popupVC, animated: true, completion: nil)

            }else if message.messageType == 3 {
                //downlaod file
                print("PDF FILE")
                guard let fileUrl = media.url else {return}
                //
                //                let down = Downloader()
                //                down.dowanloadFile(downloadURL: fileUrl) {
                //                    self.showAlert(withMessage: "download file done")
                //                } onError: {
                //                    self.showAlert(withMessage: "onError")
                //                }
                //
                DispatchQueue.main.async {
                    UIApplication.shared.open(fileUrl)
                }
            }else {
                
            }
        case .video(let media):
            guard let videoURL = media.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
            //            break
        default:
            break
        }
    }
    
    
    func pushFile(_ destination: URL) {
        var finalURL = destination.absoluteString
        
        DispatchQueue.main.async {
            if let url = URL(string: finalURL) {
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
                
            }
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                  print("Failed to identify message when audio cell receive tap gesture")
                  return
              }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
}

// MARK: - MessageLabelDelegate

extension ChatVC: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        if let url = URL(string: "\(url)") {
            UIApplication.shared.open(url)
        }
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}

// MARK: - MessageInputBarDelegate
extension ChatVC: InputBarAccessoryViewDelegate {
    
    @objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //        processInputBar(messageInputBar)
        //1==>message 2==>images 3==>file
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if isEvent {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!) { error, data in
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                self.messageList.append(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                
                DispatchQueue.main.async {
                    inputBar.inputTextView.text = ""
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }else {
            viewmodel.SendMessage(withUserId: chatuserID, AndMessage: text, AndMessageType: 1, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!) { error, data in
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                self.messageList.append(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                
                DispatchQueue.main.async {
                    inputBar.inputTextView.text = ""
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text == "" {
            setupLeftInputButton(tapMessage: false, Recorder: "play")
        }else {
            setupLeftInputButton(tapMessage: true, Recorder: "play")
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatVC: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention, .url : return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let model = messageList[indexPath.section]
        
        let avatar1 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imag: model.user.photoURL)
        let avatar2 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imag: model.user.photoURL) // receive img
        avatarView.set(avatar: isFromCurrentSender(message: message) ? avatar1 : avatar2)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_message_placeholder"))
        } else {
            imageView.image = self.sendingImageView
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message) // this is needed especially when the cell is reconfigure while is playing sound
    }
    
}


//MARK: - Customize View
extension ChatVC {
    //handle Long Press
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: self.messagesCollectionView)
            if let indexPath = self.messagesCollectionView.indexPathForItem(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                presentActionSheetForLongPress(indexPath: indexPath.section)
            }
        }
    }
    
    //setup buttons for chat
    func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        
        
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
            }
        
        
        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .FriendzrColors.primary
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
            }
    }
    
    private func setupLeftInputButton(tapMessage:Bool,Recorder:String) {
        messageInputBar.inputTextView.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        messageInputBar.inputTextView.cornerRadiusView(radius: 8)
        
        let button = InputBarSendButton()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(named: "attach_ic"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
//        button.backgroundColor = .clear
//        button.cornerRadiusView(radius: 18)
//        button.setBorder(color: UIColor.white.cgColor.copy(alpha: 0.85), width: 2)
        
        let button2 = InputBarSendButton()
        button2.setSize(CGSize(width: 35, height: 35), animated: false)
        button2.setImage(UIImage(systemName: Recorder), for: .normal)
        button2.backgroundColor = UIColor.FriendzrColors.primary!
        button2.tintColor = .white
        button2.cornerRadiusView(radius: 17.5)
        button2.setBorder(color: UIColor.white.cgColor, width: 3)
        button2.onTouchUpInside { [weak self] _ in
            self?.recordMessageAction(sender:Recorder)
        }
        
        if tapMessage {
            messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        }else {
            messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        }
        messageInputBar.leftStackView.spacing = 5
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.left = 8
        messageInputBar.padding.left = 5
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    
    //    private func setupRightInputButton() {
    //        let button = InputBarSendButton()
    //        let image = UIImage(named: "ic_send")
    //        button.setSize(CGSize(width: 35, height:35), animated: false)
    //        button.backgroundColor = UIColor.FriendzrColors.primary
    //        button.cornerRadiusView(radius: 17.5)
    //        button.setImage(image, for: .normal)
    //        button.onTouchUpInside { _ in
    //            self.sendMessageAction()
    //
    //        }
    //        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
    //        messageInputBar.setStackViewItems([button], forStack: .right, animated: false)
    //    }
    
    //    private func sendMessageAction() {
    //        print("Send Message")
    //    }
    
    private func recordMessageAction(sender:String) {
        print("Record Message")
        
        if (sender == "play"){
            soundRecorder.record()
            setupLeftInputButton(tapMessage: false, Recorder: "pause")
            //            playButton.isEnabled = false
        } else {
            soundRecorder.stop()
            setupLeftInputButton(tapMessage: false, Recorder: "play")
            messageList.append(UserMessage(audioURL: getFileURL(), user: senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6))
            self.messagesCollectionView.reloadData()
        }
    }
    
    private func presentActionSheetForLongPress(indexPath:Int) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: "", message: "Choose the action you want to do?", preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                print("\(indexPath)")
                self.messageList.remove(at: indexPath)
                self.messagesCollectionView.reloadData()
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Hide", style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { action in
                let message = self.messageList[indexPath]
                switch message.kind {
                case .contact(let contact):
                    UIPasteboard.general.string = contact.phoneNumbers[0]
                    self.view.makeToast("Copied")
                    break
                case .emoji((let text)):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied")
                    break
                case .text(let text):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied")
                    break
                default: break
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Replay", style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionAlert  = UIAlertController(title: "", message: "Choose the action you want to do?", preferredStyle: .actionSheet)
            
            actionAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
                print("\(indexPath)")
                self.messageList.remove(at: indexPath)
                self.messagesCollectionView.reloadData()
            }))
            actionAlert.addAction(UIAlertAction(title: "Hide", style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { action in
                let message = self.messageList[indexPath]
                switch message.kind {
                case .contact(let contact):
                    UIPasteboard.general.string = contact.phoneNumbers[0]
                    self.view.makeToast("Copied")
                    break
                case .emoji((let text)):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied")
                    break
                case .text(let text):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied")
                    break
                default: break
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Replay", style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }
    }
    
    private func presentInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: "Attach Media", message: "What would you like attach?", preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { action in
                self.presentPhotoInputActionSheet()
            }))
            
            //            actionAlert.addAction(UIAlertAction(title: "Video", style: .default, handler: { action in
            //                self.presentVideoInputActionSheet()
            //            }))
            //            actionAlert.addAction(UIAlertAction(title: "Location", style: .default, handler: { action in
            //                guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "SendLocationChatVC") as? SendLocationChatVC else {return}
            //                vc.onLocationCallBackResponse = self.onLocationCallBack
            //                self.navigationController?.pushViewController(vc, animated: true)
            //            }))
            
            actionAlert.addAction(UIAlertAction(title: "File", style: .default, handler: { action in
                
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: "Attach Media", message: "What would you like attach?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { action in
                self.presentPhotoInputActionSheet()
            }))
            
            //            actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { action in
            //                self.presentVideoInputActionSheet()
            //            }))
            //            actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { action in
            //
            //                guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "SendLocationChatVC") as? SendLocationChatVC else {return}
            //                vc.onLocationCallBackResponse = self.onLocationCallBack
            //                self.navigationController?.pushViewController(vc, animated: true)
            //            }))
            
            actionSheet.addAction(UIAlertAction(title: "File", style: .default, handler: { action in
                self.openFileLibrary()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func presentPhotoInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsAlert: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsAlert.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsAlert.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsAlert.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsAlert, animated:true, completion:nil)
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Photo Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
    
    
    func presentVideoInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsAlert: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsAlert.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openVideoCamera()
            }))
            settingsAlert.addAction(UIAlertAction(title:"Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openVideoLibrary()
            }))
            settingsAlert.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsAlert, animated:true, completion:nil)
        }else {
            let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
            
            settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openVideoCamera()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openVideoLibrary()
            }))
            settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
            
            present(settingsActionSheet, animated:true, completion:nil)
        }
    }
}

extension ChatVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK:- Take Picture
    func openCamera(){
        fileUpload = "IMAGE"
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- Open Library
    func openLibrary(){
        fileUpload = "IMAGE"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openVideoLibrary() {
        fileUpload = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openVideoCamera() {
        fileUpload = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.videoQuality = .typeMedium
            imagePicker.mediaTypes = ["public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //selct file to send in chat
    func openFileLibrary() {
        fileUpload = "File"
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF,kUTTypeUTF8PlainText] as [String] , in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print(videoURL)
            picker.dismiss(animated:true, completion: {
                
                self.messageList.append(UserMessage(videoURL: videoURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6))
                self.messagesCollectionView.reloadData()
            })
        }else {
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!) { error, data in
                    
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    self.messageList.append(UserMessage(imageURL: URL(string: data.attach ?? "")!, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                    
                    self.sendingImageView = UIImage(named: data.attach ?? "")
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }else {
                viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 2, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!) { error, data in
                    
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    self.messageList.append(UserMessage(imageURL: URL(string: data.attach ?? "")!, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                    
                    self.sendingImageView = UIImage(named: data.attach ?? "")
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }
            
            picker.dismiss(animated:true, completion: {
                
            })
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension ChatVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // MARK:- AVRecorder Setup
    
    func setupRecorder() {
        
        //set the settings for recorder
        
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless)),
                        AVNumberOfChannelsKey : NSNumber(value: 2),
                     AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))];
        
        var error: NSError?
        
        do {
            //  soundRecorder = try AVAudioRecorder(URL: getFileURL(), settings: recordSettings as [NSObject : AnyObject])
            soundRecorder =  try AVAudioRecorder(url: getFileURL() as URL, settings: recordSettings)
        } catch let error1 as NSError {
            error = error1
            soundRecorder = nil
        }
        
        if let err = error {
            print("AVAudioRecorder error: \(err.localizedDescription)")
        } else {
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        }
    }
    
    // MARK:- Prepare AVPlayer
    
    func preparePlayer() {
        var error: NSError?
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            soundPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
    }
    
    // MARK:- File URL
    
    func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true)
        
        return paths[0]
    }
    
    func getFileURL() -> URL {
        
        let path = getCacheDirectory().appending(fileRecordName)
        
        let filePath = URL(fileURLWithPath: path)
        
        return filePath
    }
    
    // MARK:- AVAudioPlayer delegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //        recordButton.isEnabled = true
        //        playButton.setTitle("Play", for: .normal)
        setupLeftInputButton(tapMessage: false, Recorder: "play")
    }
    
    private func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    // MARK:- AVAudioRecorder delegate methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //        playButton.isEnabled = true
        //        recordButton.setTitle("Record", for: .normal)
        setupLeftInputButton(tapMessage: false, Recorder: "play")
    }
    
    private func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    // MARK:- didReceiveMemoryWarning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatVC: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
    
    // MARK: - Helpers
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
}

extension ChatVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        //        let dir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
                try FileManager.default.removeItem(at: sandboxFileURL)
            }
            
            try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
            
            let messageDate = formatterDate.string(from: Date())
            let messageTime = formatterTime.string(from: Date())
            
            //            let imageData = try Data(contentsOf: selectedFileURL as URL)
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL) { error, data in
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    self.messageList.append(UserMessage(imageURL: URL(string: data.attach ?? "")!, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                    self.sendingImageView = UIImage(named: data.attach ?? "")
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                    
                }
            }else {
                viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 3, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL) { error, data in
                    
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    self.messageList.append(UserMessage(imageURL: URL(string: data.attach ?? "")!, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "\(messageDate) \(messageTime)", messageType: data.messagetype ?? 0))
                    
                    self.sendingImageView = UIImage(named: data.attach ?? "")
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }
            
        }
        
        catch {
            print("Error: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("close")
        controller.dismiss(animated: true, completion: nil)
    }
}
