//
//  Extensions + ConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/12/2021.
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

extension MessagesViewController {
    
    func setupNavigationbar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = UIColor.white
    }
}

// MARK: - MessagesDataSource
extension ConversationVC: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return senderUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
//    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
//        cell.layer.shouldRasterize = true
//        cell.layer.rasterizationScale = UIScreen.main.scale
//        return UICollectionViewCell
//    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read".localizedString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        
        let name = (isFromCurrentSender(message: message) ? senderUser.displayName : model.user.displayName)
        
        let colorlbl = isFromCurrentSender(message: message) ? UIColor.clear : UIColor.darkGray
        
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font:
                                                                UIFont.init(name: "Montserrat-Medium", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2),
                                                             NSAttributedString.Key.foregroundColor:colorlbl])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        let colorlbl = isFromCurrentSender(message: message) ? UIColor.white : UIColor.gray

        if model.messageType == 4 {
            return nil
        }else {
            return NSAttributedString(string: model.dateandtime, attributes: [NSAttributedString.Key.font:
                                                                                UIFont(name: "Montserrat-Medium", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2),
                                                                              NSAttributedString.Key.foregroundColor:colorlbl])
        }
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
    }
}

// MARK: - MessageCellDelegate
extension ConversationVC: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let model = messageList[indexPath.section]
        
        if model.user.senderId == senderUser.senderId {            
            if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? MyProfileViewController {
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }else {
            if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? FriendProfileViewController {
                vc.userID = self.titleID ?? ""
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
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
                NSLog("Can't use comgooglemaps://")
            }
            break
        case .contact(_):break
        case .emoji(_):break
        case .linkPreview(_):
            if message.messageType == 4 {
                print("link Preview ")
                Router().toEventDetailsVC(eventId: message.linkPreviewID, isConv: true, isEventAdmin: self.isEventAdmin)
            }
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
        let finalURL = destination.absoluteString
        
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

extension ConversationVC: MessageLabelDelegate {
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
extension ConversationVC: InputBarAccessoryViewDelegate ,UITextViewDelegate {
    
    @objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //        processInputBar(setupLeftInputButton(tapMessage: false, Recorder: "play"))
        //1==>message 2==>images 3==>file
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        self.insertMessage(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 1,linkPreviewID: "",isJoinEvent: 0))
        
//        self.messageList.append(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 1,linkPreviewID: "",isJoinEvent: 0))
        
        
        DispatchQueue.main.async {
            inputBar.inputTextView.text = ""
        }
        
        if isEvent {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!,eventShareid: "") { error, data in
                
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
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }
        else {
            if isChatGroup {
                viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!,eventShareid: "") { error, data in
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
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }else {
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
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
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
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("SSSSSS")
        setupNavigationbar()
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        //        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending...".localizedString
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa".localizedString
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension ConversationVC: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .linkPreview(_):
            return isFromCurrentSender(message: message) ? UIColor.white : UIColor.white
        default:
            break
        }
        
        return isFromCurrentSender(message: message) ? UIColor.white : UIColor.darkGray
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention, .url : return [.foregroundColor: UIColor.yellow]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .contact(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .emoji((_)):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .text(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .photo(_):
            return isFromCurrentSender(message: message) ? UIColor.clear : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .audio(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .location(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .video(_):
            return isFromCurrentSender(message: message) ? UIColor.clear : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .linkPreview(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .attributedText(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        default:
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        var borderColor:UIColor = .clear
        
        switch message.kind {
        case .photo(_):
            borderColor = .gray
        default:
            break
        }
        
        return .bubbleTailOutline(borderColor,tail, .curved)
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
extension ConversationVC {
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
        //        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "send_ic")
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        
        
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/160"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/160"
                let isOverLimit = textView.text.count > 160
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
    
    func setupLeftInputButton(tapMessage:Bool,Recorder:String) {
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        messageInputBar.inputTextView.cornerRadiusView(radius: 8)
        
        let button = InputBarSendButton()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(named: "attach_ic"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
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
        messageInputBar.inputTextView.font = UIFont(name: "Montserrat-Medium", size: 12)
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func setupDownView(textLbl:String) {
        messageInputBar.isHidden = true
        
        let downView:UIView = UIView()
        downView.backgroundColor = .white.withAlphaComponent(0.85)
        downView.setBorder()
        
        view.addSubview(downView)
        let label = UILabel()
        downView.addSubview(label)
        
        label.textColor = .black
        label.font = UIFont(name: "Montserrat-Medium", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.text = textLbl
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.bottomAnchor.constraint(equalTo: downView.bottomAnchor, constant: -30),
            label.topAnchor.constraint(equalTo: downView.topAnchor, constant: 10),
            label.leftAnchor.constraint(equalTo: downView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: downView.rightAnchor, constant: -20)
        ]
        
        downView.addConstraints(constraints)
        
        downView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = downView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let verticalConstraint = downView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = downView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        let heightConstraint = downView.heightAnchor.constraint(equalToConstant: 100)
        view.addConstraints([bottomConstraint, verticalConstraint, widthConstraint, heightConstraint])
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
            insertMessage(UserMessage(audioURL: getFileURL(), user: senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6,linkPreviewID: "",isJoinEvent: 0))
            self.messagesCollectionView.reloadData()
        }
    }
    
    private func presentActionSheetForLongPress(indexPath:Int) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: "", message: "Choose the action you want to do?".localizedString, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                print("\(indexPath)")
                self.messageList.remove(at: indexPath)
                self.messagesCollectionView.reloadData()
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Hide".localizedString, style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Copy".localizedString, style: .default, handler: { action in
                let message = self.messageList[indexPath]
                switch message.kind {
                case .contact(let contact):
                    UIPasteboard.general.string = contact.phoneNumbers[0]
                    self.view.makeToast("Copied".localizedString)
                    break
                case .emoji((let text)):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied".localizedString)
                    break
                case .text(let text):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied".localizedString)
                    break
                default: break
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Replay".localizedString, style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionAlert  = UIAlertController(title: "", message: "Choose the action you want to do?".localizedString, preferredStyle: .actionSheet)
            
            actionAlert.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
                print("\(indexPath)")
                self.messageList.remove(at: indexPath)
                self.messagesCollectionView.reloadData()
            }))
            actionAlert.addAction(UIAlertAction(title: "Hide".localizedString, style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Copy".localizedString, style: .default, handler: { action in
                let message = self.messageList[indexPath]
                switch message.kind {
                case .contact(let contact):
                    UIPasteboard.general.string = contact.phoneNumbers[0]
                    self.view.makeToast("Copied".localizedString)
                    break
                case .emoji((let text)):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied".localizedString)
                    break
                case .text(let text):
                    UIPasteboard.general.string = text
                    self.view.makeToast("Copied".localizedString)
                    break
                default: break
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Replay".localizedString, style: .default, handler: { action in
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }
    }
    
    private func presentInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: "Attach Media".localizedString, message: "What would you like attach?".localizedString, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Photo".localizedString, style: .default, handler: { action in
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
            
            actionAlert.addAction(UIAlertAction(title: "File".localizedString, style: .default, handler: { action in
                
            }))
            
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
            present(actionAlert, animated: true, completion: nil)
        }else {
            let actionSheet  = UIAlertController(title: "Attach Media".localizedString, message: "What would you like attach?".localizedString, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Photo".localizedString, style: .default, handler: { action in
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
            
            actionSheet.addAction(UIAlertAction(title: "File".localizedString, style: .default, handler: { action in
                self.openFileLibrary()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func presentPhotoInputActionSheet() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let settingsAlert: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
            
            settingsAlert.addAction(UIAlertAction(title:"Camera".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                self.openCamera()
            }))
            settingsAlert.addAction(UIAlertAction(title:"Photo Library".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
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

extension ConversationVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print(videoURL)
            picker.dismiss(animated:true, completion: {
                
                self.insertMessage(UserMessage(videoURL: videoURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6,linkPreviewID: "",isJoinEvent: 0))
                self.messagesCollectionView.reloadData()
            })
        }else {
            let image = info[.originalImage] as! UIImage
            
            self.insertMessage(UserMessage(image: image, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 2,linkPreviewID: "",isJoinEvent: 0))
            self.sendingImageView = image
            
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
                    
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
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }else {
                if isChatGroup {
                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
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
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                    }
                }else {
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 2, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
                        
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
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
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

extension ConversationVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
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

extension ConversationVC: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 16
    }
    
    // MARK: - Helpers
//    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
//        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
//    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "Mesaages Room".localizedString, subtitle: isHidden ? "2 Online".localizedString : "Typing...".localizedString)
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
}

extension ConversationVC: UIDocumentPickerDelegate {
    
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

            if isEvent {
                let imgView:UIImageView = UIImageView()
                self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                
                imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeholder"))
                self.sendingImageView  = imgView.image
                
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
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
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                    
                }
            }else {
                if isChatGroup {
                    let imgView:UIImageView = UIImageView()
                    self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime:messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                    imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeholder"))
                    self.sendingImageView  = imgView.image

                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
                        
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
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                        
                    }
                }else {
                    let imgView:UIImageView = UIImageView()
                    self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                    imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeholder"))
                    self.sendingImageView  = imgView.image
                    
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 3, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
                        
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
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
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

extension ConversationVC {
    
    func handleLinkPreviewOptionsTapped(ById id:String,IsInEvent:Int) {
        
        var joinTitle:String = ""
        if IsInEvent == 0 {
            
        }else {
            if IsInEvent == 1 {
                joinTitle = "Exit"
            }else {
                joinTitle = "Join"
            }
        }
        
        if IsInEvent == 0 {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                actionAlert.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                    Router().toEventDetailsVC(eventId: id, isConv: true, isEventAdmin: self.isEventAdmin)
                }))
                actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
                }))
                
                present(actionAlert, animated: true, completion: nil)
            }else {
                let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                    Router().toEventDetailsVC(eventId: id, isConv: true, isEventAdmin: self.isEventAdmin)
                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
                }))
                present(actionSheet, animated: true, completion: nil)
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                actionAlert.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                    Router().toEventDetailsVC(eventId: id, isConv: true, isEventAdmin: self.isEventAdmin)
                }))
                
                actionAlert.addAction(UIAlertAction(title: joinTitle, style: .default, handler: { action in
                    
                }))

                actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
                }))
                
                present(actionAlert, animated: true, completion: nil)
            }else {
                let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                    Router().toEventDetailsVC(eventId: id, isConv: true, isEventAdmin: self.isEventAdmin)

                }))
                
                actionSheet.addAction(UIAlertAction(title: joinTitle, style: .default, handler: { action in
                }))
                actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
                }))
                present(actionSheet, animated: true, completion: nil)
            }
        }
    }
}
