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
import SwiftUI

extension ConversationVC {
    
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
    
    func messageDateTime(date:String,time:String) -> String {
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
    
    func messageDateTimeNow(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
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
            print("Use custom date \(customDateString)") // Jan 18
            return  customDateString
        } else {
            print("Use relative date \(relativeDateString)") // Today, Yesterday
            return "\(relativeDateString) \(time)"
        }
    }
}


//notificationMessage
class NotificationMessage {
    static var action:String = ""
    static var actionCode:String = ""
    static var messageType:Int = 0
    
    static var messageText:String = ""
    static var messsageImageURL:String = ""
    
    static var messsageLinkTitle:String = ""
    static var messsageLinkCategory:String = ""
    static var messsageLinkImageURL:String = ""
    static var messsageLinkAttendeesJoined:String = ""
    static var messsageLinkAttendeesTotalnumbert:String = ""
    static var messsageLinkEventDate:String = ""
    static var linkPreviewID:String = ""

    static var messageId:String = ""
    static var date:Date = Date()
    static var messageDate:String = ""
    static var messageTime:String = ""
    static var eventTypeLink:String = ""
    static var isJoinEvent:Int = 0
    static var senderId:String = ""
    static var photoURL:String = ""
    static var displayName:String = ""
}

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

    var isRefreshNewMessages:Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    var keyboardManager = KeyboardManager()
    let subviewInputBar = InputBarAccessoryView()

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
    var leavevent:Int = 0 //0 is in event,1 leave event,2 leave chat event
    var isEventAdmin:Bool = false
    
    var receiveName:String = ""
    var receiveimg = ""
    var isFriend:Bool? = false
    var titleChatImage = ""
    var titleChatName:String = ""
    
    var isChatGroupAdmin:Bool = false
    var isChatGroup:Bool = false
    var groupId:String = ""
    var leaveGroup:Int = 0
        
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
    
    let formatterUnfriendDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy"
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
    
    var eventType:String = ""
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
//        messagesCollectionView.register(CustomCell.self)


        setupMessages()
        initBackButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessages), name: Notification.Name("listenToMessages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForEvent), name: Notification.Name("listenToMessagesForEvent"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForGroup), name: Notification.Name("listenToMessagesForGroup"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessagesChat), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioController.stopAnyOngoingPlaying()
        CancelRequest.currentTask = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subviewInputBar.delegate = self
        additionalBottomInset = 88
        
        configureMessageCollectionView()

        if isEvent {
            Defaults.ConversationID = eventChatID
        }else if isChatGroup {
            Defaults.ConversationID = groupId
        }else {
            Defaults.ConversationID = chatuserID
        }
        
        Defaults.availableVC = "ConversationVC"
        print("availableVC >> \(Defaults.availableVC)")

        currentPage = 1
        setupNavigationbar()
        setupLeftInputButton(tapMessage: false, Recorder: "play")
        configureMessageInputBar()
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CancelRequest.currentTask = true
        
        tabBarController?.tabBar.isHidden = false
        self.hideLoading()
        
        Defaults.ConversationID = ""
    }
    
    //MARK : - listen To Messages
    @objc func listenToMessages() {
        if NotificationMessage.actionCode == chatuserID {
            if NotificationMessage.messageType == 1 {
                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0,eventType:""))
            }
            else if NotificationMessage.messageType == 2 {
                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            else if NotificationMessage.messageType == 3 {
                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType:""))
            }
            
            else if NotificationMessage.messageType == 4 {
                let url = URL(string: NotificationMessage.messsageLinkImageURL)
                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
            }
        }
        else {
            print("This is not a group")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
    
    @objc func listenToMessagesForEvent() {
        if NotificationMessage.actionCode == eventChatID {
            if NotificationMessage.messageType == 1 {
                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            else if NotificationMessage.messageType == 2 {
                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            else if NotificationMessage.messageType == 3 {
                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            
            else if NotificationMessage.messageType == 4 {
                let url = URL(string: NotificationMessage.messsageLinkImageURL)
                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
            }
        }
        else {
            print("This is not a group")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
    
    @objc func listenToMessagesForGroup() {
        if NotificationMessage.actionCode == groupId {
            if NotificationMessage.messageType == 1 {
                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0,eventType: ""))
            }
            else if NotificationMessage.messageType == 2 {
                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            else if NotificationMessage.messageType == 3 {
                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
            }
            
            else if NotificationMessage.messageType == 4 {
                let url = URL(string: NotificationMessage.messsageLinkImageURL)
                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
            }
        }else {
            print("This is not a group")
        }
        
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
    
    func insertMessage(_ message: UserMessage) {
        messageList.append(message)
        setupNavigationbar()
        
        //Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                self?.reloadLastIndexInCollectionView()
            }
        })
    }

    @objc func updateMessagesChat() {
        print("POP")
        setupNavigationbar()
    }
    
    //MARK : - setup
    func setupMessages() {
        if isEvent {
            self.getEventChatMessages(pageNumber: 1)
        }
        else {
            if isChatGroup {
                self.getGroupChatMessages(pageNumber: 1)
            }else {
                self.getUserChatMessages(pageNumber: 1)
            }
        }
    }
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func reloadLastIndexInCollectionView() {
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        let contentOffset = messagesCollectionView.contentOffset
        messagesCollectionView.reloadData()
        messagesCollectionView.layoutIfNeeded()
        messagesCollectionView.setContentOffset(contentOffset, animated: false)
        messagesCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
        messagesCollectionView.reloadDataAndKeepOffset()
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = false // default false
        messagesCollectionView.refreshControl = refreshControl
        
//        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
//        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
//        layout?.setMessageOutgoingAvatarSize(.zero)
//        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
//        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
//
//        // Set outgoing avatar to overlap with the message bubble
//        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
//        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
//        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
//
//        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
//        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
//        layout?.setMessageIncomingAccessoryViewPosition(.messageBottom)
//        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 30, height: 30))
//        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
//
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self

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
//        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.inputTextView.tintColor = UIColor.FriendzrColors.primary!
        messageInputBar.sendButton.setTitleColor(UIColor.FriendzrColors.primary!, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.FriendzrColors.primary!.withAlphaComponent(0.3),
            for: .highlighted)
        
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
        }
        else {
            if isChatGroup == true {
                if leaveGroup == 0 {
                    messageInputBar.isHidden = false
                    initOptionsInChatEventButton()
                }else {
                    setupDownView(textLbl: "You are not subscribed to this group".localizedString)
                }
            }else {
                if isFriend == true {
                    messageInputBar.isHidden = false
                    initOptionsInChatUserButton()
                }else {
                    setupDownView(textLbl: "You are no longer connected to this Friendzr. \nReconnect to message them".localizedString)
                }
            }
        }
    }

    //MARK : - Load More Messages
    @objc func loadMoreMessages() {
        isRefreshNewMessages = true
        
        self.currentPage += 1
        print("current page == \(self.currentPage)")
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            if self.isEvent {
                self.getEventChatMessages(pageNumber: self.currentPage)
            }
            else {
                if self.isChatGroup {
                    self.getGroupChatMessages(pageNumber: self.currentPage)
                }else {
                    self.getUserChatMessages(pageNumber: self.currentPage)
                }
            }
            
        }
    }
    
    //MARK : - Help
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

    func HandleinvalidUrl() {
        DispatchQueue.main.async {
            self.view.makeToast("Please try again later".localizedString)
        }
    }
    
    func HandleInternetConnection() {
        DispatchQueue.main.async {
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                Router().toHome()
            })
        }
    }

    func getDate(dateStr:String,timeStr:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.autoupdatingCurrent
        return dateFormatter.date(from: "\(dateStr)T\(timeStr):00+0000") // replace Date String
    }
    
    func onLocationCallBack(_ lat: Double, _ lng: Double,_ title:String) -> () {
        print("\(lat)", "\(lng)",title)
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        
        self.insertMessage(UserMessage(location: CLLocation(latitude: lat, longitude: lng), user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTime(date: messageDate, time: messageTime), messageType: 4,linkPreviewID: "",isJoinEvent: 0, eventType: ""))
        
        self.messagesCollectionView.reloadData()
    }
}


//MARK : - APIs
extension ConversationVC {
    func getUserChatMessages(pageNumber:Int) {
        CancelRequest.currentTask = false
        if pageNumber > viewmodel.messages.value?.totalPages ?? 1 {
            return
        }
        
        let startDate = Date()
        if isRefreshNewMessages == true {
            self.hideLoading()
        }else {
            self.showLoading()
            messageInputBar.isHidden = true
        }
        
        viewmodel.getChatMessages(ByUserId: chatuserID, pageNumber: pageNumber)
        viewmodel.messages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
            
            DispatchQueue.main.async {
                for itm in value.data ?? [] {
                    if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
                        switch itm.currentuserMessage! {
                        case true:
                            switch itm.messagetype {
                            case 1://text
                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0, eventType:""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0, eventType:""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0, eventType:""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""),user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                            default:
                                break
                            }
                        case false:
                            switch itm.messagetype {
                            case 1://text
                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID:"",isJoinEvent: 0,eventType: ""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                
                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""), user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                            default:
                                break
                            }
                            self.receiveimg = itm.userimage ?? ""
                            self.receiveName = itm.username ?? ""
                        }
                    }
                }
                
                
                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                
                self.hideLoading()
                DispatchQueue.main.async {
                    if self.currentPage != 1 {
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        self.refreshControl.endRefreshing()
                    }else {
                        if self.messageList.isEmpty {
                            self.messagesCollectionView.reloadData()
                        }else {
                            self.reloadLastIndexInCollectionView()
                        }
                    }
                }
                
                self.showDownView()
                self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId:  self.chatuserID, isEvent: false)
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

    func getEventChatMessages(pageNumber:Int) {
        let startDate = Date()

        CancelRequest.currentTask = false
        if isRefreshNewMessages == true {
            self.hideLoading()
        }else {
            self.showLoading()
            messageInputBar.isHidden = true
        }

        viewmodel.getChatMessages(ByEventId: eventChatID, pageNumber: pageNumber)
        viewmodel.eventmessages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")

            DispatchQueue.main.async {
                for itm in value.pagedModel?.data ?? [] {
                    if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
                        switch itm.currentuserMessage! {
                        case true:
                            switch itm.messagetype {
                            case 1://text
                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }else {
                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 3: //file
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }else {
                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                
                                //                            messageList.insert(UserMessage(imageURL: URL(string: itm.eventData?.image ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0), at: 0)
                                
                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""),user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                                //                            let executionTimeWithSuccessVC4 = Date().timeIntervalSince(startDate)
                                //                            print("executionTimeWithSuccessVC4 \(executionTimeWithSuccessVC4 * 1000) second")
                                
                            default:
                                break
                            }
                        case false:
                            switch itm.messagetype {
                            case 1://text
                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                            case 2: //image
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""), user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                            default:
                                break
                            }
                            self.receiveimg = itm.userimage ?? ""
                            self.receiveName = itm.username ?? ""
                        }
                    }
                }
                
                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")

                self.hideLoading()
                DispatchQueue.main.async {
                    if self.currentPage != 1 {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        self.refreshControl.endRefreshing()
                    }else {
                        if self.messageList.isEmpty {
                            self.messagesCollectionView.reloadData()
                        }else {
                            self.messagesCollectionView.reloadData()
                            self.reloadLastIndexInCollectionView()
                        }
                    }
                }
                
                    self.showDownView()
                self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId: self.eventChatID, isEvent: true)
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
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
    
    func getGroupChatMessages(pageNumber:Int) {
        let startDate = Date()
        
        CancelRequest.currentTask = false
        if isRefreshNewMessages == true {
            self.hideLoading()
        }else {
            self.showLoading()
            messageInputBar.isHidden = true
        }
        
        viewmodel.getChatMessages(BygroupId: groupId, pageNumber: pageNumber)
        viewmodel.groupmessages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
            
            DispatchQueue.main.async {
                for itm in value.pagedModel?.data ?? [] {
                    if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
                        switch itm.currentuserMessage! {
                        case true:
                            switch itm.messagetype {
                            case 1://text
                                messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }else {
                                    messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }else {
                                    messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""),user: UserSender(senderId: senderUser.senderId, photoURL: Defaults.Image, displayName: senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                            default:
                                break
                            }
                        case false:
                            switch itm.messagetype {
                            case 1://text
                                messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                            case 2: //image
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 3: //file
                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
                                    messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
                                }
                            case 4://link
                                let url = URL(string: itm.eventData?.image ?? "")
                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
                                
                                messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""), user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
                            default:
                                break
                            }
                            receiveimg = itm.userimage ?? ""
                            receiveName = itm.username ?? ""
                            
                        }
                    }
                }
                
                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                self.hideLoading()
                
                DispatchQueue.main.async {
                    if self.currentPage != 1 {
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                        self.refreshControl.endRefreshing()
                    }else {
                        if messageList.isEmpty {
                            messagesCollectionView.reloadData()
                        }else {
                            reloadLastIndexInCollectionView()
                        }
                    }
                }
                
                showDownView()
                updateTitleView(image: titleChatImage, subtitle: titleChatName, titleId: groupId, isEvent: false)
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
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
}
