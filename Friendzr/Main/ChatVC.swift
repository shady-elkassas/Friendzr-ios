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

class ChatVC: MessagesViewController {
    
    // MARK: - Public properties
    var now = Date()
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let fileRecordName = "demo.caf"
    var fileUpload = ""
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    /// The `BasicAudioController` control the AVAudioPlayer state (play, pause, stop) and update audio cell UI accordingly.
    lazy var audioController = AudioVC(messageCollectionView: messagesCollectionView)
    lazy var messageList: [UserMessage] = []
    var refreshControl = UIRefreshControl()
    
    // MARK: - Private properties
    var senderUser = UserSender(senderId: Defaults.token, displayName: Defaults.userName, photoURL: UIImageView(image: UIImage(named: "")))
    
    var viewmodel:ChatViewModel = ChatViewModel()
    
    var internetConect:Bool = false
    var cellSelect:Bool = false
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    //    var chatUserModel:UserChatObj? = UserChatObj()
    var chatuserID = ""
    
    var eventChat:Bool = false
    var eventChatID:String = ""
    
    var titleChatName:String = ""
    var receiveName:String = ""
    var receiveimg = ""
    
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    
    let database = Firestore.firestore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        initBackButton()
        setupMessages()
        setupLeftInputButton(tapMessage: false, Recorder: "play")
        setupRecorder()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        messagesCollectionView.addGestureRecognizer(longPress)
        
        //        listenToMessages()
        
        pullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        MockSocket.shared.disconnect()
        audioController.stopAnyOngoingPlaying()
    }
    
    private var reference: CollectionReference?
    
    private func listenToMessages() {
        
        //        reference = database.collection("channels/\(chatuserID)/thread")
        //        reference?.addSnapshotListener({ snapShot, error in
        //
        //            guard let data = snapShot?.data(),error == nil else {
        //                return
        //            }
        //
        //            print(data)
        //        })
        
        //        let users = [self.currentUser.uid, self.user2UID]
        //         let data: [String: Any] = [
        //             "users":users
        //         ]
        //
        //         let db = Firestore.firestore().collection("Chats")
        //         db.addDocument(data: data) { (error) in
        //             if let error = error {
        //                 print("Unable to create chat! \(error)")
        //                 return
        //             } else {
        //                 self.loadChat()
        //             }
        //         }
        
        let docRef = database.document("channels/be5da3c5-f002-4428-989e-0339a375eb28/thread")
        docRef.addSnapshotListener { snapShot, error in
            
            guard let data = snapShot?.data(),error == nil else {
                return
            }
            
            print(data)
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
            UIColor.FriendzrColors.primary!.withAlphaComponent(0.3),
            for: .highlighted
        )
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
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
    
    func dateAddingRandomTime() -> Date {
        let randomNumber = Int(arc4random_uniform(UInt32(10)))
        if randomNumber % 2 == 0 {
            let date = Calendar.current.date(byAdding: .hour, value: randomNumber, to: now)!
            now = date
            return date
        } else {
            let randomMinute = Int(arc4random_uniform(UInt32(59)))
            let date = Calendar.current.date(byAdding: .minute, value: randomMinute, to: now)!
            now = date
            return date
        }
    }
    
    func setupMessages() {
        if eventChat {
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
        self.messageList.append(UserMessage(location: CLLocation(latitude: lat, longitude: lng), user: self.senderUser, messageId: "1", date: Date()))
        self.messagesCollectionView.reloadData()
    }
    
    //MARK: - APIs
    
    func getDate(dateStr:String,timeStr:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: "\(dateStr)T\(timeStr):00") // replace Date String
    }
    
    func getUserChatMessages(pageNumber:Int) {
        
        if pageNumber > viewmodel.messages.value?.totalPages ?? 1 {
            return
        }
        
        self.showLoading()
        viewmodel.getChatMessages(ByUserId: chatuserID ?? "", pageNumber: pageNumber)
        viewmodel.messages.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                
                for itm in value.data ?? [] {
                    if itm.currentuserMessage! {
                        messageList.append(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId , displayName: senderUser.displayName , photoURL: UIImageView(image: UIImage(named: ""))), messageId: itm.id ?? "", date: getDate(dateStr: itm.messagesdate!, timeStr: itm.messagestime!)!))
                        
                    }else {
                        messageList.append(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", displayName: itm.username ?? "", photoURL: UIImageView(image: UIImage(named: ""))), messageId: itm.id ?? "", date: getDate(dateStr: itm.messagesdate!, timeStr: itm.messagestime!)!))
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                if pageNumber > 1 {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }else {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
                
                updateTitleView(image: receiveimg, subtitle: receiveName, baseColor: .black)
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
                
                for itm in value.pagedModel?.data ?? [] {
                    if itm.currentuserMessage! {
                        messageList.append(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId , displayName: senderUser.displayName , photoURL: UIImageView(image: UIImage(named: ""))), messageId: itm.id ?? "", date: getDate(dateStr: itm.messagesdate!, timeStr: itm.messagestime!)!))
                        
                    }else {
                        messageList.append(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", displayName: itm.username ?? "", photoURL: UIImageView(image: UIImage(named: ""))), messageId: itm.id ?? "", date: getDate(dateStr: itm.messagesdate!, timeStr: itm.messagestime!)!))
                        
                        receiveimg = itm.userimage ?? ""
                        receiveName = itm.username ?? ""
                    }
                }
                
                if pageNumber > 1 {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }else {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
                
                updateTitleView(image: receiveimg, subtitle: titleChatName, baseColor: .black)
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
        self.view.makeToast("sorry for that we have some maintaince with our servers please try again in few moments".localizedString)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            self.currentPage += 1
            if self.eventChat {
                self.getEventChatMessages(pageNumber: self.currentPage)
            }else {
                self.getUserChatMessages(pageNumber: self.currentPage)
            }
        }
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.messagesCollectionView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        loadMoreMessages()
        self.refreshControl.endRefreshing()
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
        let name = (isFromCurrentSender(message: message) ? senderUser.displayName : receiveName)
        
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Light", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: messageList[indexPath.row].sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.init(name: "Montserrat-Light", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2)])
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
        let message = messageList[indexPath.section]

//        if message.sender.senderId {
//            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileVC") as? MyProfileVC else {return}
//            self.navigationController?.pushViewController(vc, animated: true)
//        }else {
//            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
//            vc.userID = chatuserID
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
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
            guard let imgURL = media.image else {return}
            let vc = ShowImageVC()
            vc.imgStr = imgURL
            navigationController?.pushViewController(vc, animated: true)
            break
        case .video(let media):
            guard let videoURL = media.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
            break
        default:
            break
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
        if eventChat {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 1, AndMessage: text, attachedImg: false, AndAttachImage: UIImage()) { error, data in
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let ـ = data else {
                    return
                }
                
                self.messageList.append(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date()))
            }
            
            DispatchQueue.main.async {
                inputBar.inputTextView.text = ""
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }else {
            viewmodel.SendMessage(withUserId: chatuserID ?? "", AndMessage: text, AndMessageType: 1, attachedImg: false, AndAttachImage: UIImage()) { error, data in
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard data != nil else {
                    return
                }
                
                self.messageList.append(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date()))
                
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
        let avatar1 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imgStr: Defaults.Image)
        let avatar2 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imgStr: receiveimg)
        avatarView.set(avatar: isFromCurrentSender(message: message) ? avatar1 : avatar2)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.cancelDownloadTask()
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
                    item.imageView?.backgroundColor = .primaryColor
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
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(named: "ic_attachment"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        let button2 = InputBarSendButton()
        button2.setSize(CGSize(width: 35, height: 35), animated: false)
        button2.setImage(UIImage(systemName: Recorder), for: .normal)
        button2.backgroundColor = UIColor.FriendzrColors.primary
        button2.tintColor = .white
        button2.cornerRadiusView(radius: 17.5)
        button2.setBorder(color: UIColor.white.cgColor, width: 3)
        button2.onTouchUpInside { [weak self] _ in
            self?.recordMessageAction(sender:Recorder)
        }
        
        if tapMessage {
            messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        }else {
            messageInputBar.setLeftStackViewWidthConstant(to: 78, animated: false)
        }
        messageInputBar.leftStackView.spacing = 5
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.left = 8
        messageInputBar.padding.left = 5
        messageInputBar.setStackViewItems([button,button2], forStack: .left, animated: false)
    }
    
    
    private func setupRightInputButton() {
        let button = InputBarSendButton()
        let image = UIImage(named: "ic_send")
        button.setSize(CGSize(width: 35, height:35), animated: false)
        button.backgroundColor = UIColor.FriendzrColors.primary
        button.cornerRadiusView(radius: 17.5)
        button.setImage(image, for: .normal)
        button.onTouchUpInside { _ in
            self.sendMessageAction()
            
        }
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .right, animated: false)
    }
    
    private func sendMessageAction() {
        print("Send Message")
    }
    
    private func recordMessageAction(sender:String) {
        print("Record Message")
        
        if (sender == "play"){
            soundRecorder.record()
            setupLeftInputButton(tapMessage: false, Recorder: "pause")
            //            playButton.isEnabled = false
        } else {
            soundRecorder.stop()
            setupLeftInputButton(tapMessage: false, Recorder: "play")
            messageList.append(UserMessage(audioURL: getFileURL(), user: senderUser, messageId: "1", date: Date()))
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
            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
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
            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }
    }
    
    private func presentInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: "Attach Media", message: "What would you like attach?", preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { action in
                self.presentPhotoInputActionSheet()
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Video", style: .default, handler: { action in
                self.presentVideoInputActionSheet()
            }))
            actionAlert.addAction(UIAlertAction(title: "Location", style: .default, handler: { action in
                
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            
            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: "Attach Media", message: "What would you like attach?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { action in
                self.presentPhotoInputActionSheet()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { action in
                self.presentVideoInputActionSheet()
            }))
            actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { action in
                
                guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "SendLocationChatVC") as? SendLocationChatVC else {return}
                vc.onLocationCallBackResponse = self.onLocationCallBack
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {  _ in
            }))
            
            actionSheet.view.tintColor = UIColor.FriendzrColors.primary
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //        if fileUpload == "VIDEO"{
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print(videoURL)
            picker.dismiss(animated:true, completion: {
                self.messageList.append(UserMessage(videoURL: videoURL, user: self.senderUser, messageId: "1", date: Date()))
                self.messagesCollectionView.reloadData()
            })
        }else {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            picker.dismiss(animated:true, completion: {
                self.attachedImg = true
                self.messageList.append(UserMessage(image: image, user: self.senderUser, messageId: "1", date: Date()))
                self.messagesCollectionView.reloadData()
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

//extension ChatVC: CameraInputBarAccessoryViewDelegate {
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
//
//
//        for item in attachments {
//            if  case .image(let image) = item {
//
//                self.sendImageMessage(photo: image)
//            }
//        }
//
//        inputBar.invalidatePlugins()
//    }
//
//
//    func sendImageMessage( photo  : UIImage)  {
//        let photoMessage = MockMessage(image: photo, user: self.currentSender() as! MockUser, messageId: UUID().uuidString, date: Date())
//        self.insertMessage(photoMessage)
//    }
//}
