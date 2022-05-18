//
//  MessagesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/05/2022.
//

import UIKit
import MessageKit
import SwiftUI

class MessagesVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var actionButtons: [UIButton]!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageInputBarView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    
    var bottomInset: CGFloat {
        return view.safeAreaInsets.bottom + 50
    }
    
    lazy var messageList: [ChatMessage] = []
    
    var isRefreshNewMessages:Bool = false
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    var viewmodel:ChatViewModel = ChatViewModel()
    
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
    
    let formatterTime2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    let imagePicker = UIImagePickerController()
    var attachedImg = false
    var eventType:String = ""
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMessages()
    }
    
    func setupViews() {
        expandButton.cornerRadiusView()
        sendBtn.cornerRadiusView()
        tableView.refreshControl = refreshControl
    }
    
    //MARK: - Setup Messages
    func setupMessages() {
        if isEvent {
            //            self.getEventChatMessages(pageNumber: 1)
        }
        else {
            if isChatGroup {
                //                self.getGroupChatMessages(pageNumber: 1)
            }else {
                self.getUserChatMessages(pageNumber: 1)
            }
        }
    }
    
    //MARK: - Load More Messages
    @objc func loadMoreMessages() {
        isRefreshNewMessages = true
        
        self.currentPage += 1
        print("current page == \(self.currentPage)")
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            if self.isEvent {
                //                self.getEventChatMessages(pageNumber: self.currentPage)
            }
            else {
                if self.isChatGroup {
                    //                    self.getGroupChatMessages(pageNumber: self.currentPage)
                }else {
                    self.getUserChatMessages(pageNumber: self.currentPage)
                }
            }
            
        }
    }
    
    func insertMessage(_ message: ChatMessage) {
        messageList.append(message)
        tableView.insertSections([messageList.count - 1], with: .bottom)
        tableView.reloadData()
    }
}

//MARK: IBActions
extension MessagesVC {
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let messageTime2 = formatterTime2.string(from: Date())

        guard let text = inputTextField.text, !text.isEmpty else { return }
        let url:URL? = URL(string: "https://www.apple.com/eg/")

        self.insertMessage(ChatMessage(sender: SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName), messageId: "", messageType: 1, messageText: MessageText(text: inputTextField.text ?? ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: messageDate, messageTime: messageTime2))
        
        viewmodel.SendMessage(withUserId: chatuserID, AndMessage: text, AndMessageType: 1, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),fileUrl: url!,eventShareid: "") { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard data != nil else {
                return
            }
        }        
    }
    
    @IBAction func expandItemsPressed(_ sender: UIButton) {
    }
}


//MARK: UITableView Delegate & DataSource
extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = messageList[indexPath.section]
        if model.messageType == 1 { //text
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "MessageTableViewCell" : "UserMessageTableViewCell") as! MessageTableViewCell
            cell.messageTextView?.text = model.messageText.text
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.messageDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            return cell
        }
        else if model.messageType == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
            cell.attachmentImageView.sd_setImage(with: URL(string: model.messageImage.image), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.attachmentDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView.isDragging else { return }
        cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform.identity
        })
    }
}

//MARK: UItextField Delegate
extension MessagesVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

//MARK: MessageTableViewCellDelegate Delegate
extension MessagesVC: MessageTableViewCellDelegate {
    func messageTableViewCellUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}


extension MessagesVC {
    //    getEventChatMessages
    //    func getEventChatMessages(pageNumber:Int) {
    //        let startDate = Date()
    //
    //        CancelRequest.currentTask = false
    //        if isRefreshNewMessages == true {
    //            self.hideLoading()
    //        }else {
    //            self.showLoading()
    //            messageInputBarView.isHidden = true
    //        }
    //
    //        viewmodel.getChatMessages(ByEventId: eventChatID, pageNumber: pageNumber)
    //        viewmodel.eventmessages.bind { [unowned self] value in
    //            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
    //            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
    //
    //            DispatchQueue.main.async {
    //                for itm in value.pagedModel?.data ?? [] {
    //                    if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
    //                        switch itm.currentuserMessage! {
    //                        case true:
    //                            switch itm.messagetype {
    //                            case 1://text
    //                                self.messageList.insert(UserMessage(text: , user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                            case 2://image
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }else {
    //                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 3: //file
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }else {
    //                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 4://link
    //                                let url = URL(string: itm.eventData?.image ?? "")
    //                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //
    //                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""),user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
    //                            default:
    //                                break
    //                            }
    //                        case false:
    //                            switch itm.messagetype {
    //                            case 1://text
    //                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                            case 2: //image
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 3://file
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 4://link
    //                                let url = URL(string: itm.eventData?.image ?? "")
    //                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""), user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
    //                            default:
    //                                break
    //                            }
    //                            self.receiveimg = itm.userimage ?? ""
    //                            self.receiveName = itm.username ?? ""
    //                        }
    //                    }
    //                }
    //
    //                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
    //                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
    //
    //                self.hideLoading()
    //                DispatchQueue.main.async {
    //                    if self.currentPage != 1 {
    //                        self.tableView.reloadData()
    //                        //                        self.tableView.reloadDataAndKeepOffset()
    //                        self.refreshControl.endRefreshing()
    //                    }else {
    //                        if self.messageList.isEmpty {
    //                            self.tableView.reloadData()
    //                        }else {
    //                            self.tableView.reloadData()
    //                            //                            self.reloadLastIndexInCollectionView()
    //                        }
    //                    }
    //                }
    //
    //                self.showDownView()
    //                self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId: self.eventChatID, isEvent: true)
    //            }
    //        }
    //
    //        // Set View Model Event Listener
    //        viewmodel.error.bind { [unowned self]error in
    //            DispatchQueue.main.async {
    //                self.hideLoading()
    //                if error == "Internal Server Error" {
    //                    self.HandleInternetConnection()
    //                }else if error == "Bad Request" {
    //                    self.HandleinvalidUrl()
    //                }else {
    //                    DispatchQueue.main.async {
    //                        self.view.makeToast(error)
    //                    }
    //                }
    //            }
    //        }
    //    }
    //
    //    func getGroupChatMessages(pageNumber:Int) {
    //        let startDate = Date()
    //
    //        CancelRequest.currentTask = false
    //        if isRefreshNewMessages == true {
    //            self.hideLoading()
    //        }else {
    //            self.showLoading()
    //            messageInputBarView.isHidden = true
    //        }
    //
    //        viewmodel.getChatMessages(BygroupId: groupId, pageNumber: pageNumber)
    //        viewmodel.groupmessages.bind { [unowned self] value in
    //            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
    //            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
    //
    //            DispatchQueue.main.async {
    //                for itm in value.pagedModel?.data ?? [] {
    //                    if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
    //                        switch itm.currentuserMessage! {
    //                        case true:
    //                            switch itm.messagetype {
    //                            case 1://text
    //                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                            case 2://image
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }else {
    //                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 3://file
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL: URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }else {
    //                                    self.messageList.insert(UserMessage(image: UIImage(named: "placeHolderApp")!, user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 4://link
    //                                let url = URL(string: itm.eventData?.image ?? "")
    //                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""),user: UserSender(senderId: self.senderUser.senderId, photoURL: Defaults.Image, displayName: self.senderUser.displayName), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
    //                            default:
    //                                break
    //                            }
    //                        case false:
    //                            switch itm.messagetype {
    //                            case 1://text
    //                                self.messageList.insert(UserMessage(text: itm.messages ?? "", user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                            case 2: //image
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 3: //file
    //                                if itm.messageAttachedVM?.isEmpty == false || itm.messageAttachedVM?.count != 0 {
    //                                    self.messageList.insert(UserMessage(imageURL:  URL(string: itm.messageAttachedVM?[0].attached ?? "") ?? URL(string: "bit.ly/3ES3blM")!, user:  UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: itm.messagetype ?? 0,linkPreviewID: "",isJoinEvent: 0,eventType: ""), at: 0)
    //                                }
    //                            case 4://link
    //                                let url = URL(string: itm.eventData?.image ?? "")
    //                                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //
    //                                self.messageList.insert(UserMessage(linkItem: MessageLinkItem(title: itm.eventData?.title ?? "", teaser: itm.eventData?.categorie ?? "", thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(itm.eventData?.joined ?? 0) / \(itm.eventData?.totalnumbert ?? 0)",date: itm.eventData?.eventdate ?? ""), user: UserSender(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", date: Date(), dateandtime: self.messageDateTime(date: itm.messagesdate ?? "", time: itm.messagestime ?? ""), messageType: 4,linkPreviewID: itm.eventData?.id ?? "",isJoinEvent: itm.eventData?.key ?? 0, eventType:itm.eventData?.eventtype ?? ""), at: 0)
    //                            default:
    //                                break
    //                            }
    //                            self.receiveimg = itm.userimage ?? ""
    //                            self.receiveName = itm.username ?? ""
    //
    //                        }
    //                    }
    //                }
    //
    //                let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
    //                print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
    //                self.hideLoading()
    //
    //                DispatchQueue.main.async {
    //                    if self.currentPage != 1 {
    //                        self.tableView.reloadData()
    //                        //                        self.tableView.reloadDataAndKeepOffset()
    //                        self.refreshControl.endRefreshing()
    //                    }else {
    //                        if self.messageList.isEmpty {
    //                            self.tableView.reloadData()
    //                        }else {
    //                            self.tableView.reloadData()
    //                            //                            self.reloadLastIndexInCollectionView()
    //                        }
    //                    }
    //                }
    //
    //                self.showDownView()
    //                self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId: self.groupId, isEvent: false)
    //            }
    //        }
    //
    //        // Set View Model Event Listener
    //        viewmodel.error.bind { [unowned self]error in
    //            DispatchQueue.main.async {
    //                self.hideLoading()
    //                if error == "Internal Server Error" {
    //                    self.HandleInternetConnection()
    //                }else if error == "Bad Request" {
    //                    self.HandleinvalidUrl()
    //                }else {
    //                    DispatchQueue.main.async {
    //                        self.view.makeToast(error)
    //                    }
    //
    //                }
    //            }
    //        }
    //    }
    
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
            messageInputBarView.isHidden = true
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
                                self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName), messageId: itm.id ?? "", messageType: 1, messageText: MessageText(text: itm.messages ?? ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    
                                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName), messageId: itm.id ?? "", messageType: 2, messageText: MessageText(text: ""), messageImage: MessageImage(image: itm.messageAttachedVM?[0].attached ?? ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName), messageId: itm.id ?? "", messageType: 3, messageText: MessageText(text: ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: itm.messageAttachedVM?[0].attached ?? ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                                }
                            case 4://link
                                self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName), messageId: itm.id ?? "", messageType: 4, messageText: MessageText(text: ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: itm.eventData?.id ?? "", eventTypeLink: itm.eventData?.eventtype ?? "", isJoinEvent: itm.eventData?.key ?? 0, messsageLinkTitle: itm.eventData?.title ?? "", messsageLinkCategory: itm.eventData?.categorie ?? "", messsageLinkImageURL: itm.eventData?.image ?? "", messsageLinkAttendeesJoined: "\(itm.eventData?.joined ?? 0)", messsageLinkAttendeesTotalnumbert: "\(itm.eventData?.totalnumbert ?? 0)", messsageLinkEventDate: itm.eventData?.eventdate ?? "", linkPreviewID: itm.eventData?.id ?? ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                            default:
                                break
                            }
                        case false:
                            switch itm.messagetype {
                            case 1://text
                                self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", messageType: 1, messageText: MessageText(text: itm.messages ?? ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                            case 2://image
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    
                                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", messageType: 2, messageText: MessageText(text: ""), messageImage: MessageImage(image: itm.messageAttachedVM?[0].attached ?? ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                                }
                            case 3://file
                                if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", messageType: 3, messageText: MessageText(text: ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: itm.messageAttachedVM?[0].attached ?? ""), messageLink: LinkPreviewEvent(eventID: "", eventTypeLink: "", isJoinEvent: 0, messsageLinkTitle: "", messsageLinkCategory: "", messsageLinkImageURL: "", messsageLinkAttendeesJoined: "", messsageLinkAttendeesTotalnumbert: "", messsageLinkEventDate: "", linkPreviewID: ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
                                }
                            case 4://link
                                
                                self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? ""), messageId: itm.id ?? "", messageType: 4, messageText: MessageText(text: ""), messageImage: MessageImage(image: ""), messageFile: MessageFile(file: ""), messageLink: LinkPreviewEvent(eventID: itm.eventData?.id ?? "", eventTypeLink: itm.eventData?.eventtype ?? "", isJoinEvent: itm.eventData?.key ?? 0, messsageLinkTitle: itm.eventData?.title ?? "", messsageLinkCategory: itm.eventData?.categorie ?? "", messsageLinkImageURL: itm.eventData?.image ?? "", messsageLinkAttendeesJoined: "\(itm.eventData?.joined ?? 0)", messsageLinkAttendeesTotalnumbert: "\(itm.eventData?.totalnumbert ?? 0)", messsageLinkEventDate: itm.eventData?.eventdate ?? "", linkPreviewID: itm.eventData?.id ?? ""), date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? ""), at: 0)
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
                        self.tableView.reloadData()
                        //                        self.tableView.reloadDataAndKeepOffset()
                        self.refreshControl.endRefreshing()
                    }else {
                        if self.messageList.isEmpty {
                            self.tableView.reloadData()
                        }else {
                            self.tableView.reloadData()
                            //                            self.reloadLastIndexInCollectionView()
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
    
    //Show Down View
    func showDownView() {
        if isEvent {
            if leavevent == 0 {
                messageInputBarView.isHidden = false
                initOptionsInChatEventButton()
            }
            else if leavevent == 1 {
                setupDownView(textLbl: "You have left this event".localizedString)
            }
            else {
                setupDownView(textLbl: "You have left this chat event".localizedString)
            }
        }
        else {
            if isChatGroup == true {
                if leaveGroup == 0 {
                    messageInputBarView.isHidden = false
                    initOptionsInChatEventButton()
                }
                else {
                    setupDownView(textLbl: "You are not subscribed to this group".localizedString)
                }
            }
            else {
                if isFriend == true {
                    messageInputBarView.isHidden = false
                    initOptionsInChatUserButton()
                }
                else {
                    setupDownView(textLbl: "You are no longer connected to this Friendzr. \nReconnect to message them".localizedString)
                }
            }
        }
    }
    
    func setupDownView(textLbl:String) {
        messageInputBarView.isHidden = true
        downView.isHidden = false
        statusLbl.text = textLbl
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
    
}

//MARK: custom Message Date Time
extension MessagesVC {
    func messageDateTime(date:String,time:String) -> String {
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
    
    func messageDateTimeNow(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.dateStyle = .full
        let dateStr = "\(date)T\(time):00+0000"
        let date = formatter.date(from: dateStr)
        
        let relativeFormatter = buildFormatter(locale: formatter.locale, hasRelativeDate: true)
        let relativeDateString = dateFormatterToString(relativeFormatter, date ?? Date())
        // "Jan 18, 2018"
        
        let nonRelativeFormatter = buildFormatter(locale: formatter.locale)
        let normalDateString = dateFormatterToString(nonRelativeFormatter, date ?? Date())
        // "Jan 18, 2018"
        
        let customFormatter = buildFormatter(locale: formatter.locale, dateFormat: "DD MMMM")
        let customDateString = dateFormatterToString(customFormatter, date ?? Date())
        // "18 January"
        
        if relativeDateString == normalDateString {
            print("Use custom date \(customDateString)") // Jan 18
            return  customDateString
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

//MARK: - updateTitleView
extension MessagesVC {
    func updateTitleView(image: String, subtitle: String?,titleId:String,isEvent:Bool) {
        
        let imageUser = UIImageView(frame: CGRect(x: 0, y: 2, width: 30, height: 30))
        imageUser.backgroundColor = UIColor.clear
        imageUser.image = UIImage(named: image)
        imageUser.contentMode = .scaleAspectFill
        imageUser.cornerRadiusForHeight()
        imageUser.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeHolderApp"))
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 34, width: 0, height: 0))
        subtitleLabel.textColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 8)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 45))
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
        
        let btn = UIButton(frame: titleView.frame)
        if isEvent == true {
            btn.addTarget(self, action: #selector(goToEventDetailsVC), for: .touchUpInside)
        }
        else {
            if isChatGroup {
                if self.leaveGroup == 0 {
                    btn.addTarget(self, action: #selector(goToGroupVC), for: .touchUpInside)
                }
            }else {
                btn.addTarget(self, action: #selector(goToUserProfileVC), for: .touchUpInside)
            }
        }
        
        titleView.addSubview(btn)
        
        navigationItem.titleView = titleView
    }
    
    @objc func goToGroupVC() {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? GroupDetailsVC {
            vc.groupId = self.groupId
            vc.isGroupAdmin = self.isChatGroupAdmin
            vc.selectedVC = true
            self.present(controller, animated: true)
        }
    }
    
    @objc func goToUserProfileVC() {
        if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? FriendProfileViewController {
            vc.userID = self.chatuserID
            vc.selectedVC = true
            self.present(controller, animated: true)
        }
    }
    
    @objc func goToEventDetailsVC() {
        if self.eventType == "External" {
            if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                vc.eventId = self.eventChatID
                vc.isEventAdmin = self.isEventAdmin
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }else {
            if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                vc.eventId = self.eventChatID
                vc.isEventAdmin = self.isEventAdmin
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }
    }
}


//MARK: - Navigation Buttons
extension MessagesVC {
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
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Unfriend".localizedString, style: .default, handler: { action in
            self.unFriendAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: "Block".localizedString, style: .default, handler: { action in
            self.blockFriendAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
            if self.isEvent == true {
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventChatID
                    vc.chatimg = self.titleChatImage
                    vc.chatname = self.titleChatName
                    vc.reportType = 2
                    vc.selectedVC = "Present"
                    self.present(controller, animated: true)
                }
            }else {
                if self.isChatGroup == true {
                    if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                        vc.id = self.groupId
                        vc.chatimg = self.titleChatImage
                        vc.chatname = self.titleChatName
                        vc.reportType = 1
                        vc.selectedVC = "Present"
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                        vc.id = self.chatuserID
                        vc.chatimg = self.titleChatImage
                        vc.chatname = self.titleChatName
                        vc.reportType = 3
                        vc.selectedVC = "Present"
                        self.present(controller, animated: true)
                    }
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func handleEventOptionsBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
            if self.isEvent == true {
                if self.eventType == "External" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                        vc.eventId = self.eventChatID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                        vc.eventId = self.eventChatID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }
            }else {
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? GroupDetailsVC {
                    vc.groupId = self.groupId
                    vc.isGroupAdmin = self.isChatGroupAdmin
                    vc.selectedVC = true
                    self.present(controller, animated: true)
                }
                
            }
        }))
        if self.isEvent {
            if !self.isEventAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                            vc.id = self.eventChatID
                            vc.chatimg = self.titleChatImage
                            vc.chatname = self.titleChatName
                            vc.reportType = 2
                            vc.selectedVC = "Present"
                            self.present(controller, animated: true)
                        }
                    }else {
                        if self.isChatGroup == true {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.groupId
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 1
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }else {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.chatuserID
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 3
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }
                    }
                }))
            }
        }else {
            if !self.isChatGroupAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                            vc.id = self.eventChatID
                            vc.chatimg = self.titleChatImage
                            vc.chatname = self.titleChatName
                            vc.reportType = 2
                            vc.selectedVC = "Present"
                            self.present(controller, animated: true)
                        }
                    }else {
                        if self.isChatGroup == true {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.groupId
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 1
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }else {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.chatuserID
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 3
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }
                    }
                }))
            }
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        present(actionSheet, animated: true, completion: nil)
        
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
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 5,requestdate: "\(actionDate) \(actionTime)") { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
                print(message)
                
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
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 3,requestdate: "\(actionDate) \(actionTime)") { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = message else {return}
                
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

//MARK: - listen To Messages
extension MessagesVC {
    //    @objc func listenToMessages() {
    //        if NotificationMessage.actionCode == chatuserID {
    //            if NotificationMessage.messageType == 1 {
    //                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0,eventType:""))
    //            }
    //            else if NotificationMessage.messageType == 2 {
    //                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 3 {
    //                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType:""))
    //            }
    //            else if NotificationMessage.messageType == 4 {
    //                let url = URL(string: NotificationMessage.messsageLinkImageURL)
    //                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
    //            }
    //        }
    //        else {
    //            print("This is not a User")
    //        }
    //        DispatchQueue.main.async {
    //            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
    //        }
    //    }
    //
    //    @objc func listenToMessagesForEvent() {
    //        if NotificationMessage.actionCode == eventChatID {
    //            if NotificationMessage.messageType == 1 {
    //                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 2 {
    //                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 3 {
    //                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 4 {
    //                let url = URL(string: NotificationMessage.messsageLinkImageURL)
    //                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
    //            }
    //        }
    //        else {
    //            print("This is not a Event")
    //        }
    //        DispatchQueue.main.async {
    //            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
    //        }
    //    }
    //
    //    @objc func listenToMessagesForGroup() {
    //        if NotificationMessage.actionCode == groupId {
    //            if NotificationMessage.messageType == 1 {
    //                self.insertMessage(UserMessage(text: NotificationMessage.messageText, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 1, linkPreviewID: "", isJoinEvent: 0,eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 2 {
    //                self.insertMessage(UserMessage(imageURL: URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 2, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //            else if NotificationMessage.messageType == 3 {
    //                self.insertMessage(UserMessage(imageURL:  URL(string: NotificationMessage.messsageImageURL) ?? URL(string: "bit.ly/3ES3blM")!, user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 3, linkPreviewID: "", isJoinEvent: 0, eventType: ""))
    //            }
    //
    //            else if NotificationMessage.messageType == 4 {
    //                let url = URL(string: NotificationMessage.messsageLinkImageURL)
    //                let data = try? Data(contentsOf: (url ?? URL(string: "bit.ly/3sbXHy5"))!)
    //                self.insertMessage(UserMessage(linkItem: MessageLinkItem(title: NotificationMessage.messsageLinkTitle, teaser: NotificationMessage.messsageLinkCategory, thumbnailImage: ((UIImage(data: data ?? Data())) ??  UIImage(named: "placeHolderApp"))!,people: "Attendees: \(NotificationMessage.messsageLinkAttendeesJoined) / \(NotificationMessage.messsageLinkAttendeesTotalnumbert)",date: NotificationMessage.messsageLinkEventDate),user: UserSender(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName), messageId: NotificationMessage.messageId, date: Date(), dateandtime: messageDateTime(date: NotificationMessage.messageDate, time: NotificationMessage.messageTime), messageType: 4,linkPreviewID: NotificationMessage.linkPreviewID,isJoinEvent: NotificationMessage.isJoinEvent, eventType:NotificationMessage.eventTypeLink))
    //            }
    //        }else {
    //            print("This is not a Group")
    //        }
    //
    //
    //        DispatchQueue.main.async {
    //            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
    //        }
    //    }
}
