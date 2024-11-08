//
//  MessagesVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/05/2022.
//

import UIKit
import MapKit
import AVFoundation
import MobileCoreServices
import AVKit
import ListPlaceholder
import SwiftUI
import SDWebImage
import ImageSlideshow
import Photos
import ListPlaceholder
import MapKit

extension MessagesVC {
    func checkTime(timeDate1:String,timeDate2:String) -> Bool {
        
//        let dateFormatter: DateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
//        let startingSlot = "2000-01-01 08:00:00" //UTC
//        let endingSlot = "2000-01-01 23:00:00" //UTC
        
        let date = Date()
        
        let date1: Date = formatter.date(from: timeDate1) ?? Date()
        let date2: Date = formatter.date(from: timeDate2) ?? Date()
        
        let currentTime = 60*Calendar.current.component(.hour, from: date) + Calendar.current.component(.minute, from: date) + (Calendar.current.component(.second, from: date)/60) // in minutes
        let time1 = 60*Calendar.current.component(.hour, from: date1) + Calendar.current.component(.minute, from: date1) + (Calendar.current.component(.second, from: date1)/60) // in minutes
        let time2 =  60*Calendar.current.component(.hour, from: date2) + Calendar.current.component(.minute, from: date2) + (Calendar.current.component(.second, from: date2)/60) // in minutes
        
        print(currentTime)
        print(time1)
        print(time2)
        
        
        if time1 >= time2 {
            return true
        }else {
            return false
        }
        
//        if(currentTime >= time1 && currentTime <= time2) {
//            return true
//        } else {
//            return false
//        }
    }
}

class MessagesVC: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var barBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageInputBarView: UIView!
    @IBOutlet weak var txtFieldContainerView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var imgsView: [UIImageView]!
    
    
    let currentSender = SenderMessage(senderId: Defaults.token, photoURL: Defaults.Image, displayName: Defaults.userName, isWhitelabel: Defaults.isWhiteLable)
    
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
    var liveLocationVM:LocationViewModel = LocationViewModel()
    
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
    
    var isCommunityGroup:Bool = false
    var fileUpload = ""
    var isUserWhiteLabel:Bool = false
    var timeNowSwting:String = ""
    
    var messageTableViewViewBottomInset: CGFloat = 0 {
        didSet {
            tableView.contentInset.bottom = messageTableViewViewBottomInset
            //            tableView.scrollIndicatorInsets.bottom = messageTableViewViewBottomInset
        }
    }
    
    var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            messageTableViewViewBottomInset += delta
        }
    }
    
    var maintainPositionOnKeyboardFrameChanged: Bool = false
    var isMessagesControllerBeingDismissed: Bool = false
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.locale = .current
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
    
    let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let formatterUnfriendDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    let formatterTime2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
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
        initBackButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSetupMessages), name: Notification.Name("handleSetupMessages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessages), name: Notification.Name("listenToMessages"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForEvent), name: Notification.Name("listenToMessagesForEvent"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(listenToMessagesForGroup), name: Notification.Name("listenToMessagesForGroup"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavBar), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidChangeState(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
        
        //        let tapInTextField =  UITapGestureRecognizer(target: self, action: #selector(self.handleTouched(_:)))
        //        inputTextField.addGestureRecognizer(tapInTextField)
        
        Defaults.availableVC = "MessagesVC"
        print("availableVC >> \(Defaults.availableVC)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationbar()
        setupMessages()
        setScrollTableViewWithKeyboard()
        
        if isEvent {
            Defaults.ConversationID = eventChatID
            Defaults.ConversationType = "Event"
        }else if isChatGroup {
            Defaults.ConversationID = groupId
            Defaults.ConversationType = "Group"
        }else {
            Defaults.ConversationID = chatuserID
            Defaults.ConversationType = "User"
        }
        
        hideNavigationBar(NavigationBar: false, BackButton: false)
        self.tabBarController?.tabBar.isHidden = true
        //        NotificationCenter.default.post(name: Notification.Name("updateNavBar"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        self.tabBarController?.tabBar.isHidden = false
        Defaults.ConversationType = ""
    }
    
    func setupViews() {
        expandButton.cornerRadiusView()
        sendBtn.cornerRadiusView()
        tableView.refreshControl = refreshControl
        inputTextField.delegate = self
        
        for item in imgsView {
            item.cornerRadiusView(radius: 10)
        }
        
        txtFieldContainerView.cornerRadiusView(radius: 25)
    }
    
    //MARK: - Setup Messages
    func setupImageShow(_ cell: MessageAttachmentTableViewCell, _ model: MessageImage) {
        //        cell.imagesSlider.slideshowInterval = 5.0
        cell.imagesSlider.pageIndicatorPosition = .init(horizontal: .center, vertical: .top)
        cell.imagesSlider.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        cell.imagesSlider.activityIndicator = DefaultActivityIndicator()
        cell.imagesSlider.delegate = self
        if model.image == "" {
            cell.imagesSlider.setImageInputs([ImageSource(image: model.imageView)])
        }else {
            cell.imagesSlider.setImageInputs([SDWebImageSource(urlString: model.image) ?? SDWebImageSource(urlString: placeholderString)!])
        }
    }
    
    func setupFileShow(_ cell: MessageAttachmentTableViewCell, _ model: MessageFile) {
        //        cell.imagesSlider.slideshowInterval = 5.0
        cell.imagesSlider.pageIndicatorPosition = .init(horizontal: .center, vertical: .top)
        cell.imagesSlider.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        cell.imagesSlider.activityIndicator = DefaultActivityIndicator()
        cell.imagesSlider.delegate = self
        if model.file == "" {
            cell.imagesSlider.setImageInputs([ImageSource(image: model.fileView)])
        }else {
            cell.imagesSlider.setImageInputs([SDWebImageSource(urlString: model.file) ?? SDWebImageSource(urlString: placeholderString)!])
        }
    }
    
    func substring(string: String, fromIndex: Int, toIndex: Int) -> String? {
        if fromIndex < toIndex && toIndex < string.count /*use string.characters.count for swift3*/{
            let startIndex = string.index(string.startIndex, offsetBy: fromIndex)
            let endIndex = string.index(string.startIndex, offsetBy: toIndex)
            return String(string[startIndex..<endIndex])
        }else{
            return nil
        }
    }
    
    func setupMessages() {
        
        timeNowSwting = formatter.string(from: Date())
        
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
    
    
    @objc func handleSetupMessages() {
        if Defaults.ConversationType == "Event" {
            self.getEventChatMessages(pageNumber: 1)
        }else if Defaults.ConversationType == "Group" {
            self.getGroupChatMessages(pageNumber: 1)
        }else {
            self.getUserChatMessages(pageNumber: 1)
        }
    }
    
    
    func onLocationShareCallBack(_ lat: String, _ lng: String,_ locationTitle:String,_ isLiveLocation: Bool,_ captionTxt:String,_ locationPeriod:String,_ startTime:String,_ endTime:String) -> () {
        print("lat: \(lat), lng: \(lng) ,title: \(locationTitle),isLiveLocation: \(isLiveLocation),captionTxt: \(captionTxt),locationPeriod: \(locationPeriod),startTime: \(startTime),endTime: \(endTime)")
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let messageTime2 = formatterTime2.string(from: Date())
        
        var locName = ""
        var locPeriodStr = ""
        
        if locationPeriod == "" {
            locPeriodStr = "15 Minutes"
        }else {
            locPeriodStr = locationPeriod
        }
        
        if isLiveLocation {
            locName = ""
        } else {
            locName = locationTitle
        }
        
        shareLocationWith(messageDate, messageTime2, lat, lng, locName , messageTime, isLiveLocation, captionTxt, locPeriodStr, startTime, endTime)
    }
    
    func shareLocationWith(_ messageDate: String, _ messageTime2: String, _ lat: String, _ lng: String, _ locationTitle: String, _ messageTime: String,_ isLiveLocation: Bool,_ captionTxt:String,_ locationPeriod:String,_ startTime:String,_ endTime:String) {
        
//        self.insertMessage(ChatMessage(sender: self.currentSender, messageId: "", messageType: 5, date: Date(), messageDate: messageDate, messageTime: messageTime2,messageLoc: MessageLocation(lat: lat, lng: lng, locationName: locationTitle,captionTxt:captionTxt,isLiveLocation: isLiveLocation,locationPeriod: locationPeriod,locationStartTime: startTime,locationEndTime: endTime)))
        
        if isEvent {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 5, AndMessage: captionTxt, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), eventShareid: "",latitude: lat,longitude: lng, locationName: locationTitle,isLiveLocation: isLiveLocation,locationStartTime: startTime,locationEndTime: endTime,locationPeriod: locationPeriod) { error, data in
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {
                    return
                }
                
                self.insertMessage(ChatMessage(sender: self.currentSender, messageId: data?.id ?? "", messageType: 5, date: Date(), messageDate: messageDate, messageTime: messageTime2,messageLoc: MessageLocation(lat: lat, lng: lng, locationName: locationTitle,captionTxt:captionTxt,isLiveLocation: isLiveLocation,locationPeriod: locationPeriod,locationStartTime: startTime,locationEndTime: endTime)))
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                }
            }
        }
        else {
            if isChatGroup {
                viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 5, AndMessage: captionTxt, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),eventShareid: "",latitude: lat,longitude: lng, locationName: locationTitle,isLiveLocation: isLiveLocation,locationStartTime: startTime,locationEndTime: endTime,locationPeriod: locationPeriod) { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {
                        return
                    }
                    
                    self.insertMessage(ChatMessage(sender: self.currentSender, messageId: data?.id ?? "", messageType: 5, date: Date(), messageDate: messageDate, messageTime: messageTime2,messageLoc: MessageLocation(lat: lat, lng: lng, locationName: locationTitle,captionTxt:captionTxt,isLiveLocation: isLiveLocation,locationPeriod: locationPeriod,locationStartTime: startTime,locationEndTime: endTime)))
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
            else {
                viewmodel.SendMessage(withUserId: chatuserID, AndMessage: captionTxt, AndMessageType: 5, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),eventShareid: "",latitude: lat,longitude: lng, locationName: locationTitle,isLiveLocation: isLiveLocation,locationStartTime: startTime,locationEndTime: endTime,locationPeriod: locationPeriod) { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard data != nil else {
                        return
                    }
                    
                    
                    self.insertMessage(ChatMessage(sender: self.currentSender, messageId: data?.id ?? "", messageType: 5, date: Date(), messageDate: messageDate, messageTime: messageTime2,messageLoc: MessageLocation(lat: lat, lng: lng, locationName: locationTitle,captionTxt:captionTxt,isLiveLocation: isLiveLocation,locationPeriod: locationPeriod,locationStartTime: startTime,locationEndTime: endTime)))

//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                        self.tableView.scroll(to: .bottom, animated: true)
//                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
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
    
    func insertMessage(_ message: ChatMessage) {
        messageList.append(message)
        
        self.tableView.scroll(to: .bottom, animated: true)
        self.reloadLastIndexInTableView()
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: messageList.count - 1, section: 0)
        let visibleRows = tableView.indexPathsForVisibleRows?.contains(lastIndexPath)
        return visibleRows ?? false
    }
    
    func reloadLastIndexInTableView() {
        let differenceOfBottomInset = tableView.contentInset.bottom //tableView.scrollIndicatorInsets.bottom
        
        let contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + differenceOfBottomInset)
        // Changing contentOffset to bigger number than the contentSize will result in a jump of content
        guard contentOffset.y <= tableView.contentSize.height else {
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }
        
        DispatchQueue.main.async {
            
            self.tableView.setContentOffset(contentOffset, animated: false)
            // Make the last row visible
            self.tableView.scroll(to: .bottom, animated: true)
        }
        
        //        DispatchQueue.main.async {
        //            self.tableView.reloadDataAndKeepOffset()
        //        }
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
    
    @objc func updateNavBar() {
        setupNavigationbar()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
        }
    }
}

//MARK: IBActions
extension MessagesVC {
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let messageTime2 = formatterTime2.string(from: Date())
        
        guard let text = inputTextField.text, !text.isEmpty else { return }
        
        self.insertMessage(ChatMessage(sender: self.currentSender, messageId: "", messageType: 1, date: Date(), messageDate: messageDate, messageTime: messageTime2,messageText: MessageText(text: inputTextField.text ?? "")))
        
        inputTextField.text = ""
        
        if isEvent {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),eventShareid: "") { error, data in
                
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
                    self.tableView.reloadData()
                    self.tableView.scroll(to: .bottom, animated: true)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                }
            }
        }
        else {
            if isChatGroup {
                viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),eventShareid: "") { error, data in
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
                        self.tableView.reloadData()
                        self.tableView.scroll(to: .bottom, animated: true)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
            else {
                viewmodel.SendMessage(withUserId: chatuserID, AndMessage: text, AndMessageType: 1, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),eventShareid: "") { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard data != nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.scroll(to: .bottom, animated: true)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func expandItemsPressed(_ sender: UIButton) {
        presentInputActionSheet()
    }
    
    private func presentInputActionSheet() {
        let actionSheet  = UIAlertController(title: "Attach Media".localizedString, message: "What would you like attach?".localizedString, preferredStyle: .actionSheet)
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
            self.openCamera()
        }
        
        let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openLibrary()
        }
        
        let fileBtn = UIAlertAction(title: "File", style: .default) {_ in
            self.openFileLibrary()
        }
        
        let locationBtn = UIAlertAction(title: "Location", style: .default) {_ in
            self.openShareLocationVC()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        //        fileBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        locationBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(libraryBtn)
        //        actionSheet.addAction(fileBtn)
//        actionSheet.addAction(locationBtn)
        actionSheet.addAction(cancelBtn)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    //    func presentImagePickerSheet() {
    //        let presentImagePickerController: (UIImagePickerController.SourceType) -> () = { source in
    //            let controller = UIImagePickerController()
    //            controller.delegate = self
    //            var sourceType = source
    //            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
    //                sourceType = .photoLibrary
    //                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
    //            }
    //            controller.sourceType = sourceType
    //            self.present(controller, animated: true, completion: nil)
    //        }
    //
    //        let controller = MSImagePickerSheetController(mediaType: .Image)
    //        controller.maximumSelection = 3
    //        controller.delegate = self
    //
    //        controller.addAction(action: ImagePickerAction(title: NSLocalizedString("Camera", comment: "Camera"), secondaryTitle: NSLocalizedString("Camera", comment: "Camera"), handler: { _ in
    //            presentImagePickerController(.camera)
    //        }, secondaryHandler: { _, numberOfPhotos in
    //            print("Comment \(numberOfPhotos) photos")
    //            presentImagePickerController(.camera)
    //        }))
    //
    //        controller.addAction(action: ImagePickerAction(title: "Photo Library", secondaryTitle: "Send \(controller.selectedImageAssets.count)", style: .Default, handler: { _ in
    //            presentImagePickerController(.photoLibrary)
    //        }, secondaryHandler: { _, numberOfPhotos in
    //            print("Send \(numberOfPhotos)")
    //        }))
    //
    //        if UIDevice.current.userInterfaceIdiom == .pad {
    //            controller.modalPresentationStyle = .popover
    //            controller.popoverPresentationController?.sourceView = view
    //            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
    //        }
    //
    //        present(controller, animated: true, completion: nil)
    //    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func openShareLocationVC() {
        if let controller = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "ShareLocationNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareLocationVC {
            vc.onLocationCallBackResponse = self.onLocationShareCallBack
            self.present(controller, animated: true)
        }
    }
}

// MARK: - ImagePickerSheetControllerDelegate
//extension MessagesVC :ImagePickerSheetControllerDelegate {
//
//    func controllerWillEnlargePreview(_ controller: MSImagePickerSheetController) {
//        print("Will enlarge the preview")
//    }
//
//    func controllerDidEnlargePreview(_ controller: MSImagePickerSheetController) {
//        print("Did enlarge the preview")
//    }
//
//    func controller(_ controller: MSImagePickerSheetController, willSelectAsset asset: PHAsset) {
//        print("Will select an asset")
//    }
//
//    func controller(_ controller: MSImagePickerSheetController, didSelectAsset asset: PHAsset) {
//        print("Did select an asset = \(controller.selectedImageAssets.count)")
//    }
//
//    func controller(_ controller: MSImagePickerSheetController, willDeselectAsset asset: PHAsset) {
//        print("Will deselect an asset")
//    }
//
//    func controller(_ controller: MSImagePickerSheetController, didDeselectAsset asset: PHAsset) {
//        print("Did deselect an asset")
//    }
//}

//MARK: UITableView Delegate & DataSource
extension MessagesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = messageList[indexPath.row]
        if model.messageType == 1 { //text
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "MessageTableViewCell" : "UserMessageTableViewCell") as! MessageTableViewCell
            cell.messageTextView?.text = model.messageText.text
            
            cell.profilePic?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            cell.messageDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            
            
            
            cell.HandleUserProfileBtn = {
                if !model.sender.isWhitelabel {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = model.sender.senderId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            return cell
        }
        else if model.messageType == 2 { //image
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
            
            cell.attachmentImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            //            if model.messageImage.image == "" {
            //                cell.attachmentImageView.image = model.messageImage.imageView
            //            }
            //            else {
            //                cell.attachmentImageView.sd_setImage(with: URL(string: model.messageImage.image), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            //            }
            cell.imagesSlider.isHidden = false
            cell.attachmentImageView.isHidden = true
            cell.tapImageBtn.isHidden = true
            setupImageShow(cell, model.messageImage)
            
            cell.parentVC = self
            cell.profilePic?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            
            cell.attachmentDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            
            cell.HandleProfileBtn = {
                if !model.sender.isWhitelabel {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = model.sender.senderId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.attachmentContainerView.setBorder()
            
            cell.HandleTapAttachmentBtn = {
                
            }
            return cell
        }
        else if model.messageType == 3 { //file
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "MessageAttachmentTableViewCell" : "UserMessageAttachmentTableViewCell") as! MessageAttachmentTableViewCell
            
            cell.imagesSlider.isHidden = true
            cell.attachmentImageView.isHidden = false
            cell.tapImageBtn.isHidden = false
            
            if model.messageFile.file == "" {
                cell.attachmentImageView.image = model.messageFile.fileView
            }else {
                cell.attachmentImageView.sd_setImage(with: URL(string: model.messageFile.file), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            }
            
            //            setupFileShow(cell, model.messageFile)
            
            cell.profilePic?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            cell.attachmentDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            cell.attachmentContainerView.backgroundColor = .clear
            cell.attachmentContainerView.setBorder()
            
            cell.HandleProfileBtn = {
                if !model.sender.isWhitelabel {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = model.sender.senderId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.HandleTapAttachmentBtn = {
                if model.messageType == 3 {
                    //downlaod file
                    print("PDF FILE")
                    if model.messageFile.file != "" {
                        let fileUrl = model.messageFile.file
                        DispatchQueue.main.async {
                            UIApplication.shared.open(URL(string: fileUrl)!)
                        }
                    }
                }
            }
            
            return cell
        }
        else if model.messageType == 4 {//share event
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "ShareEventMessageTableViewCell" : "UserShareEventMessageTableViewCell") as! ShareEventMessageTableViewCell
            cell.eventImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.eventImage.sd_setImage(with: URL(string: model.messageLink.messsageLinkImageURL), placeholderImage: UIImage(named: "placeHolderApp"))
            
            cell.profilePic?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            cell.eventNameLbl.text = model.messageLink.messsageLinkTitle
            cell.categoryNameLbl.text = model.messageLink.messsageLinkCategory
            cell.attendeesLbl.text = "Attendees: \(model.messageLink.messsageLinkAttendeesJoined) / \(model.messageLink.messsageLinkAttendeesTotalnumbert)"
            cell.startEventDateLbl.text = model.messageLink.messsageLinkEventDate
            
            cell.HandleUserProfileBtn = {
                if !model.sender.isWhitelabel {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = model.sender.senderId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            cell.HandleTapEventLinkBtn = {
                if !Defaults.isWhiteLable {
                    if model.messageLink.eventTypeLink == "External" {
                        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                        vc.eventId = model.messageLink.linkPreviewID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = false
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                        vc.eventId = model.messageLink.linkPreviewID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = false
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            
            //            cell.delegate = self
            //            cell.delegate?.messageTableViewCellUpdate()
            return cell
        }
        else if model.messageType == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: model.sender.senderId == Defaults.token ? "ShareLocationTableViewCell" : "UserShareLocationTableViewCell") as! ShareLocationTableViewCell
            
            cell.profilePic?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profilePic?.sd_setImage(with: URL(string: model.sender.photoURL), placeholderImage: UIImage(named: "userPlaceHolderImage"))
            
            let lat = Double("\(model.messageLoc.lat )")
            let lng = Double("\(model.messageLoc.lng )")
            
            cell.setupGoogleMap(lat: lat ?? 0.0, lng: lng ?? 0.0)
            
            cell.messageDateLbl.text = self.messageDateTime(date: model.messageDate, time: model.messageTime)
            
            
            let checkTime = checkTime(timeDate1: model.messageLoc.locationEndTime, timeDate2: timeNowSwting)
            print("checkTime ==== \(checkTime)")
            
            
            if model.messageLoc.isLiveLocation == true && checkTime == true {
                if model.sender.senderId == Defaults.token {
                    cell.stopLiveLocBtn.isHidden = false
                }
                else {
                    cell.locNameLbl.text = "Live location"
//                    cell.locNameLbl.textColor = .FriendzrColors.primary
                }
            }
            else {
                if model.messageLoc.locationName != "" {
                    cell.locNameLbl.text = model.messageLoc.locationName
                }else {
                    cell.locNameLbl.text = "Live location ended"
                }
                
                if model.sender.senderId == Defaults.token {
                    cell.stopLiveLocBtn.isHidden = true
                }
            }
            
            cell.HandleStopLiveLocBtn = {
                if !model.sender.isWhitelabel {
                    //stop location live
                    self.liveLocationVM.stopLiveLocation(WithID: model.messageId) { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        cell.stopLiveLocBtn.isHidden = true
                        cell.locNameLbl.text = "Live location ended"
                    }
                }
            }
            
            cell.HandleUserProfileBtn = {
                if !model.sender.isWhitelabel {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = model.sender.senderId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.HandleTapLocationBtn = {
                if !model.sender.isWhitelabel {
                    self.setupDirection(model.messageLoc,model.messageId)
                }
            }
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func goToMapInMobile(_ locLat:String ,_ locLng:String,_ locationName:String) {
        let lat = Double("\(locLat )") ?? 0.0
        let lng = Double("\(locLng )") ?? 0.0
        
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(locLat),\(locLng)&directionsmode=driving")!)
        }
        else {
            let coordinates = CLLocationCoordinate2DMake(lat, lng)
            let source = MKMapItem(coordinate: coordinates, name: "Source")
            let regionDistance:CLLocationDistance = 10000
            let destination = MKMapItem(coordinate: coordinates, name: locationName )
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            MKMapItem.openMaps(
                with: [source, destination],
                launchOptions: options
            )
        }
    }
    
    func setupDirection(_ model:MessageLocation?,_ id:String) {
        
        if model?.isLiveLocation == true && id != "" {
            DispatchQueue.main.async {
                self.liveLocationVM.getLiveLocation(WithID: id)
                self.liveLocationVM.liveLocationDet.bind { [weak self] value in
                    DispatchQueue.main.async {
                        self?.goToMapInMobile(value.latitude ?? "", value.longitude ?? "", value.locationName ?? "")
                    }
                }
                
                // Set View Model Event Listener
                self.liveLocationVM.error.bind { [weak self]error in
                    DispatchQueue.main.async {
                        if error == "Internal Server Error" {
                            self?.HandleInternetConnection()
                        }else if error == "Bad Request" {
                            self?.HandleinvalidUrl()
                        }else {
                            DispatchQueue.main.async {
                                self?.view.makeToast(error)
                            }
                            
                        }
                    }
                }
            }
        }
        else {
            self.goToMapInMobile(model?.lat ?? "", model?.lng ?? "", model?.locationName ?? "")
        }
    }
}

//MARK: UItextField Delegate
extension MessagesVC: UITextFieldDelegate ,UIPopoverPresentationControllerDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        print("handleTouched handleTouched")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("updateNavBar"), object: nil, userInfo: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textField handleTouched")
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
    func updatelivelocationMessage(_ id: String) {
        liveLocationVM.updateLiveLoction(WithID: id) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
        }
    }
    
    func extractedMessages(_ itm: MessageObj) {
        if !(self.messageList.contains(where: { $0.messageId == itm.id})) {
            switch itm.currentuserMessage! {
            case true:
                switch itm.messagetype {
                case 1://text
                    self.messageList.insert(ChatMessage(sender: self.currentSender, messageId: itm.id ?? "", messageType: 1, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageText: MessageText(text: itm.messages ?? "")), at: 0)
                case 2://image
                    if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                        
                        
                        self.messageList.insert(ChatMessage(sender: self.currentSender, messageId: itm.id ?? "", messageType: 2, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageImage: MessageImage(image: itm.messageAttachedVM?[0].attached ?? "")), at: 0)
                    }
                case 3://file
                    if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                        
                        self.messageList.insert(ChatMessage(sender: self.currentSender, messageId: itm.id ?? "", messageType: 3, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageFile: MessageFile(file: itm.messageAttachedVM?[0].attached ?? "")), at: 0)
                    }
                case 4://link
                    self.messageList.insert(ChatMessage(sender: self.currentSender, messageId: itm.id ?? "", messageType: 4, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageLink: LinkPreviewEvent(eventID: itm.eventData?.id ?? "", eventTypeLink: itm.eventData?.eventTypeName ?? "", isJoinEvent: itm.eventData?.key ?? 0, messsageLinkTitle: itm.eventData?.title ?? "", messsageLinkCategory: itm.eventData?.categorie ?? "", messsageLinkImageURL: itm.eventData?.image ?? "", messsageLinkAttendeesJoined: "\(itm.eventData?.joined ?? 0)", messsageLinkAttendeesTotalnumbert: "\(itm.eventData?.totalnumbert ?? 0)", messsageLinkEventDate: itm.eventData?.eventdate ?? "", linkPreviewID: itm.eventData?.id ?? "")), at: 0)
                case 5://location
                    
                    if itm.isLiveLocation == true {
                        self.updatelivelocationMessage(itm.id ?? "")
                    }
                    
                    self.messageList.insert(ChatMessage(sender: self.currentSender, messageId: itm.id ?? "", messageType: 5, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageLoc: MessageLocation(lat: itm.latitude ?? "", lng: itm.longitude ?? "", locationName: itm.locationName ?? "",captionTxt: itm.messages ?? "",isLiveLocation: itm.isLiveLocation,locationPeriod: itm.locationPeriod,locationStartTime: itm.locationStartTime,locationEndTime: itm.locationEndTime)), at: 0)
                default:
                    break
                }
            case false:
                switch itm.messagetype {
                case 1://text
                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? "", isWhitelabel: itm.isWhitelabel), messageId: itm.id ?? "", messageType: 1, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageText: MessageText(text: itm.messages ?? "")), at: 0)
                case 2://image
                    if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                        self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? "", isWhitelabel: itm.isWhitelabel), messageId: itm.id ?? "", messageType: 2, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageImage: MessageImage(image: itm.messageAttachedVM?[0].attached ?? "")), at: 0)
                    }
                case 3://file
                    if itm.messageAttachedVM?.count != 0 || itm.messageAttachedVM?[0].attached != "" {
                        self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? "", isWhitelabel: itm.isWhitelabel), messageId: itm.id ?? "", messageType: 3, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageFile: MessageFile(file: itm.messageAttachedVM?[0].attached ?? "")), at: 0)
                    }
                case 4://link
                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? "", isWhitelabel: itm.isWhitelabel), messageId: itm.id ?? "", messageType: 4, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageLink: LinkPreviewEvent(eventID: itm.eventData?.id ?? "", eventTypeLink: itm.eventData?.eventTypeName ?? "", isJoinEvent: itm.eventData?.key ?? 0, messsageLinkTitle: itm.eventData?.title ?? "", messsageLinkCategory: itm.eventData?.categorie ?? "", messsageLinkImageURL: itm.eventData?.image ?? "", messsageLinkAttendeesJoined: "\(itm.eventData?.joined ?? 0)", messsageLinkAttendeesTotalnumbert: "\(itm.eventData?.totalnumbert ?? 0)", messsageLinkEventDate: itm.eventData?.eventdate ?? "", linkPreviewID: itm.eventData?.id ?? "")), at: 0)
                case 5://location
                    if itm.isLiveLocation == true {
                        self.updatelivelocationMessage(itm.id ?? "")
                    }
                    
                    self.messageList.insert(ChatMessage(sender: SenderMessage(senderId: itm.userId ?? "", photoURL: itm.userimage ?? "", displayName: itm.username ?? "", isWhitelabel: itm.isWhitelabel), messageId: itm.id ?? "", messageType: 5, date: Date(), messageDate: itm.messagesdate ?? "", messageTime: itm.messagestime ?? "",messageLoc: MessageLocation(lat: itm.latitude ?? "", lng: itm.longitude ?? "", locationName: itm.locationName ?? "",captionTxt: itm.messages ?? "",isLiveLocation: itm.isLiveLocation,locationPeriod: itm.locationPeriod,locationStartTime: itm.locationStartTime,locationEndTime: itm.locationEndTime)), at: 0)
                default:
                    break
                }
                
                self.receiveimg = itm.userimage ?? ""
                self.receiveName = itm.username ?? ""
            }
        }
    }
    
    func getEventChatMessages(pageNumber:Int) {
        DispatchQueue.main.async {
            if pageNumber > self.viewmodel.messages.value?.totalPages ?? 1 {
                self.tableView.refreshControl = nil
                self.refreshControl.endRefreshing()
                return
            }
        }
        
        let startDate = Date()
        
        CancelRequest.currentTask = false
        if isRefreshNewMessages == true {
            self.hideView.isHidden = true
        }else {
            self.hideView.isHidden = false
            self.hideView.showLoader()
            messageInputBarView.isHidden = true
        }
        
        viewmodel.getChatMessages(ByEventId: eventChatID, pageNumber: pageNumber)
        viewmodel.eventmessages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
            if Defaults.availableVC == "MessagesVC" {
                DispatchQueue.main.async {
                    for itm in value.pagedModel?.data ?? [] {
                        self.extractedMessages(itm)
                    }
                    
                    let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                    print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                    
                    DispatchQueue.main.async {
                        self.hideView.isHidden = true
                        self.hideView.hideLoader()
                        self.isRefreshNewMessages = true
                    }
                    
                    DispatchQueue.main.async {
                        if self.currentPage != 1 {
                            DispatchQueue.main.async {
                                self.tableView.reloadDataAndKeepOffset()
                            }
                            
                            self.refreshControl.endRefreshing()
                        }else {
                            if self.messageList.isEmpty {
                                self.tableView.reloadData()
                            }else {
                                self.reloadLastIndexInTableView()
                            }
                        }
                    }
                    
                    self.showDownView()
                    self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId: self.eventChatID, isEvent: true)
                }
                
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideView.isHidden = true
                self.hideView.hideLoader()
                
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
        DispatchQueue.main.async {
            if pageNumber > self.viewmodel.messages.value?.totalPages ?? 1 {
                self.tableView.refreshControl = nil
                self.refreshControl.endRefreshing()
                return
            }
        }
        
        let startDate = Date()
        
        CancelRequest.currentTask = false
        if isRefreshNewMessages == true {
            self.hideView.isHidden = true
        }
        else {
            self.hideView.isHidden = false
            self.hideView.showLoader()
            messageInputBarView.isHidden = true
        }
        
        viewmodel.getChatMessages(BygroupId: groupId, pageNumber: pageNumber)
        viewmodel.groupmessages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
            if Defaults.availableVC == "MessagesVC" {
                DispatchQueue.main.async {
                    for itm in value.pagedModel?.data ?? [] {
                        self.extractedMessages(itm)
                    }
                    
                    let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                    print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                    
                    DispatchQueue.main.async {
                        self.hideView.isHidden = true
                        self.hideView.hideLoader()
                        self.isRefreshNewMessages = true
                    }
                    
                    DispatchQueue.main.async {
                        if self.currentPage != 1 {
                            DispatchQueue.main.async {
                                self.tableView.reloadDataAndKeepOffset()
                            }
                            
                            self.refreshControl.endRefreshing()
                        }else {
                            if self.messageList.isEmpty {
                                self.tableView.reloadData()
                            }else {
                                self.reloadLastIndexInTableView()
                            }
                        }
                    }
                    
                    self.showDownView()
                    self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId: self.groupId, isEvent: false)
                }
                
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideView.isHidden = true
                self.hideView.hideLoader()
                
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
    
    func getUserChatMessages(pageNumber:Int) {
        CancelRequest.currentTask = false
        
        DispatchQueue.main.async {
            if pageNumber > self.viewmodel.messages.value?.totalPages ?? 1 {
                self.tableView.refreshControl = nil
                self.refreshControl.endRefreshing()
                return
            }
        }
        
        let startDate = Date()
        
        DispatchQueue.main.async {
            if self.isRefreshNewMessages == true {
                self.hideView.isHidden = true
            }else {
                self.hideView.isHidden = false
                self.hideView.showLoader()
                self.messageInputBarView.isHidden = true
            }
        }
        
        viewmodel.getChatMessages(ByUserId: chatuserID, pageNumber: pageNumber)
        viewmodel.messages.bind { [unowned self] value in
            let executionTimeWithSuccessVC1 = Date().timeIntervalSince(startDate)
            print("executionTimeWithSuccessVC1 \(executionTimeWithSuccessVC1 * 1000) second")
            if Defaults.availableVC == "MessagesVC" {
                DispatchQueue.main.async {
                    for itm in value.data ?? [] {
                        self.extractedMessages(itm)
                    }
                    
                    let executionTimeWithSuccessVC2 = Date().timeIntervalSince(startDate)
                    print("executionTimeWithSuccessVC2 \(executionTimeWithSuccessVC2 * 1000) second")
                    
                    DispatchQueue.main.async {
                        self.hideView.isHidden = true
                        self.hideView.hideLoader()
                        self.isRefreshNewMessages = true
                    }
                    
                    DispatchQueue.main.async {
                        if self.currentPage != 1 {
                            DispatchQueue.main.async {
                                self.tableView.reloadDataAndKeepOffset()
                            }
                            
                            self.refreshControl.endRefreshing()
                        }else {
                            if self.messageList.isEmpty {
                                self.tableView.reloadData()
                            }else {
                                self.tableView.scroll(to: .bottom, animated: true)
                                self.reloadLastIndexInTableView()
                            }
                        }
                    }
                    
                    self.refreshControl.endRefreshing()
                    self.showDownView()
                    self.updateTitleView(image: self.titleChatImage, subtitle: self.titleChatName, titleId:  self.chatuserID, isEvent: false)
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideView.isHidden = true
                self.hideView.hideLoader()
                
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
        downView.setBorder()
        
        if isEvent {
            if leavevent == 0 {
                messageInputBarView.isHidden = false
                if Defaults.isWhiteLable {
                    initOptionsInChatEventWhiteLableButton()
                }else {
                    initOptionsInChatEventButton()
                }
            }
            else if leavevent == 1 {
                setupDownView(textLbl: "You have left this event.".localizedString)
            }
            else {
                setupDownView(textLbl: "You have left this chat event.".localizedString)
            }
        }
        else {
            if isChatGroup == true {
                if leaveGroup == 0 {
                    messageInputBarView.isHidden = false
                    if !Defaults.isWhiteLable {
                        initOptionsInChatEventButton()
                    }
                }
                else {
                    setupDownView(textLbl: "You are not subscribed to this group.".localizedString)
                }
            }
            else {
                if isFriend == true {
                    messageInputBarView.isHidden = false
                    if !Defaults.isWhiteLable {
                        initOptionsInChatUserButton()
                    }
                }
                else {
                    setupDownView(textLbl: "You are no longer connected to this Friendzr. \nReconnect to message them.".localizedString)
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
            self.view.makeToast("Please try again later.".localizedString)
        }
    }
    func HandleInternetConnection() {
        DispatchQueue.main.async {
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                Router().toInbox()
            })
        }
    }
}

//MARK: custom Message Date Time
extension MessagesVC {
    func messageDateTime(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // set locale to reliable US_POSIX
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
        let dateStr = "\(date)T\(time):00+0000"
        let date = formatter.date(from: dateStr)
        
        let relativeFormatter = buildFormatter(locale: formatter.locale, hasRelativeDate: true)
        let relativeDateString = dateFormatterToString(relativeFormatter, date ?? Date())
        
        let nonRelativeFormatter = buildFormatter(locale: formatter.locale)
        let normalDateString = dateFormatterToString(nonRelativeFormatter, date ?? Date())
        
        let customFormatter = buildFormatter(locale: formatter.locale, dateFormat: "DD MMMM")
        _ = dateFormatterToString(customFormatter, date ?? Date())
        
        if relativeDateString == normalDateString {
            print("Use custom date \(normalDateString)") // Jan 18
            return  normalDateString
        } else {
            return "\(relativeDateString)"
        }
    }
    
    func buildFormatter(locale: Locale,hasRelativeDate: Bool = false, dateFormat: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        if let dateFormat = dateFormat { formatter.dateFormat = dateFormat }
        formatter.doesRelativeDateFormatting = hasRelativeDate
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }
    
    
    func dateFormatterToString(_ formatter: DateFormatter, _ date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func messageDateTimeNow(date:String,time:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current // set locale to reliable US_POSIX
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
        let dateStr = "\(date)T\(time):00+0000"
        let date = formatter.date(from: dateStr)
        
        let relativeFormatter = buildFormatter2(locale: formatter.locale, hasRelativeDate: true)
        let relativeDateString = dateFormatterToString(relativeFormatter, date ?? Date())
        
        let nonRelativeFormatter = buildFormatter2(locale: formatter.locale)
        let normalDateString = dateFormatterToString(nonRelativeFormatter, date ?? Date())
        
        let customFormatter = buildFormatter2(locale: formatter.locale, dateFormat: "DD MMMM")
        _ = dateFormatterToString(customFormatter, date ?? Date())
        
        if relativeDateString == normalDateString {
            print("Use custom date \(normalDateString)") // Jan 18
            return  normalDateString
        } else {
            return "\(relativeDateString)"
        }
    }
    
    
    func buildFormatter2(locale: Locale,hasRelativeDate: Bool = false, dateFormat: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        if let dateFormat = dateFormat { formatter.dateFormat = dateFormat }
        formatter.doesRelativeDateFormatting = hasRelativeDate
        formatter.locale = Locale.current
        //        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
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
        imageUser.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "userPlaceHolderImage"))
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 34, width: 0, height: 0))
        subtitleLabel.textColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 8)
        
        var str:String = ""
        
        if (subtitle?.count ?? 0) > 50 {
            str = "\(self.substring(string: subtitle ?? "", fromIndex: 1, toIndex: 50) ?? "")..."
        }else {
            str = subtitle ?? ""
        }
        
        subtitleLabel.text = str
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 45))
        titleView.addSubview(imageUser)
        if str != nil {
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
            if !Defaults.isWhiteLable {
                btn.addTarget(self, action: #selector(goToEventDetailsVC), for: .touchUpInside)
            }
        }
        else {
            if isChatGroup {
                if self.leaveGroup == 0 {
                    btn.addTarget(self, action: #selector(goToGroupVC), for: .touchUpInside)
                }
            }
            else {
                if Defaults.isWhiteLable || !isUserWhiteLabel {
                    btn.addTarget(self, action: #selector(goToUserProfileVC), for: .touchUpInside)
                }
            }
        }
        
        titleView.addSubview(btn)
        navigationItem.titleView = titleView
    }
    
    @objc func goToGroupVC() {
        guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsVC") as? GroupDetailsVC else {return}
        vc.groupId = self.groupId
        vc.isGroupAdmin = self.isChatGroupAdmin
        vc.selectedVC = false
        vc.isCommunityGroup = self.isCommunityGroup
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToUserProfileVC() {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
        vc.userID = self.chatuserID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToEventDetailsVC() {
        if self.eventType == "External" {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
            vc.eventId = self.eventChatID
            vc.isEventAdmin = self.isEventAdmin
            vc.selectedVC = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
            vc.eventId = self.eventChatID
            vc.isEventAdmin = self.isEventAdmin
            vc.selectedVC = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - KeyboardHandler
extension MessagesVC : KeyboardHandler {
    func setScrollTableViewWithKeyboard() {
        addKeyboardObservers() {[weak self] state in
            guard state else { return }
            self?.tableView.scroll(to: .bottom, animated: true)
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
    
    
    func initOptionsInChatEventWhiteLableButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleAttendeesWhiteLable), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleAttendeesWhiteLable() {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
        vc.eventID = self.eventChatID
        vc.eventKey = 1
        self.navigationController?.pushViewController(vc, animated: true)
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
                guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                vc.id = self.eventChatID
                vc.reportType = 2
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                if self.isChatGroup == true {
                    guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                    vc.id = self.groupId
                    vc.reportType = 1
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                    vc.id = self.chatuserID
                    vc.reportType = 3
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                    vc.eventId = self.eventChatID
                    vc.isEventAdmin = self.isEventAdmin
                    vc.selectedVC = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                    vc.eventId = self.eventChatID
                    vc.isEventAdmin = self.isEventAdmin
                    vc.selectedVC = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsVC") as? GroupDetailsVC else {return}
                vc.groupId = self.groupId
                vc.isGroupAdmin = self.isChatGroupAdmin
                vc.selectedVC = false
                vc.isCommunityGroup = self.isCommunityGroup
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }))
        if self.isEvent {
            if !self.isEventAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                        vc.id = self.eventChatID
                        vc.reportType = 2
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        if self.isChatGroup == true {
                            guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                            vc.id = self.groupId
                            vc.reportType = 1
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else {
                            guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                            vc.id = self.chatuserID
                            vc.reportType = 3
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }))
            }
        }else {
            if !self.isChatGroupAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                        vc.id = self.eventChatID
                        vc.reportType = 2
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        if self.isChatGroup == true {
                            guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                            vc.id = self.groupId
                            vc.reportType = 1
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }else {
                            guard let vc = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportVC") as? ReportVC else {return}
                            vc.id = self.chatuserID
                            vc.reportType = 3
                            self.navigationController?.pushViewController(vc, animated: true)
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
        self.view.endEditing(true)
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
                    Router().toInbox()
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
        self.view.endEditing(true)
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 5, isNotFriend: false,requestdate: "\(actionDate) \(actionTime)") { error, message in
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
                    Router().toInbox()
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
        self.view.endEditing(true)
        
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 3, isNotFriend: false,requestdate: "\(actionDate) \(actionTime)") { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = message else {return}
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toInbox()
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

//MARK: - listen To Messages From Notifications
extension MessagesVC {
    func extractedNotificationMessage() {
        if NotificationMessage.messageType == 1 {
            self.insertMessage(ChatMessage(sender: SenderMessage(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName, isWhitelabel: NotificationMessage.isWhitelabel), messageId: NotificationMessage.messageId, messageType: NotificationMessage.messageType, date: Date(), messageDate: NotificationMessage.messageDate, messageTime: NotificationMessage.messageTime,messageText: MessageText(text: NotificationMessage.messageText)))
        }
        else if NotificationMessage.messageType == 2 {
            self.insertMessage(ChatMessage(sender: SenderMessage(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName, isWhitelabel: NotificationMessage.isWhitelabel), messageId: NotificationMessage.messageId, messageType: 2, date: Date(), messageDate: NotificationMessage.messageDate, messageTime: NotificationMessage.messageTime,messageImage: MessageImage(image: NotificationMessage.messsageImageURL)))
        }
        else if NotificationMessage.messageType == 3 {
            self.insertMessage(ChatMessage(sender: SenderMessage(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName, isWhitelabel: NotificationMessage.isWhitelabel), messageId: NotificationMessage.messageId, messageType: 3, date: Date(), messageDate: NotificationMessage.messageDate, messageTime: NotificationMessage.messageTime, messageFile: MessageFile(file: NotificationMessage.messsageImageURL)))
        }
        else if NotificationMessage.messageType == 4 {
            self.insertMessage(ChatMessage(sender: SenderMessage(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName, isWhitelabel: NotificationMessage.isWhitelabel), messageId: NotificationMessage.messageId, messageType: 4, date: Date(), messageDate: NotificationMessage.messageDate, messageTime: NotificationMessage.messageTime, messageLink: LinkPreviewEvent(eventID: NotificationMessage.linkPreviewID, eventTypeLink: NotificationMessage.eventTypeLink, isJoinEvent: NotificationMessage.isJoinEvent, messsageLinkTitle: NotificationMessage.messsageLinkTitle, messsageLinkCategory: NotificationMessage.messsageLinkCategory, messsageLinkImageURL: NotificationMessage.messsageLinkImageURL, messsageLinkAttendeesJoined: NotificationMessage.messsageLinkAttendeesJoined, messsageLinkAttendeesTotalnumbert: NotificationMessage.messsageLinkAttendeesTotalnumbert, messsageLinkEventDate: NotificationMessage.messsageLinkEventDate, linkPreviewID: NotificationMessage.linkPreviewID)))
        }
        else if NotificationMessage.messageType == 5 {
            self.insertMessage(ChatMessage(sender: SenderMessage(senderId: NotificationMessage.senderId, photoURL: NotificationMessage.photoURL, displayName: NotificationMessage.displayName, isWhitelabel: NotificationMessage.isWhitelabel), messageId: NotificationMessage.messageId, messageType: NotificationMessage.messageType, date: Date(), messageDate: NotificationMessage.messageDate, messageTime: NotificationMessage.messageTime,messageLoc: MessageLocation(lat: NotificationMessage.locationLat, lng: NotificationMessage.locationLng, locationName: NotificationMessage.locationName, captionTxt: NotificationMessage.messageText, isLiveLocation: NotificationMessage.isLiveLocation == "false" ? false : true, locationPeriod: NotificationMessage.locationPeriod, locationStartTime: NotificationMessage.locationStartTime, locationEndTime: NotificationMessage.locationEndTime)))
        }
    }
    
    @objc func listenToMessages() {
        
        if NotificationMessage.actionCode == chatuserID {
            self.extractedNotificationMessage()
        }
        else {
            print("This is not a User")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
    
    @objc func listenToMessagesForEvent() {
        if NotificationMessage.actionCode == eventChatID {
            self.extractedNotificationMessage()
        }
        else {
            print("This is not a Event")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
    
    @objc func listenToMessagesForGroup() {
        if NotificationMessage.actionCode == groupId {
            self.extractedNotificationMessage()
        }else {
            print("This is not a Group")
        }
        
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate && UINavigationControllerDelegate
extension MessagesVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openVideoLibrary() {
        fileUpload = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
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
            imagePicker.allowsEditing = false
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
        let messageTime2 = formatterTime2.string(from: Date())
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print(videoURL)
            picker.dismiss(animated:true, completion: {
            })
        }else {
            let image = info[.originalImage] as! UIImage
            
            self.insertMessage(ChatMessage(sender: currentSender, messageId: "", messageType: 2, date: Date(), messageDate: messageDate, messageTime: messageTime2, messageText: MessageText(text: ""), messageImage: MessageImage(imageView: image)))
            
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image,eventShareid: "") { error, data in
                    
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
                        self.tableView.reloadData()
                        self.tableView.scroll(to: .bottom, animated: true)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
            else {
                if isChatGroup {
                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image,eventShareid: "") { error, data in
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
                            self.tableView.reloadData()
                            self.tableView.scroll(to: .bottom, animated: true)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                        }
                    }
                }
                else {
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 2, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image,eventShareid: "") { error, data in
                        
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
                            self.tableView.reloadData()
                            self.tableView.scroll(to: .bottom, animated: true)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                        }
                    }
                }
            }
            
            picker.dismiss(animated:true, completion: {
            })
        }
    }
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        picker.dismiss(animated:true, completion: nil)
    //    }
}

//MARK: - UIDocumentPickerDelegate
extension MessagesVC: UIDocumentPickerDelegate {
    
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
            let messageTime2 = formatterTime2.string(from: Date())
            let imgView:UIImageView = UIImageView()
            imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeHolderApp"))
            
            self.insertMessage(ChatMessage(sender: currentSender, messageId: "", messageType: 3,date: Date(), messageDate: messageDate, messageTime: messageTime2,messageFile: MessageFile(fileView: imgView.image ?? UIImage())))
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), selectedFileURL,eventShareid: "") { error, data in
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
                        self.tableView.reloadData()
                        self.tableView.scroll(to: .bottom, animated: true)
                    }
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                    }
                }
            }
            else {
                if isChatGroup {
                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), selectedFileURL,eventShareid: "") { error, data in
                        
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
                            self.tableView.reloadData()
                            self.tableView.scroll(to: .bottom, animated: true)
                        }
                        
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                        }
                    }
                }else {
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 3, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), selectedFileURL,eventShareid: "") { error, data in
                        
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
                            self.tableView.reloadData()
                            self.tableView.scroll(to: .bottom, animated: true)
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                        }
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

//MARK: - scroll table view
extension UITableView {
    func reloadDataAndKeepOffset() {
        //        keyboardDismissMode = .onDrag
        
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
    
    func scroll(to: Position, animated: Bool) {
        let sections = numberOfSections
        let rows = numberOfRows(inSection: numberOfSections - 1)
        switch to {
        case .top:
            keyboardDismissMode = .onDrag
            if rows > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.scrollToRow(at: indexPath, at: .top, animated: animated)
            }
            break
        case .bottom:
            keyboardDismissMode = .onDrag
            if rows > 0 {
                let indexPath = IndexPath(row: rows - 1, section: sections - 1)
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
            break
        }
    }
    
    enum Position {
        case top
        case bottom
    }
}

//MARK: - handleKeyboardDidChangeState
extension MessagesVC {
    @objc func handleKeyboardDidChangeState(_ notification: Notification) {
        setupNavigationbar()
        guard !isMessagesControllerBeingDismissed else { return }
        
        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty || UIDevice.current.userInterfaceIdiom != .pad else {
            return
        }
        
        guard self.presentedViewController == nil else {
            // This is important to skip notifications from child modal controllers in iOS >= 13.0
            return
        }
        
        guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardEndFrame = view.convert(keyboardEndFrameInScreenCoords, from: view.window)
        
        let newBottomInset = requiredScrollViewBottomInset(forKeyboardFrame: keyboardEndFrame)
        let differenceOfBottomInset = newBottomInset - messageTableViewViewBottomInset
        
        if maintainPositionOnKeyboardFrameChanged && differenceOfBottomInset != 0 {
            let contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + differenceOfBottomInset)
            guard contentOffset.y <= tableView.contentSize.height else {
                return
            }
            
            tableView.setContentOffset(contentOffset, animated: false)
        }
        
        UIView.performWithoutAnimation {
            messageTableViewViewBottomInset = newBottomInset
        }
    }
    
    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        let intersection = tableView.frame.intersection(keyboardFrame)
        
        if intersection.isNull || (tableView.frame.maxY - intersection.maxY) > 0.001 {
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
        }
    }
    
    func requiredInitialScrollViewBottomInset() -> CGFloat {
        let inputAccessoryViewHeight = inputAccessoryView?.frame.height ?? 0
        return max(0, inputAccessoryViewHeight + additionalBottomInset - automaticallyAddedBottomInset)
    }
    private var automaticallyAddedBottomInset: CGFloat {
        return tableView.adjustedContentInset.bottom - tableView.contentInset.bottom
    }
    
}

//MARK: -setup navigation bar
extension MessagesVC {
    func setupNavigationbar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.setColor(lightColor: .white, darkColor: .black)
        navigationController?.navigationBar.shadowImage = UIColor.black.as1ptImage()
        navigationController?.navigationBar.setBackgroundImage(UIColor.white.as1ptImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = .white
        //        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        //        self.view.backgroundColor = .white
        navigationController?.navigationBar.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
}

extension MessagesVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
